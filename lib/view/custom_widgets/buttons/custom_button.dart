import 'package:flutter/material.dart';

import '../../../helpers/networking/api_helper.dart';
import '../../../helpers/theme/go_design_tokens.dart';

class CustomButton extends StatelessWidget {
  final double radius;
  final double? width;
  final double height;
  final TextStyle? style;
  final String? text;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? child;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final ApiResponse? apiResponse;
  final bool isLoading;
  final bool isMainColor;
  final bool hasShadow;
  final void Function()? onPressed;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  const CustomButton({
    super.key,
    this.radius = GoDesign.radius,
    this.width,
    this.height = GoDesign.controlHeight,
    this.style,
    this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.color,
    this.gradient,
    this.apiResponse,
    this.isLoading = false,
    this.isMainColor = true,
    this.hasShadow = false,
    this.onPressed,
    this.child,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final busy = apiResponse?.state == ResponseState.loading || isLoading;
    final enabled = onPressed != null && !busy;
    final background = color ?? (isMainColor ? GoDesign.orange : GoDesign.ink);
    // A supplied white/secondary color must not be painted over by an orange
    // gradient. Several wallet and cancel actions rely on that distinction.
    final fillGradient = gradient ??
        (color == null && isMainColor ? GoDesign.actionGradient : null);
    final corners = (borderRadius ?? BorderRadius.circular(radius))
        .resolve(Directionality.of(context));
    final foreground = style?.color ??
        (background == GoDesign.orange || isMainColor && color == null
            ? GoDesign.paper
            : ThemeData.estimateBrightnessForColor(background) == Brightness.dark
                ? GoDesign.paper : GoDesign.ink);
    return Semantics(
      button: true,
      enabled: enabled,
      child: SizedBox(
        width: width ?? double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            gradient: fillGradient,
            borderRadius: corners,
            border: Border.all(color: borderColor ?? Colors.transparent),
            boxShadow: boxShadow ?? (hasShadow ? GoDesign.cardShadow : null),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: corners,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: corners,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: busy
                      ? Center(child: SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground)))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
                          Flexible(child: child ?? Text(text ?? '',
                            textAlign: TextAlign.center,
                            style: style ?? TextStyle(color: foreground,
                              fontSize: 16, fontWeight: FontWeight.w700))),
                          if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
                        ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
