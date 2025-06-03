// class ScoreManager {
//   int _totalScore = 0;
//
//   int get totalScore => _totalScore;
//
//   void updateScore(int knockedDownCount) {
//     _totalScore += knockedDownCount;
//   }
//
//   void reset() {
//     _totalScore = 0;
//   }
// }
/// 保龄球计分器（10-Pin，最多 12 次 Strike）
class ScoreManager {
  final List<int> _rolls = [];   // 每一次投球实际击倒的瓶数（0-10）

  /// 记录一次投球
  void recordRoll(int pinsKnocked) {
    // 防御：合法范围 0-10
    _rolls.add(pinsKnocked.clamp(0, 10));
  }

  /// 重置整局
  void reset() => _rolls.clear();

  /// 当前总分（随时调用）
  int get totalScore => _calculateScore();

  // --------------------------------------------------------------------------
  // 私有：根据官方规则计算前 10 Frame 的分数
  // --------------------------------------------------------------------------
  int _calculateScore() {
    int score = 0;
    int rollIndex = 0;

    for (int frame = 0; frame < 10 && rollIndex < _rolls.length; frame++) {
      // Strike
      if (_rolls[rollIndex] == 10) {
        score += 10 + _nextTwoBalls(rollIndex);
        rollIndex += 1;               // Strike 只占 1 投
      }
      // Spare
      else if (_isSpare(rollIndex)) {
        score += 10 + _nextBall(rollIndex + 2);
        rollIndex += 2;
      }
      // 普通
      else {
        score += _rolls[rollIndex] + _nextBall(rollIndex + 1);
        rollIndex += 2;
      }
    }
    return score;
  }

  // --- 帮助函数 -------------------------------------------------------------
  bool _isSpare(int idx) =>
      idx + 1 < _rolls.length && _rolls[idx] + _rolls[idx + 1] == 10;

  int _nextBall(int idx) => idx < _rolls.length ? _rolls[idx] : 0;

  int _nextTwoBalls(int idx) =>
      _nextBall(idx + 1) + _nextBall(idx + 2);
}
