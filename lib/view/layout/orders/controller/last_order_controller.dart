import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../model/orders_model.dart';

class LastCorderController extends ChangeNotifier {
  ApiResponse _lastOrdersApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get lastOrdersApiResponse => _lastOrdersApiResponse;

  void initialLastOrders() {
    _lastOrdersApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _lastOrders = null;
    notifyListeners();
  }

  OrdersModel? _lastOrders;
  OrdersModel? get lastOrders => _lastOrders;

  Future<void> getlastOrders() async {
    _lastOrdersApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    notifyListeners();
    _lastOrdersApiResponse = await ApiHelper.instance.get(Urls.lastOrder);
    notifyListeners();
    if (_lastOrdersApiResponse.state == ResponseState.complete) {
      _lastOrders = OrdersModel.fromJson(_lastOrdersApiResponse.data['data']);
      notifyListeners();
    }
  }

  void refreshLastOrders() {
    getlastOrders();
    notifyListeners();
  }
}
