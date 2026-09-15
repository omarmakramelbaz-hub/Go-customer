import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../helpers/extensions/extensions.dart';
import '../../../helpers/images/app_images.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/translation/all_translation.dart';

class ChooseGalleryOrCameraBottomSheet extends StatelessWidget {
  final void Function()? onCamera;
  final void Function()? onGallery;
  const ChooseGalleryOrCameraBottomSheet({super.key, this.onCamera, this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.popupColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          15.sbH,
          SizedBox(width: 40, child: Divider(color: AppColors.hintColor)),
          15.sbH,
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextButton(
                    onPressed: onCamera,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppImages.cameraIcon,
                          colorFilter: ColorFilter.mode(AppColors.mainAppColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'camera'.tr,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.lightTextColor),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.hintColor),
                  TextButton(
                    onPressed: onGallery,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppImages.galleryIcon,
                          colorFilter: ColorFilter.mode(AppColors.mainAppColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'gallery'.tr,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.lightTextColor),
                        ),
                      ],
                    ),
                  ),
                  15.sbH,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
