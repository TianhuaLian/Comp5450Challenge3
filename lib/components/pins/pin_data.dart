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
    required this.rotation,
    required this.isHit,
    required this.isFalling,
    required this.canCauseChainReaction,
    required this.translation,
    this.rotationController,
    this.rotationAnimation,
    this.translationController,
    this.translationAnimation,
  });

  PinData copyWith({
    Offset? position,
    double? rotation,
    bool? isHit,
    bool? isFalling,
    bool? canCauseChainReaction,
    Offset? translation,
  }) {
    return PinData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      isHit: isHit ?? this.isHit,
      isFalling: isFalling ?? this.isFalling,
      canCauseChainReaction: canCauseChainReaction ?? this.canCauseChainReaction,
      translation: translation ?? this.translation,
      rotationController: null,
      rotationAnimation: null,
      translationController: null,
      translationAnimation: null,
    );
  }

  void dispose() {
    rotationController?.dispose();
    translationController?.dispose();
  }
}


class PinImage extends StatelessWidget {
  final double scale;

  const PinImage({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://i.imgur.com/cTVjcFA.png',
      width: 20 * scale,
      height: 40 * scale,
      fit: BoxFit.contain,
    );
  }
}