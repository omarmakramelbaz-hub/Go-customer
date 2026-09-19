import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/hive/hive_methods.dart';
import '../../../helpers/routes/app_routers_import.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/translation/all_translation.dart';
import '../../custom_widgets/go_drive_brand.dart';
import '../my_account/screen/my_account_screen.dart';
import '../notifications/controller/notifications_controller.dart';
import '../notifications/screen/notifications_screen.dart';
import '../request_delegate/screen/delegats_orders_screen.dart';
import 'controller/bottom_navigation_controller.dart';

class BottomNavigationBarScreen extends StatelessWidget {
  const BottomNavigationBarScreen({super.key});
  static const routeName = 'BottomNavigationBarScreen';

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => BottomNavigationController(),
    child: const _GoDriveShell(),
  );
}

class _GoDriveShell extends StatefulWidget {
  const _GoDriveShell();
  @override
  State<_GoDriveShell> createState() => _GoDriveShellState();
}

class _GoDriveShellState extends State<_GoDriveShell> {
  final Set<int> _visited = {0};

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BottomNavigationController>();
    final ar = context.languageCode == 'ar';
    final authenticated = HiveMethods.getToken() != null;
    _visited.add(nav.screenIndex);
    return PopScope(
      canPop: nav.screenIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) nav.updateIndex(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: nav.screenIndex,
          children: [
            authenticated
                ? const RequestDelegateScreen(showBackButton: false)
                : const _GuestHome(),
            if (_visited.contains(1) && authenticated)
              const DelegateOrdersScreen()
            else
              const SizedBox.shrink(),
            if (_visited.contains(2) && authenticated)
              ChangeNotifierProvider(
                create: (_) => NotificationsController()..getNotifications(),
                child: const NotificationsScreen(),
              )
            else
              const SizedBox.shrink(),
            if (_visited.contains(3))
              const MyAccountScreen()
            else
              const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: nav.screenIndex,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFE8D8),
          onDestinationSelected: (index) {
            if (!authenticated && (index == 1 || index == 2)) {
              NamedNavigatorImpl.push(LoginScreen.routeName);
              return;
            }
            nav.updateIndex(index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.delivery_dining_outlined),
              selectedIcon: Icon(
                Icons.delivery_dining,
                color: AppColors.mainAppColor,
              ),
              label: ar ? 'اطلب مندوب' : 'Book',
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              label: ar ? 'طلباتي' : 'Orders',
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_none_rounded),
              label: ar ? 'الإشعارات' : 'Notifications',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              label: ar ? 'حسابي' : 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestHome extends StatelessWidget {
  const _GuestHome();

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const GoDriveBrand(size: 48),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/images/deliveryRiderV2.png',
                  height: 190,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  ar ? 'محتاج توصل حاجة؟' : 'Need something delivered?',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ar
                      ? 'حدّد الاستلام والتسليم، اطلب مندوب، وتابع طلبك خطوة بخطوة.'
                      : 'Choose pickup and drop-off, request a courier, and track your delivery.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () =>
                      NamedNavigatorImpl.push(LoginScreen.routeName),
                  icon: const Icon(Icons.delivery_dining),
                  label: Text(ar ? 'اطلب مندوب' : 'Request a courier'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
