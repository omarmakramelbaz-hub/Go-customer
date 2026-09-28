import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_drive_customer/helpers/networking/api_helper.dart';
import 'package:go_drive_customer/helpers/translation/all_translation.dart';
import 'package:go_drive_customer/view/custom_widgets/custom_loading/custom_shimmer.dart';
import 'package:go_drive_customer/view/layout/wallet/controller/wallet_controller.dart';
import 'package:go_drive_customer/view/layout/wallet/model/wallet_model.dart';
import 'package:go_drive_customer/view/layout/wallet/widget/my_current_balance_widget.dart';

ApiResponse response(Object? balance) => ApiResponse(
  state: ResponseState.complete,
  data: {
    'status': 'Success',
    'data': {'balance': balance, 'wallet': <dynamic>[]},
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'zero and numeric-string balances load with string ledger IDs',
    () async {
      var balance = '0.00';
      final controller = WalletController(
        sessionToken: () => 'account-a',
        fetchWallet: () async => response(balance),
      );
      addTearDown(controller.dispose);
      await controller.getWallet();
      expect(controller.walletResponse.state, ResponseState.complete);
      expect(controller.wallet?.balance, 0);
      balance = '150.50';
      await controller.getWallet();
      expect(controller.wallet?.balance, 150.5);
      final parsed = WalletResponse.fromJson({
        'balance': '150.50',
        'wallet': [
          {
            'id': '3',
            'amount': '50.50',
            'from_user': '1',
            'to_user': '2',
            'order_id': '4',
            'order_no': 5,
          },
        ],
        'profile': {'id': '2', 'area_id': '7'},
      });
      expect(parsed.wallet!.single.id, 3);
      expect(parsed.wallet!.single.amount, 50.5);
      expect(parsed.wallet!.single.orderNo, '5');
      expect(parsed.profile!.areaId, 7);
    },
  );

  test(
    'invalid balances finish with an error, never a fabricated zero',
    () async {
      for (final balance in [null, 'invalid', 'NaN', 'Infinity']) {
        final controller = WalletController(
          sessionToken: () => 'account-a',
          fetchWallet: () async => response(balance),
        );
        await controller.getWallet();
        expect(controller.walletResponse.state, ResponseState.error);
        expect(controller.wallet, isNull);
        controller.dispose();
      }
    },
  );

  test(
    'failed refresh retains last known balance and can be retried',
    () async {
      var fail = false;
      final controller = WalletController(
        sessionToken: () => 'account-a',
        fetchWallet: () async {
          if (fail) throw Exception('offline');
          return response(150);
        },
      );
      addTearDown(controller.dispose);
      await controller.getWallet();
      fail = true;
      await controller.getWallet();
      expect(controller.walletResponse.state, ResponseState.error);
      expect(controller.wallet?.balance, 150);
      fail = false;
      await controller.getWallet();
      expect(controller.walletResponse.state, ResponseState.complete);
    },
  );

  test(
    'a stalled request times out and concurrent refreshes are coalesced',
    () async {
      var requests = 0;
      final controller = WalletController(
        sessionToken: () => 'account-a',
        requestTimeout: const Duration(milliseconds: 10),
        fetchWallet: () {
          requests++;
          return Completer<ApiResponse>().future;
        },
      );
      addTearDown(controller.dispose);
      final first = controller.getWallet();
      await controller.getWallet();
      expect(requests, 1);
      await first;
      expect(controller.walletResponse.state, ResponseState.error);
      expect(controller.wallet, isNull);
    },
  );

  test('late responses cannot expose the previous account balance', () async {
    String? token = 'account-a';
    final pending = Completer<ApiResponse>();
    final controller = WalletController(
      sessionToken: () => token,
      fetchWallet: () =>
          token == 'account-a' ? pending.future : Future.value(response(20)),
    );
    addTearDown(controller.dispose);
    final first = controller.getWallet();
    token = 'account-b';
    expect(controller.wallet, isNull);
    await controller.getWallet();
    pending.complete(response(900));
    await first;
    expect(controller.wallet?.balance, 20);
    token = null;
    expect(controller.wallet, isNull);
    await controller.getWallet();
    expect(controller.walletResponse.state, ResponseState.sleep);
  });

  test('logout and disposal safely invalidate an in-flight request', () async {
    for (final dispose in [false, true]) {
      String? token = 'account-a';
      final pending = Completer<ApiResponse>();
      final controller = WalletController(
        sessionToken: () => token,
        fetchWallet: () => pending.future,
      );
      final request = controller.getWallet();
      if (dispose) {
        controller.dispose();
      } else {
        token = null;
      }
      pending.complete(response(900));
      await request;
      expect(controller.wallet, isNull);
      if (!dispose) {
        expect(controller.walletResponse.state, ResponseState.sleep);
        controller.dispose();
      }
    }
  });

  testWidgets('real zero is visible and can be hidden', (tester) async {
    GlobalTranslations.locale = const Locale('ar');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyCurrentBalanceWidget(wallet: WalletResponse(balance: 0)),
        ),
      ),
    );
    expect(find.text('0.00'), findsOneWidget);
    expect(find.byType(CustomShimmer), findsNothing);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.text('0.00'), findsNothing);
    expect(find.text('••••••'), findsOneWidget);
  });

  testWidgets('loading becomes a retryable error without displaying zero', (
    tester,
  ) async {
    GlobalTranslations.locale = const Locale('ar');
    var retries = 0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MyCurrentBalanceWidget(wallet: null, isLoading: true),
        ),
      ),
    );
    expect(find.byType(CustomShimmer), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyCurrentBalanceWidget(
            wallet: null,
            hasError: true,
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.byType(CustomShimmer), findsNothing);
    expect(find.text('الرصيد غير متاح حاليًا'), findsOneWidget);
    expect(find.text('0.00'), findsNothing);
    await tester.tap(find.text('إعادة المحاولة'));
    expect(retries, 1);
  });

  testWidgets('last known balance remains marked when refresh fails', (
    tester,
  ) async {
    GlobalTranslations.locale = const Locale('ar');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyCurrentBalanceWidget(
            wallet: WalletResponse(balance: 150),
            hasError: true,
            onRetry: () {},
          ),
        ),
      ),
    );
    expect(find.text('150.00'), findsOneWidget);
    expect(find.text('تعذّر تحديث الرصيد'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });
}
