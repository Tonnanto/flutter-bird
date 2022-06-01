
import 'package:flutter/material.dart';

class Bird extends StatelessWidget {
  const Bird({
    Key? key,
    required this.size
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      width: size,
      height: size,
      child: Image.asset(
        "assets/images/flappy_bird.png"
      ),
    );
  }
}
