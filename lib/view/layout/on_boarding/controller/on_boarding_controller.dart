import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../model/splashes_model.dart';

class OnBoardingController extends ChangeNotifier {
  void initialSplashes() {
    _splashesResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _splashes = [];
    notifyListeners();
  }

  ApiResponse _splashesResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get splashesResponse => _splashesResponse;
  List<SplashesModel> _splashes = [];
  List<SplashesModel> get splashes => _splashes;

  Future<void> getSplashes() async {
    _splashesResponse = ApiResponse(state: ResponseState.loading, data: null);
    _splashes = [];
    notifyListeners();
    _splashesResponse = await ApiHelper.instance.get(Urls.splashes);
    notifyListeners();
    if (_splashesResponse.state == ResponseState.complete) {
      Iterable iterable = _splashesResponse.data['data'];
      _splashes = iterable.map((e) => SplashesModel.fromJson(e)).toList();
      notifyListeners();
    }
  }
}
