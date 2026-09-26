import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../controller/request_delegate_controller.dart';
import '../model/request_delegate_order_model.dart';
import '../widget/delegate_order_widget.dart';

class DelegateOrdersScreen extends StatefulWidget {
  static const routeName = 'DelegateOrdersScreen';
  const DelegateOrdersScreen({super.key});
  @override
  State<DelegateOrdersScreen> createState() => _DelegateOrdersScreenState();
}

class _DelegateOrdersScreenState extends State<DelegateOrdersScreen> {
  late PusherController _pusherController;
  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RequestDelegateController>().initialDelegateOrders();
      context.read<RequestDelegateController>().getDelegateOrders();
    });
    _pusherController.addEventListener('shipping.updated', _handleShippingUpdated);
  }

  void _handleShippingUpdated(PusherEvent event) {
    try {
      final decoded = jsonDecode(event.data) as Map<String, dynamic>;
      final orderData = decoded['order_id'] as Map<String, dynamic>;
      if (!mounted) return;
      final status = orderData['status']?.toString();
      final orderNo = orderData['order_no']?.toString();
      if (status != null && status != 'pending') {
        CommonMethods.showToast(message: '${'thereIsANewOrderWithStatus'.tr} $orderNo');
      }
      context.read<RequestDelegateController>().updateShippingOrder(RequestDelegateOrderModel.fromJson(orderData));
    } catch (e, stack) { log('Error handling Pusher event: $e'); log('Stack trace: $stack'); }
  }
  @override
  void dispose() {
    _pusherController.removeEventListener('shipping.updated', _handleShippingUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<RequestDelegateController>(builder: (context, controller, _) {
    final ar = context.languageCode == 'ar';
    return Scaffold(backgroundColor: GoDesign.paper,
      appBar: CustomAppBar(title: Text(ar ? 'طلباتي' : 'My orders')),
      body: SafeArea(top: false, child: RefreshIndicator(onRefresh: () async { await controller.getDelegateOrders(); },
        child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ApiResponseWidget(apiResponse: controller.delegateOrdersApiResponse,
            onReload: () => controller.getDelegateOrders(), isEmpty: controller.delegateOrders.isEmpty,
            child: Column(children: [
              ...controller.delegateOrders.map((order) => DelegateOrderWidget(requestDelegateOrderModel: order)),
              const SizedBox(height: 24),
            ])),
        ),
      )),
    );
  });
}
