

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

class Web3Provider extends ChangeNotifier {
  static const int operatingChain = 4; // Rinkeby?
  String? currentAccountAddress;
  int? currentChain;

  // Create a connector
  late final WalletConnect connector;
  SessionStatus? session;

  bool get isConnected => connector.connected;
  bool get isOnOperatingChain => currentChain == operatingChain;
  bool get isAuthenticated => isConnected && currentAccountAddress != null;

  init() {

    // Create WalletConnect Connector
    connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
    //
    //
    //
    // // Subscribe to events
    // connector.on('connect', (session) => print('connected: ' + session.toString()));
    // connector.on('session_update', (payload) => print('connected: ' + payload.toString()));
    // connector.on('disconnect', (session) => print('connected: ' + session.toString()));
    //
    //
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

  walletConnect() async {

    // Subscribe to events
    connector.on('connect', (session) => print(session));
    connector.on('session_update', (payload) => print(payload));
    connector.on('disconnect', (session) => print(session));

    // Create a new session
    if (!connector.connected) {
      session = await connector.createSession(
          chainId: 43113,
          onDisplayUri: (uri) async => { print('onDisplayUri: ' + uri), await launchUrlString(uri)});
    }

    // setState(() {
    //   account = session.accounts[0];
    // });
    //
    // if (account != null) {
    //   final client = Web3Client(rpcUrl, Client());
    //   EthereumWalletConnectProvider provider =
    //   EthereumWalletConnectProvider(connector);
    //   credentials = WalletConnectEthereumCredentials(provider: provider);
    //   yourContract = YourContract(address: contractAddr, client: client);
    // }
  }

  // /// Promtps user to authenticate with a wallet
  // Future<void> authenticate() async {
  //   if (!isEnabled) return;
  //
  //   // Get accounts from users wallet
  //   List<String> accountAddresses = await ethereum!.requestAccount();
  //
  //   if (accountAddresses.isNotEmpty) {
  //     currentAccountAddress = accountAddresses[0];
  //   }
  //
  //   currentChain = await ethereum!.getChainId();
  //
  //   notifyListeners();
  // }
  //
  // /// Resets current authentication status
  // disconnect() {
  //   currentAccountAddress = null;
  //   currentChain = null;
  //   notifyListeners();
  // }


}