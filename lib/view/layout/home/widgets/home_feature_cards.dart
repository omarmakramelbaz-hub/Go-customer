import 'package:flutter/material.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../controller/home_controller.dart';
import '../screen/draw_resturant_screen.dart';
import 'celebrate_widget.dart';

class HomeFeatureCards extends StatelessWidget {
  final HomeController controller;

  const HomeFeatureCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final coupon = controller.coupon;
    final isWinner = coupon?.flag?.trim().toLowerCase() == 'winner';

    if (isWinner) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CelebrateWidget(homeController: controller),
      );
    }

    final dashboardImage = coupon?.data?.image?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: InkWell(
        onTap: () => NamedNavigatorImpl.push(DrawRestaurantScreen.routeName),
        borderRadius: BorderRadius.circular(22),
        child: dashboardImage.isNotEmpty
            ? _DashboardContestImage(imageUrl: dashboardImage)
            : const _ContestFallbackCard(),
      ),
    );
  }
}

class _DashboardContestImage extends StatelessWidget {
  final String imageUrl;

  const _DashboardContestImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.mainAppColor.withValues(alpha: .20),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomNetworkImage(
        imageUrl: imageUrl,
        height: 140,
        width: double.infinity,
        radius: 0,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ContestFallbackCard extends StatelessWidget {
  const _ContestFallbackCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102F4A), Color(0xFF0A2135)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.mainAppColor.withValues(alpha: .28),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 42,
            child: Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .07),
                  border: Border.all(
                    color: AppColors.mainAppColor.withValues(alpha: .45),
                    width: 1.4,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.card_giftcard_rounded,
                      size: 58,
                      color: Color(0xFFFF8A00),
                    ),
                    Positioned(
                      top: 12,
                      right: 10,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: Colors.white.withValues(alpha: .92),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.mainAppColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'المسابقة اليومية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppTextStyle.text18BS().copyWith(
                    color: Colors.white,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اربح جوائز قيمة كل يوم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppTextStyle.text13BS().copyWith(
                    color: AppColors.mainAppColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'شارك الآن وكن من الفائزين المحظوظين',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppTextStyle.text10RG().copyWith(
                    color: Colors.white.withValues(alpha: .82),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard_rounded, size: 15, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'شارك الآن',
                        style: AppTextStyle.text11BS(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
