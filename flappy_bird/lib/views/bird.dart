
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../model/skin.dart';

class Bird extends StatelessWidget {
  const Bird({
    Key? key,
    this.skin,
  }) : super(key: key);

  final Skin? skin;

  String get name => skin?.name ?? "Default";

  @override
  Widget build(BuildContext context) {
    if (skin?.imageLocation != null) {
      return Image.network(skin!.imageLocation);
    }
    return Image.asset("images/flappy_bird.png");
  }
}
