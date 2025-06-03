import 'package:flutter/material.dart';

class PinData {
  final Offset position;
  double rotation;
  bool isHit;
  bool isFalling;
  bool canCauseChainReaction;
  Offset translation;

  AnimationController? rotationController;
  Animation<double>? rotationAnimation;
  AnimationController? translationController;
  Animation<Offset>? translationAnimation;

  PinData({
    required this.position,
    this.rotation = 0.0,
    this.isHit = false,
    this.isFalling = false,
    this.canCauseChainReaction = false,
    this.translation = Offset.zero,
    required this.rotationController,
    required this.rotationAnimation,
    required this.translationController,
    required this.translationAnimation,
  });

  PinData copy() {
    return PinData(
      position: position,
      rotation: rotation,
      isHit: isHit,
      isFalling: isFalling,
      canCauseChainReaction: canCauseChainReaction,
      translation: translation,
      rotationController: rotationController,
      rotationAnimation: rotationAnimation,
      translationController: translationController,
      translationAnimation: translationAnimation,
    );
  }

  PinData copyWithNewControllers({required TickerProvider vsync}) {
    AnimationController newRotationController = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: 300),
    );
    Animation<double> newRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(
      parent: newRotationController,
      curve: Curves.easeOut,
    ));

    AnimationController newTranslationController = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: 500),
    );
    Animation<Offset> newTranslationAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(
      parent: newTranslationController,
      curve: Curves.easeOutCubic,
    ));

    return PinData(
      position: position,
      rotation: 0,
      isHit: false,
      isFalling: false,
      canCauseChainReaction: false,
      translation: Offset.zero,
      rotationController: newRotationController,
      rotationAnimation: newRotationAnimation,
      translationController: newTranslationController,
      translationAnimation: newTranslationAnimation,
    );
  }

  void dispose() {
    rotationController?.dispose();
    translationController?.dispose();
  }
}
