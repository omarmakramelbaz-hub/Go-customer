import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../controller/home_controller.dart';

class GoDriveCardWidget extends StatelessWidget {
  final HomeController controller;

  const GoDriveCardWidget({super.key, required this.controller});

  void _openRequestDelegate(BuildContext context) {
    if (HiveMethods.getToken() == null) {
      _showLoginRequired(context);
      return;
    }
    Navigator.of(context).pushNamed(RequestDelegateScreen.routeName);
  }

  void _showLoginRequired(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD8B5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 20,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1E4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.mainAppColor,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سجّل الدخول للمتابعة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF202328),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'يمكنك تصفح المطاعم كزائر، وتسجيل الدخول مطلوب لطلب مندوب أو تنفيذ طلب.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF7C828A),
                            fontSize: 11.5,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: messenger.hideCurrentSnackBar,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.close_rounded,
                        color: Color(0xFF999999),
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openRequestDelegate(context),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.mainAppColor.withValues(alpha: .52),
              width: 1.15,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF102033).withValues(alpha: .07),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: -36,
                top: -48,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainAppColor.withValues(alpha: .035),
                  ),
                ),
              ),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    flex: 59,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            textDirection: TextDirection.ltr,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _newBadge(),
                              const Spacer(),
                              Text(
                                'Go Drive',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: AppTextStyle.text18BS().copyWith(
                                  color: const Color(0xFF102033),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.55,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          3.sbH,
                          Text(
                            'خدمة توصيل',
                            textAlign: TextAlign.right,
                            style: AppTextStyle.text16BS().copyWith(
                              color: AppColors.mainAppColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          4.sbH,
                          Text(
                            'اطلب مندوب في أي وقت ومن أي مكان',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppTextStyle.text12MS().copyWith(
                              color: const Color(0xFF747A82),
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              _FeatureChip(
                                icon: Icons.bolt_rounded,
                                label: 'سريع',
                              ),
                              SizedBox(width: 5),
                              _FeatureChip(
                                icon: Icons.shield_outlined,
                                label: 'آمن',
                              ),
                              SizedBox(width: 5),
                              _FeatureChip(
                                icon: Icons.near_me_outlined,
                                label: 'مباشر',
                              ),
                            ],
                          ),
                          8.sbH,
                          Container(
                            width: double.infinity,
                            height: 43,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mainAppColor,
                                  const Color(0xFFFF871B),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainAppColor.withValues(alpha: .18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  'اطلب مندوب',
                                  style: AppTextStyle.text14BS().copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                8.sbW,
                                Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 41,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 10, 10, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFF8F1),
                              Color(0xFFFFF3E7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(
                            color: AppColors.mainAppColor.withValues(alpha: .10),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 12,
                              bottom: 18,
                              child: Container(
                                width: 48,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.mainAppColor.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 22,
                              bottom: 29,
                              child: Container(
                                width: 34,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.mainAppColor.withValues(alpha: .09),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.mainAppColor,
                                  size: 22,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 28, 2, 0),
                                child: Image.asset(
                                  'assets/images/deliveryRiderV2.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomCenter,
                                  filterQuality: FilterQuality.high,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Go Drive rider asset error: $error');
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mainAppColor,
            const Color(0xFFFF8A1F),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainAppColor.withValues(alpha: .20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'جديد',
        style: AppTextStyle.text11BS().copyWith(color: Colors.white),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.mainAppColor.withValues(alpha: .12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.mainAppColor),
            3.sbW,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.text10RG().copyWith(
                  color: const Color(0xFF303640),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
