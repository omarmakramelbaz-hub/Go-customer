import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../hive/hive_methods.dart';
import '../utils/logger.dart';
import 'main_app_bloc.dart';

const List<String> _supportedLanguages = ['en', 'ar'];

class GlobalTranslations {
  static Locale? locale;
  static Map<dynamic, dynamic>? _localizedValues;
  static VoidCallback? _onLocaleChangedCallback;

  static Iterable<Locale> supportedLocales() =>
      _supportedLanguages.map<Locale>((lang) => Locale(lang, ''));

  static String text(String key, {List<String>? args}) {
    if (_localizedValues == null || !_localizedValues!.containsKey(key)) {
      if (kDebugMode) {
        PrintLog.e('Missing key: $key');
        addMissingKeyToJsonFile(key);
        return '** $key not found';
      } else {
        if (args != null) {
          String temp = key;
          for (int i = 0; i < args.length; i++) {
            temp = temp.replaceAll('{$i}', args[i]);
          }
          return temp;
        } else {
          return key;
        }
      }
    } else {
      return _localizedValues![key];
    }
  }

  static Future<void> addMissingKeyToJsonFile(String key) async {
    try {
      const filePath =
          '/Users/tolba/StudioProjects/faskhaNinja/assets/langs/missing_keys.json';
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('missing_keys.json not found at $filePath');
      }

      final content = await file.readAsString();
      final Map<String, dynamic> jsonMap = json.decode(content);

      if (!jsonMap.containsKey(key)) {
        jsonMap[key] = key;

        final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonMap);
        await file.writeAsString(formattedJson);

        PrintLog.i('✅ "$key"\nAdded key to missing_keys.json');
      } else {
        if (!jsonMap.containsKey(key)) {
          PrintLog.i('ℹ️ Key "$key" already exists in missing_keys.json');
        }
      }
    } catch (e) {
      PrintLog.e('❌ Error writing to JSON file: $e');
    }
  }

  static String get currentLanguage =>
      locale == null ? 'ar' : locale!.languageCode;

  static Future<void> init() async {
    if (locale == null) {
      await setNewLanguage(currentLanguage, false);
    }
    return;
  }

  static Future<String> getPreferredLanguage() async => HiveMethods.getLang();

  static Future<void> setPreferredLanguage(String value) async =>
      HiveMethods.updateLang(value);

  static Future<void> setNewLanguage([
    String? newLanguage,
    bool saveInPrefs = true,
    BuildContext? context,
  ]) async {
    String language = newLanguage ?? currentLanguage;

    if (language.isEmpty) {
      language = 'ar';
    }

    if (saveInPrefs) {
      await setPreferredLanguage(language);
    }

    // Load the selected locale and its translation map before notifying widgets.
    // This prevents a rebuild where context already says English while `.tr`
    // is still reading the previous Arabic translation map (or vice versa).
    final nextLocale = Locale(language, '');
    final jsonContent = await rootBundle.loadString(
      'assets/langs/${nextLocale.languageCode}.json',
    );
    final localizedValues = json.decode(jsonContent);

    locale = nextLocale;
    _localizedValues = localizedValues;

    if (_onLocaleChangedCallback != null) {
      _onLocaleChangedCallback!();
    }

    if (saveInPrefs) {
      mainAppBloc.updateLang(language);
    }

    return;
  }

  static set onLocaleChangedCallback(VoidCallback callback) {
    _onLocaleChangedCallback = callback;
  }

  static final GlobalTranslations _translations =
      GlobalTranslations._internal();

  factory GlobalTranslations() {
    return _translations;
  }

  GlobalTranslations._internal();
}

extension Translatoin on String {
  String get tr => GlobalTranslations.text(this);
  String translate({List<String>? args}) {
    if (args == null || args.isEmpty) return GlobalTranslations.text(this);

    // Try fetching raw text first
    final raw = GlobalTranslations.text(this);

    // If the string contains sequential `{}` placeholders, replace them in order
    if (raw.contains('{}')) {
      var result = raw;
      for (final arg in args) {
        result = result.replaceFirst('{}', arg);
      }
      return result;
    }

    // Otherwise, fall back to the existing indexed placeholder support ({0}, {1}, ...)
    return GlobalTranslations.text(this, args: args);
  }
}

extension AppLocal on BuildContext {
  // Locale get locale => GlobalTranslations.locale!;
  String get languageCode => GlobalTranslations.locale!.languageCode;
  bool get isRtl => GlobalTranslations.locale!.languageCode == 'ar';
  bool get isEn => languageCode == 'en';
  bool get isAr => languageCode == 'ar';

  List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}

Future<void> changeLanguage(String lang) async {
  await GlobalTranslations.setNewLanguage(lang, true);
}
