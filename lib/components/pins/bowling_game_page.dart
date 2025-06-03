// CONTROL FUNCTIONS:
// ------------------
// Ball control: throwBall() - Handles ball throwing physics and movement
// Score tracking: _knockedDownPinsCount (variable) - Counts hit pins, displayed in UI
// Full game reset: resetGame() - Resets all pins, ball position and game state
// Clear fallen pins: clearFallenPins() - Removes already knocked down pins

import 'package:flutter/material.dart';
import 'dart:math';
import 'pin_data.dart';
import 'pin_manager.dart';


class BowlingGamePage extends StatefulWidget {
  @override
  _BowlingGamePageState createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with TickerProviderStateMixin {
  final double containerWidth = 300.0;
  final double containerHeight = 500.0;
  final double pinScale = 1.8;
  late final double singlePinWidth = 20 * pinScale;
  late final double singlePinHeight = 40 * pinScale;

  final double ballRadius = 20.0;
  double ballAngle = 0.0;
  Offset ballPosition = Offset.zero;
  Offset ballVelocity = Offset.zero;
  bool ballInMotion = false;

  final Random _random = Random();

  late PinManager pinManager;
  late AnimationController _ballAnimationController;

  @override
  void initState() {
    super.initState();

    pinManager = PinManager(
      vsync: this,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      pinScale: pinScale,
    );

    _ballAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16),
    );
    _ballAnimationController.addListener(updateGame);

    ballPosition = Offset(containerWidth / 2, containerHeight - 50);
  }

  @override
  void dispose() {
    _ballAnimationController.dispose();
    pinManager.dispose();
    super.dispose();
  }

  void resetGame() {
    setState(() {
      pinManager.resetGame();
      ballInMotion = false;
      ballPosition = Offset(containerWidth / 2, containerHeight - 50);
      ballVelocity = Offset.zero;
      _ballAnimationController.stop();
      _ballAnimationController.reset();
    });
  }

  void clearFallenPins() {
    setState(() {
      pinManager.clearFallenPins();
    });
  }

  void throwBall() {
    if (ballInMotion) return;

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

      // Boundary collision handling
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
        return;
      }

      // Pin collisions
      for (int i = 0; i < pinManager.pins.length; i++) {
        if (!pinManager.pins[i].isHit) {
          final Rect pinRect = Rect.fromLTWH(
            pinManager.pins[i].position.dx - singlePinWidth / 2,
            pinManager.pins[i].position.dy - singlePinHeight,
            singlePinWidth,
            singlePinHeight,
          );
          final Rect ballRect = Rect.fromCircle(center: ballPosition, radius: ballRadius);

          if (ballRect.overlaps(pinRect)) {
            final double relativeHitPosition = ballPosition.dx - pinManager.pins[i].position.dx;
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

            _startPinAnimation(pinManager.pins[i], targetRotationAngle, Offset(displacementX, displacementY), canCauseChain: true);

            ballVelocity = ballVelocity * 0.8;
          }
        }
      }

      // Chain reactions
      for (int i = 0; i < pinManager.pins.length; i++) {
        final PinData fallingPin = pinManager.pins[i];
        if (fallingPin.isFalling && fallingPin.rotationController!.isAnimating && fallingPin.canCauseChainReaction) {
          final double collisionZoneWidth = singlePinWidth * 0.02;
          final double collisionZoneHeight = singlePinHeight * 0.05;

          final Offset fallingPinCollisionCenter = fallingPin.position + fallingPin.translationAnimation!.value;

          final Rect fallingPinCollisionRect = Rect.fromCenter(
            center: fallingPinCollisionCenter,
            width: collisionZoneWidth,
            height: collisionZoneHeight,
          );

          for (int j = 0; j < pinManager.pins.length; j++) {
            if (i == j || pinManager.pins[j].isHit) {
              continue;
            }

            final PinData standingPin = pinManager.pins[j];
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

              for (var pin in pinManager.pins)
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
              'Knocked Down: ${pinManager.knockedDownPinsCount}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}