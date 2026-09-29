import '../lib/view/layout/request_delegate/model/request_delegate_order_model.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../lib/helpers/hive/hive_methods.dart';
import '../lib/helpers/translation/all_translation.dart';
import '../lib/go_stores/customer_store_screen.dart';
import '../lib/view/layout/address/model/address_model.dart';
import '../lib/view/layout/home/widgets/go_product_department.dart';
import '../lib/view/layout/my_account/controller/my_account_controller.dart';
import '../lib/view/layout/my_account/model/setting_model.dart';
import '../lib/view/layout/wallet/controller/wallet_controller.dart';
import '../lib/view/layout/wallet/widget/chooseVCashOrVisaWidget.dart';
import '../lib/view/layout/request_delegate/controller/request_delegate_controller.dart';

class PaymentSettings extends MyAccountController {
  @override
  SettingModel get setting =>
      SettingModel(walletCardActivate: 'true', paymentCardActivate: 'true');
}

Widget app(Widget child, bool ar) => MaterialApp(
  locale: Locale(ar ? 'ar' : 'en'),
  supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: child,
);
void main() {
  test('courier payment state and fractional agreed fare come from server', () {
    final order = RequestDelegateOrderModel.fromJson({'id': 20, 'actual_price': 125.75, 'payment_type': 'online', 'payment_status': 'pending', 'payment_required': true, 'payment_deferred': true});
    expect(order.actualPrice, 125.75);
    expect(order.paymentRequired, isTrue);
    expect(order.paymentDeferred, isTrue);
    expect(order.paymentStatus, 'pending');
    expect(order.toJson()['payment_required'], isTrue);
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('go-app-fixes');
    Hive.init(directory.path);
    await Hive.openBox('app');
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'English covers every Arabic key and persisted language loads at startup',
    () async {
      final ar =
          jsonDecode(File('assets/langs/ar.json').readAsStringSync()) as Map;
      final en =
          jsonDecode(File('assets/langs/en.json').readAsStringSync()) as Map;
      expect(ar.keys.where((key) => !en.containsKey(key)), isEmpty);
      expect(
        en.values.where(
          (value) => RegExp(r'[\u0600-\u06FF]').hasMatch('$value'),
        ),
        isEmpty,
      );
      await HiveMethods.updateLang('en');
      GlobalTranslations.locale = null;
      await GlobalTranslations.init();
      expect(GlobalTranslations.currentLanguage, 'en');
      expect('creditCard'.tr, 'Bank cards');
      await GlobalTranslations.setNewLanguage('ar');
      expect(HiveMethods.getLang(), 'ar');
      expect('creditCard'.tr, 'بطاقات بنكية');
    },
  );
  test(
    'selected address is stored per account and accepts numeric coordinates',
    () async {
      final address = AddressModel.fromJson({
        'id': 7,
        'address': 'Fixture street',
        'city_name': 'Cairo',
        'lat': 30.12,
        'lng': 31,
      });
      await HiveMethods.saveDeliveryAddress(1, address.toJson());
      expect(HiveMethods.getDeliveryAddress(2), isNull);
      final restored = AddressModel.fromJson(
        HiveMethods.getDeliveryAddress(1)!,
      );
      expect(restored.address, 'Fixture street');
      expect(restored.lat, '30.12');
      expect(restored.lng, '31');
      await HiveMethods.clearDeliveryAddress(1);
      expect(HiveMethods.getDeliveryAddress(1), isNull);
    },
  );
  test('courier booking supports all four explicit payment choices', () {
    final controller = RequestDelegateController();
    expect(controller.selectedPayment, isEmpty);
    controller.setSelectedPayment('cash');
    expect(controller.selectedPayment, 'cash');
    controller.setSelectedPayment('online');
    expect(controller.selectedPayment, 'online');
    controller.setSelectedPayment('wallet');
    expect(controller.selectedPayment, 'wallet');
    controller.setSelectedPayment('v_cash');
    expect(controller.selectedPayment, 'v_cash');
    controller.dispose();
  });
  test('departments have the requested order including clinics', () {
    expect(GoProductDepartment.values.map((d) => d.name), [
      'supermarket',
      'restaurant',
      'pharmacy',
      'clinic',
    ]);
  });

  for (final ar in [true, false]) {
    testWidgets('top-up has exactly two selectable payment methods / ar=$ar', (
      tester,
    ) async {
      await tester.runAsync(
        () => GlobalTranslations.setNewLanguage(ar ? 'ar' : 'en', false),
      );
      final wallet = WalletController(sessionToken: () => null);
      final settings = PaymentSettings();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WalletController>.value(value: wallet),
            ChangeNotifierProvider<MyAccountController>.value(value: settings),
          ],
          child: app(
            Scaffold(
              body: ChooseVCashOrVisaWidget(myAccountController: settings),
            ),
            ar,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final cards = find.text(ar ? 'بطاقات بنكية' : 'Bank cards');
      final wallets = find.text(ar ? 'محافظ إلكترونية' : 'Electronic wallets');
      expect(cards, findsOneWidget);
      expect(wallets, findsOneWidget);
      expect(find.text('Apple Pay'), findsNothing);
      expect(find.text('Google Pay'), findsNothing);
      await tester.tap(wallets);
      await tester.pump();
      expect(wallet.selectedPayment, 'v_cash');
      await tester.tap(cards);
      await tester.pump();
      expect(wallet.selectedPayment, 'online');
      wallet.setSelectedPayment('cash');
      expect(wallet.selectedPayment, 'online');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      wallet.dispose();
      settings.dispose();
    });
    testWidgets('store opens its products and product details / ar=$ar', (
      tester,
    ) async {
      final requests = <String>[];
      Future<Map<String, dynamic>> read(
        String path,
        Map<String, dynamic> query,
      ) async {
        requests.add(path);
        expect(query['kind'], 'clinic');
        return path.isEmpty
            ? {
                'stores': [
                  {
                    'id': 2,
                    'name': 'Fixture clinic',
                    'address': 'Fixture address',
                  },
                ],
              }
            : {
                'store': {
                  'name': 'Fixture clinic',
                  'address': 'Fixture address',
                },
                'products': [
                  {
                    'id': 9,
                    'name': 'Consultation',
                    'price': '125.00',
                    'unit': 'visit',
                    'description': 'Fixture description',
                    'options': [
                      {'label': 'Follow-up', 'price': '60.00'},
                    ],
                  },
                ],
              };
      }

      await tester.pumpWidget(
        app(
          CustomerStoreScreen(
            kind: 'clinic',
            title: ar ? 'عيادات' : 'Clinics',
            read: read,
          ),
          ar,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('go-store-item-2')));
      await tester.pumpAndSettle();
      expect(find.text('Consultation'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('go-store-item-9')));
      await tester.pumpAndSettle();
      expect(find.text('Fixture description'), findsOneWidget);
      expect(find.text('Follow-up'), findsOneWidget);
      expect(requests, ['', '/2']);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'store error can retry into an honest empty department / ar=$ar',
      (tester) async {
        var attempts = 0;
        await tester.pumpWidget(
          app(
            CustomerStoreScreen(
              kind: 'clinic',
              title: 'Clinics',
              read: (_, __) async {
                if (++attempts == 1) throw StateError('Offline');
                return {'stores': []};
              },
            ),
            ar,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(ar ? 'إعادة المحاولة' : 'Retry'));
        await tester.pumpAndSettle();
        expect(attempts, 2);
        expect(
          find.text(
            ar
                ? 'لا توجد متاجر مسجلة في هذا القسم حاليًا'
                : 'No stores are listed in this department yet',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('قريبًا'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
