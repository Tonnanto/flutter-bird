
import '../../model/account.dart';
import '../../model/wallet_provider.dart';

/// Authenticates a user with a crypto wallet on a given chain
abstract class AuthenticationService {

  List<WalletProvider> get availableWallets;
  Account? get authenticatedAccount;
  bool get isAuthenticated;
  bool get isOnOperatingChain;
  String get operatingChainName;

  String? webQrData;

  requestAuthentication(WalletProvider? wallet, {Function()? onAuthStatusChanged});
  unauthenticate();
}

