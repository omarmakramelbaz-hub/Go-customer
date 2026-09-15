import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../restaurants/screen/restaurant_details_screen.dart';
import '../controller/home_controller.dart';
import '../model/previous_order_home_model.dart';

class YourPreviousOrdersListViewWidget extends StatelessWidget {
  final List<PreviousOrderHomeModel> previousOrders;
  const YourPreviousOrdersListViewWidget({super.key, required this.previousOrders});

  @override
  Widget build(BuildContext context) {
    return ApiResponseWidget(
      emptyWidget: Column(children: [Text('youHaveNoPreviousOrders'.tr, style: AppTextStyle.text16RS())]),
      apiResponse: context.read<HomeController>().previousOrderApiResponse,
      onReload: () => context.read<HomeController>().getPreviousOrder(),
      isEmpty: context.read<HomeController>().previousOrders.isEmpty,
      loadingWidget: const SizedBox.shrink(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: previousOrders.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                context.read<HomeController>().previousOrders[index].status == 'busy' ||
                        context.read<HomeController>().previousOrders[index].underContract == 'yes'
                    ? null
                    : NamedNavigatorImpl.push(
                        RestaurantDetailsScreen.routeName,
                        arguments: RestaurantDetailsArgs(
                          id: context.read<HomeController>().previousOrders[index].id ?? 0,
                        ),
                      );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 86,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: CustomNetworkImage(
                                imageUrl: previousOrders[index].logo ?? '',
                                height: 79,
                                width: 86,
                                radius: 12,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned.fill(
                              child: context.read<HomeController>().previousOrders[index].status == 'closed' ||
                                      context.read<HomeController>().previousOrders[index].status == 'busy' ||
                                      context.read<HomeController>().previousOrders[index].underContract == 'yes'
                                  ? Container(
                                      height: 79,
                                      width: 86,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.blackColor.withValues(alpha: 0.6),
                                            blurRadius: 1,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          context.read<HomeController>().previousOrders[index].underContract == 'yes'
                                              ? 'underContract'.tr
                                              : context.read<HomeController>().previousOrders[index].status == 'closed'
                                                  ? 'closed'.tr
                                                  : 'busy'.tr,
                                          style: AppTextStyle.text14MW(),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        12.sbH,
                        Flexible(
                          child: Text(previousOrders[index].name ?? '', style: AppTextStyle.text14RS(), maxLines: 1),
                        ),
                        4.sbH,
                        if (previousOrders[index].deliveryTime != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SvgPicture.asset(AppImages.clockIcon),
                              ),
                              const SizedBox(width: 7),
                              //مده التوصيل
                              Text(
                                previousOrders[index].deliveryTime ?? '',
                                style: AppTextStyle.text14RG().copyWith(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
