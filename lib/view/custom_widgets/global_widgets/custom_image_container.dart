import 'dart:io';

import 'package:flutter/material.dart';

import '../../../helpers/extensions/extensions.dart';
import '../../../helpers/images/app_images.dart';
import '../../../helpers/images/image_methods.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../custom_widgets/custom_image/custom_image.dart';

class CustomImageContainer extends StatefulWidget {
  const CustomImageContainer({super.key, required this.onSuccess, this.image, this.readOnly});
  final void Function(File) onSuccess;
  final File? image;
  final bool? readOnly;
  // final String? validateText;
  // final bool? isChecked;

  @override
  State<CustomImageContainer> createState() => _CustomImageContainerState();
}

class _CustomImageContainerState extends State<CustomImageContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            widget.readOnly == true
                ? null
                : ImageMethods.pickImageBottomSheet(
                    context,
                    onSuccess: (v) {
                      widget.onSuccess.call(v);
                      Navigator.pop(context);
                    },
                  );
          },
          child: Container(
            height: 122,
            width: context.width / 2.33,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textFormBorderColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: widget.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image(
                      fit: BoxFit.cover,
                      image: FileImage(widget.image!),
                      errorBuilder: (context, url, error) => const SizedBox(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomImage(
                      path: AppImages.cameraContainerIcon,
                      type: ImageType.svg,
                      color: AppColors.textFormBorderColor,
                    ),
                  ),
          ),
        ),
        5.sbH,
        // widget.validateText != null && widget.isChecked == true
        //     ? Text(
        //         mustEnter
        //             .tr
        //             .replaceAll("{}", widget.validateText ?? ""),
        //         style: AppTextStyle.text14BS()
        //             .copyWith(color: AppColor.redColor),
        //       )
        //     : const SizedBox()
      ],
    );
  }
}
