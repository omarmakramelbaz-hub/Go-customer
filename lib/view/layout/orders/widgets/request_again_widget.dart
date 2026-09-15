// import 'package:flutter/material.dart';
//
// import '../../../../helpers/extensions/extensions.dart';
// import '../../../../helpers/networking/urls.dart';
// import '../../../../helpers/routes/app_routers_import.dart';
// import '../../../../helpers/theme/app_colors.dart';
// import '../../../../helpers/theme/app_text_style.dart';
// import '../../../../helpers/translation/all_translation.dart';
// import '../../../custom_widgets/custom_image/custom_network_image.dart';
// import '../screen/request_again_screen.dart';
//
// class RequestAgainWidget extends StatelessWidget {
//   const RequestAgainWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//       width: context.width * 0.9,
//       decoration: BoxDecoration(
//         color: AppColor.whiteColor,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(color: AppColor.greyColor.withValues(alpha: .4), blurRadius: 9, offset: const Offset(0, 1)),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Text('5/12/2022', style: AppTextStyle.text14RL()),
//               const Spacer(),
//               Container(
//                 height: 30,
//                 padding: const EdgeInsets.symmetric(horizontal: 13),
//                 decoration: BoxDecoration(
//                   color: AppColor.greyColor.withValues(alpha: .15),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Center(child: Text('received'.tr, style: AppTextStyle.text14RG())),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               const CustomNetworkImage(radius: 12, imageUrl: Urls.testNoonLogo, width: 60, height: 60),
//               const SizedBox(width: 10),
//               Column(
//                 children: [
//                   Text('فسخانستا', style: AppTextStyle.text16RS()),
//                   15.sbH,
//                   Row(
//                     children: [
//                       Text('requestCode'.tr, style: AppTextStyle.text14RL()),
//                       const SizedBox(width: 10),
//                       Text('123456', style: AppTextStyle.text14RL()),
//                     ],
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               TextButton(
//                 onPressed: () {
//                   NamedNavigatorImpl.push(RequestAgainScreen.routeName);
//                 },
//                 child: Text(
//                   'requestAgain'.tr,
//                   style: TextStyle(
//                     color: AppColor.mainAppColor,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
