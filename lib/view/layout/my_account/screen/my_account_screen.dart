import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../address/screen/address_screen.dart';
import '../../auth/bottom_sheet/change_lang_bottom_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
import '../../notifications/controller/notifications_controller.dart';
import '../../notifications/screen/notifications_screen.dart';
import '../../partner_application/screen/partner_application_screen.dart';
import '../../vendor_and_delivery_register/screen/widgets/delete_account_btn.dart';
import '../../wallet/screen/wallet_screen.dart';
import '../bottom_sheet/change_password_bottom_sheet.dart';
import '../widgets/change_phone_number_bottom_sheet.dart';
import 'contact_us_screen.dart';
import 'personal_information_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    final auth = context.watch<AuthController>();
    final signedIn = HiveMethods.getToken() != null;
    final profile = signedIn ? auth.profile : null;
    final name = profile?.name?.trim();
    final mobile = profile?.mobile?.trim();
    final photo = profile?.photoProfile?.trim();
    void open(String route) => NamedNavigatorImpl.push(route);
    Widget row(IconData icon, String label, VoidCallback action, {bool accent = false}) => Column(children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Icon(icon, color: accent ? GoDesign.orange : GoDesign.ink, size: 22),
        title: Text(label, style: TextStyle(color: accent ? GoDesign.orange : GoDesign.ink,
          fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Icon(ar ? Icons.chevron_left : Icons.chevron_right, size: 19, color: GoDesign.muted),
        onTap: action,
      ),
      const Divider(height: 1, color: GoDesign.border),
    ]);

    return Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(backgroundColor: GoDesign.paper,
        appBar: CustomAppBar(title: Text(ar ? 'حسابي' : 'My account')),
        body: SafeArea(top: false, child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          children: [
            Center(child: ClipOval(child: Container(
              color: GoDesign.canvas, width: 76, height: 76,
              child: photo != null && photo.isNotEmpty
                  ? Image.network(photo, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person_outline, size: 40, color: GoDesign.ink))
                  : const Icon(Icons.person_outline, size: 40, color: GoDesign.ink)))),
            const SizedBox(height: 12),
            Text(name != null && name.isNotEmpty ? name : (ar ? 'أهلاً بك في GO' : 'Welcome to GO'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: GoDesign.ink, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(signedIn && mobile != null && mobile.isNotEmpty
                ? mobile
                : (ar ? 'كل الخدمات عندك' : 'Every service, one app'),
              textAlign: TextAlign.center, textDirection: TextDirection.ltr,
              style: const TextStyle(color: GoDesign.muted, fontSize: 13)),
            const SizedBox(height: 22),
            if (signedIn) ...[
              row(Icons.person_outline, ar ? 'بياناتي الشخصية' : 'Personal information',
                () => open(PersonalInformationScreen.routeName)),
              row(Icons.location_on_outlined, ar ? 'عناويني' : 'My addresses',
                () => open(AddressScreen.routeName)),
              row(Icons.account_balance_wallet_outlined, ar ? 'المحفظة' : 'Wallet',
                () => open(WalletScreen.routeName)),
              row(Icons.notifications_outlined, ar ? 'الإشعارات' : 'Notifications', () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangeNotifierProvider(
                  create: (_) => NotificationsController()..getNotifications(),
                  child: const NotificationsScreen())));
              }),
              row(Icons.phone_outlined, 'changePhoneNumber'.tr, () => Utils.showAppBottomSheet(
                enableDrag: true, isScrollControlled: true, const ChangePhoneNumberBottomSheet())),
              row(Icons.lock_outline, 'changePassword'.tr, () => Utils.showAppBottomSheet(
                isScrollControlled: true, const ChangePasswordBottomSheet())),
            ] else
              row(Icons.login, ar ? 'تسجيل الدخول' : 'Sign in', () => open(LoginScreen.routeName), accent: true),
            row(Icons.support_agent_outlined, ar ? 'المساعدة والدعم' : 'Help and support',
              () => open(ContactUsScreen.routeName)),
            row(Icons.description_outlined, 'termsAndConditions'.tr, () => open(TermsAndConditionsScreen.routeName)),
            row(Icons.privacy_tip_outlined, 'privacyPolicy'.tr, () => open(PrivacyPolicyScreen.routeName)),
            row(Icons.language, ar ? 'اللغة' : 'Language',
              () => Utils.showAppBottomSheet(const ChangeLangBottomSheet())),
            const SizedBox(height: 20),
            // Keep the existing partner application available to visitors too.
            GoSurface(padding: EdgeInsets.zero, child: ListTile(
              leading: const Icon(Icons.handyman_outlined, color: GoDesign.orange),
              title: Text(ar ? 'انضم إلى شركاء GO' : 'Join GO Partners',
                style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(ar ? 'قدّم خدماتك واستقبل طلبات قريبة منك' : 'Offer your services to nearby customers'),
              trailing: const Icon(Icons.add_circle_outline, color: GoDesign.orange),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PartnerApplicationScreen())))),
            if (signedIn) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: Text(ar ? 'تسجيل الخروج' : 'Sign out'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
                    title: Text(ar ? 'تسجيل الخروج؟' : 'Sign out?'),
                    content: Text(ar ? 'سيتم تسجيل خروجك من حساب GO على هذا الجهاز.'
                      : 'You will be signed out of your GO account on this device.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(ar ? 'إلغاء' : 'Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(ar ? 'تسجيل الخروج' : 'Sign out')),
                    ],
                  ));
                  if (confirmed == true) await auth.logout();
                },
              ),
              const SizedBox(height: 12),
              const DeleteAccountBtn(),
            ],
          ],
        )),
      ),
    );
  }
}
