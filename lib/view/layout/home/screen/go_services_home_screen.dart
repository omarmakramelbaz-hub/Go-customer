import '../../../custom_widgets/popups/go_popups.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../go_services/service_api.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import '../../auth/controller/auth_controller.dart';
import '../../address/screen/address_screen.dart';
import '../../address/model/address_model.dart';
import '../../bottom_navigation/controller/bottom_navigation_controller.dart';
import '../../partner_search/screen/profession_partners_screen.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../widgets/go_customer_home_view.dart';
import '../widgets/go_home_wallet_card.dart';
import '../../auth/screen/login_screen.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../../my_account/screen/personal_information_screen.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../../wallet/bottom_sheet/charge_wallet_bottom_sheet.dart';
import '../../wallet/bottom_sheet/mony_transfer_bottom_sheet.dart';
import '../../wallet/bottom_sheet/wallet_history_bottom_sheet.dart';

/// Route adapter: service keys, auth guards and booking destinations stay intact.
class GoServicesHomeScreen extends StatefulWidget {
  const GoServicesHomeScreen({
    super.key,
    required this.onOpenNotifications,
    this.active = true,
  });
  final VoidCallback onOpenNotifications;
  final bool active;
  @override
  State<GoServicesHomeScreen> createState() => _GoServicesHomeScreenState();
}

class _GoServicesHomeScreenState extends State<GoServicesHomeScreen>
    with WidgetsBindingObserver {
  Timer? _walletTimer;
  bool _foreground = true;
  String? _session;
  bool _walletActionOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    goWalletChanges.addListener(_refreshWallet);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshWallet());
    _walletTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshWallet(),
    );
  }

  void _refreshWallet() {
    if (!mounted ||
        !widget.active ||
        !_foreground ||
        !(ModalRoute.of(context)?.isCurrent ?? true))
      return;
    context.read<WalletController>().getWallet();
  }

  @override
  void didUpdateWidget(covariant GoServicesHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshWallet());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) _refreshWallet();
  }

  @override
  void dispose() {
    _walletTimer?.cancel();
    goWalletChanges.removeListener(_refreshWallet);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _walletAction(GoHomeWalletAction action) async {
    if (_walletActionOpen) return;
    _walletActionOpen = true;
    try {
      if (HiveMethods.getToken() == null || HiveMethods.isGuestMode()) {
        await Navigator.of(context).pushNamed(LoginScreen.routeName);
        return;
      }
      final wallet = context.read<WalletController>();
      final settings = context.read<MyAccountController>();
      if (action == GoHomeWalletAction.topUp) {
        if (settings.setting?.walletCardActivate == 'false' &&
            settings.setting?.paymentCardActivate == 'false')
          return;
        if (context.read<AuthController>().profile?.email == null) {
          await Navigator.of(context)
              .pushNamed(PersonalInformationScreen.routeName);
            return;
        }
      }
      wallet.getWallet();
      await showGoModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        elevation: 0,
        isScrollControlled: true,
        enableDrag: true,
        builder: (_) => ChangeNotifierProvider.value(
          value: wallet,
          child: switch (action) {
            GoHomeWalletAction.topUp => ChargeWalletBottomSheet(
              walletController: wallet,
              myAccountController: settings,
            ),
            GoHomeWalletAction.transfer => MoneyTransferBottomSheet(
              walletController: wallet,
            ),
            GoHomeWalletAction.history => const WalletHistoryBottomSheet(),
          },
        ),
      );
      _refreshWallet();
    } finally {
      _walletActionOpen = false;
      _refreshWallet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final token = HiveMethods.isGuestMode() ? null : HiveMethods.getToken();
    final signedIn = token != null && token.isNotEmpty;
    if (_session != token) {
      _session = token;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshWallet());
    }
    final wallet = context.watch<WalletController>();
    final settings = context.watch<MyAccountController>();
    final profile = signedIn ? auth.profile : null;
    final ar = context.languageCode == 'ar';
    var city = (profile?.cityName ?? HiveMethods.getCity() ?? '').trim();
    var address = (profile?.address ?? profile?.areaTitle ?? '').trim();
    final savedAddress = profile?.id == null ? null : HiveMethods.getDeliveryAddress(profile!.id!);
    if (savedAddress != null) {
      final selected = AddressModel.fromJson(savedAddress);
      city = (selected.cityName ?? selected.cityname ?? city).trim();
      address = [selected.address, selected.streetName, selected.areaName, selected.addressName]
          .whereType<String>().map((value) => value.trim()).firstWhere((value) => value.isNotEmpty, orElse: () => address);
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
    Future<void> openAddress() async {
      if (!signedIn) { await Navigator.of(context).pushNamed('LoginScreen'); return; }
      final selected = await Navigator.of(context).push<AddressModel>(MaterialPageRoute(
        builder: (_) => const AddressScreen(selectForDelivery: true),
      ));
      if (!mounted) return;
      if (selected == null || profile?.id == null) { setState(() {}); return; }
      await HiveMethods.saveDeliveryAddress(profile!.id!, selected.toJson());
      final lat = double.tryParse(selected.lat ?? '');
      final lng = double.tryParse(selected.lng ?? '');
      if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) {
        HiveMethods.updateLat(lat); HiveMethods.updateLan(lng);
      }
      if (mounted) setState(() {});
    }
    Future<void> signOut() async {
      final confirmed = await showGoDialog<bool>(context: context, builder: (dialog) => AlertDialog(
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
      wallet: GoHomeWalletCard(
        isArabic: ar, signedIn: signedIn,
        balance: wallet.wallet?.balance,
        isLoading: wallet.walletResponse.state == ResponseState.loading,
        hasError: [ResponseState.error, ResponseState.offline, ResponseState.unauthorized].contains(wallet.walletResponse.state),
        canTopUp: !(settings.setting?.walletCardActivate == 'false' && settings.setting?.paymentCardActivate == 'false'),
        onAction: _walletAction,
      ),
      isArabic: ar, firstName: name.isEmpty ? '' : name.split(RegExp(r'\s+')).first,
      locationTitle: city.isEmpty ? (ar ? 'موقعك الحالي' : 'Your location') : city,
      locationSubtitle: address.isEmpty ? (ar ? 'اختر عنوان التوصيل' : 'Choose delivery address') : address,
      notificationCount: signedIn ? profile?.notificaionsCount ?? HiveMethods.getNotificationsCount() ?? 0 : 0,
      onAddress: openAddress, onNotifications: widget.onOpenNotifications,
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
            item(Icons.notifications_outlined, ar ? 'الإشعارات' : 'Notifications', widget.onOpenNotifications),
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
