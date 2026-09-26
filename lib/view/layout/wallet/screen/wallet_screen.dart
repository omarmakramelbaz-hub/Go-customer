import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../../my_account/screen/personal_information_screen.dart';
import '../bottom_sheet/charge_wallet_bottom_sheet.dart';
import '../bottom_sheet/mony_transfer_bottom_sheet.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_model.dart';
import '../widget/my_current_balance_widget.dart';
import '../widget/recent_transactions_widget.dart';

class WalletScreen extends StatefulWidget {
  static const String routeName = 'WalletScreen';
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late PusherController _pusherController;
  final _historyKey = GlobalKey();
  String? pusherWalletAmount;

  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('balance.updated', _handleWalletUpdate);
  }

  void _handleWalletUpdate(PusherEvent event) {
    try {
      final jsonData = jsonDecode(event.data) as Map<String, dynamic>;
      final amount = jsonData['user_balance']?.toString() ?? '0';
      pusherWalletAmount = num.parse(amount).toStringAsFixed(2);
      if (mounted) {
        context.read<WalletController>().updateWallet(transaction: WalletModel.fromJson(jsonData));
      }
    } catch (e, stackTrace) {
      log('Error handling wallet update: $e');
      log('$stackTrace');
    }
  }

  @override
  void dispose() {
    _pusherController.removeEventListener('balance.updated', _handleWalletUpdate);
    super.dispose();
  }

  void _showHistory() {
    final target = _historyKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 250));
    }
  }

  void _charge(WalletController wallet, MyAccountController settings, AuthController auth) {
    if (settings.setting?.walletCardActivate == 'false' && settings.setting?.paymentCardActivate == 'false') return;
    if (auth.profile?.email == null) {
      NamedNavigatorImpl.push(PersonalInformationScreen.routeName);
      return;
    }
    Utils.showAppBottomSheet(
      enableDrag: true, isScrollControlled: true,
      ChangeNotifierProvider.value(value: wallet,
        child: ChargeWalletBottomSheet(walletController: wallet, myAccountController: settings)),
    );
  }

  @override
  Widget build(BuildContext context) => Consumer2<WalletController, MyAccountController>(
    builder: (context, wallet, settings, _) {
      final ar = context.languageCode == 'ar';
      final auth = context.read<AuthController>();
      final canCharge = !(settings.setting?.walletCardActivate == 'false' &&
          settings.setting?.paymentCardActivate == 'false');
      return Scaffold(
        backgroundColor: GoDesign.paper,
        appBar: CustomAppBar(title: Text(ar ? 'المحفظة' : 'Wallet')),
        body: SafeArea(top: false, child: RefreshIndicator(
          onRefresh: () async { await wallet.getWallet(); },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(GoDesign.pagePadding),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              MyCurrentBalanceWidget(wallet: wallet.wallet, pusherWalletAmount: pusherWalletAmount),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (canCharge) ...[
                  _action(Icons.add_circle, ar ? 'شحن الرصيد' : 'Top up',
                    () => _charge(wallet, settings, auth), primary: true),
                  const SizedBox(width: 10),
                ],
                _action(Icons.swap_horiz_rounded, ar ? 'تحويل' : 'Transfer', () {
                  Utils.showAppBottomSheet(enableDrag: true, isScrollControlled: true,
                    ChangeNotifierProvider.value(value: wallet,
                      child: MoneyTransferBottomSheet(walletController: wallet)));
                }),
                const SizedBox(width: 10),
                _action(Icons.receipt_long_outlined, ar ? 'العمليات' : 'History', _showHistory),
              ]),
              const SizedBox(height: 26),
              Row(key: _historyKey, children: [
                Expanded(child: Text(ar ? 'آخر العمليات' : 'Recent transactions',
                  style: const TextStyle(color: GoDesign.ink, fontSize: 18, fontWeight: FontWeight.w800))),
                Text('${wallet.wallet?.wallet?.length ?? 0}',
                  style: const TextStyle(color: GoDesign.muted, fontSize: 14)),
              ]),
              const SizedBox(height: 14),
              ApiResponseWidget(apiResponse: wallet.walletResponse,
                onReload: wallet.getWallet,
                isEmpty: wallet.wallet?.wallet?.isEmpty ?? true,
                child: RecentTransactionsWidget(wallet: wallet.wallet?.wallet)),
              const SizedBox(height: 20),
            ]),
          ),
        )),
      );
    },
  );

  Widget _action(IconData icon, String title, VoidCallback action, {bool primary = false}) => Expanded(
    child: Material(color: GoDesign.canvas,
      borderRadius: BorderRadius.circular(GoDesign.radius),
      child: InkWell(onTap: action, borderRadius: BorderRadius.circular(GoDesign.radius),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
          child: Column(children: [
            Icon(icon, size: 28, color: primary ? GoDesign.orange : GoDesign.ink),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: primary ? GoDesign.orange : GoDesign.ink)),
          ]),
        ),
      ),
    ),
  );
}
