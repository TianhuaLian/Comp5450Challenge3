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
                /// Display Score
                _displayScore(index + 1, frame),
                const SizedBox(height: 4),
                // Show score only if the frame has been played
                Text(
                  frame.hasPlayed ? '${frame.cumulativeScore}' : '',
                  style: TextStyle(
                    fontSize: 18,
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

  Widget _displayScore(int frameCount, Frame frame){
    List<String> writtenScore = scoreToString(frameCount, frame);
    return (
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: (frameCount != 10) ? Container() : _borderedBox(writtenScore[0], BoxPosition.left)
            ),
            Expanded(
              child: _borderedBox(writtenScore[1], (frameCount != 10) ? BoxPosition.left : BoxPosition.middle)
            ),
            Expanded(
              child: _borderedBox(writtenScore[2], BoxPosition.right)
            )
          ]
        )
      )
    );
  }

  Widget _borderedBox(String score, BoxPosition boxPosition){
    return (
      DecoratedBox(
        decoration: BoxDecoration(
          border: BoxBorder.fromLTRB(
            top: BorderSide(
              color: Colors.black,
              width: 1
            ),
            bottom:BorderSide(
              color: Colors.black,
              width: 1
            ),
            left:BorderSide(
              color: Colors.black,
              width: (boxPosition == BoxPosition.left) ? 1 : 0.5
            ),
            right: BorderSide(
              color: Colors.black,
              width: (boxPosition == BoxPosition.right) ? 1 : 0.5
              ),
          )
        ),
        child: Text(
          score,
          style: TextStyle(
            fontSize: 16,
            fontWeight: (score == 'X' || score == '/') ? FontWeight.bold : FontWeight.normal,
            color: score == "X" ? Colors.red : Colors.black),
          textAlign: TextAlign.center
        )
      )
    );
  }

    List<String> scoreToString(int frameCount, Frame frame) {
    List<int?> scores = frame.scores; // will always has 3 entries
    if (frameCount != 10) {
      if (scores[0] == 10){ // strike
        return ['', '', _scoreToSymbol(scores[0])];
      } else { // spare and normal
        return [
          '',
          _scoreToSymbol(scores[0]),
          ((scores[0] ?? 0) + (scores[1] ?? 0) == 10) ? '/' : _scoreToSymbol(scores[1])
        ];
      }
    } else {
      String roll1 = _scoreToSymbol(scores[0]);
      String roll2 = _scoreToSymbol(scores[1]);
      String roll3 = _scoreToSymbol(scores[2]);

      if ((scores[0]?? 0) != 10 && ((scores[0] ?? 0) + (scores[1] ?? 0)) == 10) {
        roll2 = "/"; // first two rolls result in spare
      }

      if ((scores[1] ?? 0) != 10 && ((scores[1] ?? 0) + (scores[2] ?? 0)) == 10) {
        roll3 = "/"; // first roll is strike, and the next two is spare
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

enum BoxPosition {left, middle, right}