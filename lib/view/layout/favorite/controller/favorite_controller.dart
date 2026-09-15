import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/favorite_model.dart';

class FavoriteController extends ChangeNotifier {
  void initialFavorite() {
    _favoriteResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _favorite = [];
    notifyListeners();
  }

  ApiResponse _favoriteResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get favoriteResponse => _favoriteResponse;

  List<FavoriteModel> _favorite = [];
  List<FavoriteModel> get favorite => _favorite;

  /// Restaurant favorites shown on the Favorites screen.
  ///
  /// The screen is a restaurant-favorites screen, so it must use the legacy
  /// restaurant wishlist endpoint rather than the product-wishlist endpoint.
  Future<void> getFavorite() async {
    _favoriteResponse = ApiResponse(state: ResponseState.loading, data: null);
    _favorite = [];
    notifyListeners();

    _favoriteResponse = await ApiHelper.instance.get(Urls.favorite);

    if (_favoriteResponse.state == ResponseState.complete) {
      final responseData = _favoriteResponse.data;
      final dynamic data = responseData is Map ? responseData['data'] : null;

      if (data is Iterable) {
        _favorite = data
            .whereType<Map>()
            .map((item) => FavoriteModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    notifyListeners();
  }

  /// Add/remove a restaurant from the restaurant wishlist.
  Future<void> addOrRemoveToWishlist({
    required int id,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    final response = await ApiHelper.instance.post(
      '${Urls.baseUrl}resturants/$id/wishlist',
    );
    Utils.loadingOff();

    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      _favorite.removeWhere((item) => item.id == id || item.vendorId == id);
      onSuccess.call();
      notifyListeners();
    } else {
      CommonMethods.showError(
        message: response.data['message'],
        apiResponse: response,
      );
    }
  }

  /// Product favorites remain a separate flow and must not affect the
  /// restaurant favorites list shown by this controller.
  Future<void> addOrRemoveProductFavorite({required int id}) async {
    Utils.loading();
    final response = await ApiHelper.instance.post(Urls.toggleProductFavorite(id));
    Utils.loadingOff();

    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
    } else {
      CommonMethods.showError(
        message: response.data['message'],
        apiResponse: response,
      );
    }
  }
}
