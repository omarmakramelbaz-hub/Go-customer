import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/request_delegate_controller.dart';

class PaymentRDBottomSheet extends StatelessWidget {
  const PaymentRDBottomSheet({super.key, required this.requestDelegateController});

  final RequestDelegateController requestDelegateController;

  bool _isArabic(BuildContext context) => context.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAccountController()
        ..initialSetting()
        ..getSetting(),
      child: Consumer<MyAccountController>(
        builder: (context, accountController, _) {
          return AnimatedBuilder(
            animation: requestDelegateController,
            builder: (context, _) {
              final isAr = _isArabic(context);
              final options = <_PaymentOption>[];

              if (accountController.setting?.paymentCardActivate == 'true') {
                options.add(
                  _PaymentOption(
                    value: 'online',
                    title: 'creditCard'.tr,
                    subtitle: isAr ? 'الدفع ببطاقة بنكية' : 'Pay by bank card',
                    icon: Icons.credit_card_rounded,
                  ),
                );
              }

              if (accountController.setting?.walletCardActivate == 'true') {
                options.add(
                  _PaymentOption(
                    value: 'v_cash',
                    title: isAr ? 'محافظ إلكترونية' : 'Electronic wallets',
                    subtitle: isAr ? 'الدفع عبر محفظتك الإلكترونية' : 'Pay using your electronic wallet',
                    icon: Icons.phone_android_rounded,
                  ),
                );
              }

              return GoSheet(title: isAr ? 'اختر طريقة الدفع' : 'Choose payment method',
                subtitle: isAr ? 'يمكنك تغيير طريقة الدفع قبل تأكيد الطلب' : 'You can change it before confirming the order',
                icon: Icons.account_balance_wallet_outlined,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        if (options.isEmpty) Padding(padding: const EdgeInsets.all(16), child:
                          accountController.settingResponse.state == ResponseState.loading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(children: [Text(isAr ? 'وسائل الدفع غير متاحة حاليًا' : 'Payment methods are currently unavailable'),
                                TextButton(onPressed: () => accountController.getSetting(), child: Text(isAr ? 'إعادة المحاولة' : 'Retry'))])),
                        ...options.map(
                          (option) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PaymentOptionTile(
                              option: option,
                              selected: requestDelegateController.selectedPayment == option.value,
                              onTap: () => requestDelegateController.setSelectedPayment(option.value),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: options.any((option) => option.value == requestDelegateController.selectedPayment) ? () => Navigator.pop(context) : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.mainAppColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isAr ? 'تأكيد طريقة الدفع' : 'Confirm payment method',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                ]));
            },
          );
        },
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _PaymentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF6EC) : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? AppColors.mainAppColor : const Color(0xFFE8EBEF),
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : const Color(0xFFFFF8F1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(option.icon, color: AppColors.mainAppColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          color: Color(0xFF171A1F),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        option.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF888E97),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.mainAppColor : Colors.white,
                    border: Border.all(
                      color: selected ? AppColors.mainAppColor : const Color(0xFFC8CCD2),
                      width: 1.3,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
