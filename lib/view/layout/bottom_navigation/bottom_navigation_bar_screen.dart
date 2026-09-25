import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/hive/hive_methods.dart';
import '../../../helpers/routes/app_routers_import.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/translation/all_translation.dart';
import '../auth/screen/login_screen.dart';
import '../favorite/screen/favorite_screen.dart';
import '../home/screen/go_services_home_screen.dart';
import '../my_account/screen/my_account_screen.dart';
import '../notifications/controller/notifications_controller.dart';
import '../notifications/screen/notifications_screen.dart';
import '../request_delegate/screen/delegats_orders_screen.dart';
import '../wallet/controller/wallet_controller.dart';
import '../wallet/screen/wallet_screen.dart';
import 'controller/bottom_navigation_controller.dart';

class BottomNavigationBarScreen extends StatelessWidget {
  const BottomNavigationBarScreen({super.key});
  static const routeName = 'BottomNavigationBarScreen';

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => BottomNavigationController(),
    child: const _GoServicesShell(),
  );
}

class _GoServicesShell extends StatefulWidget {
  const _GoServicesShell();

  @override
  State<_GoServicesShell> createState() => _GoServicesShellState();
}

class _GoServicesShellState extends State<_GoServicesShell> {
  final Set<int> _visited = {0};

  void _openNotifications() {
    if (HiveMethods.getToken() == null) {
      NamedNavigatorImpl.push(LoginScreen.routeName);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => NotificationsController()..getNotifications(),
          child: const NotificationsScreen(),
        ),
      ),
    );
  }

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
        backgroundColor: const Color(0xFFF8F9FB),
        body: IndexedStack(
          index: nav.screenIndex,
          children: [
            GoServicesHomeScreen(onOpenNotifications: _openNotifications),
            if (_visited.contains(1) && authenticated)
              const DelegateOrdersScreen()
            else
              const SizedBox.shrink(),
            if (_visited.contains(2) && authenticated)
              ChangeNotifierProvider(
                create: (_) => WalletController()
                  ..initialWallet()
                  ..getWallet(),
                child: const WalletScreen(),
              )
            else
              const SizedBox.shrink(),
            if (_visited.contains(3) && authenticated)
              const FavoriteScreen()
            else
              const SizedBox.shrink(),
            if (_visited.contains(4))
              const MyAccountScreen()
            else
              const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 72,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFFFF1E5),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                color:
                    selected ? AppColors.mainAppColor : const Color(0xFF626A72),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: nav.screenIndex,
            onDestinationSelected: (index) {
              if (!authenticated && (index == 1 || index == 2 || index == 3)) {
                NamedNavigatorImpl.push(LoginScreen.routeName);
                return;
              }
              nav.updateIndex(index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: AppColors.mainAppColor,
                ),
                label: ar ? 'الرئيسية' : 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.mainAppColor,
                ),
                label: ar ? 'طلباتي' : 'Orders',
              ),
              NavigationDestination(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.mainAppColor,
                ),
                label: ar ? 'المحفظة' : 'Wallet',
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.mainAppColor,
                ),
                label: ar ? 'المفضلة' : 'Favorites',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: AppColors.mainAppColor,
                ),
                label: ar ? 'حسابي' : 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
