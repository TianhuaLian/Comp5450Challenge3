import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../core/bowling_game.dart';

/// Listen for taps on the background to simulate "ball in gutter".
class CollisionManager extends Component with HasGameRef<BowlingGame>, TapCallbacks {
  @override
  void onTapUp(TapUpEvent event) {
    // If the user taps the upper 40 px of the screen, simulate "ball in gutter"
    if (event.localPosition.y < 40) {
      debugPrint('[Collision] Simulate onBallInGutter()');
      gameRef.onBallInGutter();
    }
  }
}
