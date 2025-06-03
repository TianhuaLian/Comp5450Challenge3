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

    for (int i = 1; i <= 10; i++) {
      final f = frames[i];


      int r1 = f.roll1 ?? 0;
      int r2 = f.roll2 ?? 0;
      int r3 = f.roll3 ?? 0;

      if (i == 10) {
        f.score = r1 + r2 + r3;
        continue;
      }

      if (f.isStrike) {

        final next = frames[i + 1];
        int next1 = next.roll1 ?? 0;
        int next2;
        if (next.isStrike && i < 9) {

          final nextNext = frames[i + 2];
          next2 = nextNext.roll1 ?? 0;
        } else {
          next2 = next.roll2 ?? 0;
        }
        f.score = 10 + next1 + next2;
      }

      else if (f.isSpare) {
        final next = frames[i + 1];
        int next1 = next.roll1 ?? 0;
        f.score = 10 + next1;
      }

      else {
        f.score = r1 + r2;
      }
    }
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
