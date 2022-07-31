
import 'dart:async';
import 'dart:math';

import 'package:flappy_bird/view/widgets/pipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/background.dart';
import 'widgets/bird.dart';
import 'widgets/flappy_text.dart';

class FlutterBirdGame extends StatefulWidget {
  const FlutterBirdGame({
    Key? key,
    required this.bird,
    required this.birdSize,
    required this.worldDimensions,
    required this.onGameOver,
  }) : super(key: key);

  final Bird bird;
  final double birdSize;
  final Size worldDimensions;
  final Function(int score) onGameOver;

  @override
  State<FlutterBirdGame> createState() => _FlutterBirdGameState();
}

class _FlutterBirdGameState extends State<FlutterBirdGame> {

  /// ++++++++++++++++++++++++ GAME STATE (MODEL) ++++++++++++++++++++++++++++

  final GlobalKey birdKey = GlobalKey();

  // game loop timer
  Timer? timer;

  // ticks between two pipes (smaller -> more pipes)
  static int ticksPerPipe = 50;
  // ticks until a spawned pipe reaches bird (smaller -> faster)
  static int speed = 100;

  double birdY = 0;
  double jumpTime = 0;
  double initialJumpHeight = 0;
  double jumpHeight = 0;
  // inclination of jump used for bird rotation
  double jumpDirection = 0;
  int score = 0;

  // tick of the last pipe that spawned
  int lastPipe = 0;

  List<Pipe> pipes = [];
  // used to determine when points are gained
  List<int> upcomingPipeTicks = [];


  /// ++++++++++++++++++++++++ GAME LOGIC (CONTROLLER) ++++++++++++++++++++++++++++

  /// Start game loop
  @override
  void initState() {
    super.initState();
    score = 0;
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {

      // render bird
      jumpTime += 0.025;
      jumpHeight = -4.4 * jumpTime * jumpTime + 2.5 * jumpTime;
      jumpDirection = -8.8 * jumpTime + 2.5;
      setState(() {
        birdY = initialJumpHeight - jumpHeight;
      });

      // render pipes
      _updatePipes();

      // update score
      if (upcomingPipeTicks.first < timer.tick) {
        upcomingPipeTicks.removeAt(0);
        setState(() { ++score; });
      }

      // check for collisions
      if (_isBirdDead()) {
        _gameOver();
      }
    });
  }

  @override
  void dispose() {
    jumpDirection = 0;
    timer = null;
    lastPipe = 0;
    pipes = [];
    birdY = 0;
    jumpTime = 0;
    initialJumpHeight = 0;
    upcomingPipeTicks = [];
    super.dispose();
  }

  /// Game Over Sequence
  _gameOver() {
    timer?.cancel();

    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        widget.onGameOver(score);
        Navigator.of(context).pop();
      });
    });

  }

  _jump(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() {
      jumpTime = 0;
      initialJumpHeight = birdY;
    });
  }

  _updatePipes() {
    if (timer == null) return;
    if (timer!.tick + speed - lastPipe >= ticksPerPipe) {
      // New Pipe
      double height = -0.9 + 1.8 * Random().nextDouble();
      int pipeTick = timer!.tick + speed;
      pipes.add(Pipe(
        height: height,
        passTick: pipeTick,
        worldDimensions: widget.worldDimensions,
      ));
      upcomingPipeTicks.add(pipeTick);
      lastPipe = pipeTick;

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
    for (Pipe pipe in pipes) {
      if (pipe.checkCollision(birdKey)) {
        return true;
      }
    }

    return false;
  }

  /// ++++++++++++++++++++++++ GAME UI (VIEW) ++++++++++++++++++++++++++++

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: _jump,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: widget.worldDimensions.width
            ),
            child: Stack(
                alignment: Alignment.center,
                children: [
                  const Background(),
                  _buildBird(),
                  Positioned.fill(child: _buildGameCanvas()),
                ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBird() => Column(
    children: [
      Expanded(
        flex: 3,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 0),
            alignment: Alignment(0, birdY),
            child: Transform.rotate(angle: pi / 4 * (-jumpDirection / 4), child: SizedBox(
              key: birdKey,
              height: widget.birdSize,
              width: widget.birdSize,
              child: widget.bird,
            ))
        ),
      ),
      const Spacer()
    ],
  );

  Widget _buildGameCanvas() {
    return Column(
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
                      FlappyText(
                        text: score.toString(),
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
}
