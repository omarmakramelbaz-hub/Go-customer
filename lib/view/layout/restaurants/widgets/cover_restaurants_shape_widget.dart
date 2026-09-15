import 'package:flutter/material.dart';

class CoverShape extends CustomPainter {
  Path getPath(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 18);
    path.arcToPoint(
      Offset(size.width - 18, size.height),
      radius: const Radius.elliptical(18, 18),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.lineTo(size.width - 28.5, size.height - 3.748);
    path.lineTo(size.width / 2, size.height - 60.6);
    path.lineTo(18, size.height);
    path.arcToPoint(
      Offset(0, size.height - 18),
      radius: const Radius.elliptical(18, 18),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = getPath(size);
    Paint paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xff000000).withValues(alpha: 1.0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomClipPath extends CustomClipper<Path> {
  final Size size;
  CustomClipPath(this.size);

  @override
  Path getClip(Size size) {
    return CoverShape().getPath(this.size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
