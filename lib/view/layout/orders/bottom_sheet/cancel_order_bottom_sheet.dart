import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';

class CancelOrderBottomSheet extends StatelessWidget {
  final int orderId;
  final VoidCallback onPressed;
  const CancelOrderBottomSheet({super.key, required this.orderId, required this.onPressed});

  @override
  Widget build(BuildContext context) => GoSheet(title: 'cancelOrder'.tr, icon: Icons.help_outline_rounded,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('doYouReallyWantToCancelTheOrder'.tr),
      const SizedBox(height: 22),
      GoPopupPrimaryButton(label: 'yesIWantToCancelIt'.tr, icon: Icons.check_rounded, onPressed: onPressed),
      const SizedBox(height: 8),
      TextButton(onPressed: () => Navigator.pop(context), child: Text('no'.tr)),
    ]));
}
