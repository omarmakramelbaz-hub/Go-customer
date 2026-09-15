import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import 'delegate_time_line_widget.dart';

class TrackingDelegateOrderWidget extends StatelessWidget {
  final String status;
  final String? orderDate;

  const TrackingDelegateOrderWidget({super.key, required this.status, this.orderDate});

  @override
  Widget build(BuildContext context) {
    if (orderDate != null) {
      DateTime createdAtDateTime = DateTime.parse(orderDate!).toLocal();

      // Add 6 hours to the createdAtDateTime
      DateTime createdAtPlus6Hours = createdAtDateTime.add(const Duration(hours: 6));

      if ((DateTime.now().isBefore(createdAtPlus6Hours) || (status != 'completed')) && (status != 'cancelled')) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              DelegateTimeLineWidget(
                isDone: true,
                isFirst: true,
                isLast: false,
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text('acceptOrder'.tr, style: AppTextStyle.text18MS()),
                      const Spacer(),
                      SvgPicture.asset(AppImages.checkIcon),
                    ],
                  ),
                ),
                icon: SvgPicture.asset(AppImages.delegateAcceptOrderIcon),
              ),
              DelegateTimeLineWidget(
                isDone: false,
                isFirst: false,
                isLast: false,
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        'receiveOrder'.tr,
                        style: status == 'shipped' || status == 'completed'
                            ? AppTextStyle.text18MS()
                            : AppTextStyle.text16ML(),
                      ),
                      const Spacer(),
                      status == 'shipped' || status == 'completed'
                          ? SvgPicture.asset(AppImages.checkIcon)
                          : const SizedBox(),
                    ],
                  ),
                ),
                icon: CustomImage(
                  path: AppImages.receiveOrderDelegateIcon,
                  type: ImageType.svg,
                  color: status == 'shipped' || status == 'completed' ? AppColors.blackColor : AppColors.greyColor,
                ),
              ),
              DelegateTimeLineWidget(
                isDone: false,
                isFirst: false,
                isLast: true,
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        'deliverOrder'.tr,
                        style: status == 'completed' ? AppTextStyle.text18MS() : AppTextStyle.text16ML(),
                      ),
                      const Spacer(),
                      status == 'completed' ? SvgPicture.asset(AppImages.checkIcon) : const SizedBox(),
                    ],
                  ),
                ),
                icon: CustomImage(
                  path: AppImages.deliveryOrderDelegate,
                  type: ImageType.svg,
                  color: status == 'completed' ? AppColors.blackColor : AppColors.greyColor,
                ),
              ),
              15.sbH,
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
