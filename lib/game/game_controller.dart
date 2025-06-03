import 'dart:math';
import 'package:flutter/material.dart';
import 'game_state.dart';
import '../game/pins/pin_manager.dart';
import '../game/pins/pin_data.dart';
import '/examples/ball.dart';
import '../score/score_manager.dart';

class GameController with ChangeNotifier {
  final TickerProvider vsync;
  final double containerWidth;
  final double containerHeight;
  final double pinScale;

  late Ball ball;
  late PinManager pinManager;
  late ScoreManager scoreManager;
  late AnimationController ballAnimationController;

  // Current game state
  GameState _currentState = GameState.title;
  GameState get currentState => _currentState;

  int _currentFrame = 1;
  int _currentRoll = 1;
  double _ballAngle = 0.0;
  
  bool get ballInMotion => ball.inMotion;
  int get knockedDownPinsCount => pinManager.knockedDownPinsCount;
  int get totalScore => scoreManager.totalScore;
  int get currentFrame => _currentFrame;
  int get currentRoll => _currentRoll;

  double get ballAngle => _ballAngle;
  set ballAngle(double value) {
    _ballAngle = value;
    notifyListeners();
  }

  GameController({
    required this.vsync,
    required this.containerWidth,
    required this.containerHeight,
    required this.pinScale,
  }) {
    _init();
  }

