// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../../helpers/images/app_images.dart';
// import '../../../../helpers/networking/urls.dart';
// import '../../../../helpers/routes/app_routers_import.dart';
// import '../../../../helpers/theme/app_colors.dart';
// import '../../../../helpers/theme/app_text_style.dart';
// import '../../../../helpers/translation/all_translation.dart';
// import '../../../custom_widgets/buttons/custom_button.dart';
// import '../../../custom_widgets/custom_image/custom_network_image.dart';
// import '../../../custom_widgets/page_container/page_container.dart';
// import 'add_address_screen.dart';
//
// class ConfirmAddressScreen extends StatelessWidget {
//   static const String routeName = 'ConfirmAddressScreen';
//   const ConfirmAddressScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return PageContainer(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               30.sbH,
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: SvgPicture.asset(AppImages.backIosIcon),
//                         ),
//                         Text('addresses'.tr, style: AppTextStyle.text18BS()),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColor.whiteColor,
//                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(34), topRight: Radius.circular(34)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColor.greyColor.withValues(alpha: 0.2),
//                       offset: const Offset(0, -3),
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 24),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor: AppColor.mainAppColor,
//                                 child: Text('A', style: AppTextStyle.text20MW()),
//                               ),
//                               const SizedBox(width: 10),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Ahmed Wael', style: AppTextStyle.text18MS()),
//                                   5.sbH,
//                                   Row(
//                                     children: [
//                                       SvgPicture.asset(AppImages.egyptIcon),
//                                       const SizedBox(width: 10),
//                                       Text('مصر', style: AppTextStyle.text16RG()),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     const Divider(thickness: 1),
//                     const SizedBox(height: 24),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: CustomNetworkImage(fit: BoxFit.cover, radius: 10, imageUrl: Urls.testNoonLogo),
//                     ),
//                     const SizedBox(height: 100),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: CustomButton(
//                         onPressed: () {
//                           NamedNavigatorImpl.push(AddAddressScreen.routeName);
//                         },
//                         text: 'confirmAddress'.tr,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
