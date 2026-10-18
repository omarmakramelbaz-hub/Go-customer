import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/go_services/service_api.dart';
import 'package:go_drive_customer/go_services/service_widgets.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final FutureOr<ResponseBody> Function(RequestOptions) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    requests.add(options);
    return await handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _reply(Map<String, dynamic> data, [int code = 200]) =>
    ResponseBody.fromString(
      jsonEncode({'status': 'Success', 'data': data}),
      code,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

Map<String, dynamic> _job([String description = 'Fresh repair status']) => {
      'id': 7,
      'status': 'awaiting_confirmation',
      'description': description,
      'offers': <dynamic>[],
    };

Map<String, dynamic> _caps() => {
      'schema_ready': true,
      'version': 1,
      'enabled': true,
      'payment_methods': ['cash'],
    };

ServiceApi _api(_Adapter adapter, {String? Function()? token}) => ServiceApi(
      partner: false,
      dio: Dio()..httpClientAdapter = adapter,
      baseUrl: 'https://example.invalid/api',
      token: token ?? () => 'fixture-session',
    );

class _TimedApi extends ServiceApi {
  _TimedApi() : super(partner: false, token: () => 'fixture-session');
  final reads = <String>[];

  @override
  Future<Map<String, dynamic>> job(int id) {
    reads.add('job');
    return Future.delayed(const Duration(milliseconds: 100), () => _job());
  }

  @override
  Future<ServiceCapabilities> capabilities() {
    reads.add('capabilities');
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => ServiceCapabilities.fromMap(_caps()),
    );
  }
}

