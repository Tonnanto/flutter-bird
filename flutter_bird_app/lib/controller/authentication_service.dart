import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:nonce/nonce.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import '../../model/account.dart';
import '../config.dart';
import '../secrets.dart';

/// Manages the authentication process and communication with crypto wallets
abstract class AuthenticationService {
  W3MService get w3mService;

  Account? get authenticatedAccount;

  bool get isOnOperatingChain;

  bool get isAuthenticated;

  String? get webQrData;

  unauthenticate();
}

class AuthenticationServiceImpl implements AuthenticationService {
  W3MChainInfo get _goerliChain => W3MChainInfo(
      chainName: 'Goerli Testnet',
      chainId: '5',
      namespace: 'eip155:5',
      tokenName: 'GTH',
      rpcUrl: 'https://ethereum-goerli.publicnode.com',
      blockExplorer: W3MBlockExplorer(name: 'Etherscan', url: 'https://goerli.etherscan.io/'));

  final String operatingChainId;
  late W3MService _w3mService;
  Function() onAuthStatusChanged;

  @override
  W3MService get w3mService => _w3mService;

  @override
  Account? get authenticatedAccount => _authenticatedAccount;
  Account? _authenticatedAccount;

  @override
  bool get isOnOperatingChain => currentChainId == operatingChainId;

  String? get currentChainId => _w3mService.selectedChain?.chainId;

  @override
  bool get isAuthenticated => isConnected && authenticatedAccount != null;

  bool get isConnected => _w3mService.isConnected;

  // The data to display in a QR Code for connections on Desktop / Browser.
  @override
  String? webQrData;

  AuthenticationServiceImpl({
    required this.operatingChainId,
    required this.onAuthStatusChanged,
  }) {
    _initializeW3MService();
  }

  void _initializeW3MService() async {
    // Add Goerli Testnet to available chains
    W3MChainPresets.chains.putIfAbsent('5', () => _goerliChain);

    //Initialize W3M Service
    _w3mService = W3MService(
      projectId: walletConnectProjectID,
      metadata: const PairingMetadata(
        name: 'Flutter Bird',
        description: 'Flutter Bird Description',
        url: 'https://anton.stamme.de/flutterbird/',
        icons: ['https://raw.githubusercontent.com/Tonnanto/flutter-bird/v1.0/flutter_bird_app/assets/icon.png'],
        redirect: Redirect(
          native: 'flutter_bird://', // TODO: configure redirect to flutter bird app
          universal: 'https://web3modal.com',
        ),
      ),
    );

    await _w3mService.init();

    // Subscribe to events
    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    _w3mService.onSessionConnectEvent.subscribe(_onSessionConnect);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionDeleteEvent.subscribe(_onSessionDelete);
  }

  void _onSessionEvent(SessionEvent? args) {
    log('session event: ' + (args?.name ?? ""), name: 'AuthenticationService');
  }

  void _onSessionUpdate(SessionUpdate? args) {
    log('session update', name: 'AuthenticationService');
    webQrData = null;
    onAuthStatusChanged();
  }

  void _onSessionConnect(SessionConnect? args) async {
    log('session connect', name: 'AuthenticationService');
    webQrData = null;
    final authenticated = await _verifySignature();
    if (authenticated) log('authenticated successfully', name: 'AuthenticationService');
    onAuthStatusChanged();
  }

  void _onSessionDelete(SessionDelete? args) {
    log('session delete', name: 'AuthenticationService');
    webQrData = null;
    _authenticatedAccount = null;
    onAuthStatusChanged();
  }

  /// Send request to the users wallet to sign a message
  /// User will be authenticated if the signature could be verified
  Future<bool> _verifySignature() async {
    String? address = w3mService.session?.address;
    if (address == null) return false;
    log('Address found: $address', name: 'AuthenticationService');
    log('Signing message...', name: 'AuthenticationService');

    // Let Crypto Wallet sign custom message
    String nonce = Nonce.generate(32, math.Random.secure());
    String messageText = 'Please sign this message to authenticate with Flutter Bird.\nChallenge: $nonce';
    final String signature = await _w3mService.web3App?.request(
        topic: _w3mService.session?.topic ?? "",
        chainId: 'eip155:5',
        request: SessionRequestParams(method: 'personal_sign', params: [
          messageText,
          address,
        ]));
    log('Signature received: $signature', name: 'AuthenticationService');

    // Check if signature is valid by recovering the exact address from message and signature
    String recoveredAddress = EthSigUtil.recoverPersonalSignature(
        signature: signature, message: Uint8List.fromList(utf8.encode(messageText)));
    log('Recovered address: $recoveredAddress', name: 'AuthenticationService');
    log('Actual address:    $address', name: 'AuthenticationService');

    // if initial address and recovered address are identical the message has been signed with the correct private key
    bool isAuthenticated = recoveredAddress.toLowerCase() == address.toLowerCase();

    // Set authenticated account
    _authenticatedAccount = isAuthenticated ? Account(address: recoveredAddress, chainId: chainId) : null;

    return isAuthenticated;
  }

  @override
  unauthenticate() async {
    await _w3mService.disconnect();
    _authenticatedAccount = null;
    webQrData = null;
  }
}
