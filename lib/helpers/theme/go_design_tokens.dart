import 'package:flutter/material.dart';

/// Presentation-only tokens from the approved GO Customer flowboard.
/// Do not put endpoints, prices, account state or booking rules in this layer.
abstract final class GoDesign {
  static const orange = Color(0xFFFD7201);
  static const orangeEnd = Color(0xFFFF5900);
  static const orangeTint = Color(0xFFFFF1E5);
  static const ink = Color(0xFF171A1F);
  static const deepInk = Color(0xFF091820);
  static const paper = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFF7F9FB);
  static const muted = Color(0xFF7D8490);
  static const border = Color(0xFFE5EAF0);
  static const success = Color(0xFF16875B);
  static const danger = Color(0xFFD92D20);
  static const radius = 12.0;
  static const cardRadius = 16.0;
  static const pagePadding = 20.0;
  static const controlHeight = 52.0;
  static const actionGradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [orange, orangeEnd],
  );
  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepInk, ink],
  );
  static const cardShadow = [
    BoxShadow(color: Color(0x08091820), blurRadius: 16, offset: Offset(0, 5)),
  ];
}
