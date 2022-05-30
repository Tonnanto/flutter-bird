import 'package:flappy_bird/views/bird.dart';
import 'package:flutter/material.dart';
import 'package:pixel_border/pixel_border.dart';

import 'views/background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flappy Bird'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Background(),
        Column(
          children: [
            const Spacer(flex: 1,),
            _buildTitle(),
            const Spacer(flex: 1,),
            _buildBird(),
            _buildPlayButton(),
            const Spacer(flex: 2,),


          ],
        ),
      ]
    );
  }

  Widget _buildTitle() => const Text(
    "Flappy Bird",
    style: TextStyle(
        fontFamily: 'flappy',
        color: Colors.white,
        shadows: [
          Shadow(
            offset: Offset(3, 3)
          )
        ]
    ),
  );

  Widget _buildBird() => AnimatedContainer(

    duration: const Duration(milliseconds: 0),
    child: const Bird(),
  );

  Widget _buildPlayButton() => GestureDetector(
    onTap: () {
      // TODO: Start game
    },
    child: Container(
      decoration: ShapeDecoration(
        shape: PixelBorder.solid(
          borderRadius: BorderRadius.circular(9.0),
          color: Colors.white,
          pixelSize: 3,
        ),
        color: Colors.white,
          shadows: const [
            BoxShadow(
                offset: Offset(3, 3)
            )
          ]
      ),
      height: 60.0,
      width: 100.0,
      child: const Center(
        child: Icon(
          Icons.play_arrow_rounded,
          size: 50,
          color: Colors.green,
        ),
      ),
    ),
  );
}
