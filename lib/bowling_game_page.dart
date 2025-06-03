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
      body: Stack(
        children: [
          _buildContent(),   // 游戏主体
          if (showScore)
            Positioned(
              top: MediaQuery.of(context).padding.top + 4, // 状态栏下 4px
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Score: ${gameController.scoreManager.totalScore}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  } // 这里加了右大括号！！！

  // 这个函数要在类作用域里，**不是**build方法内部
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
