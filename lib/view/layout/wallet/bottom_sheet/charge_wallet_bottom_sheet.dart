import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/custom_payment_web_view/custom_payment_web_view.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/wallet_controller.dart';
import '../widget/chooseVCashOrVisaWidget.dart';
import '../widget/wallet_charge_view.dart';

class ChargeWalletBottomSheet extends StatefulWidget {
  const ChargeWalletBottomSheet({
    super.key,
    required this.walletController,
    required this.myAccountController,
  });

  final WalletController walletController;
  final MyAccountController myAccountController;

  @override
  State<ChargeWalletBottomSheet> createState() =>
      _ChargeWalletBottomSheetState();
}

class _ChargeWalletBottomSheetState extends State<ChargeWalletBottomSheet> {
  void _pay(BuildContext context) {
    final walletController = widget.walletController;
    final authController = context.read<AuthController>();

    if (!walletController.chargeWalletFormKey.currentState!.validate()) {
      return;
    }

    if (walletController.selectedPayment == null) {
      CommonMethods.showError(message: 'youMustChoosePaymentMethod'.tr);
      return;
    }

    walletController.chargingWallet(
      amount: walletController.chargeAmountEc.text,
      onSuccess: (link) {
        log(link);
        NamedNavigatorImpl.push(
          CustomPaymentWebViewScreen.routeName,
          arguments: PaymentArgs(
            url: link,
            onFailed: () {
              CommonMethods.showError(message: 'paymentFailed'.tr);
            },
            onSuccess: () {
              Navigator.pop(context);
              walletController.getWallet();
              authController.getProfile();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => WalletChargeSheetView(
    translate: (key) => key.tr,
    formKey: widget.walletController.chargeWalletFormKey,
    amountController: widget.walletController.chargeAmountEc,
    amountFocusNode: widget.walletController.chargeAmountFocusNode,
    validator: (value) {
      if (value == null || value.isEmpty) return 'enterAmount'.tr;
      final amount = num.tryParse(value);
      if (amount == null || amount < 50)
        return 'minimumChargeAmount'.tr.replaceAll('{}', '50');
      return null;
    },
    paymentMethods: ChooseVCashOrVisaWidget(
      myAccountController: widget.myAccountController,
    ),
    onPay: () => _pay(context),
  );
}
