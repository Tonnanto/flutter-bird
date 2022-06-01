import 'dart:async';
import 'dart:math';

import 'package:flappy_bird/views/bird.dart';
import 'package:flutter/material.dart';
import 'package:pixel_border/pixel_border.dart';

import 'views/background.dart';
import 'views/pipe.dart';

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

  static int ticksPerPipe = 50;
  static int speed = 100;

  bool playing = false;
  double birdY = 0;
  double jumpTime = 0;
  double initialJumpHeight = 0;
  double jumpHeight = 0;
  int score = 0;

  Timer? timer;
  int lastPipe = 0;

  List<Pipe> pipes = [];

  late Size worldDimensions;
  final GlobalKey birdKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  /// Start game loop
  _start() {
    score = 0;
    playing = true;
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      jumpTime += 0.025;
      jumpHeight = -4.4 * jumpTime * jumpTime + 2.5 * jumpTime;
      setState(() {
        birdY = initialJumpHeight - jumpHeight;
      });
      if (_isBirdDead()) {
        _gameOver();
      }
      _updatePipes();
      int newScore = (timer.tick - max(speed - ticksPerPipe, 5)) ~/ ticksPerPipe;
      if (newScore != score && newScore > 0) {
        setState(() { score = newScore; });
      }
    });
  }

  /// Game Over Sequence
  _gameOver() {
    timer?.cancel();
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        timer = null;
        lastPipe = 0;
        pipes = [];
        birdY = 0;
        jumpTime = 0;
        initialJumpHeight = 0;
        playing = false;
      });
    });

  }

  _jump(TapDownDetails _) {
    if (!playing) {
      _start();
      return;
    }
    setState(() {
      jumpTime = 0;
      initialJumpHeight = birdY;
    });
  }

  _updatePipes() {
    if (timer == null) return;
    if (timer!.tick + speed - lastPipe > ticksPerPipe) {
      // New Pipe
      double height = -0.9 + 1.8 * Random().nextDouble();
      pipes.add(Pipe(
        height: height,
        passTick: timer!.tick + speed,
        worldDimensions: worldDimensions,
      ));
      lastPipe = timer!.tick + speed;

      // Remove pipe that has passed
      if (pipes.length > 2 * speed / ticksPerPipe && pipes.length > 3) {
        pipes.removeAt(0);
      }
    }
  }

  /// Checks weather the bird has hit anything
  _isBirdDead() {
    // Hits Floor or Ceiling
    if (birdY > 1.1 || birdY < -1.5) return true;

    // Hits barrier
    // TODO
    for (Pipe pipe in pipes) {
      if (pipe.checkCollision(birdKey)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {

    Size screenDimensions = MediaQuery.of(context).size;
    double maxWidth = screenDimensions.height * 3 / 4 / 1.3;
    worldDimensions = Size(min(maxWidth, screenDimensions.width), screenDimensions.height * 3 / 4);

    return GestureDetector(
      onTapDown: _jump,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Background(),
              _buildBird(),
              if (playing)
                Positioned.fill(child: _buildGameCanvas()),
              if (!playing)
                _buildMenu(),
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildMenu() => Column(
    children: [
      Expanded(flex: 3,
        child: Column(
        children: [
          const Spacer(flex: 1,),
          _buildTitle(),
          const Spacer(flex: 4,),
          _buildPlayButton(),
          const Spacer(flex: 1,),
        ],
      )),
      Expanded(flex: 1,
        child: Container(),
      )
    ],
  );

  Widget _buildTitle() => const Text(
    "Flutter Bird",
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

  Widget _buildPlayButton() => Container(
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
  );

  Widget _buildBird() => Column(
    children: [
      Expanded(
        flex: 3,
        child: Stack(
          children: [
            Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  alignment: Alignment(0, birdY),
                  child: Bird(key: birdKey ,size: worldDimensions.height / 10,),
                ))
          ],
        ),
      ),
      Expanded(
          flex: 1,
          child: Container()
      )
    ],
  );

  Widget _buildGameCanvas() => Column(
    children: [
      Expanded(
        flex: 3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pipes
            if (timer != null)
              ...pipes.map((element) {
                return AnimatedContainer(
                    duration: const Duration(milliseconds: 0),
                    alignment: Alignment((element.passTick - timer!.tick) * 3 / speed, 0),
                    child: element
                );
              }).toList(),

            // Score
            Column(
              children: [
                const Spacer(flex: 1,),
                Text(
                  score.toString(),
                  style: const TextStyle(
                      fontFamily: 'flappy',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            offset: Offset(3, 3)
                        )
                      ]
                  ),
                ),
                const Spacer(flex: 6,),
              ],
            ),

          ]
        )
      ),
      Expanded(
        flex: 1,
        child: Container()
      )
    ],
  );
}
