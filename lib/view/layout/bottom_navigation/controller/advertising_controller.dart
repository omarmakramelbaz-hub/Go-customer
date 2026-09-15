import 'package:flutter/material.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../model/advertising_model.dart';

class AdvertisingController extends ChangeNotifier {
  void init() {
    initialAdvertising();
    getAdvertising();
  }

  bool _hasSeenAdd = false;
  bool get hasSeenAdd => _hasSeenAdd;
  void setHasSeenAdd(bool value) {
    _hasSeenAdd = value;
    notifyListeners();
  }

  ApiResponse _advertisingApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get advertisingApiResponse => _advertisingApiResponse;

  void initialAdvertising() {
    _advertisingApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _advertising = [];
    //notifyListeners();
  }

  List<AdvertisingModel> _advertising = [];
  List<AdvertisingModel> get advertising => _advertising;
  Future<void> getAdvertising() async {
    _advertisingApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _advertising = [];

    _advertisingApiResponse = await ApiHelper.instance.get(
      Urls.advertising,
      queryParameters: {
        if (HiveMethods.getLat() != null && HiveMethods.getLan() != null) ...{
          'lat': HiveMethods.getLat(),
          'lng': HiveMethods.getLan(),
        },
      },
    );

    notifyListeners();

    if (_advertisingApiResponse.state == ResponseState.complete) {
      if (_advertisingApiResponse.data != null && _advertisingApiResponse.data['data'] != null) {
        Iterable iterable = _advertisingApiResponse.data['data'];

        _advertising = iterable.map((e) => AdvertisingModel.fromJson(e)).toList();
      } else {
        _advertising = [];
      }

      notifyListeners();
    }
  }
}
