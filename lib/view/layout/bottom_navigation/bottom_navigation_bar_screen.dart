import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/hive/hive_methods.dart';
import '../../../helpers/routes/app_routers_import.dart';
import '../../../helpers/theme/go_design_tokens.dart';
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
    create: (_) => BottomNavigationController(), child: const _GoServicesShell());
}

class _GoServicesShell extends StatefulWidget {
  const _GoServicesShell();
  @override
  State<_GoServicesShell> createState() => _GoServicesShellState();
}

class _GoServicesShellState extends State<_GoServicesShell> {
  final Set<int> _visited = {0};
  void _openNotifications() {
    if (HiveMethods.getToken() == null) { NamedNavigatorImpl.push(LoginScreen.routeName); return; }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangeNotifierProvider(
      create: (_) => NotificationsController()..getNotifications(), child: const NotificationsScreen())));
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BottomNavigationController>();
    final ar = context.languageCode == 'ar';
    final authenticated = HiveMethods.getToken() != null;
    _visited.add(nav.screenIndex);
    return PopScope(canPop: nav.screenIndex == 0,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) nav.updateIndex(0); },
      child: Scaffold(backgroundColor: GoDesign.paper,
        body: IndexedStack(index: nav.screenIndex, children: [
          GoServicesHomeScreen(onOpenNotifications: _openNotifications),
          if (_visited.contains(1) && authenticated) const DelegateOrdersScreen() else const SizedBox.shrink(),
          if (_visited.contains(2) && authenticated)
            ChangeNotifierProvider(create: (_) => WalletController()..initialWallet()..getWallet(), child: const WalletScreen())
          else const SizedBox.shrink(),
          if (_visited.contains(3) && authenticated) const FavoriteScreen() else const SizedBox.shrink(),
          if (_visited.contains(4)) const MyAccountScreen() else const SizedBox.shrink(),
        ]),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: GoDesign.border))),
          child: BottomNavigationBar(type: BottomNavigationBarType.fixed,
            currentIndex: nav.screenIndex, elevation: 0, backgroundColor: GoDesign.paper,
            selectedItemColor: GoDesign.orange, unselectedItemColor: GoDesign.muted,
            selectedFontSize: 11, unselectedFontSize: 11, iconSize: 23,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            showSelectedLabels: true, showUnselectedLabels: true,
            onTap: (index) {
              if (!authenticated && (index == 1 || index == 2 || index == 3)) {
                NamedNavigatorImpl.push(LoginScreen.routeName); return;
              }
              nav.updateIndex(index);
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home_rounded), label: ar ? 'الرئيسية' : 'Home'),
              BottomNavigationBarItem(icon: const Icon(Icons.receipt_long_outlined), activeIcon: const Icon(Icons.receipt_long_rounded), label: ar ? 'طلباتي' : 'Orders'),
              BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), activeIcon: const Icon(Icons.account_balance_wallet_rounded), label: ar ? 'المحفظة' : 'Wallet'),
              BottomNavigationBarItem(icon: const Icon(Icons.favorite_border_rounded), activeIcon: const Icon(Icons.favorite_rounded), label: ar ? 'المفضلة' : 'Favorites'),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), activeIcon: const Icon(Icons.person_rounded), label: ar ? 'حسابي' : 'Account'),
            ],
          ),
        ),
      ),
    );
  }
}
