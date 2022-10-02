import 'package:flutter/material.dart';

import '../../model/skin.dart';

class Bird extends StatelessWidget {
  const Bird({
    Key? key,
    this.skin,
  }) : super(key: key);

  final Skin? skin;

  bool get isLoading => skin != null && skin!.imageLocation == null;

  String get name => skin?.tokenId != null ? ('#${skin!.tokenId}') : '';

  @override
  Widget build(BuildContext context) {
    if (skin == null) {
      return Image.asset('images/flappy_bird.png');
    }

    if (skin?.imageLocation == null) {
      return _buildLoadingIndicator(context, 0.3);
    }

    return Image.network(
      skin!.imageLocation!,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator(
            context, loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1000));
      },
    );
  }

  _buildLoadingIndicator(BuildContext context, double? value) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            value: value,
          ),
          Text(
            'loading from\nIPFS...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
}
