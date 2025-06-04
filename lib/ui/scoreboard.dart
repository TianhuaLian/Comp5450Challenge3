import 'package:flutter/material.dart';
import '../game/score/score_manager.dart';

class ScoreboardWidget extends StatelessWidget {
  final ScoreManager scoreManager;

  const ScoreboardWidget({Key? key, required this.scoreManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // 每行60，高度共120，可根据需要微调
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(), // 防止内部滚动
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,          // 5列，2行
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,      // 格子形状可调整
        ),
        itemBuilder: (context, index) {
          final frame = scoreManager.frames[index + 1];

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              border: Border.all(color: Colors.brown, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 投球结果
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _cell(frame.rollDisplay(1)),
                    const SizedBox(width: 2),
                    _cell(frame.rollDisplay(2)),
                    if (index == 9) ...[
                      const SizedBox(width: 2),
                      _cell(frame.rollDisplay(3)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // 只有投过这一局才显示累计分
                Text(
                  frame.hasPlayed ? '${frame.cumulativeScore}' : '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cell(String v) => SizedBox(
    width: 12,
    child: Text(
      v,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: (v == 'X' || v == '/') ? FontWeight.bold : FontWeight.normal,
        color: v == 'X' ? Colors.red : Colors.black,
      ),
    ),
  );
}
