
import 'package:flappy_bird/secrets.dart';
import 'package:flappy_bird/controller/authentication_service.dart';
import 'package:flappy_bird/controller/authorization_service.dart';
import 'package:flutter/foundation.dart';

import '../model/account.dart';
import '../model/skin.dart';
import '../model/wallet_provider.dart';
import 'authorization_service.dart';

class FlutterBirdController extends ChangeNotifier {

  late final AuthenticationService _authenticationService;
  late final AuthorizationService _authorizationService;

  // Authentication state
  List<WalletProvider> get availableWallets => _authenticationService.availableWallets;
  Account? get authenticatedAccount => _authenticationService.authenticatedAccount;
  bool get isOnOperatingChain => _authenticationService.isOnOperatingChain;
  String get operatingChainName => _authenticationService.operatingChainName;
  bool get isAuthenticated => _authenticationService.isAuthenticated;
  String? get currentAddressShort => "${authenticatedAccount?.address.substring(0, 8)}...${authenticatedAccount?.address.substring(36)}";
  String? get webQrData => _authenticationService.webQrData;
  bool _loadingSkins = false;

  // Authorization state
  List<Skin>? skins;
  String? skinOwnerAddress;

  init() {
    /// Setting Up Web3 Connection
    const int chainId = 5; // Görli Testnet
    const String skinContractAddress = flutterBirdSkinsContractAddress;
    String rpcUrl = "https://eth-goerli.g.alchemy.com/v2/$alchemyApiKey";

    _authenticationService = AuthenticationServiceImpl(operatingChain: chainId);
    _authorizationService = AuthorizationServiceImpl(contractAddress: skinContractAddress, rpcUrl: rpcUrl);
  }

  requestAuthentication({WalletProvider? walletProvider}) {
    _authenticationService.requestAuthentication(
        walletProvider: walletProvider,
        onAuthStatusChanged: () async {
          notifyListeners();
          authorizeUser();
        }
    );
  }

  unauthenticate() {
    _authenticationService.unauthenticate();
    notifyListeners();
  }

  /// Loads a users owned skins
  authorizeUser({bool forceReload = false}) async {
    // Reload skins only if address changed
    if (!_loadingSkins && (forceReload || skinOwnerAddress != authenticatedAccount?.address)) {
      _loadingSkins = true;
      await _authorizationService.authorizeUser(authenticatedAccount?.address, onSkinsUpdated: (skins) {
        skins?.sort((a, b) => a.tokenId.compareTo(b.tokenId),);
        this.skins = skins;
        notifyListeners();
      });
      skinOwnerAddress = authenticatedAccount?.address;
      _loadingSkins = false;
      notifyListeners();
    }
  }
}