void main() {
  testWidgets(
    'parallel refresh takes one 100ms response window instead of two',
    (tester) async {
      final api = _TimedApi();
      var sequentialFinished = false;
      Future<void> sequentialBaseline() async {
        await api.job(7);
        await api.capabilities();
        sequentialFinished = true;
      }

      unawaited(sequentialBaseline());
      await tester.pump();
      expect(api.reads, ['job']);
      await tester.pump(const Duration(milliseconds: 100));
      expect(sequentialFinished, isFalse);
      expect(api.reads, ['job', 'capabilities']);
      await tester.pump(const Duration(milliseconds: 100));
      expect(sequentialFinished, isTrue);

      api.reads.clear();
      ServiceJobRefresh? result;
      unawaited(api.refreshJob(7).then((value) => result = value));
      await tester.pump();
      expect(api.reads, ['job', 'capabilities']);
      await tester.pump(const Duration(milliseconds: 99));
      expect(result, isNull);
      await tester.pump(const Duration(milliseconds: 1));
      expect(result?.complete, isTrue);
      expect(result?.job?['description'], 'Fresh repair status');
      api.close();
    },
  );

  test(
    'capabilities failures retain the fresh job and retry without caching',
    () async {
      var failing = true;
      var revision = 1;
      final adapter = _Adapter(
        (request) => request.path.endsWith('/capabilities')
            ? _reply(_caps(), failing ? 503 : 200)
            : _reply(_job('Revision $revision')),
      );
      final api = _api(adapter);

      final first = await api.refreshJob(7);
      expect(first.job?['description'], 'Revision 1');
      expect(first.capabilities, isNull);
      expect(first.complete, isFalse);
      expect(first.capabilitiesError, isA<ServiceFailure>());

      failing = false;
      revision = 2;
      final second = await api.refreshJob(7);
      expect(second.complete, isTrue);
      expect(second.job?['description'], 'Revision 2');
      expect(adapter.requests, hasLength(4));
      api.close();
    },
  );

  test(
    'a failed job remains a failure even when capabilities succeed',
    () async {
      final adapter = _Adapter(
        (request) => request.path.endsWith('/capabilities')
            ? _reply(_caps())
            : _reply({}, 503),
      );
      final api = _api(adapter);
      final result = await api.refreshJob(7);
      expect(result.job, isNull);
      expect(result.capabilities?.ready, isTrue);
      expect(result.complete, isFalse);
      expect(result.jobError, isA<ServiceFailure>());
      api.close();
    },
  );

  test(
    'a changed session cannot return an old authenticated response',
    () async {
      var session = 'old-session';
      final started = Completer<void>();
      final response = Completer<ResponseBody>();
      var first = true;
      final adapter = _Adapter((_) {
        if (first) {
          first = false;
          started.complete();
          return response.future;
        }
        return _reply(_job('New account details'));
      });
      final api = _api(adapter, token: () => session);
      final pending = api.job(7);
      await started.future;
      session = 'new-session';
      response.complete(_reply(_job('Old account details')));
      await expectLater(
        pending,
        throwsA(
          isA<ServiceFailure>().having((error) => error.status, 'status', 401),
        ),
      );
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer old-session',
      );
      final fresh = await api.job(7);
      expect(fresh['description'], 'New account details');
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-session',
      );
      api.close();
    },
  );

  test(
    'late mutation responses cannot notify another wallet session',
    () async {
      var session = 'old-session';
      final started = Completer<void>();
      final response = Completer<ResponseBody>();
      final adapter = _Adapter((_) {
        started.complete();
        return response.future;
      });
      final api = _api(adapter, token: () => session);
      final previousWalletRevision = goWalletChanges.value;
      final pending = api.accept(7, 3, 'cash');
      await started.future;
      session = 'new-session';
      response.complete(_reply(_job('Old account mutation')));
      await expectLater(pending, throwsA(isA<ServiceFailure>()));
      expect(goWalletChanges.value, previousWalletRevision);
      expect(adapter.requests.single.method, 'POST');
      api.close();
    },
  );

  test('public capabilities remain usable after a session switch', () async {
    var session = 'old-session';
    final started = Completer<void>();
    final response = Completer<ResponseBody>();
    final adapter = _Adapter((_) {
      started.complete();
      return response.future;
    });
    final api = _api(adapter, token: () => session);
    final pending = api.capabilities();
    await started.future;
    session = 'new-session';
    response.complete(_reply(_caps()));
    expect((await pending).ready, isTrue);
    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
    api.close();
  });

  for (final failureStatus in [401, 503]) {
    testWidgets(
      'fresh job stays visible with actions disabled if capabilities fail ($failureStatus)',
      (tester) async {
        final adapter = _Adapter(
          (request) => request.path.endsWith('/capabilities')
              ? _reply({}, failureStatus)
              : _reply(_job()),
        );
        final api = _api(adapter);
        await tester.pumpWidget(
          MaterialApp(home: ServiceJobScreen(api: api, ar: false, id: 7)),
        );
        await tester.pumpAndSettle();
        expect(find.text('Fresh repair status'), findsOneWidget);
        final confirm = find.widgetWithText(
          FilledButton,
          'Confirm completion and payment',
        );
        expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
        expect(
          adapter.requests.where((request) => request.method != 'GET'),
          isEmpty,
        );
        await tester.pumpWidget(const SizedBox());
        api.close();
      },
    );
  }

  testWidgets('changing session while capabilities wait clears the old job', (
    tester,
  ) async {
    var session = 'old-session';
    var reads = 0;
    final delayedCapabilities = Completer<ResponseBody>();
    final adapter = _Adapter((request) {
      if (request.path.endsWith('/capabilities')) {
        reads++;
        return reads == 2 ? delayedCapabilities.future : _reply(_caps());
      }
      return _reply(_job('Old account details'));
    });
    final api = _api(adapter, token: () => session);
    await tester.pumpWidget(
      MaterialApp(home: ServiceJobScreen(api: api, ar: false, id: 7)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Old account details'), findsOneWidget);

    final dynamic state = tester.state(find.byType(ServiceJobScreen));
    unawaited(state.load() as Future<void>);
    await tester.pump(const Duration(milliseconds: 1));
    expect(reads, 2);
    session = 'new-session';
    delayedCapabilities.complete(_reply(_caps()));
    await tester.pumpAndSettle();
    expect(find.text('Old account details'), findsNothing);
    expect(find.textContaining('Session changed'), findsOneWidget);
    expect(find.text('Confirm completion and payment'), findsNothing);
    expect(
      adapter.requests
          .where((request) => request.path.endsWith('/capabilities'))
          .every((request) => !request.headers.containsKey('Authorization')),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox());
    api.close();
  });

  testWidgets('a late mutation from another session clears the old job UI', (
    tester,
  ) async {
    var session = 'old-session';
    final mutationStarted = Completer<void>();
    final mutation = Completer<ResponseBody>();
    final adapter = _Adapter((request) {
      if (request.method == 'POST') {
        mutationStarted.complete();
        return mutation.future;
      }
      return _reply(
        request.path.endsWith('/capabilities')
            ? _caps()
            : _job('Old account details'),
      );
    });
    final api = _api(adapter, token: () => session);
    await tester.pumpWidget(
      MaterialApp(home: ServiceJobScreen(api: api, ar: false, id: 7)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Old account details'), findsOneWidget);
    final dynamic state = tester.state(find.byType(ServiceJobScreen));
    unawaited(state.run(() => api.status(7, 'completed')) as Future<void>);
    await tester.pump(const Duration(milliseconds: 1));
    expect(mutationStarted.isCompleted, isTrue);
    session = 'new-session';
    mutation.complete(_reply(_job('Old account mutation')));
    await tester.pumpAndSettle();
    expect(find.text('Old account details'), findsNothing);
    expect(find.textContaining('Session changed'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    api.close();
  });
}
