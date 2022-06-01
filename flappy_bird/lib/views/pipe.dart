
import 'dart:math';

import 'package:flutter/material.dart';

class Pipe extends StatelessWidget {
  Pipe({
    Key? key,
    this.height = 1,
    required this.passTick,
    required this.worldDimensions,
  }) : super(key: key);

  // Value between 0 and 2
  static double width = 0.25;
  // Value between 0 and 2
  final double space = 0.7;
  // Value between -1.0 and 1.0
  final double height;

  final Size worldDimensions;

  // Game tick on which this pipe is passed
  final int passTick;

  final GlobalKey topPipeKey = GlobalKey();
  final GlobalKey bottomPipeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    double height = max(this.height, -0.9 + space / 2);
    height = min(height, 0.9 - space / 2);

    double pixelSpace = worldDimensions.height / (2 / space);
    double topHeight = (height + 1) * 0.5 * worldDimensions.height;
    double bottomHeight = worldDimensions.height - topHeight;
    topHeight -= 0.5 * pixelSpace;
    bottomHeight -= 0.5 * pixelSpace;

    return SizedBox(
      width: worldDimensions.width / (2 / width),
      child: Column(
          children: [
            Container(
              key: topPipeKey,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
              ),
              height: topHeight,
            ),
            const Spacer(),
            Container(
              key: bottomPipeKey,
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

  bool checkCollision(GlobalKey birdKey) {
    RenderBox? bird = birdKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? topPipe = topPipeKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? bottomPipe = bottomPipeKey.currentContext?.findRenderObject() as RenderBox?;

    if (bird == null || topPipe == null || bottomPipe == null) return false;

    Size birdSize = bird.paintBounds.size;
    birdSize = Size(birdSize.width * 0.7, birdSize.height * 0.7);
    final topPipeSize = topPipe.paintBounds.size;
    final bottomPipeSize = bottomPipe.paintBounds.size;

    final birdPosition = bird.localToGlobal(Offset.zero);
    final topPipePosition = topPipe.localToGlobal(Offset.zero);
    final bottomPipePosition = bottomPipe.localToGlobal(Offset.zero);

    final collideTop = (birdPosition.dx < topPipePosition.dx + topPipeSize.width &&
        birdPosition.dx + birdSize.width > topPipePosition.dx &&
        birdPosition.dy < topPipePosition.dy + topPipeSize.height &&
        birdPosition.dy + birdSize.height > topPipePosition.dy);

    final collideBottom = (birdPosition.dx < bottomPipePosition.dx + bottomPipeSize.width &&
        birdPosition.dx + birdSize.width > bottomPipePosition.dx &&
        birdPosition.dy < bottomPipePosition.dy + bottomPipeSize.height &&
        birdPosition.dy + birdSize.height > bottomPipePosition.dy);

    return collideTop || collideBottom;
  }
}
