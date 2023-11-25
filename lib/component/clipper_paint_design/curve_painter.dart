import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();

    path.lineTo(0, size.height * 0.75);

    path.quadraticBezierTo(size.width * 0.1, size.height * 0.7, size.width * 0.17, size.height * 0.9);

    path.quadraticBezierTo(size.width * 0.2, size.height, size.width * 0.25, size.height * 0.9);

    path.quadraticBezierTo(size.width * 0.4, size.height * 0.4, size.width * 0.4, size.height * 0.7);

    path.quadraticBezierTo(size.width * 0.6, size.height * 0.85, size.width * 0.65, size.height * 0.65);

    path.quadraticBezierTo(size.width * 0.7, size.height * 0.9, size.width, 0);
    path.close();

    paint.color = Colors.blue.shade100;
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, size.height * 0.5);

    path.quadraticBezierTo(size.width * 0.1, size.height * 0.8, size.width * 0.15, size.height * 0.6);

    path.quadraticBezierTo(size.width * 0.2, size.height * 0.45, size.width * 0.27, size.height * 0.6);

    path.quadraticBezierTo(size.width * 0.45, size.height, size.width * 0.5, size.height * 0.8);

    path.quadraticBezierTo(size.width * 0.55, size.height * 0.45, size.width * 0.75, size.height * 0.75);

    path.quadraticBezierTo(size.width * 0.85, size.height * 0.93, size.width, size.height * 0.6);

    path.lineTo(size.width, 0);
    path.close();

    paint.color = Colors.blue.shade400;
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, size.height * 0.75);

    path.quadraticBezierTo(size.width * 0.1, size.height * 0.55, size.width * 0.22, size.height * 0.7);

    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.4, size.height * 0.75);

    path.quadraticBezierTo(size.width * 0.52, size.height * 0.5, size.width * 0.65, size.height * 0.7);

    path.quadraticBezierTo(size.width * 0.75, size.height * 0.85, size.width, size.height * 0.6);

    path.lineTo(size.width, 0);
    path.close();

    paint.color = Colors.blue.shade800;
    canvas.drawPath(path, paint);
  }
  @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
      return oldDelegate != this;
    }
}