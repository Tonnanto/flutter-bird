import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bird/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:nonce/nonce.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../model/account.dart';
import '../../model/wallet_provider.dart';
import '../config.dart';

/// Manages the authentication process and communication with crypto wallets
abstract class AuthenticationService {
  List<WalletProvider> get availableWallets;

  Account? get authenticatedAccount;

  String get operatingChainName;

  bool get isOnOperatingChain;

  bool get isAuthenticated;

  String? get webQrData;

  requestAuthentication({WalletProvider? walletProvider});

  unauthenticate();
}

class AuthenticationServiceImpl implements AuthenticationService {
  @override
  late final List<WalletProvider> availableWallets;

  final int operatingChain;
  WalletConnect? _connector;
  Function() onAuthStatusChanged;

  @override
  String get operatingChainName => operatingChain == 5 ? 'Goerli Testnet' : 'Chain $operatingChain';

  @override
  Account? get authenticatedAccount => _authenticatedAccount;
  Account? _authenticatedAccount;

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
    required this.onAuthStatusChanged,
  }) {
    if (kIsWeb) {
      requestAuthentication();
    } else {
      _loadWallets();
    }
  }

  /// Loads all WalletConnect compatible wallets
  _loadWallets() async {
    final walletResponse = await http.get(Uri.parse('https://explorer-api.walletconnect.com/v3/wallets?projectId=$walletConnectProjectID'));
    final walletData = json.decode(walletResponse.body);
    availableWallets = walletData['listings'].entries.map<WalletProvider>((data) => WalletProvider.fromJson(data.value)).toList();
  }

  /// Prompts user to authenticate with a wallet
  @override
  requestAuthentication({WalletProvider? walletProvider}) async {
    // Create fresh connector
    await _createConnector(walletProvider: walletProvider);

    // Create a new session
    if (!isConnected) {
      await _connector?.createSession(
          chainId: operatingChain,
          onDisplayUri: (uri) async {
            // Launches Wallet App
            if (kIsWeb) {
              webQrData = uri;
              onAuthStatusChanged();
            } else {
              _launchWallet(wallet: walletProvider, uri: uri);
            }
          });

      onAuthStatusChanged();
    }
  }

  /// Send request to the users wallet to sign a message
  /// User will be authenticated if the signature could be verified
  Future<bool> _verifySignature({WalletProvider? walletProvider, String? address}) async {
    int? chainId = _connector?.session.chainId;
    if (address == null || chainId == null || !isOnOperatingChain) return false;

    if (!kIsWeb) {
      // Launch wallet app if on mobile
      // Delay to make sure FlutterBird is in foreground before launching wallet app again
      await Future.delayed(const Duration(seconds: 1));
      _launchWallet(wallet: walletProvider, uri: _connector!.session.toUri());
    }

    log('Signing message...', name: 'AuthenticationService');

    // Let Crypto Wallet sign custom message
    String nonce = Nonce.generate(32, math.Random.secure());
    String messageText = 'Please sign this message to authenticate with Flutter Bird.\nChallenge: $nonce';
    final String signature = await _connector?.sendCustomRequest(method: 'personal_sign', params: [
      messageText,
      address,
    ]);

    // Check if signature is valid by recovering the exact address from message and signature
    String recoveredAddress = EthSigUtil.recoverPersonalSignature(
        signature: signature, message: Uint8List.fromList(utf8.encode(messageText)));

    // if initial address and recovered address are identical the message has been signed with the correct private key
    bool isAuthenticated = recoveredAddress.toLowerCase() == address.toLowerCase();

    // Set authenticated account
    _authenticatedAccount = isAuthenticated ? Account(address: recoveredAddress, chainId: chainId) : null;

    return isAuthenticated;
  }

  @override
  unauthenticate() async {
    await _connector?.killSession();
    _authenticatedAccount = null;
    _connector = null;
    webQrData = null;
  }

  /// Creates a WalletConnect Instance
  _createConnector({WalletProvider? walletProvider}) async {
    // Create WalletConnect Connector
    _connector = WalletConnect(
      bridge: walletConnectBridge,
      clientMeta: const PeerMeta(
        name: 'Flutter Bird',
        description: 'WalletConnect Developer App',
        url: 'https://flutterbird.com',
        icons: [
          'https://raw.githubusercontent.com/Tonnanto/flutter-bird/v1.0/flutter_bird_app/assets/icon.png',
        ],
      ),
    );

    // Subscribe to events
    _connector?.on('connect', (session) async {
      log('connected: ' + session.toString(), name: 'AuthenticationService');
      String? address = _connector?.session.accounts.first;
      webQrData = null;
      final authenticated = await _verifySignature(walletProvider: walletProvider, address: address);
      if (authenticated) log('authenticated successfully: ' + session.toString(), name: 'AuthenticationService');
      onAuthStatusChanged();
    });
    _connector?.on('session_update', (payload) async {
      log('session_update: ' + payload.toString(), name: 'AuthenticationService');
      webQrData = null;
      onAuthStatusChanged();
    });
    _connector?.on('disconnect', (session) {
      log('disconnect: ' + session.toString(), name: 'AuthenticationService');
      webQrData = null;
      _authenticatedAccount = null;
      onAuthStatusChanged();
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

    if (wallet.universal != null && await canLaunchUrl(Uri.parse(wallet.universal!))) {
      await launchUrl(
        _convertToWcUri(appLink: wallet.universal!, wcUri: uri),
        mode: LaunchMode.externalApplication,
      );
    } else if (wallet.native != null && await canLaunchUrl(Uri.parse(wallet.native!))) {
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
  }) =>
      Uri.parse('$appLink/wc?uri=${Uri.encodeComponent(wcUri)}');
}
