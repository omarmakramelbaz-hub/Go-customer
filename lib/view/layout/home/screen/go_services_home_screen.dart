import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import '../../auth/controller/auth_controller.dart';
import '../../bottom_navigation/controller/bottom_navigation_controller.dart';
import '../../partner_search/screen/profession_partners_screen.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../widgets/go_customer_home_view.dart';

/// Route-facing adapter: presentation changes must not change booking/auth APIs.
class GoServicesHomeScreen extends StatelessWidget {
  const GoServicesHomeScreen({super.key, required this.onOpenNotifications});
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    final ar = context.languageCode == 'ar';
    final signedIn = HiveMethods.getToken() != null;
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
    void selectTab(int index) {
      if (!signedIn && index != 0 && index != 4) {
        NamedNavigatorImpl.push('LoginScreen');
        return;
      }
      context.read<BottomNavigationController>().updateIndex(index);
    }
    void openAddress() => NamedNavigatorImpl.push(signedIn ? 'AddressScreen' : 'LoginScreen');

    return GoCustomerHomeView(
      isArabic: ar,
      firstName: name.isEmpty ? '' : name.split(RegExp(r'\s+')).first,
      locationTitle: city.isEmpty ? (ar ? 'موقعك الحالي' : 'Your location') : city,
      locationSubtitle: address.isEmpty ? (ar ? 'اختر عنوان الخدمة' : 'Choose service address') : address,
      notificationCount: profile?.notificaionsCount ?? HiveMethods.getNotificationsCount() ?? 0,
      onAddress: openAddress,
      onNotifications: onOpenNotifications,
      onService: (service) {
        if (service.key == 'delivery_courier') {
          NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfessionPartnersScreen(
              professionKey: service.key,
              title: ar ? service.ar : service.en,
            ),
          ));
        }
      },
      drawer: Drawer(
        backgroundColor: GoHomeStyle.ink,
        child: SafeArea(
          child: Builder(builder: (drawerContext) {
            Widget item(IconData icon, String title, VoidCallback action) => ListTile(
              leading: Icon(icon, color: GoHomeStyle.orange),
              title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(drawerContext).pop();
                action();
              },
            );
            return ListView(padding: const EdgeInsets.all(16), children: [
              const Align(alignment: AlignmentDirectional.centerStart, child: GoDriveBrand(size: 42, light: true)),
              const SizedBox(height: 20),
              Text(name.isEmpty ? (ar ? 'أهلاً بك في GO' : 'Welcome to GO') : name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              Text(signedIn ? (ar ? 'كل الخدمات عندك' : 'Every service, one app') : (ar ? 'تصفح الخدمات كزائر' : 'Explore as a guest'),
                  style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 18),
              const Divider(color: Colors.white12),
              item(Icons.home_outlined, ar ? 'الرئيسية' : 'Home', () => selectTab(0)),
              item(Icons.receipt_long_outlined, ar ? 'طلباتي' : 'My orders', () => selectTab(1)),
              item(Icons.account_balance_wallet_outlined, ar ? 'المحفظة' : 'Wallet', () => selectTab(2)),
              item(Icons.favorite_border, ar ? 'المفضلة' : 'Favorites', () => selectTab(3)),
              item(Icons.location_on_outlined, ar ? 'عناويني' : 'Addresses', openAddress),
              item(Icons.notifications_outlined, ar ? 'الإشعارات' : 'Notifications', onOpenNotifications),
              item(Icons.support_agent, ar ? 'المساعدة والدعم' : 'Help and support', () => NamedNavigatorImpl.push('ContactUsScreen')),
              item(Icons.description_outlined, ar ? 'الشروط والأحكام' : 'Terms and conditions', () => NamedNavigatorImpl.push('TermsAndConditionsScreen')),
              item(Icons.privacy_tip_outlined, ar ? 'سياسة الخصوصية' : 'Privacy policy', () => NamedNavigatorImpl.push('PrivacyPolicyScreen')),
              const Divider(color: Colors.white12),
              item(Icons.person_outline, ar ? 'إدارة حسابي' : 'Manage my account', () => selectTab(4)),
              if (!signedIn) item(Icons.login, ar ? 'تسجيل الدخول' : 'Sign in', () => NamedNavigatorImpl.push('LoginScreen')),
            ]);
          }),
        ),
      ),
    );
  }
}
