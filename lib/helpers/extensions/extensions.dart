import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

export '../translation/all_translation.dart' show AppLocal;

extension EmptyPadding on num {
  SizedBox get sbH => SizedBox(height: toDouble());

  SizedBox get sbW => SizedBox(width: toDouble());
}

extension DateHelpers on DateTime {
  String toDateFormat({String? format, String? locale}) {
    final formatter = intl.DateFormat(format ?? 'EE, d MMM hh:mm', locale ?? 'en');
    return formatter.format(this);
  }
}

extension ContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  Color get primaryColor => Theme.of(this).primaryColor;
}
