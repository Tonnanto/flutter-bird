
import 'authentication_service.dart';

class GanacheAuthenticationService implements AuthenticationService {
  @override
  String? webQrData;

  @override
  String get operatingChainName => "Local Ganache Blockchain";

  @override
  String? get authenticatedAddress => "0x7a42E0b8BE05AC3e9F01ef604bbDCDA9F4129DF1";

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