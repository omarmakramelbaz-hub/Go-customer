import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/home_controller.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final VoidCallback onLocationTap;

  const HomeHeader({
    super.key,
    required this.controller,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    final addresses = profile?.userAddresses ?? [];
    final selectedAddressId =
        auth.selectedAddressId ?? HiveMethods.getSelectedCity();
    final selectedIndex =
        addresses.indexWhere((item) => item.id == selectedAddressId);
    final address = addresses.isEmpty
        ? null
        : addresses[selectedIndex >= 0 ? selectedIndex : 0];
    final location = [address?.streetName, address?.cityName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' - ');

    return ClipPath(
      clipper: const _FiveAngleHeaderClipper(),
      child: Container(
        height: 100,
        color: AppColors.mainAppColor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 42,
              left: 12,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLocationTap,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'التوصيل إلى',
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyle.text12BS().copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x55000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              location.isEmpty ? 'اختر العنوان' : location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: AppTextStyle.text12BS().copyWith(
                                color: Colors.white,
                                fontSize: 9.5,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x55000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const _LocationButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _LocationButton extends StatelessWidget {
  const _LocationButton();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 30,
        height: 34,
        child: Icon(
          Icons.location_on_rounded,
          color: Colors.white,
          size: 28,
        ),
      );
}

class _FiveAngleHeaderClipper extends CustomClipper<Path> {
  const _FiveAngleHeaderClipper();

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    const shallowDepth = 12.0;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height - shallowDepth)
      ..lineTo(width * .83, height - 2)
      ..lineTo(width * .67, height - shallowDepth)
      ..lineTo(width * .50, height - 2)
      ..lineTo(width * .33, height - shallowDepth)
      ..lineTo(width * .17, height - 2)
      ..lineTo(0, height - shallowDepth)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
