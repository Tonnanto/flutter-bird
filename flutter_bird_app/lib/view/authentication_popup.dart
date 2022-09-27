
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controller/flutter_bird_controller.dart';
import '../model/wallet_provider.dart';

class AuthenticationPopup extends StatefulWidget {
  const AuthenticationPopup({
    Key? key
  }) : super(key: key);

  @override
  State<AuthenticationPopup> createState() => _AuthenticationPopupState();
}

class _AuthenticationPopupState extends State<AuthenticationPopup> {

  String? uri;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlutterBirdController>(
      builder: (context, web3Service, child) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(),
            _buildBody(web3Service),
          ],
        ),
      ),
    );
  }

  _buildBody(FlutterBirdController flutterBirdController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80,),
          Expanded(
            flex: (flutterBirdController.isAuthenticated || kIsWeb) ? 0 : 1,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 240,
                maxWidth: 340,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: flutterBirdController.isAuthenticated ? _buildAuthenticatedView(flutterBirdController) : _buildUnauthenticatedView(flutterBirdController),
              ),
            ),
          ),
          const SizedBox(height: 80,),
        ],
      ),
    );
  }

  _buildUnauthenticatedView(FlutterBirdController flutterBirdController) {
    if (kIsWeb && flutterBirdController.webQrData == null) {
      // Generates QR Data
      flutterBirdController.requestAuthentication();
    }
    return Column(
      children: [
        _buildAuthenticationStatusView(flutterBirdController),
        if (!kIsWeb)
          _buildWalletSelector(flutterBirdController),
        if (flutterBirdController.webQrData != null && kIsWeb)
          _buildQRView(flutterBirdController.webQrData!)
      ],
    );
  }

  _buildAuthenticatedView(FlutterBirdController flutterBirdController) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildAuthenticationStatusView(flutterBirdController),
      _buildConnectButton(flutterBirdController),
    ],
  );

  _buildAuthenticationStatusView(FlutterBirdController flutterBirdController) {
    String statusText = "Not Authenticated";
    if (flutterBirdController.isAuthenticated) {
      statusText = flutterBirdController.isOnOperatingChain ? "Authenticated" : "\nAuthenticated on wrong chain";
    }
    return Column(
      children: [
        Text(
          "Status: $statusText",
          style: Theme.of(context).textTheme.headline6,
        ),

        if (!flutterBirdController.isOnOperatingChain)
          const SizedBox(height: 16,),
        if (!flutterBirdController.isOnOperatingChain)
          Text(
            "Connect a wallet on ${flutterBirdController.operatingChainName}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),

        if (flutterBirdController.isAuthenticated)
          const SizedBox(height: 16,),
        if (flutterBirdController.isAuthenticated)
          Text(
            "Wallet address:\n" + (flutterBirdController.authenticatedAccount?.address ?? ""),
            style: Theme.of(context).textTheme.bodyLarge,
          )
      ],
    );
  }

  _buildConnectButton(FlutterBirdController web3Service) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: web3Service.isAuthenticated ? Colors.redAccent : Colors.green,
      ),
      onPressed: () async {
        if (web3Service.isAuthenticated) {
          web3Service.unauthenticate();
        } else {
          web3Service.requestAuthentication();
        }
      },
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(
            web3Service.isAuthenticated ? "Disconnect" : "Connect",
            style: Theme.of(context).textTheme.button?.copyWith(color: Colors.white),
          ),
        ),
      )
    );
  }

  _buildWalletSelector(FlutterBirdController flutterBirdController) {
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: flutterBirdController.availableWallets.length,
        itemBuilder: (BuildContext context, int index) {
          WalletProvider wallet = flutterBirdController.availableWallets[index];
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    wallet.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: wallet.imageUrl == null ? Container() : Image.network(
                        wallet.imageUrl!
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              flutterBirdController.requestAuthentication(walletProvider: wallet);
            }
          );
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4,),
      ),
    );
  }

  _buildQRView (String data) => QrImage(
    data: data,
    version: QrVersions.auto,
    size: 200.0,
  );

  _buildBackground() => Positioned.fill(child: GestureDetector(
    onTap: () {
      Navigator.of(context).pop();
    },
    child: Container(
      color: Colors.black54,
    ),
  ));
}
