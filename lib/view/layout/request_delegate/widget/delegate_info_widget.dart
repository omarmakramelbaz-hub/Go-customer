import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../controller/request_delegate_controller.dart';

class DelegateInfoWidget extends StatelessWidget {
  const DelegateInfoWidget({super.key, required this.requestDelegateController});
  final RequestDelegateController requestDelegateController;
  @override
  Widget build(BuildContext context) {
    if (requestDelegateController.delegateOrderDetails?.delegateId == null) {
      return const SizedBox();
    } else {
      return Row(
        children: [
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delegateName'.tr.replaceAll('{}', 'محمد خالد'), style: AppTextStyle.text18BS()),
              10.sbH,
              Text('orderNumber'.tr.replaceAll('{}', '15689'), style: AppTextStyle.text14RS()),
            ],
          ),
          const Spacer(),
          Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.mainAppColor,
              child: SvgPicture.asset(AppImages.callIcon),
            ),
          ),
          const SizedBox(width: 5),
          Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.mainAppColor,
              child: SvgPicture.asset(AppImages.chatIcon),
            ),
          ),
          const SizedBox(width: 15),
        ],
      );
    }
  }
}
