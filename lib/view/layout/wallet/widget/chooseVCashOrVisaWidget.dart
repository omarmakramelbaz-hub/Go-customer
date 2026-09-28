import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/wallet_controller.dart';

class ChooseVCashOrVisaWidget extends StatefulWidget {
  const ChooseVCashOrVisaWidget({
    super.key,
    required this.myAccountController,
  });

  final MyAccountController myAccountController;

  @override
  State<ChooseVCashOrVisaWidget> createState() => _ChooseVCashOrVisaWidgetState();
}

class _ChooseVCashOrVisaWidgetState extends State<ChooseVCashOrVisaWidget> {
  String? _selectedOptionKey;

  @override
  Widget build(BuildContext context) {
    final walletController = context.watch<WalletController>();
    // Listen to the shared settings controller so the sheet rebuilds as soon
    // as payment settings finish loading. Previously we only read the passed
    // controller value, so the first open could stay stuck on an empty state
    // until the sheet was closed and opened again.
    final liveAccountController = context.watch<MyAccountController>();
    final accountController = liveAccountController.setting != null
        ? liveAccountController
        : widget.myAccountController;
    final setting = accountController.setting;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final walletEnabled = setting?.walletCardActivate == 'true';
    final cardEnabled = setting?.paymentCardActivate == 'true';

    final methods = <_PaymentOptionData>[
      if (walletEnabled)
        _PaymentOptionData(
          keyName: 'electronic_wallet',
          label: isArabic ? 'محافظ إلكترونية' : 'Electronic wallets',
          backendMethod: 'v_cash',
          brand: const Icon(Icons.account_balance_wallet_outlined),
        ),
      if (cardEnabled)
        _PaymentOptionData(
          keyName: 'bank_card',
          label: isArabic ? 'بطاقات بنكية' : 'Bank cards',
          backendMethod: 'online',
          brand: SvgPicture.asset(
            AppImages.visaIcon,
            height: 18,
            fit: BoxFit.contain,
          ),
        ),
    ];

    if (methods.isEmpty) {
      final settingsState = liveAccountController.settingResponse.state;
      final isLoading = setting == null &&
          (settingsState == ResponseState.loading ||
              settingsState == ResponseState.sleep);

      if (isLoading) {
        return Container(
          height: 66,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.lightGreyColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.mainAppColor,
                ),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  isArabic
                      ? 'جاري تحميل وسائل الدفع...'
                      : 'Loading payment methods...',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text12RG(),
                ),
              ),
            ],
          ),
        );
      }

      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => liveAccountController.getSetting(),
        child: Container(
          height: 66,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.lightGreyColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.mainAppColor,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  isArabic
                      ? 'تعذر تحميل وسائل الدفع، اضغط لإعادة المحاولة'
                      : 'Could not load payment methods. Tap to retry',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text11RG(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < methods.length; i++) ...[
        _buildMethod(method: methods[i], walletController: walletController),
        if (i < methods.length - 1) const SizedBox(height: 8),
      ],
    ]);
  }

  Widget _buildMethod({
    required _PaymentOptionData method,
    required WalletController walletController,
    bool compactHorizontal = false,
  }) {
    final selected = _selectedOptionKey == method.keyName &&
        walletController.selectedPayment == method.backendMethod;

    return PaymentMethodWidget(
      label: method.label,
      brand: method.brand,
      isSelected: selected,
      compactHorizontal: compactHorizontal,
      onTap: () {
        setState(() => _selectedOptionKey = method.keyName);
        walletController.setSelectedPayment(method.backendMethod);
      },
    );
  }
}

class _PaymentOptionData {
  final String keyName;
  final String label;
  final String backendMethod;
  final Widget brand;

  const _PaymentOptionData({
    required this.keyName,
    required this.label,
    required this.backendMethod,
    required this.brand,
  });
}

class PaymentMethodWidget extends StatelessWidget {
  final String label;
  final Widget brand;
  final bool isSelected;
  final bool compactHorizontal;
  final VoidCallback onTap;

  const PaymentMethodWidget({
    super.key,
    required this.label,
    required this.brand,
    required this.isSelected,
    required this.onTap,
    this.compactHorizontal = false,
  });

  @override
  Widget build(BuildContext context) => GoPopupChoice(
    label: label, leading: brand, selected: isSelected, onTap: onTap,
  );
}

class _BrandMark extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const _BrandMark({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        height: 1,
        fontWeight: fontWeight,
        color: AppColors.mainAppColor,
      ),
    );
  }
}
