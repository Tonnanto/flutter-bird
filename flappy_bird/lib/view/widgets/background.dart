
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 3, child: Container(
          decoration: const BoxDecoration(
            color: Colors.lightBlueAccent
          ),
        )),
        Expanded(flex: 1, child: Container(
          decoration: const BoxDecoration(
              color: Colors.green
          ),
        ))
      ],
    );
  }
}
