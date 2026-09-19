import 'package:flutter/material.dart';

class GoDriveBrand extends StatelessWidget {
  const GoDriveBrand({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Go Drive',
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GO',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: size,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFE85504),
              letterSpacing: -1.5,
            ),
          ),
          SizedBox(width: size * .18),
          Text(
            'Drive',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: size * .72,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF171A1F),
            ),
          ),
        ],
      ),
    ),
  );
}
