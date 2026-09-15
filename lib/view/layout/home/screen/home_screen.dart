import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../address/screen/add_address_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/model/profile_model.dart';
import '../controller/home_controller.dart';
import '../model/previous_order_home_model.dart';
import '../model/restaurants_near_you_home_model.dart';
import '../widgets/go_drive_card_widget.dart';
import '../widgets/home_feature_cards.dart';
import '../widgets/home_header.dart';
import '../widgets/home_wallet_card.dart';
import 'home_screen_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PusherController _pusherController;

  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureProfileLoaded();
      if (!mounted) return;
      final homeController = context.read<HomeController>();
      await homeController.getHeaderImage();
      await homeController.getSlider();
      await homeController.getRestaurantsNearYou(
        lat: HiveMethods.getLat(),
        lng: HiveMethods.getLan(),
      );
      if (!mounted) return;
      await _checkSelectedCity();
    });

    _registerPusherListeners();
  }

  void _registerPusherListeners() {
    _pusherController.addEventListener('coupon.wheel.updated', _onCouponWheelUpdated);
    _pusherController.addEventListener('resturant.updated', _onResturantUpdated);
  }

  void _unregisterPusherListeners() {
    _pusherController.removeEventListener('resturant.updated', _onResturantUpdated);
    _pusherController.removeEventListener('coupon.wheel.updated', _onCouponWheelUpdated);
  }

  Future<void> _ensureProfileLoaded() async {
    final auth = context.read<AuthController>();
    if (auth.profile == null) {
      await auth.getProfile();
    }
  }

  void _onCouponWheelUpdated(PusherEvent event) {
    log('Coupon Wheel Updated: ${event.data}');
    if (!mounted) return;
    final homeProvider = context.read<HomeController>();
    homeProvider.getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
  }

  void _onResturantUpdated(PusherEvent event) {
    try {
      final decoded = json.decode(event.data) as Map<String, dynamic>;
      final resturantData = decoded['resturant'] as Map<String, dynamic>;
      if (!mounted) return;

      final resturantModel = RestaurantsNearYouHomeModel.fromJson(resturantData);
      final previousModel = PreviousOrderHomeModel.fromJson(resturantData);

      final homeController = context.read<HomeController>();
      homeController.updateResturantNearestYou(resturantModel);
      homeController.updateSpacialResturant(resturantModel);
      homeController.updatePreviousResturant(previousModel);
    } catch (e, st) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $st');
    }
  }

  @override
  void dispose() {
    _unregisterPusherListeners();
    super.dispose();
  }

  Future<void> _checkSelectedCity() async {
    final selectedCity = HiveMethods.getSelectedCity();
    if (selectedCity == null && mounted) {
      await context.read<AuthController>().getProfile();
      if (!mounted) return;
      _showCitySelectionSheet(delayed: true);
    }
  }

  String _addressPrimaryLine(UserAddresses address) {
    final street = (address.streetName ?? '').trim();
    final city = (address.cityName ?? '').trim();
    final country = (address.countryName ?? '').trim();

    if (street.isNotEmpty) return street;
    if (city.isNotEmpty) return city;
    if (country.isNotEmpty) return country;
    return 'deliveryAddresses'.tr;
  }

  String _addressSecondaryLine(UserAddresses address) {
    final primary = _addressPrimaryLine(address);
    final city = (address.cityName ?? '').trim();
    final country = (address.countryName ?? '').trim();
    final parts = <String>[];

    if (city.isNotEmpty && city != primary) parts.add(city);
    if (country.isNotEmpty && country != primary) parts.add(country);

    return parts.join(' • ');
  }

  void _showCitySelectionSheet({bool delayed = false}) {
    final authProvider = context.read<AuthController>();
    final userAddresses = authProvider.profile?.userAddresses ?? [];
    final previousIds =
        userAddresses.map((address) => address.id).whereType<int>().toSet();

    void openAddAddress() {
      if (!mounted) return;
      _openAddAddressScreen(previousIds);
    }

    if (userAddresses.isEmpty) {
      if (delayed) {
        Future.delayed(const Duration(milliseconds: 500), openAddAddress);
      } else {
        openAddAddress();
      }
      return;
    }

    final selectedAddressId =
        authProvider.selectedAddressId ?? HiveMethods.getSelectedCity();
    final orderedAddresses = List<UserAddresses>.from(userAddresses)
      ..sort((a, b) {
        final aSelected = a.id == selectedAddressId;
        final bSelected = b.id == selectedAddressId;
        if (aSelected == bSelected) return 0;
        return aSelected ? -1 : 1;
      });

    void showSheet() {
      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: !delayed,
        enableDrag: !delayed,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.42),
        builder: (sheetContext) {
          final screenHeight = MediaQuery.sizeOf(sheetContext).height;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.84),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8D8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.mainAppColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.mainAppColor,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'deliveryAddresses'.tr,
                              style: AppTextStyle.text16BS().copyWith(
                                color: AppColors.darkTextColor,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreyColor,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${orderedAddresses.length}',
                              style: AppTextStyle.text12BS().copyWith(
                                color: AppColors.darkGreyColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!delayed) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => Navigator.of(sheetContext).pop(),
                              borderRadius: BorderRadius.circular(99),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreyColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppColors.darkTextColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderColor.withOpacity(0.55),
                    ),
                    Flexible(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: orderedAddresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final address = orderedAddresses[index];
                          final isSelected = address.id == selectedAddressId;
                          final secondary = _addressSecondaryLine(address);

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onAddressSelected(address),
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.mainAppColor.withOpacity(0.07)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.mainAppColor
                                        : AppColors.borderColor.withOpacity(0.8),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? const []
                                      : const [
                                          BoxShadow(
                                            color: Color(0x0A000000),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.mainAppColor
                                            : AppColors.mainAppColor
                                                .withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        size: 23,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.mainAppColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _addressPrimaryLine(address),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                AppTextStyle.text16BS().copyWith(
                                              color: AppColors.darkTextColor,
                                              fontSize: 15,
                                              height: 1.35,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (secondary.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              secondary,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyle.text12BS()
                                                  .copyWith(
                                                color: AppColors.greyColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.mainAppColor
                                            : AppColors.lightGreyColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isSelected
                                            ? Icons.check_rounded
                                            : Icons.chevron_left_rounded,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.darkGreyColor,
                                        size: 19,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.borderColor.withOpacity(0.6),
                          ),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 18,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _openAddAddressScreen(previousIds);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.mainAppColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_location_alt_rounded,
                            size: 22,
                          ),
                          label: Text(
                            'deliveryToAnotherAddress'.tr,
                            style: AppTextStyle.text16BS().copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (delayed) {
      Future.delayed(const Duration(milliseconds: 500), showSheet);
    } else {
      showSheet();
    }
  }

  void _openAddAddressScreen(Set<int> previousIds) {
    NamedNavigatorImpl.push(
      AddAddressScreen.routeName,
      arguments: AddAddressArgs(
        onSuccess: () {
          _handleAddressAdded(previousIds);
        },
      ),
    );
  }

  Future<void> _handleAddressAdded(Set<int> previousIds) async {
    final authProvider = context.read<AuthController>();
    await authProvider.getProfile();
    if (!mounted) return;

    final refreshedAddresses = authProvider.profile?.userAddresses ?? [];
    if (refreshedAddresses.isEmpty) return;

    final newAddress = refreshedAddresses.firstWhere(
      (address) => address.id != null && !previousIds.contains(address.id),
      orElse: () => refreshedAddresses.last,
    );

    _onAddressSelected(newAddress, closeSheet: false);
  }

  void _onAddressSelected(UserAddresses address, {bool closeSheet = true}) {
    if (closeSheet) {
      Navigator.pop(context);
    }

    final authProvider = context.read<AuthController>();
    final homeController = context.read<HomeController>();

    authProvider.setSelectedAddressId(address.id);

    homeController.initialCountCart();
    homeController.initialHeaderImage();
    homeController.initialSlider();
    homeController.initialDefaultSlider();
    homeController.initialPreviousOrder();
    homeController.initialRestaurantsNearYou();
    homeController.initialCoupon();
    homeController.initialSpacialRestaurants();

    if (address.id != null) {
      HiveMethods.updateSelectedCity(address.id!);
    }
    HiveMethods.updateLat(double.tryParse(address.lat.toString()) ?? 0);
    HiveMethods.updateLan(double.tryParse(address.lng.toString()) ?? 0);
    HiveMethods.updateCity(address.streetName ?? '');
    HiveMethods.updateSelectedCityAreaId(address.cityId ?? 0);

    Future.wait([
      homeController.getHeaderImage(),
      homeController.getRestaurantsNearYou(
        lat: double.tryParse(address.lat ?? '') ?? HiveMethods.getLat(),
        lng: double.tryParse(address.lng ?? '') ?? HiveMethods.getLan(),
      ),
      homeController.getCoupon(
        lat: HiveMethods.getLat(),
        lng: HiveMethods.getLan(),
      ),
      homeController.getPreviousOrder(),
      homeController.getSpacialRestaurants(
        lat: HiveMethods.getLat(),
        lng: HiveMethods.getLan(),
      ),
      homeController.getSlider(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final isGuest = HiveMethods.getToken() == null;
        final hasSelectedLocation =
            HiveMethods.getLat() != null && HiveMethods.getLan() != null;
        final topContentSpacer =
            (isGuest || !hasSelectedLocation) ? 268.0 : 238.0;

        return Scaffold(
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Keep the first visible home card fully below the wallet.
                    SizedBox(height: topContentSpacer),
                    RestaurantsNearYouWidget(controller: controller),
                    SliderWidget(controller: controller),
                    HomeFeatureCards(controller: controller),
                    const SizedBox(height: 8),
                    GoDriveCardWidget(controller: controller),
                    20.sbH,
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: HomeHeader(
                    controller: controller,
                    onLocationTap: () => _showCitySelectionSheet(),
                  ),
                ),
                const Positioned(
                  top: 112,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: HomeWalletCard(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
