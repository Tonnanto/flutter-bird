//
// import '../../model/account.dart';
// import 'authentication_service.dart';
//
// class GanacheAuthenticationService implements AuthenticationService {
//   @override
//   String? webQrData;
//
//   @override
//   String get operatingChainName => "Local Ganache Blockchain";
//
//   @override
//   Account? get authenticatedAccount => const Account(
//     address: "0x7a42E0b8BE05AC3e9F01ef604bbDCDA9F4129DF1",
//     chainId: 0,
//   );
//
//   @override
//   bool get isAuthenticated => authenticatedAccount != null && authenticatedAccount!.address.isNotEmpty;
//
//   @override
//   bool get isOnOperatingChain => true;
//
//   @override
//   requestAuthentication({Function()? onAuthStatusChanged}) {
//     // TODO: implement requestAuthentication
//     throw UnimplementedError();
//   }
//
//   @override
//   unauthenticate() {
//     // TODO: implement unauthenticate
//     throw UnimplementedError();
//   }
// }