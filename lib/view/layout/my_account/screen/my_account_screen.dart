import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import '../../auth/bottom_sheet/change_lang_bottom_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../vendor_and_delivery_register/screen/widgets/delete_account_btn.dart';
import '../bottom_sheet/change_password_bottom_sheet.dart';
import '../widgets/change_phone_number_bottom_sheet.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    final auth = context.watch<AuthController>();
    final signedIn = HiveMethods.getToken() != null;
    Widget item(IconData icon, String title, VoidCallback action) => ListTile(
      leading: Icon(icon, color: const Color(0xFFE85504)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: action,
    );
    void open(String route) => NamedNavigatorImpl.push(route);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const GoDriveBrand(size: 34),
            const SizedBox(height: 24),
            Text(
              ar ? 'حسابي' : 'My account',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              signedIn
                  ? (auth.profile?.name ?? '')
                  : (ar ? 'أهلًا بك في Go Drive' : 'Welcome to Go Drive'),
            ),
            const SizedBox(height: 20),
            if (signedIn)
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    item(
                      Icons.person_outline_rounded,
                      'personalInformation'.tr,
                      () => open(PersonalInformationScreen.routeName),
                    ),
                    item(
                      Icons.account_balance_wallet_outlined,
                      ar ? 'المحفظة' : 'Wallet',
                      () => open(WalletScreen.routeName),
                    ),
                    item(
                      Icons.location_on_outlined,
                      ar ? 'عناويني' : 'My addresses',
                      () => open(AddressScreen.routeName),
                    ),
                    item(
                      Icons.phone_iphone_rounded,
                      'changePhoneNumber'.tr,
                      () => Utils.showAppBottomSheet(
                        enableDrag: true,
                        isScrollControlled: true,
                        const ChangePhoneNumberBottomSheet(),
                      ),
                    ),
                    item(
                      Icons.lock_outline_rounded,
                      'changePassword'.tr,
                      () => Utils.showAppBottomSheet(
                        isScrollControlled: true,
                        const ChangePasswordBottomSheet(),
                      ),
                    ),
                  ],
                ),
              )
            else
              FilledButton(
                onPressed: () => open(LoginScreen.routeName),
                child: Text(
                  ar ? 'تسجيل الدخول / إنشاء حساب' : 'Sign in / Create account',
                ),
              ),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  item(
                    Icons.language_rounded,
                    ar ? 'اللغة' : 'Language',
                    () =>
                        Utils.showAppBottomSheet(const ChangeLangBottomSheet()),
                  ),
                  item(
                    Icons.support_agent_rounded,
                    ar ? 'تواصل معنا' : 'Contact us',
                    () => open(ContactUsScreen.routeName),
                  ),
                  item(
                    Icons.privacy_tip_outlined,
                    'privacyPolicy'.tr,
                    () => open(PrivacyPolicyScreen.routeName),
                  ),
                  item(
                    Icons.description_outlined,
                    'termsAndConditions'.tr,
                    () => open(TermsAndConditionsScreen.routeName),
                  ),
                ],
              ),
            ),
            if (signedIn) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(ar ? 'تسجيل الخروج؟' : 'Sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(ar ? 'إلغاء' : 'Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(ar ? 'تسجيل الخروج' : 'Sign out'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) await auth.logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(ar ? 'تسجيل الخروج' : 'Sign out'),
              ),
              const SizedBox(height: 12),
              Text(
                ar ? 'حسابك مشترك مع فسخانستا؛ حذف الحساب يسري على التطبيقين.' : 'Your account is shared with Fasakhansta. Deleting it applies to both apps.',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const DeleteAccountBtn(),
            ],
          ],
        ),
      ),
    );
  }
}
