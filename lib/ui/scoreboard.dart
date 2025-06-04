import 'package:flutter/material.dart';
import '../game/score/score_manager.dart';

class ScoreboardWidget extends StatelessWidget {
  final ScoreManager scoreManager;

  const ScoreboardWidget({Key? key, required this.scoreManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // 60 per row
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(), // Prevent scrolling
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,          // 5 frames per row, 2 rows
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,      // Aspect ratio for each cell
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
                // Show score only if the frame has been played
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

    List<String> scoreToString(int frameCount, Frame frame) {
    List<int?> scores = frame.scores; // will always has 3 entries
    if (frameCount != 10) {
      if (scores[0] == 10){ // strike
        return ['', _scoreToSymbol(scores[0])];
      } else { // spare and normal
        return [
          _scoreToSymbol(scores[0]),
          ((scores[0] ?? 0) + (scores[1] ?? 0) == 10) ? '/' : _scoreToSymbol(scores[1])
        ];
      }
    } else {
      String roll1 = _scoreToSymbol(scores[0]);
      String roll2 = _scoreToSymbol(scores[1]);
      String roll3 = _scoreToSymbol(scores[2]);

      if (scores[0]! != 10 && ((scores[0] ?? 0) + (scores[1] ?? 0)) == 10) {
        roll2 = "/";
      }

      if (scores[1]! != 10 && ((scores[1] ?? 0) + (scores[2] ?? 0)) == 10) {
        roll3 = "/";
      }

      return [roll1, roll2, roll3];
    }
  }

  String _scoreToSymbol(int? score) {
    if (score == null) {
        return ''; // not bowled
      } else if (score == 10) {
        return 'X'; // strike, spares are handled separately
      }else if(score == 0){
        return '-'; // miss
      } else {
        return score.toString(); // Normal score
      }
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
