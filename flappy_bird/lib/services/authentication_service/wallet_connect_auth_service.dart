

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import 'authentication_service.dart';

class WalletConnectAuthenticationService implements AuthenticationService {
  static const int operatingChain = 4; // Rinkeby?

  WalletConnect? _connector;

  @override
  String? get authenticatedAddress {
    if (_connector?.session.accounts.isEmpty ?? true) return null;
    return _connector?.session.accounts.first;
  }

  @override
  bool get isOnOperatingChain => currentChain == WalletConnectAuthenticationService.operatingChain;
  int? get currentChain => _connector?.session.chainId;

  @override
  bool get isAuthenticated => isConnected && authenticatedAddress != null;
  bool get isConnected => _connector?.connected ?? false;


  // The data to display in a QR Code for connections on Desktop / Browser.
  @override
  String? webQrData;

  /// Prompts user to authenticate with a wallet
  @override
  requestAuthentication({Function()? onAuthStatusChanged}) async {

    // Create fresh connector
    _createConnector(onConnectionStatusChanged: onAuthStatusChanged);

    // Create a new session
    if (!isConnected) {
      await _connector?.createSession(
          chainId: 1,
          onDisplayUri: (uri) async {
            // Launches Wallet App (Metamask)
            if (kIsWeb) {
              webQrData = uri;
              onAuthStatusChanged?.call();
            } else {
              await launchUrlString(uri);
            }
          }
      );

      onAuthStatusChanged?.call();
    }
  }

  @override
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
    _connector?.on('connect', (session) {
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
}