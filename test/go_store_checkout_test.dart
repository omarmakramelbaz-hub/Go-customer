import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/go_services/service_api.dart';
import '../lib/go_stores/product_cart_sheet.dart';
import '../lib/go_stores/store_cart.dart';
import '../lib/go_stores/store_cart_screen.dart';
import '../lib/go_stores/store_order_api.dart';
import '../lib/view/custom_widgets/popups/go_popups.dart';
import '../lib/view/layout/address/model/address_model.dart';

const shop = {'id': 2, 'name': 'ماركت الأميرة', 'address': 'مدينة مبارك'};
const product = {'id': 5, 'name': 'أرز', 'unit': 'كيلو', 'price': '80.50', 'options': [
  {'id': '5f205abc-4346-441d-9952-f495e1f89e9f', 'label': 'نصف كيلو', 'price': '42.75'},
]};
final option = Map<String, dynamic>.from((product['options'] as List).first);

class FixtureApi extends StoreOrderApi {
  FixtureApi() : super(token: () => 'fixture');
  final submissions = <Map<String, dynamic>>[];
  Map<String, dynamic>? quoted;
  bool failOnce = false;
  @override
  Future<Map<String, dynamic>> quote(Map<String, dynamic> body) async {
    quoted = body;
    return {'quote_token': 'fixture-quote', 'subtotal': '85.50', 'delivery': '50.00', 'total': '135.50', 'payment_methods': ['cash', 'wallet', 'mobile_wallet', 'card']};
  }
  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> body) async {
    submissions.add(Map.from(body));
    if (failOnce) { failOnce = false; throw const ServiceFailure('Lost response'); }
    return {'order': {'id': 24, 'status': 'pending', 'payment_status': 'cash_due'}};
  }
}
Widget app(Widget child, {bool ar = true}) => MaterialApp(locale: Locale(ar ? 'ar' : 'en'), supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates, theme: ThemeData(fontFamily: 'Tajawal'), home: child);

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    request = options;
    return ResponseBody.fromString(jsonEncode({'status': 'Success', 'data': {'orders': [], 'page': 1, 'last_page': 1}}), 200, headers: {Headers.contentTypeHeader: ['application/json']});
  }
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Tajawal')..addFont(rootBundle.load('assets/font/Tajawal/Tajawal-Regular.ttf'))..addFont(rootBundle.load('assets/font/Tajawal/Tajawal-Bold.ttf'))).load();
  });
  test('cart merges option quantities, requires store replacement, persists and freezes uncertain checkout', () async {
    Map<String, dynamic>? saved;
    final cart = GoStoreCart(save: (value) async { saved = jsonDecode(jsonEncode(value)); });
    await cart.add(shop, product, option, 1); await cart.add(shop, product, option, 1);
    expect(cart.lines, hasLength(1)); expect(cart.count, 2); expect(cart.subtotal, 8550);
    await expectLater(cart.add({'id': 8}, product, null, 1), throwsStateError);
    final payload = cart.payload(fulfillment: 'pickup');
    final first = await cart.beginSubmit(payload, 'quote', 'cash');
    await cart.quantity(0, 4); expect(cart.count, 2);
    final restored = GoStoreCart(saved: saved);
    final retry = await restored.beginSubmit({}, 'changed', 'card');
    expect(retry, first); expect(restored.locked, true);
    await restored.clear(completed: true); expect(restored.count, 0);
  });
  test('store API always uses GO scope and authenticated isolated order endpoints', () async {
    final adapter = RecordingAdapter(); final dio = Dio()..httpClientAdapter = adapter;
    final api = StoreOrderApi(dio: dio, baseUrl: 'https://fixture.test/api/', token: () => 'fixture');
    await api.orders(history: true);
    expect(adapter.request!.uri.path, '/api/go-stores/orders');
    expect(adapter.request!.headers['X-App-Scope'], 'go');
    expect(adapter.request!.headers['Authorization'], 'Bearer fixture');
    expect(adapter.request!.queryParameters['history'], 1);
    api.close();
  });
  testWidgets('product sheet sends selected size and quantity to cart', (tester) async {
    Map<String, dynamic>? selected; int? quantity;
    await tester.pumpWidget(app(Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => showGoModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => ProductCartSheet(product: product, onAdd: (o, q) async { selected = o; quantity = q; return true; })), child: const Text('open'))))));
    await tester.tap(find.text('open')); await tester.pumpAndSettle();
    await tester.tap(find.text('نصف كيلو')); await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('product-quantity-plus'))); await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('add-product-to-cart')));
    await tester.tap(find.byKey(const ValueKey('add-product-to-cart'))); await tester.pumpAndSettle();
    expect(selected?['id'], option['id']); expect(quantity, 2); expect(tester.takeException(), isNull);
  });
  for (final ar in [true, false]) {
    testWidgets('cart reviews authoritative total and places order / ar=$ar', (tester) async {
      tester.view.physicalSize = const Size(390, 1400); tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      final cart = GoStoreCart(); await cart.add(shop, product, option, 2);
      final api = FixtureApi(); Map<String, dynamic>? placed;
      final boundary = GlobalKey();
      await tester.pumpWidget(app(RepaintBoundary(key: boundary, child: StoreCartScreen(cart: cart, api: api,
        selectAddress: (_) async => AddressModel(id: 7, address: 'مدينة مبارك، المنصورة'), onOrder: (o) => placed = o)), ar: ar));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ar ? 'اختَر عنوان التوصيل' : 'Choose delivery address')); await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('store-checkout-submit'))); await tester.pumpAndSettle();
      expect(api.quoted?['address_id'], 7); expect(api.quoted?['items'], [{'product_id': 5, 'option_id': option['id'], 'quantity': 2}]);
      expect(find.textContaining('135.50'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/ui-preview').create(recursive: true);
        await File('build/ui-preview/store-cart-${ar ? 'ar' : 'en'}.png').writeAsBytes(data!.buffer.asUint8List()); image.dispose();
      });
      await tester.tap(find.byKey(const ValueKey('store-checkout-submit'))); await tester.pumpAndSettle();
      expect(api.submissions, hasLength(1)); expect(api.submissions.single['payment_method'], 'cash'); expect(placed?['id'], 24); expect(cart.count, 0);
    });
  }
  testWidgets('lost checkout response retries exact key instead of creating another order', (tester) async {
    final cart = GoStoreCart(); await cart.add(shop, product, option, 2);
    final api = FixtureApi()..failOnce = true;
    await tester.pumpWidget(app(StoreCartScreen(cart: cart, api: api, selectAddress: (_) async => AddressModel(id: 7, address: 'العنوان'), onOrder: (_) {})));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('اختَر عنوان التوصيل')); await tester.tap(find.text('اختَر عنوان التوصيل')); await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('store-checkout-submit'))); await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('store-checkout-submit'))); await tester.pumpAndSettle();
    expect(cart.locked, true); expect(api.submissions, hasLength(1));
    await tester.tap(find.byKey(const ValueKey('store-checkout-submit'))); await tester.pumpAndSettle();
    expect(api.submissions, hasLength(2)); expect(api.submissions[0], api.submissions[1]); expect(cart.locked, false);
  });
}
