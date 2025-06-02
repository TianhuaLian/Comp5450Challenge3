import 'package:flutter/material.dart';
import './bowling_game.dart';

/// A very simple Flutter overlay that reads [game.currentState] and displays it.
class DebugOverlay extends StatefulWidget {
  final BowlingGame game;
  const DebugOverlay({Key? key, required this.game}) : super(key: key);

  @override
  _DebugOverlayState createState() => _DebugOverlayState();
}

/// A small button in the bottom-right that calls `game.nextState()`.
class NextButtonOverlay extends StatelessWidget {
  final BowlingGame game;
  const NextButtonOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      right: 32,
      child: ElevatedButton(
        onPressed: () {
          game.nextState();
        },
        child: const Text('Next State'),
      ),
    );
  }
}

class _DebugOverlayState extends State<DebugOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    // Rebuild whenever the game calls notifyListeners()
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stateName = widget.game.stateName;
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 20,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'State: $stateName',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
