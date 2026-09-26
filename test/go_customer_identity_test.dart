import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/helpers/theme/go_design_tokens.dart';
import 'package:go_drive_customer/helpers/translation/all_translation.dart';
import 'package:go_drive_customer/view/custom_widgets/buttons/custom_button.dart';
import 'package:go_drive_customer/view/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:go_drive_customer/view/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:go_drive_customer/view/custom_widgets/go_master_ui.dart';
import 'package:go_drive_customer/view/layout/home/widgets/go_customer_home_view.dart';
import 'package:go_drive_customer/view/layout/on_boarding/screen/go_guest_welcome_screen.dart';
import 'package:go_drive_customer/view/layout/request_delegate/widget/tracking_delegate_order_widget.dart';

Widget app(Widget child, {bool ar = true, double scale = 1}) {
  // Production initializes this before runApp. Mirror that contract for shared
  // controls that use the existing AppLocal extension rather than Material's locale.
  GlobalTranslations.locale = Locale(ar ? 'ar' : 'en');
  return MaterialApp(
    locale: GlobalTranslations.locale,
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, body) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: body!,
    ),
    home: child,
  );
}

GoCustomerHomeView home({bool ar = true, ValueChanged<GoService>? onService}) => GoCustomerHomeView(
  isArabic: ar, firstName: 'Omar', locationTitle: 'المنصورة', locationSubtitle: 'عنوان الخدمة',
  notificationCount: 2, onAddress: () {}, onNotifications: () {}, onService: onService ?? (_) {},
  drawer: const Drawer(child: Text('Menu')),
);

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

  test('guest artwork from the supplied reference decodes', () async {
    final svg = await rootBundle.loadString('assets/svg/go_guest_illustration.svg');
    final raw = svg.split('data:image/webp;base64,')[1].split('"')[0];
    final codec = await ui.instantiateImageCodec(base64Decode(raw));
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 157);
    expect(frame.image.height, 131);
    frame.image.dispose();
    codec.dispose();
  });

  test('all 19 existing profession API keys remain unchanged and unique', () {
    expect(goServices.map((s) => s.key).toList(), [
      'delivery_courier', 'appliance_technician', 'plumber', 'painter',
      'tile_installer', 'marble_installer', 'blacksmith', 'electrician',
      'satellite_technician', 'furniture_carpenter', 'ac_technician',
      'construction_worker', 'auto_mechanic', 'auto_electrician',
      'mens_barber', 'womens_hairdresser', 'tailor', 'male_cleaner', 'female_cleaner',
    ]);
    expect(goServices.map((s) => s.key).toSet().length, 19);
  });

  for (final width in [320.0, 390.0, 768.0]) {
    for (final ar in [true, false]) {
      testWidgets('home has no overflow at $width / Arabic=$ar', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(app(home(ar: ar), ar: ar));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('go-approved-home-v2')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final ar in [true, false]) {
    testWidgets('home supports enlarged text / Arabic=$ar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(home(ar: ar), ar: ar, scale: 1.6));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('service search preserves the booking callback', (tester) async {
    String? chosen;
    await tester.pumpWidget(app(home(onService: (s) => chosen = s.key)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('go-home-search')), 'سباك');
    await tester.pumpAndSettle();
    final plumber = find.byKey(const ValueKey('go-service-plumber'));
    await tester.ensureVisible(plumber);
    await tester.tap(plumber);
    expect(chosen, 'plumber');
    expect(find.byKey(const ValueKey('go-service-delivery_courier')), findsNothing);
  });

  testWidgets('all services action opens the real service selector', (tester) async {
    await tester.pumpWidget(app(home()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('go-home-book')));
    await tester.pumpAndSettle();
    expect(find.text('كل الخدمات'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final ar in [true, false]) {
    testWidgets('auth body scrolls with actual controls / Arabic=$ar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(Scaffold(body: GoAuthBody(isArabic: ar, children: [
        GoAuthTabs(register: false, isArabic: ar, onLogin: () {}, onRegister: () {}),
        const SizedBox(height: 24),
        CustomFormField(hintText: ar ? 'رقم الموبايل' : 'Mobile number'),
        const SizedBox(height: 14),
        CustomFormField(hintText: ar ? 'كلمة المرور' : 'Password', isPassword: true),
        const SizedBox(height: 20),
        CustomButton(key: const ValueKey('auth-submit'), text: ar ? 'تسجيل الدخول' : 'Sign in', onPressed: () {}),
        const SizedBox(height: 20),
        GoOrDivider(isArabic: ar),
      ])), ar: ar, scale: 1.6));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('password visibility changes presentation only', (tester) async {
    final controller = TextEditingController(text: 'example-password');
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(Scaffold(body: CustomFormField(controller: controller, isPassword: true))));
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isFalse);
    expect(controller.text, 'example-password');
  });

  testWidgets('white secondary button is not overpainted orange', (tester) async {
    var taps = 0;
    await tester.pumpWidget(app(Scaffold(body: CustomButton(
      color: Colors.white, borderColor: GoDesign.border, text: 'Secondary', onPressed: () => taps++))));
    final box = tester.widget<DecoratedBox>(find.descendant(
      of: find.byType(CustomButton), matching: find.byType(DecoratedBox)).first);
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, Colors.white);
    expect(decoration.gradient, isNull);
    await tester.tap(find.text('Secondary'));
    expect(taps, 1);
  });

  testWidgets('loading action keeps its space and cannot be submitted', (tester) async {
    var taps = 0;
    await tester.pumpWidget(app(Scaffold(body: CustomButton(text: 'Send', onPressed: () => taps++))));
    final before = tester.getSize(find.byType(CustomButton));
    await tester.pumpWidget(app(Scaffold(body: CustomButton(text: 'Send', isLoading: true, onPressed: () => taps++))));
    await tester.pump();
    expect(tester.getSize(find.byType(CustomButton)), before);
    await tester.tap(find.byType(CustomButton));
    expect(taps, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('dark detail headers correct legacy black title text', (tester) async {
    await tester.pumpWidget(app(Scaffold(appBar: CustomAppBar(
      title: const Text('Wallet', style: TextStyle(color: Colors.black))), body: const SizedBox.shrink())));
    expect(tester.widget<Text>(find.text('Wallet')).style?.color, GoDesign.paper);
    expect(tester.takeException(), isNull);
  });

  for (final ar in [true, false]) {
    testWidgets('guest welcome remains usable at small size / Arabic=$ar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var continued = false;
      await tester.pumpWidget(app(GoGuestWelcomeScreen(isArabic: ar,
        onContinue: () => continued = true, onLogin: () {}, onRegister: () {}), ar: ar, scale: 1.6));
      await tester.pumpAndSettle();
      final button = find.text(ar ? 'متابعة كزائر' : 'Continue as guest');
      await tester.ensureVisible(button);
      await tester.tap(button);
      expect(continued, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tracking renders actual status without mock timestamps', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const Scaffold(body: SingleChildScrollView(
      padding: EdgeInsets.all(20), child: TrackingDelegateOrderWidget(status: 'pending'))), ar: false, scale: 1.6));
    await tester.pumpAndSettle();
    expect(find.text('Current status'), findsOneWidget);
    expect(find.text('Finding a driver'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(app(const Scaffold(body: TrackingDelegateOrderWidget(status: 'cancelled')), ar: false));
    await tester.pumpAndSettle();
    expect(find.text('Order cancelled'), findsOneWidget);
    expect(find.text('Delivered'), findsNothing);
  });
}
