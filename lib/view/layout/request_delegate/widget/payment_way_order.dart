import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';

class PaymentWayOrderWidget extends StatelessWidget {
  const PaymentWayOrderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('paymentMethod'.tr, style: AppTextStyle.text18BS()),
          10.sbH,
          Row(
            children: [
              Container(
                height: 24,
                width: 5,
                decoration: BoxDecoration(
                  color: AppColors.mainAppColor,
                  borderRadius: BorderRadius.horizontal(
                    left: context.languageCode == 'ar' ? const Radius.circular(5) : const Radius.circular(0),
                    right: context.languageCode == 'ar' ? const Radius.circular(0) : const Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CustomImage(
                height: 18,
                path: buildPaymentTypeIcon(paymentType: 'cash'),
                type: ImageType.svg,
                color: AppColors.mainAppColor,
              ),
              const SizedBox(width: 10),
              Text(buildPaymentTitle(paymentType: 'cash'), style: AppTextStyle.text16BM()),
            ],
          ),
        ],
      ),
    );
  }

  String buildPaymentTitle({required String paymentType}) {
    switch (paymentType) {
      case 'cash':
        return 'cash'.tr;
      case 'online':
        return 'visa'.tr;
      case 'v_cash':
        return 'digitalWalletAndInstaPay'.tr;
      case 'wallet':
        return 'appWallet'.tr;
      default:
        return 'cash'.tr;
    }
  }

  String buildPaymentTypeIcon({required String paymentType}) {
    switch (paymentType) {
      case 'cash':
        return AppImages.cashIcon;
      case 'online':
        return AppImages.visaIcon;
      case 'v_cash':
        return AppImages.vfCash;
      case 'wallet':
        return AppImages.walletImage.tr;
      default:
        return AppImages.cashIcon;
    }
  }
}
