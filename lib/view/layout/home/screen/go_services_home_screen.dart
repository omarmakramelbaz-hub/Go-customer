import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import '../../auth/controller/auth_controller.dart';
import '../../bottom_navigation/controller/bottom_navigation_controller.dart';
import '../../partner_search/screen/profession_partners_screen.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../widgets/go_customer_home_view.dart';

/// Route adapter: service keys, auth guards and booking destinations stay intact.
class GoServicesHomeScreen extends StatelessWidget {
  const GoServicesHomeScreen({super.key, required this.onOpenNotifications});
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final signedIn = HiveMethods.getToken() != null;
    final profile = signedIn ? auth.profile : null;
    final ar = context.languageCode == 'ar';
    var city = (profile?.cityName ?? HiveMethods.getCity() ?? '').trim();
    var address = (profile?.address ?? profile?.areaTitle ?? '').trim();
    final selectedId = HiveMethods.getSelectedCity();
    for (final item in profile?.userAddresses ?? []) {
      if (selectedId != null && item.id == selectedId) {
        city = (item.cityName ?? city).trim();
        address = (item.streetName ?? item.addressName ?? item.areaName ?? item.address ?? address).trim();
        break;
      }
    }
    final name = (profile?.name ?? '').trim();
    final photo = profile?.photoProfile?.trim() ?? '';
    void selectTab(int index) {
      if (!signedIn && index != 0 && index != 4) {
        NamedNavigatorImpl.push('LoginScreen');
        return;
      }
      context.read<BottomNavigationController>().updateIndex(index);
    }
    void openAddress() => NamedNavigatorImpl.push(signedIn ? 'AddressScreen' : 'LoginScreen');
    Future<void> signOut() async {
      final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
        title: Text(ar ? 'تسجيل الخروج؟' : 'Sign out?'),
        content: Text(ar ? 'سيتم تسجيل خروجك من حساب GO على هذا الجهاز.'
          : 'You will be signed out of your GO account on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(ar ? 'إلغاء' : 'Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: Text(ar ? 'تسجيل الخروج' : 'Sign out')),
        ],
      ));
      if (confirmed == true) await auth.logout();
    }

    return GoCustomerHomeView(
      isArabic: ar, firstName: name.isEmpty ? '' : name.split(RegExp(r'\s+')).first,
      locationTitle: city.isEmpty ? (ar ? 'موقعك الحالي' : 'Your location') : city,
      locationSubtitle: address.isEmpty ? (ar ? 'اختر عنوان الخدمة' : 'Choose service address') : address,
      notificationCount: signedIn ? profile?.notificaionsCount ?? HiveMethods.getNotificationsCount() ?? 0 : 0,
      onAddress: openAddress, onNotifications: onOpenNotifications,
      onService: (service) {
        if (service.key == 'delivery_courier') NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
        else Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfessionPartnersScreen(
          professionKey: service.key, title: ar ? service.ar : service.en)));
      },
      drawer: Drawer(backgroundColor: GoDesign.deepInk,
        child: SafeArea(child: Builder(builder: (drawerContext) {
          Widget item(IconData icon, String title, VoidCallback action, {bool selected = false, bool accent = false}) =>
            Padding(padding: const EdgeInsets.only(bottom: 4), child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              selected: selected, selectedTileColor: GoDesign.orange.withValues(alpha: .12),
              leading: Icon(icon, color: selected || accent ? GoDesign.orange : Colors.white, size: 22),
              title: Text(title, style: TextStyle(color: selected || accent ? GoDesign.orange : Colors.white,
                fontSize: 15, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
              onTap: () { Navigator.of(drawerContext).pop(); action(); },
            ));
          return ListView(padding: const EdgeInsets.fromLTRB(14, 22, 14, 18), children: [
            InkWell(onTap: () { Navigator.of(drawerContext).pop(); selectTab(4); },
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10), child: Row(children: [
                ClipOval(child: Container(width: 56, height: 56, color: GoDesign.paper,
                  child: photo.isEmpty ? const Icon(Icons.person_outline, color: GoDesign.ink, size: 30)
                    : Image.network(photo, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person_outline, color: GoDesign.ink, size: 30)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name.isEmpty ? (ar ? 'أهلاً بك في GO' : 'Welcome to GO') : name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(signedIn ? (ar ? 'حساب العميل' : 'Customer account') : (ar ? 'تصفح كزائر' : 'Guest browsing'),
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ])),
              ]))),
            const SizedBox(height: 18),
            item(Icons.home_rounded, ar ? 'الرئيسية' : 'Home', () => selectTab(0), selected: true),
            item(Icons.receipt_long_outlined, ar ? 'طلباتي' : 'My orders', () => selectTab(1)),
            item(Icons.account_balance_wallet_outlined, ar ? 'المحفظة' : 'Wallet', () => selectTab(2)),
            item(Icons.favorite_border, ar ? 'المفضلة' : 'Favorites', () => selectTab(3)),
            item(Icons.location_on_outlined, ar ? 'عناويني' : 'Addresses', openAddress),
            item(Icons.notifications_outlined, ar ? 'الإشعارات' : 'Notifications', onOpenNotifications),
            item(Icons.support_agent, ar ? 'المساعدة والدعم' : 'Help and support', () => NamedNavigatorImpl.push('ContactUsScreen')),
            item(Icons.description_outlined, ar ? 'الشروط والأحكام' : 'Terms and conditions', () => NamedNavigatorImpl.push('TermsAndConditionsScreen')),
            item(Icons.privacy_tip_outlined, ar ? 'سياسة الخصوصية' : 'Privacy policy', () => NamedNavigatorImpl.push('PrivacyPolicyScreen')),
            item(Icons.info_outline, ar ? 'عن التطبيق' : 'About the app', () => showAboutDialog(context: context,
              applicationName: 'Go Customer', applicationIcon: const GoDriveBrand(size: 26),
              children: [Text(ar ? 'كل الخدمات عندك' : 'Every service, one app')])),
            const Divider(color: Colors.white12),
            item(Icons.person_outline, ar ? 'إدارة حسابي' : 'Manage my account', () => selectTab(4)),
            if (signedIn) item(Icons.logout_rounded, ar ? 'تسجيل الخروج' : 'Sign out', signOut, accent: true)
            else item(Icons.login, ar ? 'تسجيل الدخول' : 'Sign in', () => NamedNavigatorImpl.push('LoginScreen'), accent: true),
          ]);
        })),
      ),
    );
  }
}
