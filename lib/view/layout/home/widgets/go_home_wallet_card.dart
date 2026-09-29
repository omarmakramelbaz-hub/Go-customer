import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';

enum GoHomeWalletAction { topUp, transfer, history }

/// The artwork is decorative; every amount and action is a live Flutter control.
class GoHomeWalletCard extends StatelessWidget {
  const GoHomeWalletCard({
    super.key,
    required this.isArabic,
    required this.signedIn,
    required this.balance,
    required this.onAction,
    this.isLoading = false,
    this.hasError = false,
    this.canTopUp = true,
  });

  final bool isArabic;
  final bool signedIn;
  final double? balance;
  final bool isLoading;
  final bool hasError;
  final bool canTopUp;
  final ValueChanged<GoHomeWalletAction> onAction;
  static const debossed = TextStyle(
    color: Color(0xFF161719),
    fontWeight: FontWeight.w800,
    shadows: [
      Shadow(
        color: Color(0xFF030405),
        offset: Offset(0, -0.8),
        blurRadius: 0.6,
      ),
      Shadow(color: Color(0xBB969696), offset: Offset(0, 1), blurRadius: 0.7),
    ],
  );
  static const artwork = 'assets/brand/go_home_wallet.webp';

  @override
  Widget build(BuildContext context) {
    final ar = isArabic;
    final amount = signedIn && balance != null && balance!.isFinite
        ? balance!.toStringAsFixed(2)
        : null;
    final label = !signedIn
        ? (ar ? 'سجّل الدخول' : 'Sign in')
        : hasError
        ? (ar ? 'تعذّر التحديث' : 'Refresh unavailable')
        : (ar ? 'الرصيد الحالي' : 'Current balance');
    final semantics = !signedIn
        ? label
        : '${ar ? 'الرصيد الحالي' : 'Current balance'}: '
              '${amount ?? (ar ? 'غير متاح' : 'unavailable')} '
              '${amount == null ? '' : (ar ? 'جنيه مصري' : 'EGP')}'
              '${hasError ? '. $label' : ''}';
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        key: const ValueKey('go-home-wallet'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: semantics,
            liveRegion: true,
            excludeSemantics: true,
            child: AspectRatio(
              aspectRatio: 1.6,
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      artwork,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    Positioned(
                      left: box.maxWidth * .17,
                      right: box.maxWidth * .32,
                      top: box.maxHeight * .22,
                      bottom: box.maxHeight * .28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StitchedWalletText(
                              label,
                              style: debossed.copyWith(
                                color: hasError ? GoDesign.orange : null,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (signedIn && amount == null && isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: GoDesign.orange,
                                  ),
                                ),
                              )
                            else
                              _StitchedWalletText(
                                amount ?? '—',
                                key: const ValueKey('go-home-wallet-balance'),
                                textDirection: TextDirection.ltr,
                                style: debossed.copyWith(
                                  letterSpacing: 0.5,
                                  fontSize: 38,
                                  height: 1.1,
                                ),
                              ),
                            if (amount != null)
                              _StitchedWalletText(
                                ar ? 'ج.م' : 'EGP',
                                style: debossed.copyWith(fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              _action(
                GoHomeWalletAction.topUp,
                ar ? 'شحن' : 'Top up',
                Icons.add_circle_outline,
                primary: true,
                enabled: !signedIn || canTopUp,
              ),
              const SizedBox(width: 4),
              _action(
                GoHomeWalletAction.transfer,
                ar ? 'تحويل' : 'Transfer',
                Icons.swap_horiz_rounded,
              ),
              const SizedBox(width: 4),
              _action(
                GoHomeWalletAction.history,
                ar ? 'العمليات' : 'History',
                Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(
    GoHomeWalletAction action,
    String title,
    IconData icon, {
    bool primary = false,
    bool enabled = true,
  }) {
    final foreground = !enabled
        ? GoDesign.muted
        : primary
        ? Colors.white
        : GoDesign.deepInk;
    return Expanded(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: title,
        excludeSemantics: true,
        child: Material(
          color: primary && enabled ? GoDesign.orange : const Color(0xFFFFEDDA),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            key: ValueKey('go-home-wallet-${action.name}'),
            onTap: enabled ? () => onAction(action) : null,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: foreground),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Embroidery follows the shaped letters, including Arabic joins and live digits.
class _StitchedWalletText extends StatelessWidget {
  const _StitchedWalletText(
    this.text, {
    super.key,
    required this.style,
    this.textDirection,
  });

  final String text;
  final TextStyle style;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final defaults = DefaultTextStyle.of(context);
    final resolvedStyle = defaults.style.merge(style);
    final direction = textDirection ?? Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final locale = Localizations.maybeLocaleOf(context);
    return CustomPaint(
      foregroundPainter: _LetterStitchingPainter(
        text: text,
        style: resolvedStyle,
        direction: direction,
        scaler: scaler,
        locale: locale,
        heightBehavior: defaults.textHeightBehavior,
      ),
      child: Text(
        text,
        style: resolvedStyle,
        textDirection: direction,
        textScaler: scaler,
        locale: locale,
        textHeightBehavior: defaults.textHeightBehavior,
      ),
    );
  }
}

class _LetterStitchingPainter extends CustomPainter {
  const _LetterStitchingPainter({
    required this.text,
    required this.style,
    required this.direction,
    required this.scaler,
    required this.locale,
    required this.heightBehavior,
  });

  final String text;
  final TextStyle style;
  final TextDirection direction;
  final TextScaler scaler;
  final Locale? locale;
  final TextHeightBehavior? heightBehavior;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final fontSize = style.fontSize ?? 14;
    final scale = scaler.scale(fontSize) / fontSize;
    final pitch = fontSize * .12 * scale;
    final thread = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (fontSize * .05).clamp(.85, 1.9) * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      // Short orange stitches with a lit strand and a gap exposing the leather.
      // The shader is applied to glyph outlines, never to their bounding box.
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        tileMode: TileMode.repeated,
        colors: [
          Color(0xFFC75D13),
          GoDesign.orange,
          Color(0xFFFFCB8B),
          GoDesign.orange,
          Color(0x00FF7900),
          Color(0x00FF7900),
        ],
        stops: [0, .2, .35, .65, .8, 1],
      ).createShader(Rect.fromLTWH(0, 0, pitch, pitch));
    final lettering = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          foreground: thread,
          shadows: const [
            Shadow(
              color: Color(0xDD090502),
              offset: Offset(0, .65),
              blurRadius: .4,
            ),
          ],
        ),
      ),
      textDirection: direction,
      textScaler: scaler,
      locale: locale,
      textHeightBehavior: heightBehavior,
    )..layout(maxWidth: size.width);
    lettering.paint(canvas, Offset.zero);
    lettering.dispose();
  }

  @override
  bool shouldRepaint(covariant _LetterStitchingPainter oldDelegate) =>
      text != oldDelegate.text ||
      style != oldDelegate.style ||
      direction != oldDelegate.direction ||
      scaler != oldDelegate.scaler ||
      locale != oldDelegate.locale ||
      heightBehavior != oldDelegate.heightBehavior;
}
