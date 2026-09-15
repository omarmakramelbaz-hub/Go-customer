import 'package:flutter/material.dart';

import 'stepper_data.dart';
import 'stepper_dot.dart';

class DotProvider extends StatelessWidget {
  final Color dotColor;

  const DotProvider({
    super.key,
    required this.index,
    required this.activeIndex,
    required this.item,
    required this.totalLength,
    this.iconHeight,
    this.iconWidth,
    required this.dotColor,
  });

  /// Stepper item of type [StepperData] to inflate stepper with data
  final StepperData item;

  /// Index at which the item is present
  final int index;

  /// Total length of the list provided
  final int totalLength;

  /// Active index which needs to be highlighted and before that
  final int activeIndex;

  /// Height of [StepperData.iconWidget]
  final double? iconHeight;

  /// Width of [StepperData.iconWidget]
  final double? iconWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: iconHeight,
      width: iconWidth,
      child: item.iconWidget ??
          StepperDot(index: index, totalLength: totalLength, activeIndex: activeIndex, dotColor: dotColor),
    );
  }
}