  void _init() {
    // Initialize PinManager instance
    pinManager = PinManager(
      vsync: vsync,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      pinScale: pinScale,
    );

    // Initialize ScoreManager instance
    scoreManager = ScoreManager();

    // Initialize Ball instance
    ball = Ball(
      position: Offset(containerWidth / 2, containerHeight - 50),
      radius: 20.0,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
    );

    ballAnimationController = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: 16),
    )..addListener(_updateGame);
  }

  void startGame() {
    _currentState = GameState.aiming;
    _currentFrame = 1;
    _currentRoll = 1;
    resetGame();
    notifyListeners();
  }

  void pauseGame() {
    if (_currentState == GameState.rolling) {
      ballAnimationController.stop();
    }
    _currentState = GameState.pause;
    notifyListeners();
  }

  void resumeGame() {
    if (_currentState == GameState.pause) {
      _currentState = GameState.aiming;
      if (ball.inMotion) {
        ballAnimationController.repeat();
        _currentState = GameState.rolling;
      }
      notifyListeners();
    }
  }

  void throwBall() {
    if (_currentState != GameState.aiming) return;

    ball.throwBall(_ballAngle);
    ballAnimationController.repeat();
    _currentState = GameState.rolling;
    notifyListeners();
  }

  /// Resets the game state, including the ball and pin states.
  void resetGame() {
    pinManager.resetGame();
    ball.reset(Offset(containerWidth / 2, containerHeight - 50));
    ballAnimationController.stop();
    ballAnimationController.reset();
  }

  /// Restarts the game and starting a new game.
  void restartGame() {
    scoreManager.reset();
    startGame();
  }

  void _updateGame() {
    if (_currentState != GameState.rolling) return;

    ball.updatePosition();

    if (ball.isOutOfBounds()) {
      _handleBallStop();
    }

    // Pin collisions
    for (int i = 0; i < pinManager.pins.length; i++) {
      if (!pinManager.pins[i].isHit) {
        final double pinWidth = pinManager.singlePinWidth;
        final double pinHeight = pinManager.singlePinHeight;

        final Rect pinRect = Rect.fromLTWH(
          pinManager.pins[i].position.dx - pinWidth / 2,
          pinManager.pins[i].position.dy - pinHeight,
          pinWidth,
          pinHeight,
        );

        final Rect ballRect = Rect.fromCircle(
          center: ball.position,
          radius: ball.radius,
        );

        if (ballRect.overlaps(pinRect)) {
          final double relativeHitPosition = ball.position.dx - pinManager.pins[i].position.dx;
          double targetRotationAngle;
          if (pinManager.random.nextBool()) {
            targetRotationAngle = -pi / 2;
          } else {
            targetRotationAngle = pi / 2;
          }

          double displacementX = 0;
          double displacementY = - (pinManager.random.nextDouble() * 30 + 30);

          if (targetRotationAngle < 0) {
            displacementX = - (pinManager.random.nextDouble() * 15 + 15);
          } else {
            displacementX = pinManager.random.nextDouble() * 15 + 15;
          }

          _startPinAnimation(
              pinManager.pins[i],
              targetRotationAngle,
              Offset(displacementX, displacementY),
              canCauseChain: true
          );

          ball.velocity = ball.velocity * 0.8;
        }
      }
    }

    // Chain reactions
    for (int i = 0; i < pinManager.pins.length; i++) {
      final pin = pinManager.pins[i];
      if (pin.isFalling &&
          pin.rotationController!.isAnimating &&
          pin.canCauseChainReaction) {

        final double pinWidth = pinManager.singlePinWidth;
        final double pinHeight = pinManager.singlePinHeight;
        final double collisionZoneWidth = pinWidth * 0.02;
        final double collisionZoneHeight = pinHeight * 0.05;

        final Offset fallingPinCollisionCenter = pin.position + pin.translationAnimation!.value;
        final Rect fallingPinCollisionRect = Rect.fromCenter(
          center: fallingPinCollisionCenter,
          width: collisionZoneWidth,
          height: collisionZoneHeight,
        );

        for (int j = 0; j < pinManager.pins.length; j++) {
          if (i == j || pinManager.pins[j].isHit) continue;

          final standingPin = pinManager.pins[j];
          final Rect standingPinRect = Rect.fromLTWH(
            standingPin.position.dx - pinWidth / 2,
            standingPin.position.dy - pinHeight,
            pinWidth,
            pinHeight,
          );

          if (fallingPinCollisionRect.overlaps(standingPinRect)) {
            double targetRotationAngle;
            final double collisionX = standingPin.position.dx;
            final double fallingPinCurrentX = fallingPinCollisionCenter.dx;

            if (fallingPinCurrentX < collisionX) {
              targetRotationAngle = pi / 2;
            } else {
              targetRotationAngle = -pi / 2;
            }

            double displacementX = 0;
            double displacementY = - (pinManager.random.nextDouble() * 20 + 20);

            if (targetRotationAngle < 0) {
              displacementX = - (pinManager.random.nextDouble() * 10 + 10);
            } else {
              displacementX = pinManager.random.nextDouble() * 10 + 10;
            }

            _startPinAnimation(
                standingPin,
                targetRotationAngle,
                Offset(displacementX, displacementY),
                canCauseChain: false
            );
            break;
          }
        }
      }
    }
  }

  void _handleBallStop() {
    ball.reset(Offset(containerWidth / 2, containerHeight - 50));
    ballAnimationController.stop();
    ballAnimationController.reset();

    // Update score
    final pinsKnocked = pinManager.knockedDownPinsCount;
    scoreManager.updateScore(_currentFrame, _currentRoll, pinsKnocked);

    _currentState = GameState.checkingPins;
    notifyListeners();
  }

  void clearFallenPins() {
    if (_currentState != GameState.checkingPins) return;

    pinManager.clearFallenPins();

    // Determine next state
    if (_currentRoll == 1 && !scoreManager.isStrike(_currentFrame)) {
      // Second roll in same frame
      _currentRoll = 2;
      _currentState = GameState.aiming;
    } else {
      // Frame complete
      _currentState = GameState.frameEnd;
    }

    notifyListeners();
  }

  void nextFrame() {
    if (_currentState != GameState.frameEnd) return;

    if (_currentFrame == 10) {
      if (scoreManager.isStrike(10) || scoreManager.isSpare(10)) {
        // Allow for third roll
        _currentRoll = 3;
        resetGame();
        _currentState = GameState.aiming;
      } else {
        _currentState = GameState.gameOver;
      }
    } else {
      _currentFrame++;
      _currentRoll = 1;
      resetGame();
      _currentState = GameState.aiming;
    }

    notifyListeners();
  }

  void _startPinAnimation(PinData pin, double targetRotationAngle, Offset targetTranslation,
      {required bool canCauseChain}) {
    pin.isHit = true;
    pin.isFalling = true;
    pin.canCauseChainReaction = canCauseChain;

    pin.rotationAnimation = Tween<double>(
      begin: pin.rotationAnimation!.value,
      end: targetRotationAngle,
    ).animate(CurvedAnimation(
      parent: pin.rotationController!,
      curve: Curves.easeOut,
    ));
    pin.rotationController!.forward(from: 0.0);

    pin.translationAnimation = Tween<Offset>(
      begin: pin.translationAnimation!.value,
      end: targetTranslation,
    ).animate(CurvedAnimation(
      parent: pin.translationController!,
      curve: Curves.easeOutCubic,
    ));
    pin.translationController!.forward(from: 0.0);

    pin.rotationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        pin.isFalling = false;
      }
    });
  }

  void dispose() {
    ballAnimationController.dispose();
    pinManager.dispose();
    super.dispose();
  }

  void showScoreboard() {
    debugPrint('[GameController] Show Scoreboard');
  }
}