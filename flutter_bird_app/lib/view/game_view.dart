import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bird/view/widgets/pipe.dart';

import 'widgets/background.dart';
import 'widgets/bird.dart';
import 'widgets/flappy_text.dart';

class GameView extends StatefulWidget {
  const GameView({
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
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  /// ++++++++++++++++++++++++ GAME STATE (MODEL) ++++++++++++++++++++++++++++

  final GlobalKey birdKey = GlobalKey();

  // game loop timer
  Timer? timer;
  bool isGameOver = false;
  int gameOverTick = -1; // Timer tick of when the game has ended (used to stop pipe movement)
  String gameOverPhrase = 'GAME OVER!';

  // ticks between two pipes (smaller -> more pipes)
  static int ticksPerPipe = 100;

  // ticks until a spawned pipe reaches bird (smaller -> faster)
  static int speed = 220;

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
    timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      // render bird
      jumpTime += 0.0125;
      jumpHeight = -4.3 * jumpTime * jumpTime + 2.3 * jumpTime;
      jumpDirection = -8.8 * jumpTime + 2.5;
      setState(() {
        birdY = initialJumpHeight - jumpHeight;
      });

      // only move pipes, update score and check collisions if game is not over
      if (!isGameOver) {
        // render pipes
        _updatePipes();

        // update score
        if (upcomingPipeTicks.first < timer.tick) {
          upcomingPipeTicks.removeAt(0);
          setState(() {
            ++score;
          });
        }

        // check for collisions
        if (_isBirdDead()) {
          _gameOver();
        }
      }
    });
  }

  @override
  void dispose() {
    jumpDirection = 0;
    timer = null;
    isGameOver = false;
    gameOverPhrase = 'GAME OVER!';
    gameOverTick = -1;
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
    _jump(null);
    isGameOver = true;
    gameOverTick = timer?.tick ?? 0;
    gameOverPhrase = GameOverPhrases.getRandomPhrase(score);
    int gameOverTime = 2000 + score * 50; // display game over screen longer the higher the score

    Timer(Duration(milliseconds: gameOverTime), () {
      setState(() {
        widget.onGameOver(score);
        timer?.cancel();
        Navigator.of(context).pop();
      });
    });
  }

  _jump(TapDownDetails? _) {
    // don't handle jumps if game is over
    if (isGameOver) return;

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
        child: Stack(alignment: Alignment.center, children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.worldDimensions.width),
              child: Stack(alignment: Alignment.center, children: [
                const Background(),
                _buildBird(),
                Positioned.fill(child: _buildGameCanvas()),
              ]),
            ),
          ),

          // Workaround to clip Pipes when Game Canvas is padded on the sides (browser)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                    )),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.worldDimensions.width),
                  child: Container(),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                    )),
              ],
            ),
          )
        ]),
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
                child: Transform.rotate(
                    angle: pi / 4 * (-jumpDirection / 6),
                    child: SizedBox(
                      key: birdKey,
                      height: widget.birdSize,
                      width: widget.birdSize,
                      child: widget.bird,
                    ))),
          ),
          const Spacer()
        ],
      );

  Widget _buildGameCanvas() {
    return Column(
      children: [
        Expanded(
            flex: 3,
            child: Stack(alignment: Alignment.center, children: [
              // Pipes
              if (timer != null)
                ...pipes.map((element) {
                  int pipeTick = isGameOver ? gameOverTick : timer!.tick;
                  return AnimatedAlign(
                      duration: const Duration(milliseconds: 0),
                      alignment: Alignment((element.passTick - pipeTick) * 3 / speed, 0),
                      child: element);
                }).toList(),

              // Score
              Column(
                children: [
                  const Spacer(
                    flex: 1,
                  ),
                  FlappyText(
                    text: score.toString(),
                  ),
                  const Spacer(
                    flex: 6,
                  ),
                ],
              ),

              // Game Over Text
              Positioned(
                top: isGameOver ? MediaQuery.of(context).size.height / 3 : -100,
                left: 8,
                right: 8,
                child: AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: isGameOver ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: Duration(seconds: 1),
                    curve: Curves.bounceOut,
                    scale: isGameOver ? 1.0 : 0.5,
                    child: Container(
                      alignment: Alignment.center,
                      child: FlappyText(
                        text: gameOverPhrase,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ])),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}

enum PerformanceLevel {
  Worst,
  Poor,
  Average,
  Good,
  Extraordinary,
}

class GameOverPhrases {
  static final Random _random = Random();

  static final Map<PerformanceLevel, List<String>> phrases = {
    PerformanceLevel.Worst: [
      "Yikes, that was painful!",
      "Catastrophic failure!",
      "Epic fail alert!",
      "Total disaster zone!",
      "Well, that was embarrassing!",
      "Womp womp...",
      "Train wreck incoming!",
      "That was... something!",
      "Absolutely disastrous!",
      "You had one job!",
      "Complete meltdown!",
      "Couldn't get any worse!",
      "Game over... and over!",
      "Total fiasco!",
      "Utter chaos!",
      "Dumpster fire status!",
      "You're in trouble!",
      "Going from bad to worse!",
      "Total wipeout!",
      "It's a disaster movie!",
      "Epic facepalm moment!",
      "You broke the game!",
      "The stuff of nightmares!",
      "A comedy of errors!",
      "It's a disaster zone!",
      "Well, that escalated quickly!",
      "The epitome of failure!",
      "That was a train wreck!",
      "The end of the world!",
      "It's a catastrophe!",
      "Try that again!",
      "Dead bird.",
      "Birds aren't real anyways.",
    ],
    PerformanceLevel.Poor: [
      "Ouch, rough one!",
      "Tough luck, buddy!",
      "Not your day, huh?",
      "Well, that didn't go as planned!",
      "Bumpy ride, eh?",
      "Uh-oh, better luck next time!",
      "Yikes, tough break!",
      "That's gotta hurt!",
      "Oops, better luck next round!",
      "Not your finest hour!",
      "Welp, that happened!",
      "Bummer, buddy!",
      "Swing and a miss!",
      "Well, that was unexpected!",
      "Better luck next attempt!",
      "Oopsie daisy!",
      "Yikes, what happened there?",
      "A minor setback!",
      "Keep your chin up!",
      "Everyone has off days!",
      "A slight stumble!",
      "Well, that was unfortunate!",
      "Tough break, champ!",
      "A temporary setback!",
      "Shake it off!",
      "You'll get 'em next time!",
      "Keep your head high!",
      "Every failure is a lesson!",
      "The struggle is real!",
      "Onwards and upwards!",
      "Try that again!",
      "Keep your head up!",
      "Dead bird.",
      "Birds aren't real anyways.",
    ],
    PerformanceLevel.Average: [
      "Not bad, not bad!",
      "Pretty decent effort!",
      "Middle of the road!",
      "You did okay-ish!",
      "Room for improvement!",
      "Not too shabby!",
      "Fairly respectable!",
      "A solid attempt!",
      "You're getting there!",
      "Keep practicing!",
      "Not the worst, not the best!",
      "Showing potential!",
      "Meh, could be worse!",
      "So-so performance!",
      "Average Joe gaming!",
      "Could use some work!",
      "Meh, it'll do!",
      "Noteworthy attempt!",
      "Getting the hang of it!",
      "Steady progress!",
      "Room for growth!",
      "Needs a little polish!",
      "Still learning the ropes!",
      "Noteworthy effort!",
      "Mediocre at best!",
      "A valiant effort!",
      "Making strides!",
      "It's a start!",
      "Room for improvement!",
      "Progress in the making!",
    ],
    PerformanceLevel.Good: [
      "You aced it!",
      "Top-notch gaming!",
      "Legendary skills!",
      "Absolute mastery!",
      "Flawless victory!",
      "Epic gaming spree!",
      "You're unstoppable!",
      "Total domination!",
      "You crushed it!",
      "Gaming prodigy!",
      "Superb performance!",
      "You're on fire!",
      "Masterful maneuvers!",
      "You're the MVP!",
      "Gaming wizardry!",
      "Truly impressive!",
      "Perfect execution!",
      "Pro-level gaming!",
      "Exemplary gameplay!",
      "Unbeatable skills!",
      "Impressive reflexes!",
      "You're a gaming phenom!",
      "That's how it's done!",
      "Outstanding performance!",
      "Supreme gaming skills!",
      "Skillful precision!",
      "You're a gaming legend!",
      "Unstoppable force!",
      "Astounding abilities!",
      "Unparalleled excellence!",
    ],
    PerformanceLevel.Extraordinary: [
      "Mind-blowing skills!",
      "Otherworldly gaming!",
      "Beyond legendary!",
      "You're a gaming deity!",
      "Out of this world!",
      "Alien-level gameplay!",
      "Absolutely phenomenal!",
      "A performance for the ages!",
      "The stuff of legends!",
      "Pure gaming magic!",
      "You're in a league of your own!",
      "Gaming supernova!",
      "Absolutely breathtaking!",
      "Galactic domination!",
      "You're a gaming marvel!",
      "Simply awe-inspiring!",
      "Unbelievably phenomenal!",
      "A performance beyond compare!",
      "You've reached gaming nirvana!",
      "Sublime gaming mastery!",
      "Unearthly gaming prowess!",
      "A performance of cosmic proportions!",
      "Legendary beyond measure!",
      "Mind-bogglingly incredible!",
      "You've transcended gaming!",
      "A performance for the history books!",
      "You're rewriting the rules of gaming!",
      "Truly, truly extraordinary!",
      "The pinnacle of gaming excellence!",
      "You're the chosen one!",
      "You must be Anton Stamme himself!"
    ],
  };

  static PerformanceLevel getPerformanceLevel(int score) {
    if (score < 5) {
      return PerformanceLevel.Worst;
    } else if (score < 15) {
      return PerformanceLevel.Poor;
    } else if (score < 25) {
      return PerformanceLevel.Average;
    } else if (score < 50) {
      return PerformanceLevel.Good;
    } else {
      return PerformanceLevel.Extraordinary;
    }
  }

  static String getRandomPhrase(int score) {
    PerformanceLevel level = getPerformanceLevel(score);
    final List<String> phrasesForLevel = phrases[level]!;
    return phrasesForLevel[_random.nextInt(phrasesForLevel.length)];
  }
}
