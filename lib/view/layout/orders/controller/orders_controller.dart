import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/delivery_activity/delivery_provider.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../cart/screen/cart_screen.dart';
import '../model/orders_model.dart';

class OrdersController extends ChangeNotifier {
  // void updateOrder(OrdersModel updatedOrder) {
  //   // Find the index of the order with the matching ID
  //   final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
  //
  //   if (index != -1) {
  //     // Update the existing order
  //     _orders[index] = updatedOrder;
  //   } else {
  //     // If the order doesn't exist, add it to the list
  //     _orders.add(updatedOrder);
  //   }
  //
  //   // Notify listeners to update the UI
  //   notifyListeners();
  // }

  ApiResponse _ordersApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get ordersApiResponse => _ordersApiResponse;

  void initialOrders() {
    _ordersApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _orders = [];
    notifyListeners();
  }

  List<OrdersModel> _orders = [];
  List<OrdersModel> get orders => _orders;
  Future<void> getOrders() async {
    _ordersApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    notifyListeners();
    _ordersApiResponse = await ApiHelper.instance.get(Urls.orders);
    notifyListeners();
    if (_ordersApiResponse.state == ResponseState.complete) {
      Iterable iterable = _ordersApiResponse.data['data'];
      _orders = iterable.map((e) => OrdersModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  //===========> details Orders <==========
  ApiResponse _detailsOrdersApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get detailsOrdersApiResponse => _detailsOrdersApiResponse;

  void initialDetailsOrders() {
    _detailsOrdersApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _detailsOrders = null;
    notifyListeners();
  }

  OrdersModel? _detailsOrders;
  OrdersModel? get detailsOrders => _detailsOrders;

  Future<void> getDetailsOrders({required int id}) async {
    _detailsOrdersApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    notifyListeners();
    _detailsOrdersApiResponse = await ApiHelper.instance.get('${Urls.detailsOrders}/$id');
    notifyListeners();
    if (_detailsOrdersApiResponse.state == ResponseState.complete) {
      _detailsOrders = OrdersModel.fromJson(_detailsOrdersApiResponse.data['data']);
      notifyListeners();
      prepareReorderData();
    }
  }

  List<int?> productId = [];
  List<int?> productFeatureId = [];
  List<String?> productClean = [];
  List<int?> productQuantity = [];
  void prepareReorderData() {
    if (_detailsOrders != null && _detailsOrders!.items != null) {
      // Filter out items with restaurantProduct status "hide"
      final validItems = _detailsOrders!.items!
          .where((item) => item.restaurantProduct != null && item.restaurantProduct!.status != 'hide')
          .toList();

      // Map data only for valid items
      productId = validItems.map((item) => item.restaurantProduct?.id).toList();
      productFeatureId = validItems.map((item) => item.productFeature).toList();
      productClean = validItems.map((item) => item.productClean).toList();
      productQuantity = validItems.map((item) => item.qty).toList();
    }
  }

  // void prepareReorderData() {
  //   if (_detailsOrders != null && _detailsOrders!.items != null) {
  //     productId = _detailsOrders!.items!
  //         .map((item) => item.restaurantProduct?.id)
  //         .toList();
  //     productFeatureId =
  //         _detailsOrders!.items!.map((item) => item.productFeature).toList();
  //     productClean =
  //         _detailsOrders!.items!.map((item) => item.productClean).toList();
  //     productQuantity = _detailsOrders!.items!.map((item) => item.qty).toList();
  //   }
  // }

  void updateProductDetails({required int index, int? quantity, int? featureId, String? clean}) {
    if (index < productQuantity.length) {
      productQuantity[index] = quantity;
      productFeatureId[index] = featureId;
      productClean[index] = clean;
      notifyListeners();
    }
  }

  //=> reorder
  Future<void> addReorderToCart({
    required List<int?> productId,
    required List<int?> productFeatureId,
    required List<String?> productClean,
    required List<int?> productQuantity,
  }) async {
    FormData body = FormData();
    for (int i = 0; i < productId.length; i++) {
      body.fields.add(MapEntry('resturant_product_id[$i]', productId[i]?.toString() ?? ''));
      body.fields.add(MapEntry('product_feature[$i]', productFeatureId[i]?.toString() ?? ''));
      body.fields.add(MapEntry('product_clean[$i]', productClean[i] ?? ''));
      body.fields.add(MapEntry('qty[$i]', productQuantity[i]?.toString() ?? ''));
    }
    Utils.loading();
    final response = await ApiHelper.instance.post(Urls.reOrder, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      NamedNavigatorImpl.push(CartScreen.routeName);
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  //===========> review Orders <==========
  Future<void> reviewOrders({
    required int orderId,
    required int restaurantId,
    required int rate,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({'order_id': orderId, 'resturant_id': restaurantId, 'rate': rate});
    final response = await ApiHelper.instance.post(Urls.reviewOrders, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  //===========> cancel order <==========
  Future<void> cancelOrder({
    required int orderId,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();

    final response = await ApiHelper.instance.post('${Urls.cancelOrder}/$orderId');

    if (response.state == ResponseState.complete) {
      Utils.loadingOff();
      CommonMethods.showToast(message: response.data['message']);
      Provider.of<DeliveryProvider>(NamedNavigatorImpl.context, listen: false).stopDelivery();
      onSuccess.call();
      await getOrders();
      return;
    }

    // The legacy backend used to update the order first and could then fail
    // while sending an e-mail / broadcast. Verify the persisted state before
    // showing an error so the customer never sees a false cancellation error.
    final verifyResponse = await ApiHelper.instance.get('${Urls.detailsOrders}/$orderId');
    String? verifiedStatus;
    if (verifyResponse.state == ResponseState.complete) {
      final dynamic verifyData = verifyResponse.data['data'];
      if (verifyData is Map) {
        verifiedStatus = verifyData['status']?.toString();
      }
    }

    Utils.loadingOff();

    if (verifiedStatus == 'cancelled') {
      CommonMethods.showToast(message: 'تم إلغاء الطلب بنجاح');
      Provider.of<DeliveryProvider>(NamedNavigatorImpl.context, listen: false).stopDelivery();
      onSuccess.call();
      await getOrders();
      return;
    }

    CommonMethods.showError(message: response.data['message'], apiResponse: response);
  }

  //===========> commission order <==========
  Future<void> commissionOrder({required int orderId, required int commission, required VoidCallback onSuccess}) async {
    FormData body = FormData.fromMap({'order_id': orderId, 'commission': commission});
    Utils.loading();
    final response = await ApiHelper.instance.post(Urls.commissionOrder, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  void increaseQuantity({required int index}) {
    _detailsOrders!.items![index].qty = _detailsOrders!.items![index].qty! + 1;
    notifyListeners();
  }
}
