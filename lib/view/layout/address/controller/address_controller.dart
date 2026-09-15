import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/address_model.dart';

class AddressController extends ChangeNotifier {
  void initialAddress() {
    _addressResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _address = [];
    notifyListeners();
  }

  ApiResponse _addressResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get addressResponse => _addressResponse;
  List<AddressModel> _address = [];
  List<AddressModel> get address => _address;

  Future<void> getAddress({List<int>? areaId}) async {
    _addressResponse = ApiResponse(state: ResponseState.loading, data: null);
    _address = [];
    notifyListeners();
    _addressResponse = await ApiHelper.instance.get(
      Urls.userAddress,
      queryParameters: {
        if (areaId != null)
          for (int i = 0; i < areaId.length; i++) ...{'area_id[$i]': areaId[i]},
      },
    );
    notifyListeners();
    if (_addressResponse.state == ResponseState.complete) {
      Iterable iterable = _addressResponse.data['data'];
      _address = iterable.map((e) => AddressModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> storeAddress({
    required String areaName,
    required String apartmentNo,
    required String floorNo,
    required String streetName,
    required String mobile,
    String? badge,
    String? addressName,
    required String type,
    required double lat,
    required double lang,
    required String countryName,
    required String cityName,
    required String address,
    required Function({int? userAddressId}) onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'area_name': areaName,
      'apartment_no': apartmentNo,
      'floor_no': floorNo,
      'street_name': streetName,
      'mobile': mobile,
      if (badge != null) 'badge': badge,
      if (addressName != null) 'address_name': addressName,
      'type': type,
      'lat': lat,
      'lng': lang,
      'country_name': countryName,
      'city_name': cityName,
      'address': address,
    });
    final response = await ApiHelper.instance.post(Urls.storeAddress, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call(userAddressId: response.data['data']['id']);
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  Future<void> updateAddress({
    required int id,
    required String areaName,
    required String apartmentNo,
    required String floorNo,
    required String streetName,
    required String mobile,
    String? badge,
    String? addressName,
    required String type,
    required double lat,
    required double lang,
    required String countryName,
    required String cityName,
    required String address,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'area_name': areaName,
      'apartment_no': apartmentNo,
      'floor_no': floorNo,
      'street_name': streetName,
      'mobile': mobile,
      if (badge != null) 'badge': badge,
      if (addressName != null) 'address_name': addressName,
      'type': type,
      'lat': lat,
      'lng': lang,
      'country_name': countryName,
      'city_name': cityName,
      'address': address,
    });
    final response = await ApiHelper.instance.post('${Urls.updateAddress}$id', body: body);

    if (response.state == ResponseState.complete) {
      Utils.loadingOff();
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
      notifyListeners();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  Future<void> deleteAddress({required int id, required VoidCallback onSuccess}) async {
    Utils.loading();

    final response = await ApiHelper.instance.delete('${Urls.deleteAddress}$id');
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
      getAddress();
      notifyListeners();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  void initialAddressDetails() {
    _addressDetailsResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _addressDetails = null;
    notifyListeners();
  }

  ApiResponse _addressDetailsResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get addressDetailsResponse => _addressDetailsResponse;

  AddressModel? _addressDetails;
  AddressModel? get addressDetails => _addressDetails;

  Future<void> getAddressDetails({required int id}) async {
    _addressDetailsResponse = ApiResponse(state: ResponseState.loading, data: null);
    _addressDetails = null;
    notifyListeners();
    _addressDetailsResponse = await ApiHelper.instance.get('${Urls.addressDetails}$id');

    if (_addressDetailsResponse.state == ResponseState.complete) {
      _addressDetails = AddressModel.fromJson(_addressDetailsResponse.data['data']);
      notifyListeners();
    }
  }

  String _indexSelectedOfficeOrHouseOrApartment = 'office';

  String get indexSelectedOfficeOrHouseOrApartment => _indexSelectedOfficeOrHouseOrApartment;

  void setIndexSelectedOfficeOrHouseOrApartment(String title) {
    _indexSelectedOfficeOrHouseOrApartment = title;
    notifyListeners();
  }

  //========================== update user location ============================
  Future<void> updateUserLocation({
    required int userId,
    required double lat,
    required double lang,
    required String countryName,
    required String cityName,
    required String address,
    required Function(int addressId) onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'lat': lat,
      'lng': lang,
      'country_name': countryName,
      'city_name': cityName,
      'address': address,
    });
    final response = await ApiHelper.instance.post('${Urls.updateUserLocation}$userId/user-location', body: body);

    if (response.state == ResponseState.complete) {
      Utils.loadingOff();
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call(response.data['data']['id']);
      notifyListeners();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  //?======================================== can deliver =========================
  Future<void> canDeliver({
    required int restaurantId,
    required String customerLat,
    required String customerLng,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'restaurant_id': restaurantId,
      'customer_lat': customerLat,
      'customer_lng': customerLng,
    });
    final response = await ApiHelper.instance.post(Urls.canDeliver, body: body);

    if (response.state == ResponseState.complete) {
      Utils.loadingOff();
      if (response.data['can_deliver'] == true) {
        onSuccess.call();
      }
      if (response.data['can_deliver'] == false) {
        CommonMethods.showError(message: 'cantDlever'.tr);
      }

      notifyListeners();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }
}
