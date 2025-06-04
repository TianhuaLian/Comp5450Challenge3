import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final int totalScore;
  final VoidCallback onRestart;
  final VoidCallback onScoreboard;

  const GameOverScreen({
    super.key,
    required this.totalScore,
    required this.onRestart,
    required this.onScoreboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text('Final Score: $totalScore',
                style: TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 120),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orangeAccent,
              ), //Replay
              child: Text(
                'Replay',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onScoreboard,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orangeAccent,
              ), //Scoreboard
              child: Text(
                'Scoreboard',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
