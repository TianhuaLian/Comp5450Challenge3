import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A stubbed ScoreManager that just tracks how many rolls have been made,
/// and after 4 rolls, declares the game over (to test state flow).
class ScoreManager extends Component {
  int _rollCount = 0;
  static const int _maxRollsBeforeGameOver = 4;

  bool get isGameOver => _rollCount >= _maxRollsBeforeGameOver;

  /// Called whenever the game registers a roll; here we just increment a counter.
  void registerRoll(int pinsKnocked) {
    _rollCount++;
    debugPrint('[Score] registerRoll($pinsKnocked) → roll $_rollCount');
  }

  /// Reset everything so we can start a new game
  void resetAll() {
    _rollCount = 0;
    debugPrint('[Score] resetAll()');
  }
}
