import '../popups/go_popups.dart';
import 'package:flutter/material.dart';

import '../../../helpers/extensions/extensions.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/theme/app_text_style.dart';

class DarkAppBottomSheet extends StatelessWidget {
  const DarkAppBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.isDark = false,
    this.showBorder = false,
  });
  final String title;
  final List<Widget> children;
  final bool? isDark;
  final bool? showBorder;
  @override
  Widget build(BuildContext context) => GoSheet(title: title, dark: isDark == true,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children));
}
