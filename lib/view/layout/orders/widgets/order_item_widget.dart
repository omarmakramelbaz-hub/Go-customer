import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../model/orders_model.dart';

class OrderItemWidget extends StatelessWidget {
  final Items? orderItem;
  final String paymentType;

  const OrderItemWidget({super.key, this.orderItem, required this.paymentType});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderItem?.restaurantProduct?.productName ?? '', style: AppTextStyle.text16RS()),
                    if (orderItem?.productFeatureName != null || orderItem?.productClean != null)
                      5.sbH
                    else
                      const SizedBox(),
                    Row(
                      children: [
                        Text(
                          getProductFeatureName(orderItem?.productFeatureName ?? '') ?? '',
                          style: AppTextStyle.text16RS(),
                        ),
                        orderItem?.productFeatureName != null
                            ? Text(' - ', style: AppTextStyle.text16RS())
                            : const SizedBox(),
                        Text(getProductClean(orderItem?.productClean ?? '') ?? '', style: AppTextStyle.text16RS()),
                      ],
                    ),
                    orderItem?.productFeatureName != null || orderItem?.productClean != null ? 5.sbH : const SizedBox(),
                    Row(
                      children: [
                        Text(
                          'pound'.tr.replaceAll(
                                '{}',
                                orderItem?.updatedTotal == 0
                                    ? orderItem?.total.toString() ?? ''
                                    : '${orderItem?.updatedTotal}',
                              ),
                          style: AppTextStyle.text16RG(),
                        ),
                        const SizedBox(width: 20),
                        orderItem?.updatedTotal != 0
                            ? Text(
                                'pound'.tr.replaceAll('{}', orderItem?.total.toString() ?? ''),
                                style: AppTextStyle.text14RG().copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.greyColor,
                                  decorationThickness: 5,
                                  inherit: false,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 26,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.greyColor.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(orderItem?.qty.toString() ?? '', style: AppTextStyle.text18BS().copyWith(height: 1.6)),
                ),
              ),
            ],
          ),
        ),
        orderItem?.updatedTotal != 0
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 11),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightMainAppColor,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Row(
                  children: [
                    const CustomImage(path: AppImages.infoIcon, type: ImageType.svg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${'orderPriceChanged'.tr.replaceAll("\$", "${orderItem?.total ?? '0'}").replaceAll("{}", "${orderItem?.updatedTotal ?? '0'}")}\n ${orderItem?.reasonUpdateTotal}",
                            style: AppTextStyle.text14RS(),
                          ),
                          paymentType == 'cash'
                              ? const SizedBox()
                              : Text('theDifferenceTransferred'.tr, style: AppTextStyle.text16RS()),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        Divider(color: AppColors.greyColor.withValues(alpha: .1), thickness: 2),
      ],
    );
  }

  String? getProductClean(String? productClean) {
    switch (productClean) {
      case 'extra_clean':
        return 'clean'.tr;
      case 'extra_clear':
        return 'clear'.tr;
      case 'extra_large':
        return 'large'.tr;
      case 'extra_medium':
        return 'medium'.tr;
      case 'extra_vacuim':
        return 'vacuum'.tr;
      case 'extra_combo':
        return 'combo'.tr;
      default:
        return '';
    }
  }

  String? getProductFeatureName(String? productFeatureName) {
    switch (productFeatureName) {
      case 'kilo':
        return 'kilo'.tr;
      case 'half':
        return 'half'.tr;
      case 'quarter':
        return 'quarter'.tr;
      default:
        return '';
    }
  }
}
