import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../controller/restaurants_controller.dart';
import '../screen/product_details_screen.dart';

class ChoicesAccordingToYourTasteWidget extends StatefulWidget {
  const ChoicesAccordingToYourTasteWidget({super.key});

  @override
  State<ChoicesAccordingToYourTasteWidget> createState() => _ChoicesAccordingToYourTasteWidgetState();
}

class _ChoicesAccordingToYourTasteWidgetState extends State<ChoicesAccordingToYourTasteWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantsController>(
      builder: (BuildContext context, restaurantsController, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two items horizontally
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 5.0,
            mainAxisExtent: 230,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: restaurantsController.detailsRestaurant?.highestRated?.length ?? 0,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (restaurantsController.detailsRestaurant?.status == 'closed') {
                  CommonMethods.showError(message: 'thisRestaurantIsClosed'.tr);
                } else {
                  if (restaurantsController.detailsRestaurant?.highestRated?[index].status == 'show') {
                    NamedNavigatorImpl.push(
                      ProductDetailsScreen.routeName,
                      arguments: ProductDetailsDetailsArgs(
                        id: restaurantsController.detailsRestaurant?.highestRated?[index].id ?? 0,
                      ),
                    );
                  } else {
                    CommonMethods.showError(message: 'productNotAvailable'.tr);
                  }
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomNetworkImage(
                    imageUrl: restaurantsController.detailsRestaurant?.highestRated?[index].productImage ?? '',
                    height: 121,
                    width: double.infinity,
                    radius: 12,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 12),
                  restaurantsController.detailsRestaurant?.highestRated?[index].highestRated == 'yes'
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.mainAppColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomImage(path: AppImages.starIcon, type: ImageType.svg),
                                const SizedBox(width: 5),
                                Text(
                                  'highestRate'.tr,
                                  style: AppTextStyle.text16BS().copyWith(color: AppColors.darkMainAppColor),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 12),
                  Text(
                    restaurantsController.detailsRestaurant?.highestRated?[index].productName ?? '',
                    style: AppTextStyle.text16RS(),
                  ),
                  const SizedBox(height: 8),
                  if (restaurantsController.detailsRestaurant?.highestRated?[index].productPrice != null) ...[
                    restaurantsController.detailsRestaurant?.highestRated?[index].status == 'show'
                        ? Text(
                            'pound'.tr.replaceAll(
                                  '{}',
                                  restaurantsController.detailsRestaurant?.highestRated?[index].productPrice
                                          .toString() ??
                                      '',
                                ),
                            style: AppTextStyle.text14RG(),
                          )
                        : Text('notAvailable'.tr, style: AppTextStyle.text16RG()),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
