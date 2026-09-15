// import 'package:faskhaninja/helpers/theme/app_text_style.dart';
// import 'package:flutter/material.dart';

// class RadioItemListTile extends StatelessWidget {
//   const RadioItemListTile({super.key});
// final                                                restaurantsController

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Radio(
//           activeColor: AppColor.yellowColor(
//             context,
//           ),
//           value: 2,
//           groupValue: _selectedRadio,
//           onChanged: (value) {
//             setState(() {
//               _selectedRadio = value!;
//             });
//             context.read<CartController>().totalCountAddTCart = null;
//           },
//         ),
//         Text(
//           'large'.tr,
//           style: _selectedRadio == 2
//               ? AppTextStyle.text16MS()
//                   .copyWith(color: AppColor.yellowColor)
//               : AppTextStyle.text16MG(),
//         ),
//         const Spacer(),
//         restaurantsController.productsDetailsRestaurant == null
//             ? const SizedBox()
//             : Text(
//                 "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraLarge?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
//                 style: _selectedRadio == 2
//                     ? AppTextStyle.text16MS()
//                     : AppTextStyle.text16MG(),
//               ),
//       ],
//     );
//   }
// }
