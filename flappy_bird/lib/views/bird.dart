
import 'package:flutter/material.dart';

class Bird extends StatelessWidget {
  const Bird({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Image.asset(
        "assets/images/flappy_bird.png"
      ),
    );
  }
}
