import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import '../lib/go_stores/customer_store_screen.dart';
import '../lib/go_stores/store_browse_view.dart';
import '../lib/helpers/hive/hive_methods.dart';
import '../lib/view/layout/address/model/address_model.dart';

Widget app(Widget child, {bool ar = true, double scale = 1}) => MaterialApp(
  locale: Locale(ar ? 'ar' : 'en'), supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: ThemeData(fontFamily: 'Tajawal'),
  builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
  home: child,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory hiveDirectory;
  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('go-store-browser');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('app');
    final fonts = FontLoader('Tajawal')
      ..addFont(rootBundle.load('assets/font/Tajawal/Tajawal-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Tajawal/Tajawal-Bold.ttf'));
    await fonts.load();
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  setUp(() async { await Hive.box('app').clear(); await HiveMethods.deleteToken(); });
  tearDownAll(() async { await Hive.close(); await hiveDirectory.delete(recursive: true); });

  test('unknown delivery and rating data are never interpreted as zero', () {
    final store = GoStoreSummary({'id': 1, 'name': 'Store'});
    expect(store.avgRate, isNull);
    expect(store.serviceFees, isNull);
    expect(store.distance, isNull);
    expect(store.nearby, isFalse);
  });

  for (final ar in [true, false]) {
    testWidgets('restaurant-style store page renders phone layout / ar=$ar', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        await Hive.box('app').put('userId', 77);
        await HiveMethods.updateToken('local-preview-only');
        await HiveMethods.saveDeliveryAddress(77, AddressModel(address: ar ? 'مدينة مبارك، المنصورة' : 'Mubarak City, Mansoura', lat: '31.04', lng: '31.38').toJson());
      });
      final boundary = GlobalKey();
      final first = {'id': 1, 'name': ar ? 'ماركت الأميرة' : 'Al Amira Market', 'address': ar ? 'مدينة مبارك' : 'Mubarak City', 'distance_km': 1.2, 'nearby': true};
      await tester.pumpWidget(app(RepaintBoundary(key: boundary, child: CustomerStoreScreen(
        kind: 'supermarket', title: ar ? 'سوبر ماركت' : 'Supermarkets', read: (_, query) async => {
          'stores': [first, {'id': 2, 'name': ar ? 'متجر المدينة' : 'City Market', 'address': ar ? 'شارع الجمهورية' : 'El Gomhoria Street'}],
          'nearby_stores': [first], 'total': 2, 'nearby_total': 1,
        },
      )), ar: ar));
      await tester.pumpAndSettle();
      expect(find.text(ar ? 'متاجر قريبة منك' : 'Nearby stores'), findsOneWidget);
      expect(find.text(ar ? 'كل المتاجر' : 'All stores'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/ui-preview').create(recursive: true);
        await File('build/ui-preview/store-browser-${ar ? 'ar' : 'en'}.png').writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    });
  }

  testWidgets('address selection reloads nearby stores and persists per account', (tester) async {
    await tester.runAsync(() async { await Hive.box('app').put('userId', 21); });
    final queries = <Map<String, dynamic>>[];
    await tester.pumpWidget(app(CustomerStoreScreen(kind: 'supermarket', title: 'المتاجر',
      selectAddress: (_) async => AddressModel(id: 10, address: 'العنوان الجديد', lat: '30', lng: '31'),
      read: (_, query) async { queries.add(Map.of(query)); return {'stores': [], 'nearby_stores': query.containsKey('lat') ? [{'id': 9, 'name': 'أقرب متجر', 'distance_km': 1.0, 'nearby': true}] : []}; },
    )));
    await tester.pumpAndSettle();
    expect(find.text('تغيير العنوان'), findsOneWidget);
    await tester.runAsync(() => tester.widget<StoreBrowseView>(find.byType(StoreBrowseView)).onAddress());
    await tester.pumpAndSettle();
    expect(queries.last['lat'], 30);
    expect(queries.last['lng'], 31);
    expect(find.text('العنوان الجديد'), findsOneWidget);
    expect(find.text('أقرب متجر'), findsOneWidget);
    expect(HiveMethods.getDeliveryAddress(21)?['id'], 10);
    expect(HiveMethods.getDeliveryAddress(22), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search ignores late responses and pagination retains query', (tester) async {
    final old = Completer<Map<String, dynamic>>();
    final queries = <Map<String, dynamic>>[];
    await tester.pumpWidget(app(CustomerStoreScreen(kind: 'supermarket', title: 'المتاجر', read: (_, query) async {
      queries.add(Map.of(query));
      if (query['search'] == 'قديم') return old.future;
      if (query['search'] == 'جديد') return {'stores': [{'id': query['page'], 'name': query['page'] == 1 ? 'نتيجة جديدة' : 'الصفحة الثانية'}], 'page': query['page'], 'last_page': 2, 'total': 2};
      return {'stores': []};
    })));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('go-store-search')), 220, scrollable: find.byType(Scrollable).first);
    await tester.enterText(find.byKey(const ValueKey('go-store-search')), 'قديم');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.enterText(find.byKey(const ValueKey('go-store-search')), 'جديد');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    old.complete({'stores': [{'id': 100, 'name': 'نتيجة قديمة'}]});
    await tester.pumpAndSettle();
    expect(find.text('نتيجة قديمة'), findsNothing);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('عرض المزيد'), 180, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('عرض المزيد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض المزيد'));
    await tester.pumpAndSettle();
    expect(queries.last['search'], 'جديد');
    expect(queries.last['page'], 2);
    await tester.scrollUntilVisible(find.text('الصفحة الثانية'), 180, scrollable: find.byType(Scrollable).first);
    expect(find.text('الصفحة الثانية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
