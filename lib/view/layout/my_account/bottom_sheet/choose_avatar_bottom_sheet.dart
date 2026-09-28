import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../auth/controller/auth_controller.dart';

class ChooseAvatarBottomSheet extends StatelessWidget {
  final VoidCallback? onSuccess;
  const ChooseAvatarBottomSheet({super.key, this.onSuccess});

  @override
  Widget build(BuildContext context) => GoSheet(title: 'chooseYourAvatar'.tr, icon: Icons.face_outlined,
    child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.read<AuthController>().chooseAvatar(
                          gender: 'male',
                          onSuccess: () {
                            context.read<AuthController>().getProfile();
                            Navigator.pop(context);
                          },
                        );
                  },
                  child: SvgPicture.asset(AppImages.avatarMale),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.read<AuthController>().chooseAvatar(
                          gender: 'female',
                          onSuccess: () {
                            context.read<AuthController>().getProfile();
                            Navigator.pop(context);
                          },
                        );
                  },
                  child: SvgPicture.asset(AppImages.avatarFemale),
                ),
              ),
            ],
          ));
}
