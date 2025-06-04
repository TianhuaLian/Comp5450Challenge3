import 'package:flutter/material.dart';
import 'dart:math';

class Ball {
  Offset position;
  Offset velocity;
  final double radius;
  bool inMotion;
  final double containerWidth;
  final double containerHeight;
  bool inGutter = false;

  Ball({
    required this.position,
    required this.radius,
    required this.containerWidth,
    required this.containerHeight,
    this.velocity = Offset.zero,
    this.inMotion = false,
  });

  void updatePosition(bool enableBounce) {
    if (!inMotion) return;

    position += velocity;

    // Handle side collisions
    if (!inGutter) {
      if (position.dx - radius <= 0) {
        _handleSideCollision(0, enableBounce);
      } else if (position.dx + radius >= containerWidth) {
        _handleSideCollision(containerWidth, enableBounce);
      }
    }
  }

  void _handleSideCollision(double boundaryX, bool enableBounce) {
    if (enableBounce) {
      // Bounce behavior
      position = Offset(
          boundaryX == 0 ? radius : containerWidth - radius,
          position.dy
      );
      velocity = Offset(-velocity.dx * 0.7, velocity.dy);
    } else {
      // Gutter behavior
      inGutter = true;
      velocity = Offset(0, -velocity.dy.abs() + 3.0);
      velocity = Offset(velocity.dx , velocity.dy);
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
    inGutter = false;
  }

  void throwBall(double angle) {
    if (inMotion) return;

    inMotion = true;
    double radians = angle * pi / 180;
    velocity = Offset(sin(radians) * 8, -cos(radians) * 8);
  }
}