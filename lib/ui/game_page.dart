import 'package:flutter/material.dart';
import '/core/game_controller.dart';
import '/components/pins/pin_renderer.dart';

class BowlingGamePage extends StatefulWidget {
  @override
  _BowlingGamePageState createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with TickerProviderStateMixin {
  final double containerWidth = 300.0;
  final double containerHeight = 500.0;
  final double pinScale = 1.8;

  late GameController gameController;

  @override
  void initState() {
    super.initState();
    gameController = GameController(
      vsync: this,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      pinScale: pinScale,
    );
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
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

              // Render pins
              for (var pin in gameController.pinManager.pins)
                PinRenderer(
                  pin: pin,
                  pinWidth: gameController.pinManager.singlePinWidth,
                  pinHeight: gameController.pinManager.singlePinHeight,
                  pinScale: gameController.pinScale,
                ),

              // Render ball
              AnimatedBuilder(
                animation: gameController.ballAnimationController,
                builder: (context, _) {
                  return Positioned(
                    left: gameController.ball.position.dx - gameController.ball.radius,
                    top: gameController.ball.position.dy - gameController.ball.radius,
                    child: Container(
                      width: gameController.ball.radius * 2,
                      height: gameController.ball.radius * 2,
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
                  );
                },
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
            Text('Throw Angle: ${gameController.ballAngle.toStringAsFixed(1)}°'),
            Slider(
              min: -45,
              max: 45,
              value: gameController.ballAngle,
              onChanged: (value) {
                setState(() {
                  gameController.ballAngle = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: gameController.throwBall,
                  child: Text('Throw'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gameController.clearFallenPins();
                    });
                  },
                  child: Text('Clear Fallen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gameController.resetGame();
                    });
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Knocked Down: ${gameController.knockedDownPinsCount}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}