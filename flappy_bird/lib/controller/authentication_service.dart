

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:http/http.dart' as http;


import '../../model/account.dart';
import '../../model/wallet_provider.dart';

abstract class AuthenticationService {
  List<WalletProvider> get availableWallets;
  Account? get authenticatedAccount;
  String get operatingChainName;
  bool get isOnOperatingChain;
  bool get isAuthenticated;
  String? get webQrData;

  requestAuthentication({WalletProvider? walletProvider, Function()? onAuthStatusChanged});
  unauthenticate();
}

class AuthenticationServiceImpl implements AuthenticationService {

  @override
  late final List<WalletProvider> availableWallets;

  final int operatingChain;
  WalletConnect? _connector;

  @override
  String get operatingChainName => operatingChain == 5 ? "Goerli Testnet" : "Chain $operatingChain";

  @override
  Account? get authenticatedAccount {
    if (_connector?.session.accounts.isEmpty ?? true) return null;
    return Account(
      address: _connector!.session.accounts.first,
      chainId: _connector!.session.chainId,
    );
  }

  @override
  bool get isOnOperatingChain => currentChain == operatingChain;
  int? get currentChain => _connector?.session.chainId;

  @override
  bool get isAuthenticated => isConnected && authenticatedAccount != null;
  bool get isConnected => _connector?.connected ?? false;


  // The data to display in a QR Code for connections on Desktop / Browser.
  @override
  String? webQrData;

  AuthenticationServiceImpl({
    required this.operatingChain,
  }) {
    if (kIsWeb) {
      requestAuthentication();
    } else {
      _loadWallets();
    }
  }

  /// Loads all WalletConnect compatible wallets
  _loadWallets() async {
    final walletResponse = await http.get(Uri.parse('https://registry.walletconnect.org/data/wallets.json'));
    final walletData = json.decode(walletResponse.body);
    availableWallets = walletData.entries.map<WalletProvider>((data) => WalletProvider.fromJson(data.value)).toList();
  }

  /// Prompts user to authenticate with a wallet
  @override
  requestAuthentication({WalletProvider? walletProvider, Function()? onAuthStatusChanged}) async {

    // Create fresh connector
    _createConnector(onConnectionStatusChanged: onAuthStatusChanged);

    // Create a new session
    if (!isConnected) {
      await _connector?.createSession(
          chainId: operatingChain,
          onDisplayUri: (uri) async {
            // Launches Wallet App (Metamask)
            if (kIsWeb) {
              webQrData = uri;
              onAuthStatusChanged?.call();
            } else {
              _launchWallet(wallet: walletProvider, uri: uri);
            }
          }
      );

      onAuthStatusChanged?.call();
    }
  }

  unauthenticate() async {
    await _connector?.killSession();
    _connector = null;
    webQrData = null;
  }

  /// Creates a WalletConnect Instance
  _createConnector({Function()? onConnectionStatusChanged}) {
    // Create WalletConnect Connector
    _connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'Flutter Bird',
        description: 'WalletConnect Developer App',
        url: 'https://flutterbird.com',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media' // TODO
        ],
      ),
    );

    // Subscribe to events
    _connector?.on('connect', (session) async {
      print('connected: ' + session.toString());
      webQrData = null;
      onConnectionStatusChanged?.call();
    });
    _connector?.on('session_update', (payload) {
      print('session_update: ' + payload.toString());
      webQrData = null;
      onConnectionStatusChanged?.call();
    });
    _connector?.on('disconnect', (session) {
      print('disconnect: ' + session.toString());
      webQrData = null;
      onConnectionStatusChanged?.call();
    });
  }

  Future<void> _launchWallet({
    WalletProvider? wallet,
    required String uri,
  }) async {

    if (wallet == null) {
      launchUrl(Uri.parse(uri));
      return;
    }

    if (wallet.universal != null &&
        await canLaunchUrl(Uri.parse(wallet.universal!))) {
      await launchUrl(
        _convertToWcUri(appLink: wallet.universal!, wcUri: uri),
        mode: LaunchMode.externalApplication,
      );
    } else if (wallet.native != null &&
        await canLaunchUrl(Uri.parse(wallet.native!))) {
      await launchUrl(
        _convertToWcUri(appLink: wallet.native!, wcUri: uri),
      );
    } else {

      if (Platform.isIOS && wallet.iosLink != null) {
        await launchUrl(Uri.parse(wallet.iosLink!));
      } else if (Platform.isAndroid && wallet.androidLink != null) {
        await launchUrl(Uri.parse(wallet.androidLink!));
      }
    }
  }

  Uri _convertToWcUri({
    required String appLink,
    required String wcUri,
  }) => Uri.parse('$appLink/wc?uri=${Uri.encodeComponent(wcUri)}');
}