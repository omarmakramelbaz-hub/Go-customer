import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/go_services/service_api.dart';
import '../lib/go_services/service_widgets.dart';

class MemoryAdapter implements HttpClientAdapter {
  MemoryAdapter(this.handler);
  final ResponseBody Function(RequestOptions) handler;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancel) async { requests.add(options); return handler(options); }
  @override
  void close({bool force = false}) {}
}
ResponseBody reply(Map<String, dynamic> data, [int code = 200]) => ResponseBody.fromString(jsonEncode({'status': 'Success', 'data': data}), code, headers: {Headers.contentTypeHeader: ['application/json']});
ServiceApi api(MemoryAdapter adapter, {bool partner = false}) => ServiceApi(partner: partner, dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://example.invalid/api/', token: () => 'test-token-not-real');
Map<String, dynamic> exampleJob() => {'id': 7, 'status': 'searching', 'description': 'Repair kitchen sink', 'area': 'District', 'search_until': DateTime.now().add(const Duration(hours: 1)).toIso8601String(), 'offers': [{'id': 3, 'partner_id': 9, 'name': 'Professional', 'price': '500.00', 'scope': 'Replace the damaged connection', 'materials_included': false, 'arrival_minutes': 30, 'duration_minutes': 60, 'status': 'offered', 'expires_at': DateTime.now().add(const Duration(minutes: 30)).toIso8601String()}]};
void main() {
  test('prices stay exact, Arabic digits work and invalid amounts fail closed', () {
    expect(normalizeServicePrice('١٢٣٫٤٥'), '123.45');
    expect(normalizeServicePrice('001.2'), '1.20');
    expect(normalizeServicePrice('1000000'), '1000000.00');
    for (final value in ['0', '-1', '0.99', '1.001', 'NaN', '1e3', '1,000', '1000000.01']) { expect(normalizeServicePrice(value), isNull, reason: value); }
    for (var i = 100; i < 1100; i++) { final value = '${i ~/ 100}.${(i % 100).toString().padLeft(2, '0')}'; expect(normalizeServicePrice(value), value); }
  });
  test('expiry, rejected offers and booked jobs cannot be accepted', () {
    final job = exampleJob(); final offer = serviceMaps(job['offers']).first;
    expect(serviceOfferLive(job, offer), isTrue);
    expect(serviceOfferLive({...job, 'status': 'booked'}, offer), isFalse);
    expect(serviceOfferLive(job, {...offer, 'status': 'rejected'}), isFalse);
    expect(serviceOfferLive(job, {...offer, 'expires_at': 'bad'}), isFalse);
    expect(serviceOfferLive(job, offer, now: DateTime.now().add(const Duration(hours: 2))), isFalse);
  });
  test('quotes require invitation, unexpired search and no previous offer', () {
    final job = {...exampleJob(), 'recipient_status': 'invited', 'offers': <dynamic>[]};
    expect(serviceCanQuote(job), isTrue);
    expect(serviceCanQuote({...job, 'recipient_status': 'declined'}), isFalse);
    expect(serviceCanQuote({...job, 'offers': [{'id': 1}]}), isFalse);
    expect(serviceCanQuote({...job, 'search_until': 'invalid'}), isFalse);
  });
  test('only advertised recognized methods are visible', () {
    final caps = ServiceCapabilities.fromMap({'schema_ready': true, 'version': 1, 'enabled': false, 'payment_methods': ['cash', 'wallet', 'unsupported']});
    expect(caps.ready, isTrue); expect(caps.enabled, isFalse); expect(caps.methods, ['cash', 'wallet']);
    expect(ServiceCapabilities.fromMap({'schema_ready': true, 'version': 99}).ready, isFalse);
  });
  test('old backend 404 permits fallback, server failures do not', () async {
    final old = api(MemoryAdapter((_) => reply({}, 404)));
    expect((await old.capabilities()).ready, isFalse); old.close();
    final broken = api(MemoryAdapter((_) => reply({}, 503)));
    await expectLater(broken.capabilities(), throwsA(isA<ServiceFailure>())); broken.close();
  });
  test('acceptance posts only the chosen payment method; server owns money', () async {
    final adapter = MemoryAdapter((_) => reply(exampleJob())); final client = api(adapter);
    await client.accept(7, 3, 'cash');
    expect(adapter.requests.single.path, endsWith('/go-services/jobs/7/offers/3/accept'));
    expect(adapter.requests.single.method, 'POST'); expect(adapter.requests.single.data, {'payment_method': 'cash'});
    expect(adapter.requests.single.headers['X-App-Scope'], 'go');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer test-token-not-real'); client.close();
  });
  test('partner quote uses correct scope and decimal string; skip is POST', () async {
    final adapter = MemoryAdapter((_) => reply(exampleJob())); final client = api(adapter, partner: true);
    await client.quote(7, {'price': '500.00', 'scope': 'Work scope', 'materials_included': false, 'arrival_minutes': 30, 'duration_minutes': 60});
    await client.skip(7);
    expect(adapter.requests.first.headers['X-App-Scope'], 'go_partner');
    expect((adapter.requests.first.data as Map)['price'], '500.00');
    expect(adapter.requests.last.method, 'POST'); client.close();
  });
  test('public capabilities never carry the customer token', () async {
    final adapter = MemoryAdapter((_) => reply({'schema_ready': true, 'version': 1, 'enabled': true})); final client = api(adapter);
    await client.capabilities(); expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse); client.close();
  });
  testWidgets('legacy fallback only when server lacks the schema', (tester) async {
    final client = api(MemoryAdapter((_) => reply({}, 404)));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ServiceGate(api: client, partner: false, ar: false, fallback: (_) => const Text('legacy retained'), builder: (_, __) => const Text('new marketplace')))));
    await tester.pumpAndSettle(); expect(find.text('legacy retained'), findsOneWidget); expect(find.text('new marketplace'), findsNothing);
    await tester.pumpWidget(const SizedBox()); client.close();
  });
  testWidgets('new professional requests wait for quotations and retry readiness', (tester) async {
    var ready = false;
    final adapter = MemoryAdapter((_) => reply({'schema_ready': ready, 'version': 1, 'enabled': ready}));
    final client = api(adapter);
    await tester.pumpWidget(MaterialApp(home: ServiceGate(api: client, partner: false, ar: false, title: 'Plumber', builder: (_, __) => const Text('quotation hub'))));
    await tester.pumpAndSettle();
    expect(find.text('Labour quotations are currently unavailable'), findsOneWidget);
    expect(find.text('quotation hub'), findsNothing);
    expect(adapter.requests.every((r) => r.method == 'GET' && r.path.endsWith('/capabilities')), isTrue);
    ready = true;
    await tester.tap(find.text('Retry')); await tester.pumpAndSettle();
    expect(find.text('quotation hub'), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); client.close();
  });
  testWidgets('rejecting one quote sends its id and retains the other quotes', (tester) async {
    var job = exampleJob();
    final first = serviceMaps(job['offers']).first;
    job['offers'] = [first, {...first, 'id': 4, 'name': 'Another professional', 'price': '450.00'}];
    final adapter = MemoryAdapter((request) {
      if (request.path.endsWith('capabilities')) return reply({'schema_ready': true, 'version': 1, 'enabled': true, 'payment_methods': ['cash']});
      if (request.method == 'POST') {
        job = {...job, 'offers': [{...first, 'status': 'rejected'}, serviceMaps(job['offers'])[1]]};
      }
      return reply(job);
    });
    final client = api(adapter);
    await tester.pumpWidget(MaterialApp(home: ServiceJobScreen(api: client, ar: false, id: 7)));
    await tester.pumpAndSettle();
    final reject = find.text('Reject and keep searching').first;
    await tester.scrollUntilVisible(reject, 200); await tester.tap(reject); await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm')); await tester.pumpAndSettle();
    final mutations = adapter.requests.where((r) => r.method == 'POST').toList();
    expect(mutations, hasLength(1));
    expect(mutations.single.path, endsWith('/jobs/7/offers/3/reject'));
    expect(serviceMaps(job['offers'])[1]['status'], 'offered');
    await tester.pumpWidget(const SizedBox()); client.close();
  });
  testWidgets('acceptance requires review and explicit confirmation', (tester) async {
    final adapter = MemoryAdapter((request) => request.path.endsWith('capabilities') ? reply({'schema_ready': true, 'version': 1, 'enabled': true, 'payment_methods': ['cash']}) : reply(exampleJob())); final client = api(adapter);
    await tester.pumpWidget(MaterialApp(home: ServiceJobScreen(api: client, ar: false, id: 7)));
    await tester.pumpAndSettle();
    final choose = find.text('Choose this quote'); await tester.scrollUntilVisible(choose, 200); await tester.tap(choose); await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Accept quote')); expect(button.onPressed, isNull);
    expect(adapter.requests.where((request) => request.method == 'POST'), isEmpty);
    await tester.pumpWidget(const SizedBox()); client.close();
  });
}
