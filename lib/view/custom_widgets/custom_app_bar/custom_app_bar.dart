import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../helpers/images/app_images.dart';
import '../../../helpers/theme/go_design_tokens.dart';
import '../../../helpers/utils/utils.dart';
import '../../layout/auth/bottom_sheet/change_lang_bottom_sheet.dart';

Color _headerForeground(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? GoDesign.paper : GoDesign.ink;

Widget? _headerTitle(Widget? title, Color foreground) {
  if (title is Text && title.data != null) {
    return Text(title.data!, key: title.key,
      style: (title.style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
        .copyWith(color: foreground),
      textAlign: title.textAlign, maxLines: title.maxLines ?? 1,
      overflow: title.overflow ?? TextOverflow.ellipsis,
      semanticsLabel: title.semanticsLabel);
  }
  return title;
}

class CustomAppBar extends PreferredSize {
  final double height;
  final double radius;
  final double elevation;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final Color? appBarColor;
  final Color? shadowColor;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onPop;
  final bool showLang;

  CustomAppBar({
    super.key, this.height = kToolbarHeight, this.radius = 0, this.elevation = 0,
    this.leading, this.actions, this.title, this.appBarColor, this.centerTitle,
    this.bottom, this.leadingWidth, this.shadowColor,
    this.automaticallyImplyLeading = true, this.borderRadius, this.onPop,
    this.showLang = false,
  }) : super(
    preferredSize: Size.fromHeight(height + (bottom?.preferredSize.height ?? 0)),
    child: AppBar(
      elevation: elevation,
      scrolledUnderElevation: 0,
      backgroundColor: appBarColor ?? GoDesign.deepInk,
      foregroundColor: _headerForeground(appBarColor ?? GoDesign.deepInk),
      iconTheme: IconThemeData(color: _headerForeground(appBarColor ?? GoDesign.deepInk)),
      actionsIconTheme: IconThemeData(color: _headerForeground(appBarColor ?? GoDesign.deepInk)),
      systemOverlayStyle: _headerForeground(appBarColor ?? GoDesign.deepInk) == GoDesign.paper
          ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      toolbarHeight: height,
      automaticallyImplyLeading: automaticallyImplyLeading,
      shadowColor: shadowColor,
      centerTitle: centerTitle ?? true,
      title: _headerTitle(title, _headerForeground(appBarColor ?? GoDesign.deepInk)),
      leading: leading ?? (onPop == null ? null : BackButton(onPressed: onPop,
        color: _headerForeground(appBarColor ?? GoDesign.deepInk))),
      actions: actions ?? [
        if (showLang)
          IconButton(
            onPressed: () => Utils.showAppBottomSheet(const ChangeLangBottomSheet()),
            icon: SvgPicture.asset(AppImages.langIcon, width: 24, height: 24,
              colorFilter: ColorFilter.mode(
                _headerForeground(appBarColor ?? GoDesign.deepInk), BlendMode.srcIn)),
          ),
      ],
      shape: radius > 0 || borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius ??
              BorderRadius.vertical(bottom: Radius.circular(radius))) : null,
      leadingWidth: leadingWidth,
      bottom: bottom,
    ),
  );
}
