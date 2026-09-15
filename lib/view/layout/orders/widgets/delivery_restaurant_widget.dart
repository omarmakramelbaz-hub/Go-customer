import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../model/orders_model.dart';

class DeliveryRestaurantWidget extends StatelessWidget {
  final OrdersModel? orders;
  const DeliveryRestaurantWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomNetworkImage(
            imageUrl: orders?.resturantLogo ?? '',
            radius: 35,
            fit: BoxFit.fitHeight,
            height: 70,
            width: 70,
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('restaurantDelegate'.tr, style: AppTextStyle.text14RS()),
              5.sbH,
              Text(orders?.resturantName ?? '', style: AppTextStyle.text16BS()),
            ],
          ),
          const Spacer(),
          // GestureDetector(
          //   onTap: () {
          //     UrlLauncherMethods.makePhoneCall(
          //       orders?.resturantPhone ?? "",
          //     );
          //   },
          //   child: Card(
          //     elevation: 10,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20)),
          //     child: CircleAvatar(
          //       radius: 20,
          //       backgroundColor: AppColor.mainAppColor,
          //       child: SvgPicture.asset(AppImages.callIcon),
          //     ),
          //   ),
          // ),
          // GestureDetector(
          //   onTap: () {
          //     NavigatorMethods.pushNamed(context, ChatScreen.routeName,
          //         arguments: ChatScreenArgs(orderId: "VC${orders?.id ?? 0}"));
          //   },
          //   child: Card(
          //     elevation: 10,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20)),
          //     child: CircleAvatar(
          //       radius: 20,
          //       backgroundColor: AppColor.mainAppColor,
          //       child: SvgPicture.asset(AppImages.chatIcon),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
