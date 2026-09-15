import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';

class SettingButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const SettingButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(title, style: AppTextStyle.text16MS()),
            const Spacer(),
            SvgPicture.asset(context.languageCode == 'en' ? AppImages.backIosIcon : AppImages.backLeftIcon),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
