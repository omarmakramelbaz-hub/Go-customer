import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';

class CustomAccountAppBar extends StatelessWidget {
  final String title;
  final Widget? actions;
  const CustomAccountAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(context.languageCode == 'ar' ? AppImages.backIosIcon : AppImages.backLeftIcon),
          ),
          Text(title, style: AppTextStyle.text18BS()),
          const Spacer(),
          if (actions != null) actions!,
        ],
      ),
    );
  }
}
