
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Bird extends StatelessWidget {
  const Bird({
    Key? key,
    // required this.size,
    this.imageData,
    this.imagePath = "images/flappy_bird.png",
    this.name = "Default",
  }) : super(key: key);

  // final double size;
  final Uint8List? imageData;
  final String imagePath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return imageData != null ? Image.memory(imageData!) : Image.asset(imagePath);
  }
}
