// import 'package:faskhaninja/helpers/theme/app_colors.dart';
// import 'package:flutter/material.dart';

// import 'stepper_data.dart';

// class HorizontalStepperItem extends StatelessWidget {
//   final double barwidth;

//   final Color dotColor;

//   /// Stepper Item to show horizontal stepper
//   const HorizontalStepperItem(
//       {super.key,
//       required this.item,
//       required this.index,
//       required this.totalLength,
//       required this.activeIndex,
//       required this.isInverted,
//       required this.activeBarColor,
//       required this.inActiveBarColor,
//       required this.barHeight,
//       required this.iconHeight,
//       this.barwidth = 10,
//       required this.iconWidth,
//       required this.dotColor});

//   /// Stepper item of type [StepperData] to inflate stepper with data
//   final StepperData item;

//   /// Index at which the item is present
//   final int index;

//   /// Total length of the list provided
//   final int totalLength;

//   /// Active index which needs to be highlighted and before that
//   final int activeIndex;

//   /// Inverts the stepper with text that is being used
//   final bool isInverted;

//   /// Bar color for active step
//   final Color activeBarColor;

//   /// Bar color for inactive step
//   final Color inActiveBarColor;

//   /// Bar height/thickness
//   final double barHeight;

//   /// Height of [StepperData.iconWidget]
//   final double iconHeight;

//   /// Width of [StepperData.iconWidget]
//   final double iconWidth;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children:
//           isInverted ? getInvertedChildren(context) : getChildren(context),
//     );
//   }

//   List<Widget> getChildren(BuildContext context) {
//     return [
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 12.r),
//             width: 48.sp,
//             height: 48.sp,
//             decoration: ShapeDecoration(
//               color: (index <= activeIndex)
//                   ? const Color(0xFFFFF7EA)
//                   : const Color(0xFFF8F8F8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: CustomSvgImages(
//                 imageNamed: OrderDetailsStatus.values[index].getSvg(),
//                 color: (index <= activeIndex) ? null : const Color(0xFFBFBFBF)),
//           ),
//           9.hSpace,
//           item.title!.text.toCustomText(style: font12Primary400),
//           9.hSpace,
//           Row(
//             children: [
//               Container(
//                 color: index == 0
//                     ? Colors.white
//                     : (index <= activeIndex)
//                         ? AppColor.
//                         : const Color(0xFFF8F8F8),
//                 height: barHeight,
//                 width: barwidth / 2,
//               ),
//               CustomSvgImages(
//                 imageNamed: (index <= activeIndex)
//                     ? 'done'
//                     : 'not_done',
//               ),
//               Container(
//                 color: index == 3
//                     ? Colors.white
//                     : (index + 1 <= activeIndex)
//                         ? AppColors.greenForFont
//                         : const Color(0xFFF8F8F8),
//                 height: barHeight,
//                 width: barwidth / 2,
//               ),
//             ],
//           )
//         ],
//       )
//       // Row(
//       //   children: [
//       //     DotProvider(
//       //       activeIndex: activeIndex,
//       //       index: index,
//       //       item: item,
//       //       dotColor:dotColor,
//       //       totalLength: totalLength,
//       //       iconHeight: iconHeight,
//       //       iconWidth: iconWidth,
//       //     ),
//       //     const SizedBox(width: 8),
//       //     Text(
//       //       item.title!.text,
//       //       textAlign: TextAlign.center,
//       //       style: item.title!.textStyle ??
//       //           TextStyle(
//       //             fontSize: 12,
//       //             color: (index <= activeIndex) ? Colors.blue : Colors.grey,
//       //             fontWeight: FontWeight.w600,
//       //           ),
//       //     ),
//       //     const SizedBox(width: 8),
//       //     totalLength == index+1? const SizedBox():
//       //     Container(
//       //       color: Colors.grey,
//       //       height: barHeight,
//       //       width: barwidth,
//       //     ),
//       //     const SizedBox(width: 8),
//       //
//       //   ],
//       // ),
//     ];
//   }

//   List<Widget> getInvertedChildren(BuildContext context) {
//     return getChildren(context).reversed.toList();
//   }
// }
//
