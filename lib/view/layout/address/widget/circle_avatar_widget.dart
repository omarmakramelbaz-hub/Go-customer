import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';

class CircleAvatarWidget extends StatelessWidget {
  final String? gender, name;

  const CircleAvatarWidget({super.key, this.gender, this.name});

  @override
  Widget build(BuildContext context) {
    if (gender == 'male') {
      return SvgPicture.asset(AppImages.avatarMale);
    } else if (gender == 'female') {
      return SvgPicture.asset(AppImages.avatarFemale);
    } else {
      return Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(color: AppColors.mainAppColor, shape: BoxShape.circle),
        child: Center(
          child: Text(
            name?.substring(0, 1) ?? '',
            style: AppTextStyle.text18BW().copyWith(fontSize: 40),
          ),
        ),
      );
    }
  }
}
