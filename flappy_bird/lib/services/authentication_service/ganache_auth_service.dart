
import 'authentication_service.dart';

class GanacheAuthenticationService implements AuthenticationService {
  @override
  String? webQrData;

  @override
  String? get authenticatedAddress => "0x05586474C0456580d3927f4e3F77B92Ef9ab76e3";

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