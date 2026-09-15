import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../home/model/previous_order_home_model.dart';
import '../model/details_restaurants_model.dart';
import '../model/highst_rated_model.dart';
import '../model/previous_order_model.dart';
import '../model/products_details_restaurant_model.dart';
import '../model/products_restaurant_model.dart' as products;
import '../model/restaurants_model.dart';

class RestaurantsController extends ChangeNotifier {
  void updateResturant(RestaurantsModel updatedResturant) {
    final index = _restaurants.indexWhere((order) => order.id == updatedResturant.id);
    if (index != -1) {
      _restaurants[index] = updatedResturant;
    } else {
      _restaurants.add(updatedResturant);
    }
    notifyListeners();
  }

  ApiResponse _restaurantsApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get restaurantsApiResponse => _restaurantsApiResponse;

  void initialRestaurants() {
    _restaurantsApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _restaurants = [];
    notifyListeners();
  }

  List<RestaurantsModel> _restaurants = [];
  List<RestaurantsModel> get restaurant => _restaurants;

  Future<void> getRestaurants({
    int? mostReviewed,
    int? mostResearched,
    String? search,
    String? favorableRestaurants,
    double? lat,
    double? lng,
    int? cityName,
  }) async {
    _restaurantsApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _restaurants = [];
    notifyListeners();
    _restaurantsApiResponse = await ApiHelper.instance.get(
      Urls.restaurants,
      queryParameters: {
        if (favorableRestaurants != null) 'is_featured': favorableRestaurants,
        if (mostReviewed != null) 'most_reviewed': mostReviewed,
        if (mostResearched != null) 'most_researched': mostResearched,
        if (search != null) 'search': search,
        if (lat != null && lng != null) ...{
          'lat': lat,
          'lng': lng,
        },
        if (cityName != null) 'area_id': cityName,
      },
    );
    notifyListeners();
    if (_restaurantsApiResponse.state == ResponseState.complete) {
      Iterable iterable = _restaurantsApiResponse.data['data'];
      _restaurants = iterable.map((e) => RestaurantsModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  num? _productPrice;
  num? get productPrice => _productPrice;
  void setProductPrice(num value) {
    _productPrice = value;
    notifyListeners();
  }

  num totalPrice = 0.0;

  num? _productQuantity;
  num? get productQuantity => _productQuantity;
  void setProductQuantity(num value) {
    _productQuantity = value;
    notifyListeners();
  }

  num? _quantity;
  num? get quantity => _quantity;
  void setQuantity(num value) {
    _quantity = value;
    notifyListeners();
  }

  void incrementQuantity() {
    _productQuantity = _productQuantity! + 1;
    notifyListeners();
    calculateTotalPrice();
  }

  void decrementQuantity() {
    if (_productQuantity! > 1) {
      _productQuantity = _productQuantity! - 1;
    }
    notifyListeners();
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    num total = 0.0;
    if (_productPrice != null && _productQuantity != null) {
      try {
        total = (_productPrice! * _productQuantity!) / _quantity!;
        setProductPrice(total);
      } catch (e) {
        log('Error parsing price: $_productPrice - ${e.toString()}');
      }
    }
  }

  void updateResturantDetails(DetailsRestaurantModel updatedResturant) {
    if (updatedResturant.id == _detailsRestaurant?.id) {
      _detailsRestaurant = updatedResturant;
    }
    notifyListeners();
  }

  void updateAccordingToYourTasteResturantProductOrder(HighestRated highestRated) {
    final highestRatedList = _detailsRestaurant?.highestRated;
    if (highestRatedList == null) return;

    final index = highestRatedList.indexWhere((order) => order.id == highestRated.id);
    if (index != -1) {
      highestRatedList[index] = highestRated;
    } else {
      highestRatedList.add(highestRated);
    }
    notifyListeners();
  }

  // Kept for the restaurant-details Pusher event handler.
  void updateAccordingToYourTasteResturantProduct(HighestRated highestRated) {
    updateAccordingToYourTasteResturantProductOrder(highestRated);
  }

  ApiResponse _restaurantsDetailsApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get restaurantsDetailsApiResponse => _restaurantsDetailsApiResponse;

  void initialRestaurantsDetails() {
    _restaurantsDetailsApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _detailsRestaurant = null;
    notifyListeners();
  }

  DetailsRestaurantModel? _detailsRestaurant;
  DetailsRestaurantModel? get detailsRestaurant => _detailsRestaurant;

  Future<void> getRestaurantsDetails({required int id}) async {
    _restaurantsDetailsApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _detailsRestaurant = null;
    notifyListeners();
    _restaurantsDetailsApiResponse = await ApiHelper.instance.get('${Urls.restaurants}/$id');
    notifyListeners();
    if (_restaurantsDetailsApiResponse.state == ResponseState.complete) {
      _detailsRestaurant = DetailsRestaurantModel.fromJson(_restaurantsDetailsApiResponse.data['data']);
      notifyListeners();
    }
  }

  void updateResturantPreviousProductOrder(PreviousOrderModel product) {
    final index = _previousOrders.indexWhere((order) => order.id == product.id);
    if (index != -1) {
      _previousOrders[index] = product;
    } else {
      _previousOrders.add(product);
    }
    notifyListeners();
  }

  ApiResponse _previousOrderApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get previousOrderApiResponse => _previousOrderApiResponse;

  void initialPreviousOrder() {
    _previousOrderApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _previousOrders = [];
    notifyListeners();
  }

  List<PreviousOrderModel> _previousOrders = [];
  List<PreviousOrderModel> get previousOrders => _previousOrders;

  Future<void> getPreviousOrder({required int id}) async {
    _previousOrderApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _previousOrders = [];
    notifyListeners();
    HiveMethods.getToken() != null
        ? _previousOrderApiResponse = await ApiHelper.instance.get('${Urls.previousOrders}/$id')
        : null;
    notifyListeners();
    if (_previousOrderApiResponse.state == ResponseState.complete) {
      Iterable iterable = _previousOrderApiResponse.data['data'];
      _previousOrders = iterable.map((e) => PreviousOrderModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  void updateResturantProductOrder(products.ResturantItems product) {
    final index = _productsRestaurant.indexWhere(
      (order) => order.resturantItems?.any((e) => e.id == product.id) ?? false,
    );
    if (index != -1) {
      final productIndex = _productsRestaurant[index].resturantItems?.indexWhere((e) => e.id == product.id);
      if (productIndex != null && productIndex != -1) {
        _productsRestaurant[index].resturantItems![productIndex] = product;
      }
    }
    notifyListeners();
  }

  ApiResponse _productsRestaurantApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get productsRestaurantApiResponse => _productsRestaurantApiResponse;

  void initialProductsRestaurant() {
    _productsRestaurantApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _productsRestaurant = [];
    notifyListeners();
  }

  List<products.ProductsRestaurantModel> _productsRestaurant = [];
  List<products.ProductsRestaurantModel> get productsRestaurant => _productsRestaurant;

  Future<void> getProductsRestaurant({required int id}) async {
    _productsRestaurantApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _productsRestaurant = [];
    notifyListeners();
    _productsRestaurantApiResponse = await ApiHelper.instance.get('${Urls.baseUrl}resturants/$id/products');
    notifyListeners();
    if (_productsRestaurantApiResponse.state == ResponseState.complete) {
      Iterable iterable = _productsRestaurantApiResponse.data['data'];
      _productsRestaurant = iterable.map((e) => products.ProductsRestaurantModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  ApiResponse _productsDetailsRestaurantApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get productsDetailsRestaurantApiResponse => _productsDetailsRestaurantApiResponse;

  void initialProductsDetailsRestaurant() {
    _productsDetailsRestaurantApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _productsDetailsRestaurant = null;
    notifyListeners();
  }

  ProductsDetailsRestaurantModel? _productsDetailsRestaurant;
  ProductsDetailsRestaurantModel? get productsDetailsRestaurant => _productsDetailsRestaurant;

  Future<void> getProductsDetailsRestaurant({required int id}) async {
    _productsDetailsRestaurantApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _productsDetailsRestaurant = null;
    notifyListeners();
    _productsDetailsRestaurantApiResponse = await ApiHelper.instance.get('${Urls.productDetails}$id');
    notifyListeners();
    if (_productsDetailsRestaurantApiResponse.state == ResponseState.complete) {
      _productsDetailsRestaurant = ProductsDetailsRestaurantModel.fromJson(
        _productsDetailsRestaurantApiResponse.data['data'],
      );
      notifyListeners();
    }
  }

  void updatePreviousResturant(PreviousOrderHomeModel updatedResturant) {
    final index = _previousRestOrders.indexWhere((order) => order.id == updatedResturant.id);
    if (index != -1) {
      _previousRestOrders[index] = updatedResturant;
    } else {
      _previousRestOrders.add(updatedResturant);
    }
    notifyListeners();
  }

  ApiResponse _previousRestOrderApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get previousRestOrderApiResponse => _previousRestOrderApiResponse;

  void initialRestPreviousOrder() {
    _previousRestOrderApiResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _previousRestOrders = [];
    notifyListeners();
  }

  List<PreviousOrderHomeModel> _previousRestOrders = [];
  List<PreviousOrderHomeModel> get previousRestOrders => _previousRestOrders;

  Future<void> getPreviousRestOrder() async {
    _previousRestOrderApiResponse = ApiResponse(state: ResponseState.loading, data: null);
    _previousRestOrders = [];
    notifyListeners();
    _previousRestOrderApiResponse = await ApiHelper.instance.get(Urls.previousOrderHome);
    notifyListeners();
    if (_previousRestOrderApiResponse.state == ResponseState.complete) {
      Iterable iterable = _previousRestOrderApiResponse.data['data'];
      _previousRestOrders = iterable.map((e) => PreviousOrderHomeModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addOrRemoveToWishlist({required int id, required VoidCallback onSuccess}) async {
    Utils.loading();
    final response = await ApiHelper.instance.post('${Urls.baseUrl}resturants/$id/wishlist');
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
      notifyListeners();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }
}
