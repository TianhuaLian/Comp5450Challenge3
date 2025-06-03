import 'package:flutter/material.dart';

class ScoreManager {
  final List<Frame> frames = List.generate(11, (index) => Frame());

  int get totalScore {
    return frames.sublist(1,11).fold(0, (sum, frame) => sum + frame.score);
  }

  void updateScore(int frame, int roll, int pins) {
    frames[frame].updateRoll(roll, pins);
    _calculateScores();
  }

  bool isStrike(int frame) => frames[frame].isStrike;
  bool isSpare(int frame) => frames[frame].isSpare;

  void _calculateScores() {
    debugPrint('[Game] Calculating Scores......');
    // Implement bowling scoring rules here
    // This would handle strikes, spares, and frame accumulation
  }

  void reset() {
    for (var frame in frames) {
      frame.reset();
    }
  }
}

class Frame {
  int? roll1;
  int? roll2;
  int? roll3; // For 10th frame
  int score = 0;

  bool get isStrike => roll1 == 10;
  bool get isSpare => (roll1 ?? 0) + (roll2 ?? 0) == 10 && !isStrike;

  void updateRoll(int roll, int pins) {
    if (roll == 1) roll1 = pins;
    if (roll == 2) roll2 = pins;
    if (roll == 3) roll3 = pins;
  }

  void reset() {
    roll1 = null;
    roll2 = null;
    roll3 = null;
    score = 0;
  }
}
