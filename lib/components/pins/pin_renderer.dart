import 'package:flutter/material.dart';
import 'pin_data.dart';

class PinRenderer extends StatelessWidget {
  final PinData pin;
  final double pinWidth;
  final double pinHeight;
  final double pinScale;

  const PinRenderer({
    required this.pin,
    required this.pinWidth,
    required this.pinHeight,
    required this.pinScale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pin.rotationAnimation!,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: pin.translationAnimation!,
          builder: (context, child) {
            final double baseLeft = pin.position.dx - pinWidth / 2;
            final double baseTop = pin.position.dy - pinHeight;
            final double currentLeft = baseLeft + pin.translationAnimation!.value.dx;
            final double currentTop = baseTop + pin.translationAnimation!.value.dy;

            return Positioned(
              top: currentTop,
              left: currentLeft,
              child: Transform.rotate(
                angle: pin.rotationAnimation!.value,
                alignment: Alignment.bottomCenter,
                child: Image.network(
                  'https://i.imgur.com/cTVjcFA.png',
                  width: 20 * pinScale,
                  height: 40 * pinScale,
                  fit: BoxFit.contain,
                )
              ),
            );
          },
        );
      },
    );
  }
}
