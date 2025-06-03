import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../game/pins/pin_renderer.dart';
import '../game/game_state.dart';

class GameScreen extends StatelessWidget {
  final GameController gameController;
  final double containerWidth;
  final double containerHeight;
  final double pinScale;

  const GameScreen({
    required this.gameController,
    required this.containerWidth,
    required this.containerHeight,
    required this.pinScale,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background filled with a color
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey,
        ),

        /// Game content
        Container(
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 80),
          width: containerWidth,
          height: containerHeight,
          color: Colors.brown[200],
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Lane marker
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              /// Render pins
              for (var pin in gameController.pinManager.pins)
                PinRenderer(
                  pin: pin,
                  pinWidth: gameController.pinManager.singlePinWidth,
                  pinHeight: gameController.pinManager.singlePinHeight,
                  pinScale: gameController.pinScale,
                ),

              /// Render ball
              AnimatedBuilder(
                animation: gameController.ballAnimationController,
                builder: (context, _) {
                  return Positioned(
                    left: gameController.ball.position.dx -
                        gameController.ball.radius,
                    top: gameController.ball.position.dy -
                        gameController.ball.radius,
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

        /// Game UI overlay
        Positioned(
          top: 50,
          left: 30,
          child: Row(
            children: [
              // Text('State: ${gameController.currentState.name}',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // SizedBox(width: 20),
              // Text('Frame: ${gameController.currentFrame}',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // SizedBox(width: 20),
              // Text('Roll: ${gameController.currentRoll}',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        /// Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildGameControls(),
        ),
      ],
    );
  }

  Widget _buildGameControls() {
    switch (gameController.currentState) {
      case GameState.aiming:
        return _buildAimingControls();
      case GameState.checkingPins:
        return _buildCheckingPinsControls();
      case GameState.frameEnd:
        return _buildFrameEndControls();
      default:
        return Container(); // No controls for other states
    }
  }

  /// Aiming controls for the game
  Widget _buildAimingControls() {
    return Container(
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
            onChanged: (value) => gameController.ballAngle = value,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: gameController.throwBall,
                child: Text('Throw'),
              ),
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: gameController.pauseGame,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckingPinsControls() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        children: [
          Text('Knocked Down: ${gameController.pinManager.knockedDownPinsCount}'),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: gameController.clearFallenPins,
            child: Text('Clear Fallen Pins'),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameEndControls() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        children: [
          Text('Frame ${gameController.currentFrame} Complete',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: gameController.nextFrame,
            child: Text('Continue to Frame ${gameController.currentFrame + 1}'),
          ),
        ],
      ),
    );
  }
}