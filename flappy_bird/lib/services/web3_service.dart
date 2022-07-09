
import 'package:flappy_bird/services/authentication_service/authentication_service.dart';
import 'package:flappy_bird/services/authentication_service/ganache_auth_service.dart';
import 'package:flappy_bird/services/authorization_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../model/skin.dart';
import 'authentication_service/wallet_connect_auth_service.dart';



class Web3Service extends ChangeNotifier {

  late final AuthenticationService _authenticationService;
  late final AuthorizationService _authorizationService;

  // Authentication state
  String? get authenticatedAddress => _authenticationService.authenticatedAddress;
  bool get isOnOperatingChain => _authenticationService.isOnOperatingChain;
  String get operatingChainName => _authenticationService.operatingChainName;
  bool get isAuthenticated => _authenticationService.isAuthenticated;
  String? get currentAddressShort => "${authenticatedAddress?.substring(0, 8)}...${authenticatedAddress?.substring(36)}";
  String? get webQrData => _authenticationService.webQrData;
  bool _loadingSkins = false;

  // Authorization state
  List<Skin>? skins;
  String? skinOwnerAddress;

  init() {
    /// Setting Up Web3 Connection
    const bool localTestBlockchain = false;
    const int chainId = 5; // Görli Testnet
    const String skinContractAddress = "0x387f544E4c3B2351d015dF57c30831Ad58D6C798";
    String rpcUrl = "https://eth-goerli.g.alchemy.com/v2/CT0kmRGFDplSz7RUTk1KMp-ppWcVwKtz"; // TODO: Hide

    if (localTestBlockchain)
      rpcUrl = kIsWeb ? 'http://127.0.0.1:7545' : 'http://10.0.2.2:7545'; // Local Ganache Chain

    _authenticationService = localTestBlockchain ? GanacheAuthenticationService() : WalletConnectAuthenticationService(operatingChain: chainId);
    _authorizationService = AuthorizationService(contractAddress: skinContractAddress, rpcUrl: rpcUrl);
  }

  requestAuthentication() {
    _authenticationService.requestAuthentication(
        onAuthStatusChanged: () async {
          notifyListeners();
          loadSkins();
        }
    );
  }

  unauthenticate() {
    _authenticationService.unauthenticate();
    notifyListeners();
  }

  loadSkins({bool forceReload = false}) async {
    // Reload skins only if address changed
    if (!_loadingSkins && (forceReload || skinOwnerAddress != authenticatedAddress)) {
      _loadingSkins = true;
      await _authorizationService.loadSkinsForOwner(authenticatedAddress, onSkinsUpdated: (skins) {
        skins?.sort((a, b) => a.tokenId.compareTo(b.tokenId),);
        this.skins = skins;
        notifyListeners();
      });
      skinOwnerAddress = authenticatedAddress;
      _loadingSkins = false;
      notifyListeners();
    }
  }
}