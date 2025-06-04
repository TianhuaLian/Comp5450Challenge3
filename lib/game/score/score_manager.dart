class ScoreManager {
  final List<Frame> frames = List.generate(11, (index) => Frame());

  int get totalScore {
    return frames.sublist(1, 11).fold(0, (sum, frame) => sum + frame.score);
  }

  void updateScore(int frame, int roll, int pins) {
    frames[frame].updateRoll(roll, pins);
    _calculateScores();
  }

  bool isStrike(int frame) => frames[frame].isStrike;
  bool isSpare(int frame) => frames[frame].isSpare;

  // Determine if the game is over (it's over when the 10th inning is played)
  bool get isGameOver {
    final f10 = frames[10];
    // First roll
    if (f10.roll1 == null) return false;
    // Over in two rolls if the first roll isn't a strike or a spare,
    if (!f10.isStrike && !f10.isSpare) {
      return f10.roll2 != null;
    }
    // strike/spare till the third ball
    return f10.roll2 != null && f10.roll3 != null;
  }

  void _calculateScores() {
    int runningTotal = 0;
    for (int i = 1; i <= 10; i++) {
      final f = frames[i];

      int r1 = f.roll1 ?? 0;
      int r2 = f.roll2 ?? 0;
      int r3 = f.roll3 ?? 0;

      if (i == 10) {
        f.score = r1 + r2 + r3;
      } else if (f.isStrike) {
        final next = frames[i + 1];
        int next1 = next.roll1 ?? 0;
        int next2 = next.isStrike && i < 9 ? (frames[i + 2].roll1 ?? 0) : (next.roll2 ?? 0);
        f.score = 10 + next1 + next2;
      } else if (f.isSpare) {
        f.score = 10 + (frames[i + 1].roll1 ?? 0);
      } else {
        f.score = r1 + r2;
      }

      // Only update cumulative score if the frame has been played
      if (f.hasPlayed) {
        runningTotal += f.score;
        f.cumulativeScore = runningTotal;
      } else {
        f.cumulativeScore = 0;
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
  int cumulativeScore = 0;

  bool get isStrike => roll1 == 10;
  bool get isSpare => (roll1 ?? 0) + (roll2 ?? 0) == 10 && roll1 != 10;
  bool get hasPlayed => roll1 != null || roll2 != null || roll3 != null;

  // For displaying
  String rollDisplay(int rollNumber) {
    if (rollNumber == 1) {
      return roll1 == 10 ? 'X' : (roll1 ?? '-').toString();
    } else if (rollNumber == 2) {
      if (isStrike) return '-';
      if (isSpare) return '/';
      return (roll2 ?? '-').toString();
    } else if (rollNumber == 3 && (isSpare || isStrike)) {
      return roll3 == 10 ? 'X' : (roll3 ?? '-').toString();
    }
    return '-';
  }

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
    cumulativeScore = 0;
  }
}
