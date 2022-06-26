
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/web3_provider.dart';

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
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(),
            _buildBody(web3Provider),
          ],
        ),
      ),
    );
  }

  _buildBody(Web3Provider web3Provider) {
    bool shouldDisplayQR = (web3Provider.webQrData != null && kIsWeb);
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
              _buildQRView(web3Provider.webQrData!),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    web3Provider.walletDisconnect();
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
              _buildAuthenticationStatusView(web3Provider),
              const Spacer(),
              _buildConnectButton(web3Provider),
            ],
          ),
        ),
      ),
    );
  }

  _buildAuthenticationStatusView(Web3Provider web3Provider) {
    return Column(
      children: [
        Text(
          "Status: ${web3Provider.isAuthenticated ? "Authenticated" : "Not Authenticated"}",
          style: Theme.of(context).textTheme.headline6,
        ),
        if (web3Provider.isAuthenticated)
          Text(
            web3Provider.currentAddressShort ?? "",
            style: Theme.of(context).textTheme.bodyLarge,
          )
      ],
    );
  }

  _buildConnectButton(Web3Provider web3Provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: web3Provider.isAuthenticated ? Colors.redAccent : Colors.green,
      ),
      onPressed: () {
        if (web3Provider.isAuthenticated) {
          web3Provider.walletDisconnect();
        } else {
          web3Provider.walletConnect();
        }
      },
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(
            web3Provider.isAuthenticated ? "Disconnect" : "Connect",
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
