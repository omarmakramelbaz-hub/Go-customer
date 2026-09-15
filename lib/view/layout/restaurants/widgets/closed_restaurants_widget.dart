// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../../helpers/extensions/extensions.dart';
// import '../../../../helpers/images/app_images.dart';
// import '../../../../helpers/networking/urls.dart';
// import '../../../../helpers/theme/app_colors.dart';
// import '../../../../helpers/theme/app_text_style.dart';
// import '../../../../helpers/translation/all_translation.dart';
// import '../../../custom_widgets/custom_image/custom_network_image.dart';
//
// class ClosedRestaurantsWidget extends StatelessWidget {
//   const ClosedRestaurantsWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: 10,
//       itemBuilder: (context, index) => Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             margin: const EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               color: AppColor.whiteColor,
//               boxShadow: [
//                 BoxShadow(color: Colors.grey.withValues(alpha: 0.5), blurRadius: 1, offset: const Offset(0, 0)),
//               ],
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const CustomNetworkImage(
//                   imageUrl: Urls.testNoonLogo,
//                   height: 84,
//                   width: 114,
//                   radius: 15,
//                   fit: BoxFit.cover,
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     15.sbH,
//                     Text('مطعم فسخانستا', style: AppTextStyle.text16RS()),
//                     10.sbH,
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SvgPicture.asset(AppImages.starIcon),
//                         const SizedBox(width: 8),
//                         Text('4.5', style: AppTextStyle.text14RS()),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 15),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(padding: const EdgeInsets.only(top: 2), child: SvgPicture.asset(AppImages.clockIcon)),
//                       const SizedBox(width: 7),
//                       Text('28 د', style: AppTextStyle.text16RG().copyWith(fontWeight: FontWeight.w300)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: 10,
//             right: 20,
//             child: Container(
//               width: 114,
//               height: 84,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: AppColor.darkTextColor.withValues(alpha: .70),
//               ),
//               child: Center(child: Text('closed'.tr, style: AppTextStyle.text18MW())),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
