import 'dart:math';
import 'package:flutter/material.dart';
import 'pin_data.dart';

class PinManager {
  final TickerProvider vsync;
  final double pinScale;
  late final double singlePinWidth;
  late final double singlePinHeight;
  final double verticalSpacing = 20.0;
  final double horizontalSpacing = 50.0;
  final double startCenterX;

  List<PinData> pins = [];
  List<PinData> originalPins = [];

  final Random _random = Random();

  Random get random => _random;
  int get knockedDownPinsCount => pins.where((pin) => pin.isHit).length;

  PinManager({
    required this.vsync,
    required this.startCenterX,
    required this.pinScale,
  }) {
    singlePinWidth = 20 * pinScale;
    singlePinHeight = 40 * pinScale;
    resetPins();
  }

  void resetPins() {
    for (var pin in pins) {
      pin.dispose();
    }

    pins = [];
    originalPins = [];

    _addPinsInRow(count: 4, rowIndex: 0, baseTop: 100);
    _addPinsInRow(count: 3, rowIndex: 1, baseTop: 100);
    _addPinsInRow(count: 2, rowIndex: 2, baseTop: 100);
    _addPinsInRow(count: 1, rowIndex: 3, baseTop: 100);

    originalPins = List.from(pins.map((pin) => pin.copy()));
  }

  void _addPinsInRow({
    required int count,
    required int rowIndex,
    required double baseTop,
  }) {
    final double rowTotalWidth = (count - 1) * horizontalSpacing + singlePinWidth;
    final double firstPinLeftCenterX = startCenterX - (rowTotalWidth / 2) + (singlePinWidth / 2);
    final double bottomCenterY = baseTop + singlePinHeight / 2;

    for (int i = 0; i < count; i++) {
      AnimationController rotationController = AnimationController(
        vsync: vsync,
        duration: Duration(milliseconds: 300),
      );
      Animation<double> rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(
        parent: rotationController,
        curve: Curves.easeOut,
      ));

      AnimationController translationController = AnimationController(
        vsync: vsync,
        duration: Duration(milliseconds: 500),
      );
      Animation<Offset> translationAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(
        parent: translationController,
        curve: Curves.easeOutCubic,
      ));

      pins.add(PinData(
        position: Offset(firstPinLeftCenterX + (i * horizontalSpacing), bottomCenterY + (rowIndex * verticalSpacing)),
        rotationController: rotationController,
        rotationAnimation: rotationAnimation,
        translationController: translationController,
        translationAnimation: translationAnimation,
      ));
    }
  }

  void resetGame() {
    for (var pin in pins) {
      pin.dispose();
    }

    pins = List.from(originalPins.map((pinData) {
      return pinData.copyWithNewControllers(vsync: vsync);
    }));
  }

  void clearFallenPins() {
    pins.removeWhere((pin) => pin.isHit);
  }


  void dispose() {
    for (var pin in pins) {
      pin.dispose();
    }
    for (var pin in originalPins) {
      pin.dispose();
    }
  }
}