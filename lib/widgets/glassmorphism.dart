import 'dart:ui';

import 'package:flutter/material.dart';

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final bool displayShadow;
  const GlassMorphism(
      {Key? key,
      required this.child,
      required this.borderRadius,
      this.displayShadow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            blurRadius: 24,
            spreadRadius: 16,
            color: Colors.black.withOpacity(displayShadow ? 0.1 : 0.0),
          )
        ]),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 40.0,
              sigmaY: 40.0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}