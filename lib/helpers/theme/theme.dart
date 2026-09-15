import 'package:flutter/material.dart';

import '../translation/all_translation.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

ThemeData theme(BuildContext context) {
  return ThemeData(
    primaryColor: AppColors.mainAppColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: false,
    hintColor: AppColors.hintColor,
    brightness: Brightness.light,
    buttonTheme: ButtonThemeData(buttonColor: AppColors.mainAppColor, alignedDropdown: true),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.mainAppColor,
      secondary: AppColors.secondAppColor,
      surface: AppColors.whiteColor,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.secondAppColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyle.appBarStyle,
      foregroundColor: AppColors.appBarTextColor,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldColor,
    fontFamily: context.languageCode == 'ar' ? 'Tajawal' : 'Roboto',
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.mainAppColor),
    platform: TargetPlatform.iOS,
  );
}
