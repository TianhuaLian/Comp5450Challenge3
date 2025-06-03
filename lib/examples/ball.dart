import 'package:flutter/material.dart';
import 'dart:math';

class Ball {
  Offset position;
  Offset velocity;
  final double radius;
  bool inMotion;
  final double containerWidth;
  final double containerHeight;

  Ball({
    required this.position,
    required this.radius,
    required this.containerWidth,
    required this.containerHeight,
    this.velocity = Offset.zero,
    this.inMotion = false,
  });

  void updatePosition() {
    if (!inMotion) return;

    position += velocity;

    // Boundary collision handling
    if (position.dx - radius <= 0) {
      position = Offset(radius, position.dy);
      velocity = Offset(-velocity.dx * 0.7, velocity.dy);
    } else if (position.dx + radius >= containerWidth) {
      position = Offset(containerWidth - radius, position.dy);
      velocity = Offset(-velocity.dx * 0.7, velocity.dy);
    }
  }

  bool isOutOfBounds() {
    return position.dy + radius <= 0 ||
        position.dy - radius >= containerHeight;
  }

  void reset(Offset newPosition) {
    position = newPosition;
    velocity = Offset.zero;
    inMotion = false;
  }

  void throwBall(double angle) {
    if (inMotion) return;

    inMotion = true;
    double radians = angle * pi / 180;
    velocity = Offset(sin(radians) * 8, -cos(radians) * 8);
  }
}