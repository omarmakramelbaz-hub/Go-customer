import 'package:flutter/material.dart';

import '../../helpers/theme/go_design_tokens.dart';
import 'go_drive_brand.dart';

/// Shared presentation widgets. All navigation and business actions are supplied
/// by route adapters; this file never reads or writes a customer's session.
class GoBrandHeader extends StatelessWidget {
  const GoBrandHeader({super.key, this.light = false, this.size = 68, this.isArabic = true});
  final bool light;
  final double size;
  final bool isArabic;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GoDriveBrand(size: size, light: light),
      const SizedBox(height: 8),
      Text(isArabic ? 'كل الخدمات عندك' : 'Every service, one app',
        textAlign: TextAlign.center,
        style: TextStyle(color: light ? GoDesign.paper : GoDesign.ink,
          fontSize: 15, fontWeight: FontWeight.w800)),
    ],
  );
}

class GoAuthTabs extends StatelessWidget {
  const GoAuthTabs({super.key, required this.register, required this.isArabic,
    required this.onLogin, required this.onRegister});
  final bool register;
  final bool isArabic;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool selected, VoidCallback action) => Expanded(
      child: Semantics(selected: selected, child: Material(
        color: selected ? GoDesign.orange : GoDesign.canvas,
        borderRadius: BorderRadius.circular(GoDesign.radius),
        child: InkWell(
          onTap: selected ? null : action,
          borderRadius: BorderRadius.circular(GoDesign.radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                  color: selected ? GoDesign.paper : GoDesign.ink))),
          ),
        ),
      )),
    );
    return Row(children: [
      tab(isArabic ? 'تسجيل الدخول' : 'Sign in', !register, onLogin),
      const SizedBox(width: 8),
      tab(isArabic ? 'إنشاء حساب' : 'Create account', register, onRegister),
    ]);
  }
}

class GoAuthBody extends StatelessWidget {
  const GoAuthBody({super.key, required this.children, this.isArabic = true});
  final List<Widget> children;
  final bool isArabic;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(GoDesign.pagePadding,
        constraints.maxHeight > 700 ? 48 : 24, GoDesign.pagePadding, 28),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: GoBrandHeader(isArabic: isArabic)),
          const SizedBox(height: 28),
          ...children,
        ]),
      )),
    )),
  );
}

class GoSurface extends StatelessWidget {
  const GoSurface({super.key, required this.child,
    this.padding = const EdgeInsets.all(16), this.margin = EdgeInsets.zero});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(color: GoDesign.paper,
      borderRadius: BorderRadius.circular(GoDesign.cardRadius),
      border: Border.all(color: GoDesign.border), boxShadow: GoDesign.cardShadow),
    child: child,
  );
}

class GoOrDivider extends StatelessWidget {
  const GoOrDivider({super.key, this.isArabic = true});
  final bool isArabic;
  @override
  Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider(color: GoDesign.border)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(isArabic ? 'أو' : 'or', style: const TextStyle(color: GoDesign.muted))),
    const Expanded(child: Divider(color: GoDesign.border)),
  ]);
}

/// The dark diagonal planes and orange sweep in the supplied splash reference.
/// Pure decoration: no timers or routing, so restoring a session is unchanged.
class GoSplashBackdrop extends StatelessWidget {
  const GoSplashBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: GoDesign.darkGradient),
    child: CustomPaint(painter: _GoSplashPainter(), child: child),
  );
}

class _GoSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shade = Paint()..color = const Color(0x24000000);
    final planes = Path()
      ..moveTo(0, size.height * .28)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * .14)
      ..lineTo(0, size.height * .42)
      ..close();
    canvas.drawPath(planes, shade);
    final sweep = Path()
      ..moveTo(-8, size.height * .84)
      ..cubicTo(size.width * .28, size.height * .65,
        size.width * .87, size.height * .76, size.width + 8, size.height * .58);
    canvas.drawPath(sweep, Paint()..color = GoDesign.orange
      ..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant _GoSplashPainter oldDelegate) => false;
}
