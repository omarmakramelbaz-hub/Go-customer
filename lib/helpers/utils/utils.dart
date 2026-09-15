import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../../view/custom_widgets/custom_loading/custom_loading.dart';
import '../routes/app_routers_import.dart';
import '../theme/app_colors.dart';

class Utils {
  static void showAppDialog(Widget dialog, {bool willPop = true}) {
    showDialog(
      context: NamedNavigatorImpl.context,
      barrierDismissible: willPop,
      builder: (context) {
        return PopScope(canPop: willPop, child: dialog);
      },
    );
  }

  static void showAppBottomSheet(
    Widget bottomSheet, {
    bool willPop = true,
    bool? isScrollControlled,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: isScrollControlled ?? false,
      isDismissible: willPop,
      enableDrag: enableDrag,
      context: NamedNavigatorImpl.context,
      builder: (context) {
        return PopScope(canPop: willPop, child: bottomSheet);
      },
    );
  }

  static void loading({
    double size = 60,
    double radius = 30,
    double loadingSize = 30,
    Color? backgroundColor,
    Color? loadingColor,
  }) {
    FocusScope.of(NamedNavigatorImpl.navigatorState.currentContext!).requestFocus(FocusNode());
    BotToast.showCustomLoading(
      toastBuilder: (cancelFunc) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.scaffoldColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: CustomLoading(color: loadingColor ?? AppColors.mainAppColor, size: loadingSize),
        ),
      ),
    );
  }

  static void loadingOff() => BotToast.closeAllLoading();
}
