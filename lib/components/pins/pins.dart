// CONTROL FUNCTIONS:
// ------------------
// Ball control: throwBall() - Handles ball throwing physics and movement
// Score tracking: _knockedDownPinsCount (variable) - Counts hit pins, displayed in UI
// Full game reset: resetGame() - Resets all pins, ball position and game state
// Clear fallen pins: clearFallenPins() - Removes already knocked down pins

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(BowlingPinsApp());
}

class BowlingPinsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bowling Game',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: BowlingGamePage(),
    );
  }
}

class BowlingGamePage extends StatefulWidget {
  @override
  _BowlingGamePageState createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with TickerProviderStateMixin {
  final double containerWidth = 300.0;
  final double containerHeight = 500.0;
  final double pinScale = 1.8;
  late final double singlePinWidth;
  late final double singlePinHeight;
  final double verticalSpacing = 20.0;
  final double horizontalSpacing = 50.0;

  final double ballRadius = 20.0;
  double ballAngle = 0.0;
  Offset ballPosition = Offset.zero;
  Offset ballVelocity = Offset.zero;
  bool ballInMotion = false;

  List<PinData> pins = [];
  List<PinData> originalPins = [];
  int _knockedDownPinsCount = 0;

  late AnimationController _ballAnimationController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    singlePinWidth = 20 * pinScale;
    singlePinHeight = 40 * pinScale;

    _ballAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16),
    );
    _ballAnimationController.addListener(updateGame);

    resetPins();
    ballPosition = Offset(containerWidth / 2, containerHeight - 50);
  }

  @override
  void dispose() {
    _ballAnimationController.dispose();
    for (var pin in pins) {
      pin.dispose();
    }
    super.dispose();
  }

  void resetPins() {
    for (var pin in pins) {
      pin.dispose();
    }

    setState(() {
      pins = [];
      originalPins = [];
      _knockedDownPinsCount = 0;

      _addPinsInRow(count: 4, rowIndex: 0, baseTop: 100);
      _addPinsInRow(count: 3, rowIndex: 1, baseTop: 100);
      _addPinsInRow(count: 2, rowIndex: 2, baseTop: 100);
      _addPinsInRow(count: 1, rowIndex: 3, baseTop: 100);

      originalPins = List.from(pins.map((pin) => pin.copyWith()));
    });
  }

  void resetGame() {
    setState(() {
      for (var pin in pins) {
        pin.dispose();
      }

      pins = List.from(originalPins.map((pinData) {
        AnimationController newRotationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        );
        Animation<double> newRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(
          parent: newRotationController,
          curve: Curves.easeOut,
        ));

        AnimationController newTranslationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 500),
        );
        Animation<Offset> newTranslationAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(
          parent: newTranslationController,
          curve: Curves.easeOutCubic,
        ));

        return PinData(
          position: pinData.position,
          rotation: 0,
          isHit: false,
          isFalling: false,
          canCauseChainReaction: false,
          translation: Offset.zero,
          rotationController: newRotationController,
          rotationAnimation: newRotationAnimation,
          translationController: newTranslationController,
          translationAnimation: newTranslationAnimation,
        );
      }));

      ballInMotion = false;
      ballPosition = Offset(containerWidth / 2, containerHeight - 50);
      ballVelocity = Offset.zero;
      _ballAnimationController.stop();
      _ballAnimationController.reset();
      _knockedDownPinsCount = 0;
    });
  }

  void clearFallenPins() {
    setState(() {
      pins.removeWhere((pin) => pin.isHit);
    });
  }

  void _addPinsInRow({
    required int count,
    required int rowIndex,
    required double baseTop,
  }) {
    final double rowTotalWidth = (count - 1) * horizontalSpacing + singlePinWidth;
    final double startCenterX = (containerWidth / 2);
    final double firstPinLeftCenterX = startCenterX - (rowTotalWidth / 2) + (singlePinWidth / 2);
    final double bottomCenterY = baseTop + singlePinHeight / 2;

    for (int i = 0; i < count; i++) {
      AnimationController rotationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
      );
      Animation<double> rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(
        parent: rotationController,
        curve: Curves.easeOut,
      ));

      AnimationController translationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      );
      Animation<Offset> translationAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(
        parent: translationController,
        curve: Curves.easeOutCubic,
      ));

      pins.add(PinData(
        position: Offset(firstPinLeftCenterX + (i * horizontalSpacing), bottomCenterY + (rowIndex * verticalSpacing)),
        rotation: 0,
        isHit: false,
        isFalling: false,
        canCauseChainReaction: false,
        translation: Offset.zero,
        rotationController: rotationController,
        rotationAnimation: rotationAnimation,
        translationController: translationController,
        translationAnimation: translationAnimation,
      ));
    }
  }

  void throwBall() {
    if (ballInMotion) return;

    setState(() {
      _knockedDownPinsCount = 0;
    });

    setState(() {
      ballInMotion = true;
      double radians = ballAngle * pi / 180;
      ballVelocity = Offset(sin(radians) * 8, -cos(radians) * 8);
    });

    _ballAnimationController.repeat();
  }

  void updateGame() {
    if (!ballInMotion) return;

    setState(() {
      ballPosition += ballVelocity;

      if (ballPosition.dx - ballRadius <= 0) {
        ballPosition = Offset(ballRadius, ballPosition.dy);
        ballVelocity = Offset(-ballVelocity.dx * 0.7, ballVelocity.dy);
      } else if (ballPosition.dx + ballRadius >= containerWidth) {
        ballPosition = Offset(containerWidth - ballRadius, ballPosition.dy);
        ballVelocity = Offset(-ballVelocity.dx * 0.7, ballVelocity.dy);
      }

      if (ballPosition.dy + ballRadius <= 0 || ballPosition.dy - ballRadius >= containerHeight) {
        ballInMotion = false;
        _ballAnimationController.stop();
        _ballAnimationController.reset();
        ballPosition = Offset(containerWidth / 2, containerHeight - 50);
        _knockedDownPinsCount = pins.where((pin) => pin.isHit).length;
        return;
      }

      for (int i = 0; i < pins.length; i++) {
        if (!pins[i].isHit) {
          final Rect pinRect = Rect.fromLTWH(
            pins[i].position.dx - singlePinWidth / 2,
            pins[i].position.dy - singlePinHeight,
            singlePinWidth,
            singlePinHeight,
          );
          final Rect ballRect = Rect.fromCircle(center: ballPosition, radius: ballRadius);

          if (ballRect.overlaps(pinRect)) {
            final double relativeHitPosition = ballPosition.dx - pins[i].position.dx;
            double targetRotationAngle;
            if (_random.nextBool()) {
              targetRotationAngle = -pi / 2;
            } else {
              targetRotationAngle = pi / 2;
            }

            double displacementX = 0;
            double displacementY = - (_random.nextDouble() * 30 + 30);

            if (targetRotationAngle < 0) {
              displacementX = - (_random.nextDouble() * 15 + 15);
            } else {
              displacementX = _random.nextDouble() * 15 + 15;
            }

            _startPinAnimation(pins[i], targetRotationAngle, Offset(displacementX, displacementY), canCauseChain: true);

            ballVelocity = ballVelocity * 0.8;
            if (relativeHitPosition > 0) {
              ballVelocity = Offset(ballVelocity.dx * 0.9, ballVelocity.dy);
            } else {
              ballVelocity = Offset(ballVelocity.dx * 0.9, ballVelocity.dy);
            }
          }
        }
      }

      for (int i = 0; i < pins.length; i++) {
        final PinData fallingPin = pins[i];
        if (fallingPin.isFalling && fallingPin.rotationController!.isAnimating && fallingPin.canCauseChainReaction) {
          final double collisionZoneWidth = singlePinWidth * 0.02;
          final double collisionZoneHeight = singlePinHeight * 0.05;

          final Offset fallingPinCollisionCenter = fallingPin.position + fallingPin.translationAnimation!.value;

          final Rect fallingPinCollisionRect = Rect.fromCenter(
            center: fallingPinCollisionCenter,
            width: collisionZoneWidth,
            height: collisionZoneHeight,
          );

          for (int j = 0; j < pins.length; j++) {
            if (i == j || pins[j].isHit) {
              continue;
            }

            final PinData standingPin = pins[j];
            final Rect standingPinRect = Rect.fromLTWH(
              standingPin.position.dx - singlePinWidth / 2,
              standingPin.position.dy - singlePinHeight,
              singlePinWidth,
              singlePinHeight,
            );

            if (fallingPinCollisionRect.overlaps(standingPinRect)) {
              double targetRotationAngle;
              final double collisionX = standingPin.position.dx;
              final double fallingPinCurrentX = fallingPinCollisionCenter.dx;

              if (fallingPinCurrentX < collisionX) {
                targetRotationAngle = pi / 2;
              } else {
                targetRotationAngle = -pi / 2;
              }

              double displacementX = 0;
              double displacementY = - (_random.nextDouble() * 20 + 20);

              if (targetRotationAngle < 0) {
                displacementX = - (_random.nextDouble() * 10 + 10);
              } else {
                displacementX = _random.nextDouble() * 10 + 10;
              }

              _startPinAnimation(standingPin, targetRotationAngle, Offset(displacementX, displacementY), canCauseChain: false);
              break;
            }
          }
        }
      }
    });
  }

  void _startPinAnimation(PinData pin, double targetRotationAngle, Offset targetTranslation, {required bool canCauseChain}) {
    pin.isHit = true;
    pin.isFalling = true;
    pin.canCauseChainReaction = canCauseChain;

    pin.rotationAnimation = Tween<double>(begin: pin.rotationAnimation!.value, end: targetRotationAngle).animate(CurvedAnimation(
      parent: pin.rotationController!,
      curve: Curves.easeOut,
    ));
    pin.rotationController!.forward(from: 0.0);

    pin.translationAnimation = Tween<Offset>(begin: pin.translationAnimation!.value, end: targetTranslation).animate(CurvedAnimation(
      parent: pin.translationController!,
      curve: Curves.easeOutCubic,
    ));
    pin.translationController!.forward(from: 0.0);

    pin.rotationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        pin.isFalling = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          color: Colors.brown[200],
          child: Stack(
            children: [
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              for (var pin in pins)
                AnimatedBuilder(
                  animation: pin.rotationAnimation!,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: pin.translationAnimation!,
                      builder: (context, child) {
                        final double baseLeft = pin.position.dx - singlePinWidth / 2;
                        final double baseTop = pin.position.dy - singlePinHeight;

                        final double currentLeft = baseLeft + pin.translationAnimation!.value.dx;
                        final double currentTop = baseTop + pin.translationAnimation!.value.dy;

                        return Positioned(
                          top: currentTop,
                          left: currentLeft,
                          child: Transform.rotate(
                            angle: pin.rotationAnimation!.value,
                            alignment: Alignment.bottomCenter,
                            child: PinImage(scale: pinScale),
                          ),
                        );
                      },
                    );
                  },
                ),

              Positioned(
                left: ballPosition.dx - ballRadius,
                top: ballPosition.dy - ballRadius,
                child: Container(
                  width: ballRadius * 2,
                  height: ballRadius * 2,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Throw Angle: ${ballAngle.toStringAsFixed(1)}°'),
            Slider(
              min: -45,
              max: 45,
              value: ballAngle,
              onChanged: (value) {
                setState(() {
                  ballAngle = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: throwBall,
                  child: Text('Throw'),
                ),
                ElevatedButton(
                  onPressed: clearFallenPins,
                  child: Text('Clear Fallen'),
                ),
                ElevatedButton(
                  onPressed: resetGame,
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Knocked Down: $_knockedDownPinsCount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class PinData {
  final Offset position;
  double rotation;
  bool isHit;
  bool isFalling;
  bool canCauseChainReaction;
  Offset translation;

  AnimationController? rotationController;
  Animation<double>? rotationAnimation;
  AnimationController? translationController;
  Animation<Offset>? translationAnimation;

  PinData({
    required this.position,
    required this.rotation,
    required this.isHit,
    required this.isFalling,
    required this.canCauseChainReaction,
    required this.translation,
    this.rotationController,
    this.rotationAnimation,
    this.translationController,
    this.translationAnimation,
  });

  PinData copyWith({
    Offset? position,
    double? rotation,
    bool? isHit,
    bool? isFalling,
    bool? canCauseChainReaction,
    Offset? translation,
  }) {
    return PinData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      isHit: isHit ?? this.isHit,
      isFalling: isFalling ?? this.isFalling,
      canCauseChainReaction: canCauseChainReaction ?? this.canCauseChainReaction,
      translation: translation ?? this.translation,
      rotationController: null,
      rotationAnimation: null,
      translationController: null,
      translationAnimation: null,
    );
  }

  void dispose() {
    rotationController?.dispose();
    translationController?.dispose();
  }
}

class PinImage extends StatelessWidget {
  final double scale;

  const PinImage({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://i.imgur.com/cTVjcFA.png',
      width: 20 * scale,
      height: 40 * scale,
      fit: BoxFit.contain,
    );
  }
}