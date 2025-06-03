import 'package:flutter/material.dart';
import 'game/game_state.dart';
import 'game/game_controller.dart';
import 'ui/start_screen.dart';
import 'ui/game_screen.dart';
import 'ui/game_over.dart';
import 'ui/pause.dart';

class BowlingGamePage extends StatefulWidget {
  @override
  _BowlingGamePageState createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with TickerProviderStateMixin {
  final double containerWidth = 300.0;
  final double containerHeight = 600.0;
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
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showScore = gameController.currentState != GameState.title &&
        gameController.currentState != GameState.gameOver;

    return Scaffold(
      body: Column(
        children: [
          if (showScore)
            SafeArea(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Score: ${gameController.scoreManager.totalScore}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (gameController.currentState) {
      case GameState.title:
        return StartScreen(
            onStart: gameController.startGame
        );
      case GameState.gameOver:
        return GameOverScreen(
          totalScore: gameController.scoreManager.totalScore,
          onRestart: gameController.restartGame,
          onScoreboard: gameController.showScoreboard,
        );
      case GameState.pause:
        return Pause(
          onResume: gameController.resumeGame,
        );
      default:
        return GameScreen(
          gameController: gameController,
          containerWidth: containerWidth,
          containerHeight: containerHeight,
          pinScale: pinScale,
        );
    }
  }
}
