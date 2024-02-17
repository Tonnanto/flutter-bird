import 'package:flutter/material.dart';

class FlappyText extends StatelessWidget {
  const FlappyText({
    Key? key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.strokeWidth,
    this.textAlign,
  }) : super(key: key);

  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? strokeWidth;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    // Replace 0 and 1 because they look like 8 and 7
    String text = this.text.replaceAll('1', 'l').replaceAll('0', 'O');
    return Stack(
        // Workaround: Two Texts to give title outline + shadow
        children: [
          Text(
            text,
            style: TextStyle(
                fontFamily: 'flappy',
                fontSize: fontSize ?? 64,
                height: 1,
                wordSpacing: -8,
                fontWeight: fontWeight ?? FontWeight.w500,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth ?? 4
                  ..color = Colors.grey.shade800,
                shadows: [
                  Shadow(offset: Offset((strokeWidth ?? 4) - 1, (strokeWidth ?? 4) - 1), color: Colors.grey.shade800)
                ]),
            textAlign: textAlign,
          ),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'flappy',
              fontSize: fontSize ?? 64,
              height: 1,
              wordSpacing: -8,
              fontWeight: fontWeight ?? FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: textAlign,
          ),
        ]);
  }
}
