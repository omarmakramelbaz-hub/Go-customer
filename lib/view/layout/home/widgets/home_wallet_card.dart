import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/utils/utils.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../../my_account/screen/personal_information_screen.dart';
import '../../wallet/bottom_sheet/charge_wallet_bottom_sheet.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../../wallet/screen/wallet_screen.dart';

class HomeWalletCard extends StatefulWidget {
  const HomeWalletCard({super.key});

  @override
  State<HomeWalletCard> createState() => _HomeWalletCardState();
}

class _HomeWalletCardState extends State<HomeWalletCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<WalletController>();
      if (controller.wallet == null) controller.getWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(
      builder: (context, controller, _) {
        return _WalletContent(balance: controller.wallet?.balance ?? 0);
      },
    );
  }
}

class _WalletContent extends StatelessWidget {
  final double balance;

  const _WalletContent({required this.balance});

  void _openWalletCharge(BuildContext context) {
    final authController = context.read<AuthController>();
    final walletController = context.read<WalletController>();
    final myAccountController = context.read<MyAccountController>();

    if (authController.profile?.email == null) {
      NamedNavigatorImpl.push(PersonalInformationScreen.routeName);
      return;
    }

    Utils.showAppBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      ChangeNotifierProvider.value(
        value: walletController,
        child: ChargeWalletBottomSheet(
          walletController: walletController,
          myAccountController: myAccountController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _OuterWalletEdgeStitchPainter(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 0, 30, 14),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF151515),
              Color(0xFF252525),
              Color(0xFF0D0D0D),
            ],
            stops: [0, .52, 1],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF171717), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x22FFFFFF),
              blurRadius: 2,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: CustomPaint(
            painter: _LeatherWalletPainter(),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _LeatherWalletBadge(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المحفظة',
                          style: AppTextStyle.text15BS().copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'الرصيد الحالي',
                          style: AppTextStyle.text12BS().copyWith(
                            color: const Color(0xFFB9B9B9),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              balance.toStringAsFixed(2),
                              style: AppTextStyle.text20BS().copyWith(
                                fontSize: 29,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                'جنيه',
                                style: AppTextStyle.text16MS().copyWith(
                                  color: const Color(0xFFD2D2D2),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            Expanded(
                              child: _WalletButton(
                                title: 'شحن المحفظة',
                                filled: true,
                                stitchColor: const Color(0xFF000000),
                                icon: Icons.add_rounded,
                                onTap: () => _openWalletCharge(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _WalletButton(
                                title: 'تفاصيل المحفظة',
                                filled: false,
                                stitchColor: const Color(0xFFFF8A00),
                                icon: Icons.receipt_long_outlined,
                                onTap: () => NamedNavigatorImpl.push(
                                  WalletScreen.routeName,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _OuterWalletEdgeStitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 60 || size.height <= 14) return;

    const leftMargin = 30.0;
    const rightMargin = 30.0;
    const bottomMargin = 14.0;
    const edgeInset = 1.0;
    final cardWidth = math.max(0, size.width - leftMargin - rightMargin);
    final cardHeight = math.max(0, size.height - bottomMargin);

    final rect = Rect.fromLTWH(
      leftMargin + edgeInset,
      edgeInset,
      math.max(0, cardWidth - edgeInset * 2),
      math.max(0, cardHeight - edgeInset * 2),
    );

    final double radius = 26.0 - edgeInset;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(math.max(0.0, radius)),
        ),
      );

    _drawDashedPath(
      canvas,
      path,
      1.35,
      5.0,
      4.0,
      .98,
      const Color(0xFFFF8A00),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawDashedPath(
  Canvas canvas,
  Path path,
  double strokeWidth,
  double dashLength,
  double gapLength,
  double alpha,
  Color color,
) {
  final stitchPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = strokeWidth
    ..color = color.withValues(alpha: alpha);

  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final end = math.min(distance + dashLength, metric.length).toDouble();
      if (end > distance) {
        canvas.drawPath(metric.extractPath(distance, end), stitchPaint);
      }
      distance += dashLength + gapLength;
    }
  }
}

class _LeatherWalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .65
      ..color = const Color(0xFFB9B9B9).withValues(alpha: .075);

    for (var i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 2.5 + random.nextDouble() * 7.5;
      final angle = random.nextDouble() * math.pi;
      final end = Offset(
        x + math.cos(angle) * length,
        y + math.sin(angle) * length * .45,
      );
      canvas.drawLine(Offset(x, y), end, texturePaint);
    }

    final crackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .8
      ..color = const Color(0xFF000000).withValues(alpha: .22);

    for (var i = 0; i < 16; i++) {
      final start = Offset(
        8 + random.nextDouble() * (size.width - 16),
        9 + random.nextDouble() * (size.height - 18),
      );
      final angle = random.nextDouble() * math.pi * 2;
      final path = Path()..moveTo(start.dx, start.dy);
      var point = start;
      final segments = 2 + random.nextInt(3);

      for (var s = 0; s < segments; s++) {
        final length = 8 + random.nextDouble() * 15;
        final turn = (random.nextDouble() - .5) * .9;
        final nextAngle = angle + turn + (s * .08);
        point = Offset(
          point.dx + math.cos(nextAngle) * length,
          point.dy + math.sin(nextAngle) * length * .55,
        );
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, crackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeatherWalletBadge extends StatelessWidget {
  const _LeatherWalletBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 86,
      child: CustomPaint(
        painter: _WalletIllustrationPainter(),
      ),
    );
  }
}

class _WalletIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()..color = const Color(0x33000000);
    canvas.drawCircle(Offset(size.width * .52, size.height * .51), 38, shadow);

    final leather = Paint()..color = const Color(0xFF171717);
    final leatherHi = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFFF8A00);

    final walletRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 18, 52, 55),
      const Radius.circular(8),
    );
    canvas.drawRRect(walletRect, leather);
    canvas.drawRRect(walletRect, leatherHi);

    final flap = Path()
      ..moveTo(19, 23)
      ..lineTo(63, 16)
      ..quadraticBezierTo(72, 15, 74, 24)
      ..lineTo(73, 32)
      ..lineTo(21, 39)
      ..close();
    canvas.drawPath(flap, leather);
    canvas.drawPath(flap, leatherHi);

    final tab = RRect.fromRectAndRadius(
      Rect.fromLTWH(57, 39, 29, 16),
      const Radius.circular(7),
    );
    canvas.drawRRect(tab, leather);
    canvas.drawRRect(tab, leatherHi);

    final button = Paint()..color = const Color(0xFFFF9D1A);
    canvas.drawCircle(const Offset(66, 47), 6, button);

    final stitch = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFA63D);

    final stitchPath = Path()
      ..moveTo(23, 22)
      ..lineTo(67, 17)
      ..lineTo(70, 72)
      ..lineTo(24, 68)
      ..close();
    _drawDashed(canvas, stitchPath, stitch);

    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(46, 4, 22, 22),
      const Radius.circular(3),
    );
    canvas.save();
    canvas.translate(57, 15);
    canvas.rotate(-.12);
    canvas.translate(-57, -15);
    canvas.drawRRect(card, Paint()..color = const Color(0xFFFF8A00));
    canvas.restore();
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + 3.5, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WalletButton extends StatelessWidget {
  final String title;
  final bool filled;
  final Color stitchColor;
  final IconData icon;
  final VoidCallback onTap;

  const _WalletButton({
    required this.title,
    required this.filled,
    required this.stitchColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        filled ? const Color(0xFFFF7A00) : const Color(0xFF1B1B1B);
    final foreground = filled ? Colors.white : const Color(0xFFFFA31A);
    final borderColor =
        filled ? const Color(0xFF111111) : const Color(0xFFFF8A00);

    return Semantics(
      button: true,
      label: title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 38,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: borderColor,
                width: filled ? 1.0 : 1.8,
              ),
              boxShadow: filled
                  ? const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13, color: foreground),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTextStyle.text12BS().copyWith(
                      color: foreground,
                      fontSize: 9,
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
