import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/help_model.dart';
import '../model/setting_model.dart';

class MyAccountController extends ChangeNotifier {
  //            Help               //
  void initialHelp() {
    _helpResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _help = [];
    notifyListeners();
  }

  ApiResponse _helpResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get helpResponse => _helpResponse;
  List<HelpModel> _help = [];
  List<HelpModel> get help => _help;
  Future<void> getHelp() async {
    _helpResponse = ApiResponse(state: ResponseState.loading, data: null);
    _help = [];
    notifyListeners();
    _helpResponse = await ApiHelper.instance.get(Urls.help);
    notifyListeners();
    if (_helpResponse.state == ResponseState.complete) {
      Iterable iterable = _helpResponse.data['data'];
      _help = iterable.map((e) => HelpModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  //                 Setting               //

  ApiResponse get settingResponse => _settingResponse;
  ApiResponse _settingResponse = ApiResponse(state: ResponseState.sleep, data: null);

  void initialSetting() {
    _settingResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _setting = null;
    notifyListeners();
  }

  SettingModel? _setting;
  SettingModel? get setting => _setting;

  Future<void> getSetting() async {
    _settingResponse = ApiResponse(state: ResponseState.loading, data: null);
    notifyListeners();

    _settingResponse = await ApiHelper.instance.get(Urls.setting);
    notifyListeners();
    if (_settingResponse.state == ResponseState.complete) {
      _setting = SettingModel.fromJson(_settingResponse.data['data']);
      notifyListeners();
    }
  }

  Future<void> storeContact({
    required String name,
    required String email,
    required String message,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({'name': name, 'email': email, 'message': message});
    final response = await ApiHelper.instance.post(Urls.storeContact, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }
  //! changePhoneNumber

  Future<void> changePhoneNumber({
    required String phoneNumber,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();

    FormData body = FormData.fromMap({'mobile': phoneNumber, 'current_password': password});
    final response = await ApiHelper.instance.post(Urls.changePhoneNumber, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }
}
