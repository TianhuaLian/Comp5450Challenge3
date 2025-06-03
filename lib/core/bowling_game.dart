import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game_state.dart';
import '../examples/ball.dart';
import '../examples/collision_manager.dart';
import '../examples/pin_manager.dart';
import '../examples/score_manager.dart';


class BowlingGame extends FlameGame with HasCollisionDetection, ChangeNotifier {
  // Current game state
  GameState _state = GameState.Title;

  GameState get currentState => _state;

  //temporary getter to expose state name as a string
  String get stateName =>
      _state
          .toString()
          .split('.')
          .last;

  // Subsystem references
  //late BallComponent ball;
  late CollisionManager collisionSystem;
  late PinManager pinManager;
  late ScoreManager scoreManager;

  // Pins knocked down in the current roll
  int _pinsKnockedThisRoll = 0;

  @override
  Future<void> onLoad() async {
    // Initialize subsystems
    //ball = BallComponent();
    collisionSystem = CollisionManager();
    pinManager = PinManager();
    scoreManager = ScoreManager();

    // Register subsystems with the FlameGame
    //await add(ball);
    await add(collisionSystem);
    await add(pinManager);
    await add(scoreManager);

    // Initially pause the game; show Title overlay via main.dart
    pauseEngine();
    _logStateChange();
    notifyListeners();
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (_state) {
      case GameState.Title:
      // Waiting for user to tap "Start"
        break;

      case GameState.Aiming:
      // Waiting for user input (no extra per-frame logic)
        break;

      case GameState.Rolling:
      // Let subsystems (ball, collision) handle movement and collisions
        break;

      case GameState.CheckingPins:
      // Once ball is at rest, check if all pins have settled
        if (pinManager.allPinsAtRest()) {
          int knocked = pinManager.countKnockedPinsThisRoll();
          onPinsSettled(knocked);
        }
        break;

      case GameState.FrameEnd:
      // Waiting for user to trigger next frame or auto-advance
        break;

      case GameState.GameOver:
      // Game is over; waiting for "Play Again"
        break;
    }
  }


  // === State Transition Methods ===

  /// Call this when the player taps "Start" on the Title screen
  void toAiming() {
    _state = GameState.Aiming;
    resumeEngine();
    _logStateChange();
    notifyListeners();
    // Show aiming UI overlay (handled by main.dart via overlays)
  }

  /// Transition to Rolling state when the ball is launched
  void toRolling() {
    _state = GameState.Rolling;
    _logStateChange();
    notifyListeners();
    // Hide aiming UI; subsystems take over
  }

  /// Transition to CheckingPins state once ball comes to rest
  void toCheckingPins() {
    _state = GameState.CheckingPins;
    _logStateChange();
    notifyListeners();
    // PinManager will be allowed to report knocked pins now
  }

  /// Transition to FrameEnd after scoring this roll
  void toFrameEnd() {
    _state = GameState.FrameEnd;
    _logStateChange();
    notifyListeners();
    // Show "Next Frame" button overlay (handled by main.dart)
  }

  /// Transition to GameOver when all frames are complete
  void toGameOver() {
    _state = GameState.GameOver;
    _logStateChange();
    notifyListeners();
    // Show "Game Over" overlay (handled by main.dart)
  }

  // === Event Handlers / Callbacks ===

  /// Called by BallComponent when its velocity drops to zero
  void onBallAtRest() {
    debugPrint('[Game] onBallAtRest()');
    if (_state == GameState.Rolling) {
      toCheckingPins();
    }
  }

  /// Called when the ball falls into the gutter
  void onBallInGutter() {
    debugPrint('[Game] onBallInGutter()');
    if (_state == GameState.Rolling) {
      // No pins knocked; treat as zero
      onPinsSettled(0);
    }
  }

  /// Called when PinManager reports that pins have settled
  void onPinsSettled(int knockedCount) {
    debugPrint('[Game] onPinsSettled($knockedCount)');
    // Store knocked count for this roll
    _pinsKnockedThisRoll = knockedCount;

    // Register roll with ScoreManager
    scoreManager.registerRoll(_pinsKnockedThisRoll);

    // Check if the game is over
    if (scoreManager.isGameOver) {
      toGameOver();
      return;
    }

    // Otherwise, proceed to FrameEnd
    toFrameEnd();
  }

  /// Called (from UI overlay) when user taps "Next Frame"
  void onNextFrame() {
    debugPrint('[Game] onNextFrame()');
    // Reset pins and ball for the next frame
    // TODO: Determine fullRack vs. spare/partial logic
    pinManager.resetPins(fullRack: true);
    //ball.resetPosition();

    // Clear per-roll counter
    _pinsKnockedThisRoll = 0;

    // Return to Aiming
    toAiming();
  }

  /// Called when user taps "Play Again" on GameOver screen
  void onRestart() {
    debugPrint('[Game] onRestart()');
    // Reset ScoreManager
    scoreManager.resetAll();

    // Reset pins and ball
    pinManager.resetPins(fullRack: true);
    //ball.resetPosition();

    // Clear any overlays and show Title
    pauseEngine();
    _state = GameState.Title;
    _logStateChange();
    notifyListeners();
  }

  void _logStateChange() {
    debugPrint('[Game] State → $_state');
  }

  // A helper that cycles through the enum in order.
  void nextState() {
    switch (_state) {
      case GameState.Title:
        toAiming();
        break;
      case GameState.Aiming:
        toRolling();
        break;
      case GameState.Rolling:
        onBallAtRest(); // simulates “ball is at rest” → CheckingPins
        break;
      case GameState.CheckingPins:
      // immediately treat pins as settled with 0 knocked
        onPinsSettled(0);
        break;
      case GameState.FrameEnd:
        onNextFrame(); // simulates “Next Frame” tap
        break;
      case GameState.GameOver:
        onRestart(); // simulates “Play Again”
        break;
    }
  }
}