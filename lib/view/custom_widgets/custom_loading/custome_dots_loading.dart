import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../helpers/theme/app_colors.dart';

class CustomDotsLoading extends StatelessWidget {
  final double size;
  final Color? color;
  const CustomDotsLoading({super.key, this.size = 35, this.color});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.staggeredDotsWave(color: color ?? AppColors.mainAppColor, size: size);
  }
}
