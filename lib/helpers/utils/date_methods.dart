import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../hive/hive_methods.dart';
import '../theme/app_colors.dart';
import '../translation/all_translation.dart';

class DateMethods {
  static String formatToDate(String? date) {
    DateTime? dateTime = DateTime.tryParse(date.toString());
    return dateTime != null ? DateFormat('yyyy-MM-dd', 'en').format(dateTime) : '';
  }

  static String formatDateToArabic(String createdAt) {
    DateTime date = DateTime.parse(createdAt);
    String formattedDate = DateFormat('EEEE, d MMMM', HiveMethods.getLang()).format(date);
    return formattedDate;
  }

  static String formatOrderDate(String? date) {
    DateTime? dateTime = DateTime.tryParse(date.toString());
    return dateTime != null ? DateFormat('hh:mm  yyyy-MM-dd', 'en').format(dateTime) : '';
  }

  static String formatToTime(String? date) {
    DateTime? dateTime = DateTime.tryParse(date.toString());
    return dateTime != null ? DateFormat('hh:mm a', 'en').format(dateTime) : '';
  }

  static String timeAgo(String? date, BuildContext context) {
    DateTime? dateTime = DateTime.tryParse(date.toString());
    return dateTime != null ? timeago.format(dateTime, locale: context.languageCode) : '';
  }

  static Future<void> pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required void Function(DateTime) onSuccess,
    DateTime? firstDate,
    DateTime? lastDate,
    Color? mainColor,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(fontFamily: context.isRtl ? 'Tajawal' : 'Roboto').copyWith(
            colorScheme: ColorScheme.dark(
              primary: mainColor ?? AppColors.mainAppColor,
              onPrimary: backgroundColor,
              surface: backgroundColor,
              onSurface: textColor,
            ),
            dialogBackgroundColor: backgroundColor,
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: textColor)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSuccess.call(picked);
    }
  }

  static Future<void> pickTime(
    BuildContext context, {
    required DateTime initialDate,
    required void Function(DateTime) onSuccess,
    Color? mainColor,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: ThemeData(fontFamily: context.isRtl ? 'Tajawal' : 'Roboto').copyWith(
              colorScheme: ColorScheme.dark(
                primary: mainColor ?? AppColors.mainAppColor,
                onPrimary: backgroundColor,
                surface: backgroundColor,
                onSurface: textColor,
              ),
              dialogBackgroundColor: backgroundColor,
              textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: textColor)),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      DateTime time = DateTime(0000, 00, 00, picked.hour, picked.minute);
      onSuccess.call(time);
    }
  }
}

void initTimeago() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());
}
