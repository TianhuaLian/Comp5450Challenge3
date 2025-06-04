import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../game/pins/pin_renderer.dart';
import '../game/game_state.dart';
import '../ui/scoreboard.dart';

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
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showScoreboard = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          margin: EdgeInsets.symmetric(horizontal: 35, vertical: 95),
          width: widget.containerWidth,
          height: widget.containerHeight,
          color: Colors.white.withOpacity(0),

/*          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 80),
          width: widget.containerWidth,
          height: widget.containerHeight,
          color: Colors.brown[200],*/

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
                    left: widget.gameController.ball.position.dx -
                        widget.gameController.ball.radius,
                    top: widget.gameController.ball.position.dy -
                        widget.gameController.ball.radius,
                    child: Container(
                      width: widget.gameController.ball.radius * 2,
                      height: widget.gameController.ball.radius * 2,
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
        /// Toggle Scoreboard button and pause button
        Positioned(
          bottom: 200,
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.insert_chart_outlined, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: EdgeInsets.all(10),
                ),
                onPressed: () {
                  setState(() {
                    _showScoreboard = !_showScoreboard;
                  });
                },
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: EdgeInsets.all(10),
                ),
                onPressed: widget.gameController.pauseGame,
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
    );
  }

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

  /// Aiming controls for the game
  Widget _buildAimingControls() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Throw Angle: ${widget.gameController.ballAngle.toStringAsFixed(1)}°'),
          Slider(
            min: -45,
            max: 45,
            value: widget.gameController.ballAngle,
            onChanged: (value) => widget.gameController.ballAngle = value,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: widget.gameController.throwBall,
                child: Text('Throw'),
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