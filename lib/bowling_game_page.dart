import 'package:flutter/material.dart';
import 'game/game_state.dart';
import 'game/game_controller.dart';
import 'ui/start_screen.dart';
import 'ui/game_screen.dart';
import 'ui/game_over.dart';
import 'ui/pause.dart';
import 'ui/scoreboard.dart';

class BowlingGamePage extends StatefulWidget {
  @override
  _BowlingGamePageState createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with TickerProviderStateMixin {
  final double containerWidth = 294.0;
  final double containerHeight = 650.0;
  final double pinScale = 1.8;

  late GameController gameController;
  bool showScoreboardInline = false; // 控制计分板和Score文本的互斥显示

  @override
  void initState() {
    super.initState();
    gameController = GameController(
      vsync: this,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      pinScale: pinScale,
    )..addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    setState(() {
      if (gameController.currentState == GameState.checkingPins) {
        showScoreboardInline = true;
      } else if (gameController.currentState == GameState.aiming ||
          gameController.currentState == GameState.frameEnd) {
        showScoreboardInline = false;
      }
    });
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showScoreOrBoard = gameController.currentState != GameState.title &&
        gameController.currentState != GameState.gameOver;

    return Scaffold(
      body: Stack(
        children: [
          _buildContent(), // 游戏主体

          // 记分板和Score文本互斥显示, 同时确保初始界面不显示
          if (showScoreOrBoard)
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              left: 0,
              right: 0,
              child: showScoreboardInline
                  ? ScoreboardWidget(scoreManager: gameController.scoreManager)
                  : Center(
                child: Text(
                  'Score: ${gameController.scoreManager.totalScore}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (gameController.currentState) {
      case GameState.title:
        return StartScreen(onStart: gameController.startGame);
      case GameState.gameOver:
        return GameOverScreen(
          totalScore: gameController.scoreManager.totalScore,
          onRestart: gameController.restartGame,
          onScoreboard: () => showScoreboard(context),
        );
      case GameState.pause:
        return Pause(onResume: gameController.resumeGame);
      default:
        return GameScreen(
          gameController: gameController,
          containerWidth: containerWidth,
          containerHeight: containerHeight,
          pinScale: pinScale,
        );
    }
  }

  void showScoreboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leaderboard'),
        content: ScoreboardWidget(scoreManager: gameController.scoreManager),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}