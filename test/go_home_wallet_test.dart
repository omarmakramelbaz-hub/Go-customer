import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/helpers/translation/all_translation.dart';
import 'package:go_drive_customer/view/layout/home/widgets/go_customer_home_view.dart';
import 'package:go_drive_customer/view/layout/home/widgets/go_home_wallet_card.dart';
import 'package:go_drive_customer/view/layout/home/widgets/service_photo_sprite.dart';

Widget preview({
  required bool ar,
  required Widget wallet,
  double scale = 1,
  GlobalKey? boundary,
}) {
  GlobalTranslations.locale = Locale(ar ? 'ar' : 'en');
  return MaterialApp(
    locale: GlobalTranslations.locale,
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(fontFamily: 'Tajawal'),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(
          key: boundary,
          child: GoCustomerHomeView(
            isArabic: ar,
            firstName: '',
            locationTitle: ar ? 'موقعك الحالي' : 'Your location',
            locationSubtitle: ar ? 'مصر' : 'Egypt',
            notificationCount: 0,
            onAddress: () {},
            onNotifications: () {},
            onService: (_) {},
            drawer: const Drawer(),
            wallet: wallet,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Tajawal')
          ..addFont(rootBundle.load('assets/font/Tajawal/Tajawal-Regular.ttf'))
          ..addFont(rootBundle.load('assets/font/Tajawal/Tajawal-Bold.ttf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final width in [320.0, 390.0, 768.0]) {
    for (final ar in [true, false]) {
      testWidgets(
        'wallet stays beside headline with working actions: $width / ar=$ar',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 960));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final actions = <GoHomeWalletAction>[];
          final boundary = GlobalKey();
          await tester.pumpWidget(
            preview(
              ar: ar,
              scale: width == 320 ? 1.6 : 1,
              boundary: boundary,
              wallet: GoHomeWalletCard(
                isArabic: ar,
                signedIn: true,
                balance: 1250.50,
                onAction: actions.add,
              ),
            ),
          );
          await tester.runAsync(() async {
            final context = tester.element(find.byType(GoCustomerHomeView));
            await precacheImage(
              const AssetImage(GoHomeWalletCard.artwork),
              context,
            );
            await precacheImage(MemoryImage(goServiceSpriteBytes), context);
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('1250.50'), findsOneWidget);
          final wallet = tester.getRect(
            find.byKey(const ValueKey('go-home-wallet')),
          );
          final title = tester.getRect(
            find.byKey(const ValueKey('go-home-headline')),
          );
          expect(
            ar ? wallet.right < title.left : title.right < wallet.left,
            isTrue,
          );
          for (final action in GoHomeWalletAction.values) {
            final button = find.byKey(
              ValueKey('go-home-wallet-${action.name}'),
            );
            expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
            await tester.tap(button);
          }
          expect(actions, GoHomeWalletAction.values);
          final chargeX = tester
              .getCenter(find.byKey(const ValueKey('go-home-wallet-topUp')))
              .dx;
          final historyX = tester
              .getCenter(find.byKey(const ValueKey('go-home-wallet-history')))
              .dx;
          expect(ar ? chargeX > historyX : chargeX < historyX, isTrue);
          if (ar && width == 390) {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await render.toImage(pixelRatio: 2);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File('build/ui-preview/home-leather-wallet-ar.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        },
      );
    }
  }

  testWidgets(
    'zero, negative, unavailable and guest states never show a made-up balance',
    (tester) async {
      for (final balance in [0.0, -25.50, null]) {
        await tester.pumpWidget(
          preview(
            ar: true,
            wallet: GoHomeWalletCard(
              isArabic: true,
              signedIn: true,
              balance: balance,
              hasError: balance == null,
              onAction: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(balance?.toStringAsFixed(2) ?? '—'), findsOneWidget);
        if (balance == null) {
          expect(find.text('0.00'), findsNothing);
          expect(find.text('تعذّر التحديث'), findsOneWidget);
        }
      }
      await tester.pumpWidget(
        preview(
          ar: true,
          wallet: GoHomeWalletCard(
            isArabic: true,
            signedIn: false,
            balance: 900,
            onAction: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('900.00'), findsNothing);
      expect(find.text('سجّل الدخول'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
