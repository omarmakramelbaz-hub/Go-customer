import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double widthFactor = size.width / 375;

    Path path_0 = Path();
    path_0.moveTo(widthFactor * 375, 318);
    path_0.lineTo(0, 318);
    path_0.lineTo(0, 15);
    path_0.lineTo(0.115 * widthFactor, 15);
    path_0.arcToPoint(
      Offset(widthFactor * 17, 0),
      radius: Radius.elliptical(widthFactor * 16.991, 16.991),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(widthFactor * 84, 0);
    path_0.arcToPoint(
      Offset(widthFactor * 100.884, 15),
      radius: Radius.elliptical(widthFactor * 16.991, 16.991),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(widthFactor * 101.101, 15);
    path_0.arcToPoint(
      Offset(widthFactor * 273.901, 15),
      radius: Radius.elliptical(widthFactor * 87.437, 87.437),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(widthFactor * 274.119, 15);
    path_0.arcToPoint(
      Offset(widthFactor * 291, 0),
      radius: Radius.elliptical(widthFactor * 16.991, 16.991),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(widthFactor * 358, 0);
    path_0.arcToPoint(
      Offset(widthFactor * 374.884, 15),
      radius: Radius.elliptical(widthFactor * 16.991, 16.991),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(widthFactor * 375, 15);
    path_0.lineTo(widthFactor * 375, 318);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.shader = ui.Gradient.linear(
      Offset(size.width * 0.5000000, 0),
      Offset(size.width * 0.5000000, size.height * 0.01000000),
      [const Color(0xfffd7201).withValues(alpha: 1), const Color(0xffff9d4d).withValues(alpha: 1)],
      [0, 1],
    );
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
