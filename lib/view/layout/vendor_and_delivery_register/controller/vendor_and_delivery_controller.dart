import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/contract_model.dart';

class VendorAndDeliveryController extends ChangeNotifier {
  Future<void> vendorRegister({
    required String fullName,
    required String ownerName,
    required int branchesNo,
    required int nationalId,
    required String commercialRegistrationNo,
    required File nationalIdImage,
    required File commercialRegistrationNoImage,
    required String taxNo,
    required File taxNoImage,
    required String estMobile,
    String? sndMobile,
    required String vodafoneCashMobile,
    required String email,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'type': 'vendor',
      'full_name': fullName,
      'owner_name': ownerName,
      'branches_no': branchesNo,
      'national_id': nationalId,
      'commercial_registration_no': commercialRegistrationNo,
      'national_id_image': await MultipartFile.fromFile(nationalIdImage.path),
      'commercial_registration_no_image': await MultipartFile.fromFile(commercialRegistrationNoImage.path),
      'tax_no': taxNo,
      'tax_no_image': await MultipartFile.fromFile(taxNoImage.path),
      'mobile': estMobile,
      if (sndMobile != null) 'another_mobile': sndMobile,
      'vodafone_cash_mobile': vodafoneCashMobile,
      'email': email,
    });
    final response = await ApiHelper.instance.post(Urls.vendorSignUp, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);

      notifyListeners();
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  Future<void> deliveryRegister({
    required String fullName,
    required int nationalId,
    required String drivingLicenseNo,
    required File nationalIdImage,
    required File drivingLicenseImage,
    required String workArea,
    required String estMobile,
    String? sndMobile,
    required String vodafoneCashMobile,
    required String email,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'type': 'delegate',
      'full_name': fullName,
      'national_id': nationalId,
      'driving_license_no': drivingLicenseNo,
      'national_id_image': await MultipartFile.fromFile(nationalIdImage.path),
      'driving_license_image': await MultipartFile.fromFile(drivingLicenseImage.path),
      'location': workArea,
      'mobile': estMobile,
      if (sndMobile != null) 'another_mobile': sndMobile,
      'vodafone_cash_mobile': vodafoneCashMobile,
      'email': email,
    });
    final response = await ApiHelper.instance.post(Urls.vendorSignUp, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);

      notifyListeners();
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }
  //    ===============>get Contract ==============

  ApiResponse _contractApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get contractApiResponse => _contractApiResponse;

  void initialContract() {
    _contractApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _contract = null;
    notifyListeners();
  }

  ContractModel? _contract;
  ContractModel? get contract => _contract;
  Future<void> getContract({required String typeContract}) async {
    _contractApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _contract = null;
    notifyListeners();
    _contractApiResponse = await ApiHelper.instance.get('${Urls.contract}$typeContract');
    notifyListeners();
    if (_contractApiResponse.state == ResponseState.complete) {
      _contract = ContractModel.fromJson(_contractApiResponse.data['data']);

      notifyListeners();
    }
  }
}
