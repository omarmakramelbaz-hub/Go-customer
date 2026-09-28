import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../lib/helpers/hive/hive_methods.dart';
import '../lib/helpers/networking/api_helper.dart';
import '../lib/view/layout/wallet/controller/wallet_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (!kIsWeb) return;
    Hive.init('wallet-login-regression');
    await Hive.openBox('app');
  });
  tearDownAll(() async {
    if (kIsWeb) await Hive.close();
  });

  test(
    'wallet loads immediately after web login despite redirect grace',
    () async {
      await Hive.box('app').put('isVisitor', false);
      await HiveMethods.updateToken('wallet-test-session');
      expect(HiveMethods.isVisitor(), isTrue);
      expect(HiveMethods.isGuestMode(), isFalse);
      var requests = 0;
      final controller = WalletController(
        fetchWallet: () async {
          requests++;
          return ApiResponse(
            state: ResponseState.complete,
            data: {
              'status': 'Success',
              'data': {'balance': '150.00', 'wallet': []},
            },
          );
        },
      );
      addTearDown(controller.dispose);
      await controller.getWallet();
      expect(requests, 1);
      expect(controller.wallet?.balance, 150);
      expect(controller.walletResponse.state, ResponseState.complete);
    },
    skip: !kIsWeb,
  );

  test('actual guest mode still blocks wallet requests', () async {
    await HiveMethods.updateToken('old-wallet-test-session');
    await Hive.box('app').put('isVisitor', true);
    var requests = 0;
    final controller = WalletController(
      fetchWallet: () async {
        requests++;
        return ApiResponse(state: ResponseState.complete, data: null);
      },
    );
    addTearDown(controller.dispose);
    await controller.getWallet();
    expect(requests, 0);
    expect(controller.wallet, isNull);
    expect(controller.walletResponse.state, ResponseState.sleep);
    await HiveMethods.deleteToken();
    await Hive.box('app').clear();
  }, skip: !kIsWeb);
}
