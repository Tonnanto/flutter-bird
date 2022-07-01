
/// Authenticates a user with a crypto wallet on a given chain
abstract class AuthenticationService {
  String? get authenticatedAddress;
  bool get isAuthenticated;
  bool get isOnOperatingChain;

  String? webQrData;

  requestAuthentication({Function()? onAuthStatusChanged});
  unauthenticate();
}

