import 'package:flutter/material.dart';

class AuthBackgroundImage extends StatelessWidget {
  final String imagePath;
  final double verticalShift;
  final BoxFit fit;
  final Alignment alignment;

  const AuthBackgroundImage({
    super.key,
    required this.imagePath,
    this.verticalShift = 0,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, verticalShift),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            fit: fit,
            alignment: alignment,
          ),
        ),
      ),
    );
  }
}

