import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import '../core/bowling_game.dart';

/// Simply occupies a circle on screen.
/// Tapping it will simulate "ball at rest" (no physics).
class BallComponent extends CircleComponent with TapCallbacks, HasGameReference<BowlingGame> {
  BallComponent() : super(radius: 24.0, paint: Paint()..color = Colors.white);
  late BowlingGame gameRef;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameRef = findGame() as BowlingGame;
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 2);
  }

  /// Handle a tap on the ball: immediately tell the game "ball is at rest"
  @override
  bool onTapDown(TapDownEvent event) {
    debugPrint('[Ball] onTapDown → calling game.onBallAtRest()');
    gameRef.onBallAtRest();
    return true;
  }

  /// Provide a stub for resetPosition (used by core)
  void resetPosition() {
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 2);
    debugPrint('[Ball] resetPosition()');
  }
}
