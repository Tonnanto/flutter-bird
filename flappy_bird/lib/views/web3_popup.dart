
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/web3_service.dart';

class Web3Popup extends StatefulWidget {
  const Web3Popup({
    Key? key
  }) : super(key: key);

  @override
  State<Web3Popup> createState() => _Web3PopupState();
}

class _Web3PopupState extends State<Web3Popup> {

  String? uri;

  @override
  Widget build(BuildContext context) {
    return Consumer<Web3Service>(
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

  _buildBody(Web3Service web3Service) {
    bool shouldDisplayQR = (web3Service.webQrData != null && kIsWeb);
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 300,
          maxWidth: 300,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: shouldDisplayQR ? [
              _buildQRView(web3Service.webQrData!),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    web3Service.unauthenticate();
                  },
                  child: SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.button?.copyWith(color: Colors.white),
                      ),
                    ),
                  )
              )
            ] : [
              _buildAuthenticationStatusView(web3Service),
              const Spacer(),
              _buildConnectButton(web3Service),
            ],
          ),
        ),
      ),
    );
  }

  _buildAuthenticationStatusView(Web3Service web3Service) {
    String statusText = "Not Authenticated";
    if (web3Service.isAuthenticated) {
      statusText = web3Service.isOnOperatingChain ? "Authenticated" : "\nAuthenticated on wrong chain";
    }
    return Column(
      children: [
        Text(
          "Status: $statusText",
          style: Theme.of(context).textTheme.headline6,
        ),

        if (!web3Service.isOnOperatingChain)
          const SizedBox(height: 16,),
        if (!web3Service.isOnOperatingChain)
          Text(
            "Please connect with a wallet on ${web3Service.operatingChainName}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),

        if (web3Service.isAuthenticated)
          const SizedBox(height: 16,),
        if (web3Service.isAuthenticated)
          Text(
            "Wallet address:\n" + (web3Service.authenticatedAddress ?? ""),
            style: Theme.of(context).textTheme.bodyLarge,
          )
      ],
    );
  }

  _buildConnectButton(Web3Service web3Service) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: web3Service.isAuthenticated ? Colors.redAccent : Colors.green,
      ),
      onPressed: () {
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
