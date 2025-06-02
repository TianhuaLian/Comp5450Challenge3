import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/bowling_game.dart';
import '../core/debug.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BowlingGame _game;

  @override
  void initState() {
    super.initState();
    _game = BowlingGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bowling Game')),
      body: GameWidget<BowlingGame>(
        game: _game,
        overlayBuilderMap: {
          'DebugText': (_, game) => DebugOverlay(game: game),
          'NextButton': (_, game) => NextButtonOverlay(game: game),
        },
        initialActiveOverlays: const ['DebugText', 'NextButton'],
      ),
    );
  }

  @override
  void dispose() {
    _game.onRemove();
    super.dispose();
  }
}
