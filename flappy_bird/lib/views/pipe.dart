
import 'dart:math';

import 'package:flutter/material.dart';

class Pipe extends StatelessWidget {
  const Pipe({
    Key? key,
    this.height = 1,
    required this.passTick,
  }) : super(key: key);

  // In pixel
  static double width = 55;
  // Value between 0 and 2
  final double space = 0.8;
  // Value between -1.0 and 1.0
  final double height;

  // Game tick on which this pipe is passed
  final int passTick;

  @override
  Widget build(BuildContext context) {

    double height = max(this.height, -0.9 + space / 2);
    height = min(height, 0.9 - space / 2);

    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    double pixelSpace = totalHeight / (2 / space);
    double topHeight = (height + 1) * 0.5 * totalHeight;
    double bottomHeight = totalHeight - topHeight;
    topHeight -= 0.5 * pixelSpace;
    bottomHeight -= 0.5 * pixelSpace;

    return SizedBox(
      width: width,
      child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
              ),
              height: topHeight,
            ),
            const Spacer(),
            Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))
              ),
              height: bottomHeight,
            )
          ],
      ),
    );
  }
}
