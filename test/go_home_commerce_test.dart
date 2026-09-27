import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/helpers/theme/theme.dart';
import 'package:go_drive_customer/helpers/translation/all_translation.dart';
import 'package:go_drive_customer/view/layout/home/widgets/go_customer_home_view.dart';
import 'package:go_drive_customer/view/layout/home/widgets/service_photo_sprite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Tajawal', 'Roboto']) {
      await (FontLoader(family)
            ..addFont(
                rootBundle.load('assets/font/$family/$family-Regular.ttf'))
            ..addFont(rootBundle.load('assets/font/$family/$family-Bold.ttf')))
          .load();
    }
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  for (final ar in [true, false]) {
    for (final large in [false, true]) {
      testWidgets(
          'department search, shortcut and all-service booking / ar=$ar / large=$large',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(large ? 320 : 390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.runAsync(
            () => GlobalTranslations.setNewLanguage(ar ? 'ar' : 'en', false));
        String? selected;
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          locale: GlobalTranslations.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
              builder: (context) => Theme(
                    data: theme(context),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(large ? 1.6 : 1)),
                      child: RepaintBoundary(
                          key: boundaryKey,
                          child: GoCustomerHomeView(
                            isArabic: ar,
                            firstName: '',
                            locationTitle:
                                ar ? 'موقعك الحالي' : 'Your location',
                            locationSubtitle: ar
                                ? 'اختر عنوان التوصيل'
                                : 'Choose delivery address',
                            notificationCount: 0,
                            onAddress: () {},
                            onNotifications: () {},
                            onService: (service) => selected = service.key,
                            drawer: const Drawer(),
                          )),
                    ),
                  )),
        ));
        await tester.runAsync(() async {
          final context = tester.element(find.byType(GoCustomerHomeView));
          await precacheImage(MemoryImage(goServiceSpriteBytes), context);
          await precacheImage(
              const AssetImage('assets/brand/go_product_departments.webp'),
              context);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        Future<void> capture(String name) async {
          if (!ar || large) return;
          final boundary = boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File('build/ui-preview/$name.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await capture('home-commerce-ar');

        await tester.enterText(find.byKey(const ValueKey('go-home-search')),
            ar ? 'صيدليات' : 'pharmacies');
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('go-department-card-pharmacy')),
            findsOneWidget);
        expect(find.byKey(const ValueKey('go-department-card-supermarket')),
            findsNothing);
        expect(find.byKey(const ValueKey('go-service-plumber')), findsNothing);

        final shortcut = find.byKey(const ValueKey('go-product-supermarket'));
        await tester.ensureVisible(shortcut);
        await tester.tap(shortcut);
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<TextField>(find.byKey(const ValueKey('go-home-search')))
                .controller!
                .text,
            isEmpty);
        final storeCard =
            find.byKey(const ValueKey('go-department-card-supermarket'));
        expect(tester.getTopLeft(storeCard).dy, inInclusiveRange(0, 844));
        expect(tester.takeException(), isNull);
        await capture('home-departments-ar');

        final all = find.byKey(const ValueKey('go-home-book'));
        await tester.ensureVisible(all);
        await tester.tap(all);
        await tester.pumpAndSettle();
        final lastProfession = find.text(ar ? 'عاملة نظافة' : 'Female cleaner');
        final listScroll = find.descendant(
            of: find.byType(ListView), matching: find.byType(Scrollable));
        await tester.scrollUntilVisible(lastProfession, 250,
            scrollable: listScroll);
        await tester.tap(lastProfession);
        await tester.pumpAndSettle();
        expect(selected, 'female_cleaner');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
