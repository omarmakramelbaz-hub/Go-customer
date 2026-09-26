import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/helpers/legal/go_customer_legal.dart';
import 'package:go_drive_customer/helpers/translation/all_translation.dart';
import 'package:go_drive_customer/view/custom_widgets/go_legal_document.dart';
import 'package:go_drive_customer/view/layout/my_account/screen/privacy_policy_screen.dart';
import 'package:go_drive_customer/view/layout/my_account/screen/terms_and_conditions_screen.dart';

Widget host(Widget child, {bool ar = true, double scale = 1}) {
  GlobalTranslations.locale = Locale(ar ? 'ar' : 'en');
  return MaterialApp(
    locale: GlobalTranslations.locale,
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, body) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: body!),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both documents are versioned, fully bilingual and specific to GO', () {
    expect(GoCustomerLegal.updatedAt, '2026-09-26');
    expect(GoCustomerLegal.terms.sections.length, 14);
    expect(GoCustomerLegal.privacy.sections.length, 15);
    for (final doc in [GoCustomerLegal.terms, GoCustomerLegal.privacy]) {
      expect(doc.sections.map((s) => s.id).toSet().length, doc.sections.length);
      for (final section in doc.sections) {
        expect(section.titleAr, isNotEmpty);
        expect(section.titleEn, isNotEmpty);
        expect(section.bodyAr.length, greaterThan(150));
        expect(section.bodyEn.length, greaterThan(150));
      }
      final text = [doc.summaryAr, doc.summaryEn,
        ...doc.sections.expand((s) => [s.titleAr, s.titleEn, s.bodyAr, s.bodyEn])].join('\n');
      for (final stale in ['فسخانجي', 'فسخانستا', 'فسخنجي', 'فسخنستا', 'Fasakhansta']) {
        expect(text.contains(stale), isFalse, reason: 'Unexpected restaurant copy: $stale');
      }
    }
  });

  test('terms preserve mutual agreement, final price and no duplicate commission', () {
    final quote = GoCustomerLegal.terms.sections.singleWhere((s) => s.id == 'quotes');
    expect(quote.bodyAr, contains('موافقة العميل والشريك'));
    expect(quote.bodyAr, contains('السعر النهائي'));
    expect(quote.bodyAr, contains('لا تضاف إليه عمولة'));
    expect(quote.bodyEn, contains('both the customer and partner accept'));
    final changes = GoCustomerLegal.terms.sections.singleWhere((s) => s.id == 'changes');
    expect(changes.bodyEn, contains('must not be collected twice'));
  });

  test('privacy discloses necessary pre-acceptance sharing and shared systems', () {
    final sharing = GoCustomerLegal.privacy.sections.singleWhere((s) => s.id == 'partners');
    expect(sharing.bodyAr, contains('قبل قبول العرض'));
    final shared = GoCustomerLegal.privacy.sections.singleWhere((s) => s.id == 'shared-systems');
    expect(shared.bodyEn, contains('shared backend services'));
    final rights = GoCustomerLegal.privacy.sections.singleWhere((s) => s.id == 'rights');
    expect(rights.bodyEn, contains('Uninstalling alone does not delete an account'));
  });

  test('policy routes cannot load shared restaurant legal fields', () {
    for (final path in [
      'lib/view/layout/my_account/screen/privacy_policy_screen.dart',
      'lib/view/layout/my_account/screen/terms_and_conditions_screen.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains('GoCustomerLegal.'));
      expect(source, isNot(contains('getSetting')));
      expect(source, isNot(contains('MyAccountController')));
      expect(source, isNot(contains('setting?.privacy')));
      expect(source, isNot(contains('setting?.terms')));
    }
    expect(PrivacyPolicyScreen.routeName, 'PrivacyPolicyScreen');
    expect(TermsAndConditionsScreen.routeName, 'TermsAndConditionsScreen');
  });

  for (final ar in [true, false]) {
    for (final width in [320.0, 390.0, 768.0]) {
      for (final privacy in [true, false]) {
        testWidgets('policy works without session/providers ar=$ar width=$width privacy=$privacy', (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final doc = privacy ? GoCustomerLegal.privacy : GoCustomerLegal.terms;
          await tester.pumpWidget(host(privacy ? const PrivacyPolicyScreen() : const TermsAndConditionsScreen(),
            ar: ar, scale: width == 320 ? 1.6 : 1));
          await tester.pumpAndSettle();
          expect(find.byKey(ValueKey('go-legal-${doc.id}')), findsOneWidget);
          expect(Directionality.of(tester.element(find.byKey(ValueKey('go-legal-${doc.id}')))),
            ar ? TextDirection.rtl : TextDirection.ltr);
          for (final section in doc.sections) {
            expect(find.text(section.title(ar)), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byKey(const ValueKey('go-legal-support')));
          await tester.pumpAndSettle();
          expect(find.text(GoCustomerLegal.revision), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('support and related-policy buttons invoke their supplied actions', (tester) async {
    var support = 0;
    var related = 0;
    await tester.pumpWidget(host(GoLegalDocumentView(document: GoCustomerLegal.privacy,
      onSupport: () => support++, onRelatedDocument: () => related++)));
    await tester.pumpAndSettle();
    final supportButton = find.byKey(const ValueKey('go-legal-support'));
    final relatedButton = find.byKey(const ValueKey('go-legal-related'));
    await tester.ensureVisible(supportButton);
    await tester.pumpAndSettle();
    await tester.tap(supportButton);
    await tester.ensureVisible(relatedButton);
    await tester.pumpAndSettle();
    await tester.tap(relatedButton);
    expect(support, 1);
    expect(related, 1);
    expect(tester.takeException(), isNull);
  });
}
