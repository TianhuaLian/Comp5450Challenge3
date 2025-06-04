import 'package:flutter/material.dart';
import '../game/game_controller.dart';

class SettingsMenu extends StatelessWidget {
  final GameController gameController;

  const SettingsMenu({required this.gameController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wall Bounce:'),
                  Switch(
                    value: gameController.enableBounce,
                    onChanged: (value) {
                      gameController.enableBounce = value;
                    },
                  ),
                ],
              ),
              Text(
                gameController.enableBounce
                    ? 'Ball will bounce off walls'
                    : 'Ball will fall into gutter',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
