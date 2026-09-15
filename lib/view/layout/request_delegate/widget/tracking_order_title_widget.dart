import 'package:flutter/material.dart';

import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';

class TrackingOrderTitleWidget extends StatelessWidget {
  const TrackingOrderTitleWidget({super.key, required this.orderStatus});
  final String orderStatus;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
      child: Text(buildOrderTitle(orderStatus: orderStatus), style: AppTextStyle.text18BS()),
    );
  }

  String buildOrderTitle({required String orderStatus}) {
    switch (orderStatus) {
      case 'pending':
        return 'orderAcceptedFromDelegate'.tr;
      case 'shipped':
        return 'delegateAcceptedAndInRoute'.tr;
      case 'Completed':
        return 'orderDeliveredFromDelegate'.tr;
      case 'cancelled':
        return 'orderCancelled'.tr;
      default:
        return 'pending'.tr;
    }
  }
}
