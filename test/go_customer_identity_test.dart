import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/view/layout/home/widgets/go_customer_home_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('approved raster artwork decodes', () async {
    final svg = await rootBundle.loadString('assets/svg/go_logo.svg');
    final raw = svg.split('data:image/webp;base64,')[1].split('"')[0];
    final codec = await ui.instantiateImageCodec(base64Decode(raw.replaceAll(RegExp(r'\s'), '')));
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 192);
    expect(frame.image.height, 122);
    frame.image.dispose();
    codec.dispose();
  });

  test('all existing profession API keys remain unique', () {
    expect(goServices.length, 19);
    expect(goServices.map((s) => s.key).toSet().length, 19);
    expect(goServices.first.key, 'delivery_courier');
  });

  for (final width in [320.0, 390.0, 768.0]) {
    for (final ar in [true, false]) {
      testWidgets('home has no overflow at $width / Arabic=$ar', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(home: GoCustomerHomeView(
          isArabic: ar, firstName: 'Omar', locationTitle: 'المنصورة', locationSubtitle: 'عنوان الخدمة',
          notificationCount: 2, onAddress: () {}, onNotifications: () {}, onService: (_) {},
          drawer: const Drawer(child: Text('Menu')),
        )));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('go-approved-home-v2')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('service search preserves the booking callback', (tester) async {
    String? chosen;
    await tester.pumpWidget(MaterialApp(home: GoCustomerHomeView(
      isArabic: true, firstName: '', locationTitle: 'موقعك الحالي', locationSubtitle: 'اختر العنوان',
      notificationCount: 0, onAddress: () {}, onNotifications: () {}, onService: (s) => chosen = s.key,
    )));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('go-home-search')), 'سباك');
    await tester.pumpAndSettle();
    final plumber = find.byKey(const ValueKey('go-service-plumber'));
    await tester.ensureVisible(plumber);
    await tester.tap(plumber);
    expect(chosen, 'plumber');
    expect(find.byKey(const ValueKey('go-service-delivery_courier')), findsNothing);
  });
}
