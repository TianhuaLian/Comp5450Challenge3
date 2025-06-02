import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A stubbed PinManager that immediately reports "all pins at rest"
/// and lets you press anywhere (except on the ball) to simulate pins settled.
class PinManager extends Component {
  int _pinsKnockedThisRoll = 0;
  bool _collisionsEnabled = false;

  /// When called, countKnockedPinsThisRoll() returns this value.
  int countKnockedPinsThisRoll() => _pinsKnockedThisRoll;

  /// We’ll always say "all pins at rest" so the game can immediately move on.
  bool allPinsAtRest() {
    return true;
  }

  /// Stub: Enable pin collisions (not actually used here)
  void enablePinCollisions() {
    _collisionsEnabled = true;
    debugPrint('[Pins] enablePinCollisions()');
  }

  /// Stub: reset all pins to an upright state (no real visuals)
  void resetPins({required bool fullRack}) {
    _collisionsEnabled = false;
    _pinsKnockedThisRoll = 0;
    debugPrint('[Pins] resetPins(fullRack: $fullRack)');
  }

  /// A method to simulate that N pins fell. You can call this from console
  /// or wire a tap in the real layout. For now, assume 5 pins per roll:
  void simulateFivePinsFallen() {
    _pinsKnockedThisRoll = 5;
    debugPrint('[Pins] simulateFivePinsFallen() → next count = 5');
  }
}
