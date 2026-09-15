import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../../custom_widgets/global_widgets/connect_support_widget.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../bottom_sheet/cancel_order_bottom_sheet.dart';
import '../bottom_sheet/pay_tips_bottom_sheet.dart';
import '../controller/orders_controller.dart';
import '../model/orders_model.dart';
import '../widgets/delivery_agent_widget.dart';
import '../widgets/delivery_restaurant_widget.dart';
import '../widgets/order_item_widget.dart';
import '../widgets/tracking_your_order_widget.dart';
import 'service_rating_screen.dart';

class TrackingYourOrderArgs {
  final int id;

  TrackingYourOrderArgs({required this.id});
}

class TrackingYourOrderScreen extends StatefulWidget {
  final TrackingYourOrderArgs args;
  static const routeName = 'TrackingYourOrderScreen';

  const TrackingYourOrderScreen({super.key, required this.args});

  @override
  State<TrackingYourOrderScreen> createState() => _TrackingYourOrderScreenState();
}

class _TrackingYourOrderScreenState extends State<TrackingYourOrderScreen> {
  late PusherController _pusherController;

  @override
  initState() {
    super.initState();
    _pusherController = context.read<PusherController>();
    final controller = Provider.of<OrdersController>(context, listen: false);
    final accountController = Provider.of<MyAccountController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (controller.detailsOrders?.status != 'completed' &&
      //     controller.detailsOrders?.status != 'cancelled' &&
      //     controller.detailsOrders?.status != 'declined') {
      //   final liveActivitiesController = Provider.of<DeliveryProvider>(context, listen: false);
      //   liveActivitiesController.init(widget.args.id).whenComplete(() {
      //     liveActivitiesController.startDelivery(controller.detailsOrders?.status);
      //   });
      // }

      controller.initialDetailsOrders();
      controller.getDetailsOrders(id: widget.args.id);
      accountController.initialSetting();
      accountController.getSetting();
    });
    _pusherController.addEventListener('user.updated', _handleOrderUpdated);
  }

  void _handleOrderUpdated(PusherEvent event) {
    try {
      Provider.of<OrdersController>(context, listen: false).getDetailsOrders(id: widget.args.id);

      if (mounted) {}
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  dispose() {
    _pusherController.removeEventListener('user.updated', _handleOrderUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 90,
        radius: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
          onPressed: () => NamedNavigatorImpl.pop(),
        ),
        title: Text('trackingYourOrder'.tr, style: AppTextStyle.text20BS()),
        actions: const [],
      ),
      body: Consumer2<OrdersController, MyAccountController>(
        builder: (context, ordersController, settingController, _) {
          DateTime createdAtPlus6Hours = DateTime.now();

          final orders = ordersController.detailsOrders;
          final status = orders?.status ?? '';
          final delegateFromOut = orders?.delegateFromOut;
          bool isDeclined = status == 'declined';
          bool isPending = status == 'pending';
          bool isNewOrder = status == 'new_order';
          bool isCompleted = status == 'completed';
          bool isCancelled = status == 'cancelled';

          if (orders?.updatedAt != null) {
            DateTime createdAtDateTime = DateTime.parse(orders?.updatedAt.toString() ?? '').toLocal();
            createdAtPlus6Hours = createdAtDateTime.add(const Duration(hours: 6));
          }
          return ApiResponseWidget(
            apiResponse: ordersController.detailsOrdersApiResponse,
            onReload: () => ordersController.getDetailsOrders(id: widget.args.id),
            isEmpty: ordersController.detailsOrders == null,
            child: RefreshIndicator(
              onRefresh: () async {
                ordersController.getDetailsOrders(id: widget.args.id);
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 100),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(36),
                              topLeft: Radius.circular(36),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greyColor.withValues(alpha: .2),
                                blurRadius: 10,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 90),
                              Center(child: Text(orders?.resturantName ?? '', style: AppTextStyle.text18BS())),
                              10.sbH,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('requestCode'.tr, style: AppTextStyle.text14RS()),
                                  const SizedBox(width: 5),
                                  Text(':', style: AppTextStyle.text16RS()),
                                  const SizedBox(width: 6),
                                  Text(orders?.orderNo ?? ''),
                                ],
                              ),
                              10.sbH,
                              Divider(color: AppColors.greyColor.withValues(alpha: .1), thickness: 5),
                              15.sbH,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Text(
                                  _getString(orders),
                                  style: AppTextStyle.text18BS(),
                                ),
                              ),
                              15.sbH,
                              if (!isCancelled || !isDeclined)
                                TrackingYourOrderWidget(orderDate: orders?.updatedAt ?? '', status: status),
                              if ((!isCompleted &&
                                      status != 'show' &&
                                      delegateFromOut == 'out_resturant' &&
                                      delegateFromOut == 'shipped') ||
                                  isPending)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      Utils.showAppBottomSheet(
                                        CancelOrderBottomSheet(
                                          orderId: orders?.id ?? 0,
                                          onPressed: () {
                                            NamedNavigatorImpl.pop();
                                            context.read<OrdersController>().cancelOrder(
                                                  orderId: orders?.id ?? 0,
                                                  onSuccess: () => NamedNavigatorImpl.pop(),
                                                );
                                          },
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text('doYouWant'.tr, style: AppTextStyle.text16RS()),
                                        const SizedBox(width: 5),
                                        Text('cancelYourOrder'.tr, style: AppTextStyle.text16RM()),
                                      ],
                                    ),
                                  ),
                                ),
                              5.sbH,
                              Divider(color: AppColors.greyColor.withValues(alpha: .1), thickness: 2),
                              ...List.generate(
                                orders?.items?.length ?? 0,
                                (index) => OrderItemWidget(
                                  paymentType: orders?.paymentType ?? '',
                                  orderItem: orders?.items?[index],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 21),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('subtotal'.tr, style: AppTextStyle.text16RG()),
                                        const Spacer(),
                                        Text(
                                          'pound'.tr.replaceAll(
                                                '{}',
                                                '${orders?.updatedTotalItemPrice ?? orders?.totalItemPrice}',
                                              ),
                                          style: AppTextStyle.text16RG(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Text('deliveryCharges'.tr, style: AppTextStyle.text16RG()),
                                        const Spacer(),
                                        Text(
                                          'pound'.tr.replaceAll(
                                                '{}',
                                                '${orders?.deliveryPrice.toString()}',
                                              ),
                                          style: AppTextStyle.text16RG(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Text('serviceFees'.tr, style: AppTextStyle.text16RG()),
                                        const Spacer(),
                                        Text(
                                          'pound'.tr.replaceAll('{}', '${orders?.serviceFees}'),
                                          style: AppTextStyle.text16RG(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text('addedValuePrice'.tr, style: AppTextStyle.text16RG()),
                                        const Spacer(),
                                        Text(
                                          'pound'.tr.replaceAll('{}', '${orders?.tax}'),
                                          style: AppTextStyle.text16RG(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text('total'.tr, style: AppTextStyle.text16MS()),
                                        const Spacer(),
                                        Text(
                                          'pound'.tr.replaceAll('{}', '${orders?.grandTotal}'),
                                          style: AppTextStyle.text16MS(),
                                        ),
                                      ],
                                    ),
                                    Divider(color: AppColors.greyColor.withValues(alpha: .1), thickness: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: Text(
                                            'paymentMethod'.tr,
                                            style: AppTextStyle.text16BS(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 24,
                                          width: 5,
                                          decoration: BoxDecoration(
                                            color: AppColors.mainAppColor,
                                            borderRadius: BorderRadius.horizontal(
                                              left: context.languageCode == 'ar'
                                                  ? const Radius.circular(5)
                                                  : const Radius.circular(0),
                                              right: context.languageCode == 'ar'
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        CustomImage(
                                          height: 18,
                                          path: _getImagePath(orders?.paymentType),
                                          type: ImageType.svg,
                                          color: AppColors.mainAppColor,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(_getText(orders?.paymentType), style: AppTextStyle.text16BM()),
                                      ],
                                    ),
                                    30.sbH,
                                  ],
                                ),
                              ),
                              Divider(color: AppColors.greyColor.withValues(alpha: .1), thickness: 2),
                            ],
                          ),
                        ),
                        30.sbH,
                        (() {
                          if (delegateFromOut == 'out_resturant' &&
                              orders?.delegateId != null &&
                              DateTime.now().isBefore(createdAtPlus6Hours)) {
                            if (isNewOrder) {
                              return DeliveryRestaurantWidget(orders: ordersController.detailsOrders);
                            } else {
                              return DeliveryAgentWidget(orders: ordersController.detailsOrders);
                            }
                          } else {
                            if (delegateFromOut == 'in_resturant' && orders?.resturantId != null) {
                              if (DateTime.now().isBefore(createdAtPlus6Hours)) {
                                return DeliveryRestaurantWidget(orders: ordersController.detailsOrders);
                              } else {
                                return const SizedBox();
                              }
                            } else {
                              return const SizedBox();
                            }
                          }
                        }()),
                        (() {
                          if (isCompleted &&
                              orders?.hasRatedBefore != 1 &&
                              (!isCompleted || DateTime.now().isBefore(createdAtPlus6Hours))) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: CustomButton(
                                    onPressed: () {
                                      NamedNavigatorImpl.push(
                                        ServiceRatingScreen.routeName,
                                        arguments: ServiceRatingArgs(
                                          detailsOrder: ordersController.detailsOrders,
                                          onRatingChanged: () {
                                            ordersController.getDetailsOrders(id: widget.args.id);
                                          },
                                        ),
                                      );
                                    },
                                    text: 'serviceEvaluation'.tr,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        }()),
                        if (Provider.of<AuthController>(context, listen: false).profile?.balance != 0 &&
                            delegateFromOut == 'out_resturant' &&
                            orders?.hasCommissionedBefore != 1 &&
                            isCompleted &&
                            DateTime.now().isBefore(createdAtPlus6Hours)) ...[
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Utils.showAppBottomSheet(
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  PayTipsBottomSheet(
                                    orderId: orders?.id ?? 0,
                                    onSuccess: () => ordersController.getDetailsOrders(id: widget.args.id),
                                  ),
                                );
                              },
                              child: Text(
                                'payATipsToTheRepresentative'.tr,
                                style: AppTextStyle.text16BS(),
                              ),
                            ),
                          ),
                        ],
                        if (!isCompleted || DateTime.now().isBefore(createdAtPlus6Hours)) ...[
                          if (isCancelled) const SizedBox() else const ConnectSupportWidget(),
                        ],
                      ],
                    ),
                    Positioned(
                      right: context.width * 0.3,
                      left: context.width * 0.3,
                      top: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                          border: Border.all(color: AppColors.lightDarkColor.withValues(alpha: 0.5)),
                        ),
                        child: CustomNetworkImage(
                          radius: 80,
                          height: 170,
                          fit: BoxFit.cover,
                          imageUrl: orders?.resturantLogo ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getString(OrdersModel? orders) {
    if (orders?.status == 'shipped') {
      return 'theRepresentativeHasReceivedTheOrderAndIsNowHeadingToYourDestination'.tr;
    } else if (orders?.status == 'declined') {
      return 'orderDeclinedFromRestaurant'.tr;
    } else if (orders?.status == 'cancelled') {
      return 'orderCanceled'.tr;
    } else {
      if (orders?.status == 'completed' || orders?.delegateFromOut == 'in_resturant') {
        return 'yourOrderHasBeenDelivered'.tr;
      } else {
        return 'yourOrderHasBeenReceivedAndIsBeingPreparedPleaseWaitALittle'.tr;
      }
    }
  }

  String _getImagePath(String? paymentType) {
    switch (paymentType) {
      case 'cash':
        return AppImages.cashIcon;
      case 'online':
        return AppImages.visaIcon;
      case 'v_cash':
        return AppImages.vfCash;
      case 'wallet':
        return AppImages.payWalletIcon;
      default:
        return '';
    }
  }

  String _getText(String? paymentType) {
    switch (paymentType) {
      case 'cash':
        return 'cash'.tr;
      case 'online':
        return 'visa'.tr;
      case 'v_cash':
        return 'vfCash'.tr;
      case 'wallet':
        return 'appWallet'.tr;
      default:
        return '';
    }
  }
}
