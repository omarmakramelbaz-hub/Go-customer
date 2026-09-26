import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../translation/all_translation.dart';
import 'go_design_tokens.dart';

ThemeData theme(BuildContext context) {
  final font = context.languageCode == 'ar' ? 'Tajawal' : 'Roboto';
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(GoDesign.radius));
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(GoDesign.radius),
    borderSide: const BorderSide(color: GoDesign.border),
  );
  final buttonStyle = FilledButton.styleFrom(
    backgroundColor: GoDesign.orange,
    foregroundColor: GoDesign.paper,
    disabledBackgroundColor: GoDesign.border,
    disabledForegroundColor: GoDesign.muted,
    minimumSize: const Size(48, GoDesign.controlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: shape,
    textStyle: TextStyle(fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700),
  );
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: GoDesign.orange,
    scaffoldBackgroundColor: GoDesign.canvas,
    canvasColor: GoDesign.paper,
    hintColor: GoDesign.muted,
    dividerColor: GoDesign.border,
    fontFamily: font,
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: font, bodyColor: GoDesign.ink, displayColor: GoDesign.ink),
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    colorScheme: const ColorScheme.light(
      primary: GoDesign.orange, onPrimary: GoDesign.paper,
      secondary: GoDesign.ink, onSecondary: GoDesign.paper,
      surface: GoDesign.paper, onSurface: GoDesign.ink,
      error: GoDesign.danger, onError: GoDesign.paper,
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: GoDesign.deepInk,
      foregroundColor: GoDesign.paper,
      elevation: 0, scrolledUnderElevation: 0, centerTitle: true,
      iconTheme: const IconThemeData(color: GoDesign.paper, size: 22),
      titleTextStyle: TextStyle(fontFamily: font, color: GoDesign.paper,
        fontSize: 18, fontWeight: FontWeight.w700),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true, fillColor: GoDesign.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      hintStyle: const TextStyle(color: GoDesign.muted, fontSize: 14),
      prefixIconColor: GoDesign.muted, suffixIconColor: GoDesign.muted,
      border: fieldBorder, enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: GoDesign.orange, width: 1.5)),
      errorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: GoDesign.danger)),
      focusedErrorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: GoDesign.danger, width: 1.5)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: GoDesign.orange, backgroundColor: GoDesign.paper,
      side: const BorderSide(color: GoDesign.orange), shape: shape,
      minimumSize: const Size(48, GoDesign.controlHeight),
      textStyle: TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w700))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: GoDesign.orange,
      minimumSize: const Size(48, 48),
      textStyle: TextStyle(fontFamily: font, fontWeight: FontWeight.w700))),
    cardTheme: CardThemeData(
      color: GoDesign.paper, surfaceTintColor: Colors.transparent,
      elevation: 0, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GoDesign.cardRadius),
        side: const BorderSide(color: GoDesign.border))),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: GoDesign.paper, selectedItemColor: GoDesign.orange,
      unselectedItemColor: GoDesign.muted, type: BottomNavigationBarType.fixed,
      elevation: 0, showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 12)),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: GoDesign.paper, modalBackgroundColor: GoDesign.paper,
      surfaceTintColor: Colors.transparent, clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
    dialogTheme: DialogThemeData(backgroundColor: GoDesign.paper, shape: shape),
    drawerTheme: const DrawerThemeData(backgroundColor: GoDesign.deepInk),
    listTileTheme: const ListTileThemeData(iconColor: GoDesign.ink, textColor: GoDesign.ink),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: GoDesign.orange),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: GoDesign.orange, selectionColor: GoDesign.orangeTint, selectionHandleColor: GoDesign.orange),
    snackBarTheme: SnackBarThemeData(backgroundColor: GoDesign.ink,
      contentTextStyle: TextStyle(fontFamily: font, color: GoDesign.paper),
      behavior: SnackBarBehavior.floating, shape: shape),
    platform: TargetPlatform.iOS,
  );
}
