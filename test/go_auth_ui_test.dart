import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/helpers/theme/theme.dart';
import 'package:go_drive_customer/helpers/translation/all_translation.dart';
import 'package:go_drive_customer/view/layout/auth/screen/login_screen.dart';
import 'package:go_drive_customer/view/layout/auth/screen/register_screen.dart';
import 'package:go_drive_customer/view/layout/auth/screen/check_mobile_has_account.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final family in ['Tajawal', 'Roboto']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/font/$family/$family-Regular.ttf'))
        ..addFont(rootBundle.load('assets/font/$family/$family-Bold.ttf'));
      await loader.load();
    }
  });

  for (final entry in <String, Widget>{
    'login': const LoginScreen(),
    'register': const RegisterScreen(),
    'recovery': const CheckMobileHasAccount(),
  }.entries) {
    for (final ar in [true, false]) {
      for (final large in [false, true]) {
        testWidgets('${entry.key} / Arabic=$ar / large text=$large', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(Size(large ? 320 : 390, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await GlobalTranslations.setNewLanguage(ar ? 'ar' : 'en', false);
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              locale: GlobalTranslations.locale,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: Builder(
                builder: (context) => Theme(
                  data: theme(context),
                  child: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(large ? 1.6 : 1)),
                    child: RepaintBoundary(
                      key: boundaryKey,
                      child: entry.value,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final phone = find.byType(EditableText).first;
          await tester.ensureVisible(phone);
          await tester.enterText(
            find.byType(TextFormField).first,
            '1012345678',
          );
          expect(
            tester.widget<EditableText>(phone).textDirection,
            TextDirection.ltr,
          );
          expect(find.text('+20'), findsOneWidget);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (ar && !large) {
            tester.state<FormState>(find.byType(Form)).reset();
            Scrollable.of(tester.element(find.byType(TextFormField).first))
                .position
                .jumpTo(0);
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
            // Capture the actual widget tree for review; no production routes or API calls.
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 2);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File('build/ui-preview/${entry.key}-ar.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        });
      }
    }
  }
}
