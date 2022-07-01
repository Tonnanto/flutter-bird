
import 'package:flappy_bird/services/authentication_service/authentication_service.dart';
import 'package:flappy_bird/services/authentication_service/ganache_auth_service.dart';
import 'package:flappy_bird/services/authorization_service.dart';
import 'package:flutter/cupertino.dart';

import '../model/skin.dart';
import 'authentication_service/wallet_connect_auth_service.dart';



class Web3Service extends ChangeNotifier {

  late final AuthenticationService _authenticationService;
  late final AuthorizationService _authorizationService;

  // Authentication state
  String? get authenticatedAddress => _authenticationService.authenticatedAddress;
  bool get isOnOperatingChain => _authenticationService.isOnOperatingChain;
  bool get isAuthenticated => _authenticationService.isAuthenticated;
  String? get currentAddressShort => "${authenticatedAddress?.substring(0, 8)}...${authenticatedAddress?.substring(36)}";
  String? get webQrData => _authenticationService.webQrData;

  // Authorization state
  List<Skin>? skins;
  String? skinOwnerAddress;

  init() {
    _authenticationService = GanacheAuthenticationService();
    _authorizationService = AuthorizationService();
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
    if (forceReload || skinOwnerAddress != authenticatedAddress) {
      skins = await _authorizationService.getSkinsForOwner(authenticatedAddress);
      skinOwnerAddress = authenticatedAddress;
    }
    notifyListeners();
  }

}