import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../restaurants/screen/product_details_screen.dart';
import '../model/orders_model.dart';

class RequestImageWidget extends StatelessWidget {
  final Items items;
  const RequestImageWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NamedNavigatorImpl.push(
          ProductDetailsScreen.routeName,
          arguments: ProductDetailsDetailsArgs(id: items.restaurantProduct?.id ?? 0),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                CustomNetworkImage(
                  fit: BoxFit.cover,
                  radius: 12,
                  imageUrl: items.restaurantProduct?.productImage ?? '',
                ),
                15.sbH,
                Text(items.restaurantProduct?.productName ?? '', style: AppTextStyle.text18RS()),
                const SizedBox(height: 7),
                Text('pound'.translate(args: [items.price.toString()]), style: AppTextStyle.text18RS()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
