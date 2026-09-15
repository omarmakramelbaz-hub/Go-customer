import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../model/last_search_model.dart';

class SearchRestaurantController extends ChangeNotifier {
  ApiResponse _lastSearchApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get lastSearchApiResponse => _lastSearchApiResponse;
  void initialLastSearch() {
    _lastSearchApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _lastSearch = [];
    notifyListeners();
  }

  List<LastSearchModel> _lastSearch = [];
  List<LastSearchModel> get lastSearch => _lastSearch;

  Future<void> getLastSearch() async {
    _lastSearchApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _lastSearch = [];
    notifyListeners();
    _lastSearchApiResponse = await ApiHelper.instance.get(Urls.lastSearch);
    notifyListeners();
    if (_lastSearchApiResponse.state == ResponseState.complete) {
      Iterable iterable = _lastSearchApiResponse.data['data'];
      _lastSearch = iterable.map((e) => LastSearchModel.fromJson(e)).toList();
      notifyListeners();
    }
  }
}
