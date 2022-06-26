

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class Web3Provider extends ChangeNotifier {
  static const int operatingChain = 4; // Rinkeby?

  // Create a connector
  WalletConnect? connector;
  SessionStatus? sessionStatus;

  String? get currentAccountAddress => connector?.session.accounts.first;
  String? get currentAddressShort => "${currentAccountAddress?.substring(0, 8)}...${currentAccountAddress?.substring(36)}";
  int? get currentChain => connector?.session.chainId;
  bool get isConnected => connector?.connected ?? false;
  bool get isOnOperatingChain => currentChain == operatingChain;
  bool get isAuthenticated => isConnected && currentAccountAddress != null;

  // The data to display in a QR Code for connections on Desktop / Browser.
  String? webQrData;

  init() {




    // // Approve session
    // connector.approveSession(chainId: 4160, accounts: ['0x4292...931B3']);

    // Reject session
    // connector.rejectSession(message: 'Optional error message');

    // Update session
    // connector.updateSession(SessionStatus(chainId: 4000, accounts: ['0x4292...931B3']));

    // Create a new session
    // if (!connector.connected) {
    //   connector.createSession(
    //     chainId: 4160, // TODO: ID?
    //     onDisplayUri: (uri) => print('onDisplayUri: ' + uri),
    //   ).then((value) {
    //     session = value;
    //     notifyListeners();
    //   });
    // }
  }

  /// Prompts user to authenticate with a wallet
  walletConnect() async {

    // Create fresh connector
    _createConnector();

    // Create a new session
    if (!isConnected) {
      sessionStatus = await connector?.createSession(
          chainId: 1,
          onDisplayUri: (uri) async {
            // Launches Wallet App (Metamask)
            if (kIsWeb) {
              webQrData = uri;
              notifyListeners();
            } else {
              await launchUrlString(uri);
            }
          }
      );

      notifyListeners();
    }


    // if (isAuthenticated) {
    //   final client = Web3Client(rpcUrl, Client());
    //   EthereumWalletConnectProvider provider =
    //   EthereumWalletConnectProvider(connector);
    //   credentials = WalletConnectEthereumCredentials(provider: provider);
    //   yourContract = YourContract(address: contractAddr, client: client);
    // }
  }

  walletDisconnect() async {
    await connector?.killSession();
    connector = null;
    webQrData = null;
    notifyListeners();
  }

  /// Creates a WalletConnect Instance
  _createConnector() {
    // Create WalletConnect Connector
    connector = WalletConnect(
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
    connector?.on('connect', (session) {
      print('connected: ' + session.toString());
      webQrData = null;
      notifyListeners();
    });
    connector?.on('session_update', (payload) {
      print('session_update: ' + payload.toString());
      webQrData = null;
      notifyListeners();
    });
    connector?.on('disconnect', (session) {
      print('disconnect: ' + session.toString());
      webQrData = null;
      notifyListeners();
    });
  }

}