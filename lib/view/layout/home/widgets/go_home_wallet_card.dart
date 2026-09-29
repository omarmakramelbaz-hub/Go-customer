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
                      right: box.maxWidth * .30,
                      top: box.maxHeight * .24,
                      bottom: box.maxHeight * .23,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
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
                              Text(
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
                              Text(
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
