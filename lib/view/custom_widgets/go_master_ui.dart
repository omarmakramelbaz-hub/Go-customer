import 'package:flutter/material.dart';

import '../../helpers/identity/go_customer_identity.dart';
import '../../helpers/theme/go_design_tokens.dart';
import 'custom_form_field/custom_form_field.dart';
import 'go_drive_brand.dart';

/// Presentation widgets only. Route adapters own sessions and business actions.
class GoBrandHeader extends StatelessWidget {
  const GoBrandHeader({
    super.key,
    this.light = false,
    this.size = 68,
    this.isArabic = true,
    this.tagline,
  });
  final bool light;
  final double size;
  final bool isArabic;
  final String? tagline;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: size * 1.92,
        child: Center(
          child: GoDriveBrand(size: size, light: light),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 23, height: 3, color: GoDesign.orange),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              tagline ??
                  (isArabic ? 'كل الخدمات عندك' : 'Every service, one app'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: light ? GoDesign.paper : GoDesign.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 23, height: 3, color: GoDesign.orange),
        ],
      ),
    ],
  );
}

class GoAuthTabs extends StatelessWidget {
  const GoAuthTabs({
    super.key,
    required this.register,
    required this.isArabic,
    required this.onLogin,
    required this.onRegister,
  });
  final bool register;
  final bool isArabic;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool selected, VoidCallback action) => Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? GoDesign.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            onTap: selected ? null : action,
            borderRadius: BorderRadius.circular(9),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 12,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 14,
                    color: selected ? GoDesign.paper : GoDesign.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GoDesign.segmented,
        borderRadius: BorderRadius.circular(GoDesign.radius),
      ),
      child: Row(
        children: [
          tab(isArabic ? 'تسجيل الدخول' : 'Sign in', !register, onLogin),
          tab(isArabic ? 'إنشاء حساب' : 'Create account', register, onRegister),
        ],
      ),
    );
  }
}

class GoAuthBody extends StatelessWidget {
  const GoAuthBody({super.key, required this.children, this.isArabic = true});
  final List<Widget> children;
  final bool isArabic;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 700;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            GoDesign.authPadding,
            compact ? 20 : 42,
            GoDesign.authPadding,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: GoDesign.authMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GoBrandHeader(
                      isArabic: isArabic,
                      size: compact ? 61.6 : 73.6,
                    ),
                  ),
                  SizedBox(height: compact ? 26 : 36),
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Uses the same stable left-to-right phone layout as GO Partner in both locales.
class GoAuthPhoneField extends StatelessWidget {
  const GoAuthPhoneField({
    super.key,
    required this.controller,
    required this.isArabic,
    required this.validator,
    this.countryCode = '20',
  });
  final TextEditingController controller;
  final bool isArabic;
  final String countryCode;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => CustomFormField(
    controller: controller,
    validator: validator,
    title: isArabic ? 'رقم الهاتف' : 'Phone number',
    keyboardType: TextInputType.phone,
    textDirection: TextDirection.ltr,
    hintText: '10X XXX XXXX',
    unFocusColor: GoDesign.fieldBorder,
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+$countryCode',
            style: const TextStyle(
              color: GoDesign.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            height: 22,
            child: VerticalDivider(width: 1, color: GoDesign.fieldBorder),
          ),
        ],
      ),
    ),
    suffixIcon: const Icon(
      Icons.phone_outlined,
      color: GoDesign.authMuted,
      size: 21,
    ),
  );
}

class GoAuthPasswordField extends StatelessWidget {
  const GoAuthPasswordField({
    super.key,
    required this.controller,
    required this.title,
    required this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });
  final TextEditingController controller;
  final String title;
  final FormFieldValidator<String> validator;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) => CustomFormField(
    controller: controller,
    title: title,
    validator: validator,
    isPassword: true,
    textDirection: TextDirection.ltr,
    unFocusColor: GoDesign.fieldBorder,
    passwordColor: GoDesign.authMuted,
    focusNode: focusNode,
    onFieldSubmitted: onFieldSubmitted,
    prefixIcon: const Icon(
      Icons.lock_outline_rounded,
      color: GoDesign.authMuted,
      size: 21,
    ),
  );
}

class GoSurface extends StatelessWidget {
  const GoSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: GoDesign.paper,
      borderRadius: BorderRadius.circular(GoDesign.cardRadius),
      border: Border.all(color: GoDesign.border),
    ),
    child: child,
  );
}

class GoOrDivider extends StatelessWidget {
  const GoOrDivider({super.key, this.isArabic = true});
  final bool isArabic;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: GoDesign.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          isArabic ? 'أو' : 'or',
          style: const TextStyle(color: GoDesign.muted),
        ),
      ),
      const Expanded(child: Divider(color: GoDesign.border)),
    ],
  );
}

/// Original Partner opening artwork. No timers, progress UI or route changes.
class GoSplashBackdrop extends StatelessWidget {
  const GoSplashBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(GoCustomerIdentity.splashBackgroundAsset, fit: BoxFit.cover),
      child,
    ],
  );
}
