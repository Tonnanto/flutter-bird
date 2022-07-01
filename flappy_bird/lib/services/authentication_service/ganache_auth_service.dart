
import 'authentication_service.dart';

class GanacheAuthenticationService implements AuthenticationService {
  @override
  String? webQrData;

  @override
  String? get authenticatedAddress => "0x24EEB7c2b61dAbFC81735365fD3273afe7518e02";

  @override
  bool get isAuthenticated => authenticatedAddress != null && authenticatedAddress!.isNotEmpty;

  @override
  bool get isOnOperatingChain => true;

  @override
  requestAuthentication({Function()? onAuthStatusChanged}) {
    // TODO: implement requestAuthentication
    throw UnimplementedError();
  }

  @override
  unauthenticate() {
    // TODO: implement unauthenticate
    throw UnimplementedError();
  }

}