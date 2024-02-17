import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bird/controller/authentication_service.dart';
import 'package:flutter_bird/controller/authorization_service.dart';
import 'package:flutter_bird/config.dart';
import 'package:flutter_bird/secrets.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import '../model/account.dart';
import '../model/skin.dart';

class FlutterBirdController extends ChangeNotifier {
  late final AuthenticationService _authenticationService;
  late final AuthorizationService _authorizationService;
  W3MService get walletConnectService => _authenticationService.w3mService;

  // Authentication state
  Account? get authenticatedAccount => _authenticationService.authenticatedAccount;

  bool get isOnOperatingChain => _authenticationService.isOnOperatingChain;

  bool get isAuthenticated => _authenticationService.isAuthenticated;

  String? get currentAddressShort =>
      '${authenticatedAccount?.address.substring(0, 8)}...${authenticatedAccount?.address.substring(36)}';

  String? get webQrData => _authenticationService.webQrData;
  bool _loadingSkins = false;

  // Authorization state
  List<Skin>? skins;
  String? skinOwnerAddress;

  init() {
    // Setting Up Web3 Connection
    const String skinContractAddress = flutterBirdSkinsContractAddress;
    String rpcUrl = alchemyNodeProviderUrl + alchemyApiKey;

    _authenticationService = AuthenticationServiceImpl(
        operatingChainId: chainId,
        onAuthStatusChanged: () async {
          notifyListeners();
          authorizeUser();
        });
    _authorizationService = AuthorizationServiceImpl(contractAddress: skinContractAddress, rpcUrl: rpcUrl);
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
        skins?.sort(
          (a, b) => a.tokenId.compareTo(b.tokenId),
        );
        this.skins = skins;
        notifyListeners();
      });
      skinOwnerAddress = authenticatedAccount?.address;
      _loadingSkins = false;
      notifyListeners();
    }
  }
}
