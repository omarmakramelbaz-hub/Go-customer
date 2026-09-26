import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/go_services/service_api.dart';
import 'package:go_drive_customer/go_services/service_widgets.dart';

class ControlledServiceApi extends ServiceApi {
  ControlledServiceApi() : super(partner: false, baseUrl: 'https://example.invalid/api', token: () => 'fixture-token');
  final oldPoll = Completer<Map<String, dynamic>>();
  int reads = 0;
  int accepts = 0;
  bool booked = false;
  bool delaySecondRead = true;
  String? acceptedMethod;
  Map<String, dynamic> searching() => {
    'id': 7, 'status': 'searching', 'description': 'Repair the kitchen sink connection',
    'area': 'District', 'search_until': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    'offers': [{
      'id': 3, 'name': 'Professional', 'price': '500.00', 'scope': 'Replace the damaged connection',
      'status': 'offered', 'materials_included': false, 'arrival_minutes': 30, 'duration_minutes': 60,
      'expires_at': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
    }],
  };
  Map<String, dynamic> accepted() => {
    ...searching(), 'status': 'booked', 'accepted_offer_id': 3, 'price': '500.00',
    'payment_method': acceptedMethod ?? 'cash',
    'payment_status': acceptedMethod == 'card' ? 'unpaid' : 'cash_due',
    'payment_due_at': DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
    'offers': [{...serviceMaps(searching()['offers']).single, 'status': 'accepted'}],
  };
  @override
  Future<ServiceCapabilities> capabilities() async => const ServiceCapabilities(ready: true, enabled: true, methods: ['cash', 'card']);
  @override
  Future<Map<String, dynamic>> job(int id) {
    reads++;
    if (delaySecondRead && reads == 2) return oldPoll.future;
    return Future.value(booked ? accepted() : searching());
  }
  @override
  Future<Map<String, dynamic>> accept(int id, int offer, String method) async {
    if (id != 7 || offer != 3) throw StateError('Wrong job/offer');
    accepts++; booked = true; acceptedMethod = method;
    return accepted();
  }
}

Future<void> reviewAndAccept(WidgetTester tester, String method) async {
  final choose = find.text('Choose this quote');
  await tester.scrollUntilVisible(choose, 200);
  await tester.tap(choose);
  await tester.pumpAndSettle();
  final dialog = find.byType(AlertDialog);
  final payment = find.descendant(of: dialog, matching: find.text(method));
  await tester.ensureVisible(payment);
  await tester.tap(payment);
  final consent = find.descendant(of: dialog, matching: find.byType(CheckboxListTile));
  await tester.ensureVisible(consent);
  await tester.tap(consent);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Accept quote'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a delayed pre-acceptance poll cannot resurrect an unaccepted quote', (tester) async {
    final api = ControlledServiceApi();
    await tester.pumpWidget(MaterialApp(home: ServiceJobScreen(api: api, ar: false, id: 7)));
    await tester.pumpAndSettle();
    expect(api.reads, 1);
    await tester.pump(const Duration(seconds: 10));
    expect(api.reads, 2);
    expect(api.oldPoll.isCompleted, isFalse);
    await reviewAndAccept(tester, 'Cash to professional');
    expect(api.accepts, 1);
    expect(api.acceptedMethod, 'cash');
    api.oldPoll.complete(api.searching());
    await tester.pumpAndSettle();
    // Assert actual current UI state, rather than merely counting requests.
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('Booked'), findsOneWidget);
    expect(find.text('Choose this quote'), findsNothing);
    expect(find.text('Reject and keep searching'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    api.close();
  });

  testWidgets('selecting an electronic method does not mark the job paid', (tester) async {
    final api = ControlledServiceApi()..delaySecondRead = false;
    await tester.pumpWidget(MaterialApp(home: ServiceJobScreen(api: api, ar: false, id: 7)));
    await tester.pumpAndSettle();
    await reviewAndAccept(tester, 'Bank card');
    expect(api.accepts, 1);
    expect(api.acceptedMethod, 'card');
    await tester.scrollUntilVisible(find.text('Payment not confirmed'), 200);
    expect(find.text('Payment not confirmed'), findsOneWidget);
    expect(find.text('Confirm completion and payment'), findsNothing);
    expect(find.text('Payment verified; funds held'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    api.close();
  });
}
