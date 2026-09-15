import 'package:flutter/material.dart';

import '../../../custom_widgets/global_widgets/app_bottom_sheet.dart';
import '../model/user_cart_model.dart';

class UpdateItemInCartBottomSheet extends StatelessWidget {
  const UpdateItemInCartBottomSheet({super.key, required this.productName, required this.resturantProduct});
  final String productName;
  final ResturantProduct resturantProduct;
  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(title: productName, children: const []);
  }
}
