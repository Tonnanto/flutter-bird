
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 3, child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/skyline.png"),
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter
            ),
            color: Color.fromARGB(255, 84, 192, 201)
          ),
        )),
        Expanded(flex: 1, child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/floor.png"),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            // color: Color.fromARGB(255, 100, 224, 117)
          ),
        ))
      ],
    );
  }
}
