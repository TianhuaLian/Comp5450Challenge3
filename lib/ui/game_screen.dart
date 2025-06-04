import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../game/pins/pin_renderer.dart';
import '../game/game_state.dart';
import '../ui/scoreboard.dart';
import '../ui/settings_menu.dart';

class GameScreen extends StatefulWidget {
  final GameController gameController;
  final double containerWidth;
  final double containerHeight;
  final double pinScale;

  const GameScreen({
    required this.gameController,
    required this.containerWidth,
    required this.containerHeight,
    required this.pinScale,
    Key? key,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showScoreboard = false;
  Offset? _swipeStart;

  @override
  Widget build(BuildContext context) {
    // Wrap the whole Stack with GestureDetector
    return GestureDetector(
      onPanUpdate: (details) {
        // Continuously record finger’s position
        if (widget.gameController.currentState == GameState.aiming &&
            _swipeStart != null) {
          // Overwrite the end‐position each update
          _lastSwipeEnd = details.localPosition;
        }
      },
      onPanStart: (details) => _swipeStart = details.localPosition,
      onPanEnd: (details) {
        if (widget.gameController.currentState == GameState.aiming &&
            _swipeStart != null && _lastSwipeEnd != null) {
          final Offset swipeEnd = _lastSwipeEnd!;
          final Offset swipeVec = swipeEnd - _swipeStart!;

          // If swipe is too small, ignore
          if (swipeVec.distance < 10) {
            _swipeStart = null;
            _lastSwipeEnd = null;
            return;
          }

          // Upward drag = 0°
          final double radians = atan2(swipeVec.dx, -swipeVec.dy);
          final double degrees = radians * 180 / pi;

          // Clamp angle to [-45°, +45°]
          final double clampedAngle = degrees.clamp(-45.0, 45.0);
          widget.gameController.ballAngle = clampedAngle;

          // Power: map drag length to some max velocity
          /*final double maxDragDistance = 200.0;
          final double powerRatio = (swipeVec.distance / maxDragDistance).clamp(0.0, 1.0);
          widget.gameController.ballPower = powerRatio * 300;*/

          widget.gameController.throwBall();

          _swipeStart = null;
          _lastSwipeEnd = null;
        }
      },
      child: Stack(
        children: [
          /// Background filled with a color
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// Game content
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 96),
          width: widget.containerWidth + widget.gameController.ball.radius * 2,
          height: widget.containerHeight,
          color: Colors.white.withOpacity(0),

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
              for (var pin in widget.gameController.pinManager.pins)
                PinRenderer(
                  pin: pin,
                  pinWidth: widget.gameController.pinManager.singlePinWidth,
                  pinHeight: widget.gameController.pinManager.singlePinHeight,
                  pinScale: widget.gameController.pinScale,
                ),

              /// Render ball
              AnimatedBuilder(
                animation: widget.gameController.ballAnimationController,
                builder: (context, _) {
                  return Positioned(
                    left: widget.gameController.ball.position.dx,
                    top: widget.gameController.ball.position.dy -
                        widget.gameController.ball.radius,
                    child: Container(
                      width: widget.gameController.ball.radius * 2,
                      height: widget.gameController.ball.radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        image: DecorationImage(
                          image: AssetImage('assets/images/ball.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        /// Game UI overlay
        /// Toggle Scoreboard button and pause button
        Positioned(
          top: 100,
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.pause, color: Colors.black),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white70,
                  padding: EdgeInsets.all(10),
                ),
                onPressed: widget.gameController.pauseGame,
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.black),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white70,
                  padding: EdgeInsets.all(10),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: SettingsMenu(gameController: widget.gameController),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.insert_chart_outlined, color: Colors.black),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white70,
                  padding: EdgeInsets.all(10),
                ),
                onPressed: () {
                  setState(() {
                    _showScoreboard = !_showScoreboard;
                  });
                },
              ),
            ],
          ),
        ),

        /// Scoreboard overlay
        if (_showScoreboard)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScoreboardWidget(scoreManager: widget.gameController.scoreManager),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => setState(() => _showScoreboard = false),
                        child: Text('Close Scoreboard'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        /// Special result overlay
        if (widget.gameController.currentState == GameState.checkingPins &&
            widget.gameController.specialResult != null)
          Positioned.fill(
            child: Container(
              color: Colors.black38,
              child: Center(
                child: Text(
                  widget.gameController.specialResult!,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black)
                    ],
                  ),
                ),
              ),
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
      ),
    );
  }

  Offset? _lastSwipeEnd;
  Widget _buildGameControls() {
    switch (widget.gameController.currentState) {
      case GameState.aiming:
        return _buildAimingControls();
      /*case GameState.checkingPins:
        return _buildCheckingPinsControls();*/
      case GameState.frameEnd:
        return _buildFrameEndControls();
      default:
        return Container(); // No controls for other states
    }
  }

  /// Aiming controls for the game (swipe instructions only)
  Widget _buildAimingControls() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Swipe up to throw!\nSwipe direction controls angle.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Last Angle: ${widget.gameController.ballAngle.toStringAsFixed(1)}°',
            style: TextStyle(fontSize: 16),
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
          Text('Knocked Down: ${widget.gameController.pinManager.knockedDownPinsCount}'),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.gameController.clearFallenPins,
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
          Text('Frame ${widget.gameController.currentFrame} Complete',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.gameController.nextFrame,
            child: Text('Continue to Frame ${widget.gameController.currentFrame + 1}'),
          ),
        ],
      ),
    );
  }
}