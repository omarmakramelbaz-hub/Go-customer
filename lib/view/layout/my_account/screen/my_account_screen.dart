import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import '../../address/screen/address_screen.dart';
import '../../auth/bottom_sheet/change_lang_bottom_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
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

  static const _orange = Color(0xFFE85504);
  static const _navy = Color(0xFF0B1721);
  static const _muted = Color(0xFF7C858E);
  static const _bg = Color(0xFFF7F8FA);
  static const _line = Color(0xFFE7EBEE);

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    final auth = context.watch<AuthController>();
    final signedIn = HiveMethods.getToken() != null;
    final name = signedIn
        ? (auth.profile?.name?.trim().isNotEmpty == true
            ? auth.profile!.name!.trim()
            : (ar ? 'مستخدم GO' : 'GO user'))
        : (ar ? 'أهلاً بك في GO' : 'Welcome to GO');
    final mobile = auth.profile?.mobile?.trim();

    void open(String route) => NamedNavigatorImpl.push(route);

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
            children: [
              Row(
                children: [
                  const GoDriveBrand(size: 31),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _line),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: _navy,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ProfileHeader(
                signedIn: signedIn,
                name: name,
                mobile: mobile,
                ar: ar,
                onLogin: () => open(LoginScreen.routeName),
              ),
              const SizedBox(height: 14),
              _PartnerCta(
                ar: ar,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PartnerApplicationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              if (signedIn) ...[
                _SectionTitle(title: ar ? 'الحساب' : 'Account'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingRow(
                      icon: Icons.person_outline_rounded,
                      title: 'personalInformation'.tr,
                      subtitle: ar
                          ? 'الاسم والصورة والبيانات الأساسية'
                          : 'Name, photo and basic information',
                      onTap: () => open(PersonalInformationScreen.routeName),
                    ),
                    _divider(),
                    _SettingRow(
                      icon: Icons.location_on_outlined,
                      title: ar ? 'عناويني' : 'My addresses',
                      subtitle: ar
                          ? 'إدارة عناوين الخدمة المحفوظة'
                          : 'Manage saved service addresses',
                      onTap: () => open(AddressScreen.routeName),
                    ),
                    _divider(),
                    _SettingRow(
                      icon: Icons.phone_iphone_rounded,
                      title: 'changePhoneNumber'.tr,
                      subtitle: ar
                          ? 'تحديث رقم الهاتف المسجل'
                          : 'Update your registered phone',
                      onTap: () => Utils.showAppBottomSheet(
                        enableDrag: true,
                        isScrollControlled: true,
                        const ChangePhoneNumberBottomSheet(),
                      ),
                    ),
                    _divider(),
                    _SettingRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'changePassword'.tr,
                      subtitle: ar
                          ? 'تغيير كلمة مرور حساب GO'
                          : 'Change your GO account password',
                      onTap: () => Utils.showAppBottomSheet(
                        isScrollControlled: true,
                        const ChangePasswordBottomSheet(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionTitle(title: ar ? 'الدفع' : 'Payments'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: ar ? 'المحفظة' : 'Wallet',
                      subtitle: ar
                          ? 'الرصيد وسجل العمليات'
                          : 'Balance and transaction history',
                      onTap: () => open(WalletScreen.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
              _SectionTitle(title: ar ? 'الإعدادات والدعم' : 'Settings & support'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SettingRow(
                    icon: Icons.language_rounded,
                    title: ar ? 'اللغة' : 'Language',
                    onTap: () =>
                        Utils.showAppBottomSheet(const ChangeLangBottomSheet()),
                  ),
                  _divider(),
                  _SettingRow(
                    icon: Icons.support_agent_rounded,
                    title: ar ? 'تواصل معنا' : 'Contact us',
                    onTap: () => open(ContactUsScreen.routeName),
                  ),
                  _divider(),
                  _SettingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'privacyPolicy'.tr,
                    onTap: () => open(PrivacyPolicyScreen.routeName),
                  ),
                  _divider(),
                  _SettingRow(
                    icon: Icons.description_outlined,
                    title: 'termsAndConditions'.tr,
                    onTap: () => open(TermsAndConditionsScreen.routeName),
                  ),
                ],
              ),
              if (signedIn) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(ar ? 'تسجيل الخروج؟' : 'Sign out?'),
                          content: Text(
                            ar
                                ? 'سيتم تسجيل خروجك من حساب GO على هذا الجهاز.'
                                : 'You will be signed out of your GO account on this device.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(ar ? 'إلغاء' : 'Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(ar ? 'تسجيل الخروج' : 'Sign out'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) await auth.logout();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(
                      ar ? 'تسجيل الخروج' : 'Sign out',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _orange,
                      side: const BorderSide(color: Color(0xFFFFC9AA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const DeleteAccountBtn(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _divider() => const Divider(
        height: 1,
        indent: 62,
        color: Color(0xFFF0F2F4),
      );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.signedIn,
    required this.name,
    required this.mobile,
    required this.ar,
    required this.onLogin,
  });

  final bool signedIn;
  final String name;
  final String? mobile;
  final bool ar;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: MyAccountScreen._line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E8),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: MyAccountScreen._orange,
              size: 38,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyAccountScreen._navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  signedIn
                      ? ((mobile == null || mobile!.isEmpty)
                          ? (ar ? 'حساب GO' : 'GO account')
                          : '+20 $mobile')
                      : (ar
                          ? 'سجّل الدخول لإدارة حسابك وطلباتك'
                          : 'Sign in to manage your account and requests'),
                  style: const TextStyle(
                    color: MyAccountScreen._muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!signedIn)
            FilledButton(
              onPressed: onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: MyAccountScreen._orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(ar ? 'دخول' : 'Sign in'),
            ),
        ],
      ),
    );
  }
}

class _PartnerCta extends StatelessWidget {
  const _PartnerCta({required this.ar, required this.onTap});

  final bool ar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF14344B), Color(0xFF081722)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1E0B1721),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.handyman_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ar ? 'انضم إلى شركاء GO' : 'Join GO Partners',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    ar
                        ? 'عندك مهنة أو خدمة؟ سجّل بياناتك وابدأ استقبال طلبات قريبة منك.'
                        : 'Have a trade or service? Apply and receive nearby customer requests.',
                    style: const TextStyle(
                      color: Color(0xFFC7D4DD),
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: MyAccountScreen._orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ar
                    ? Icons.arrow_back_rounded
                    : Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: MyAccountScreen._navy,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MyAccountScreen._line),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: MyAccountScreen._orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: MyAccountScreen._navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: MyAccountScreen._muted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFA7ADB3),
            ),
          ],
        ),
      ),
    );
  }
}
