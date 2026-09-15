import '../../restaurants/model/details_restaurants_model.dart';

class CartItemModel {
  int? id;
  ResturantProduct? resturantProduct;
  int? resturantId;
  String? resturantName;
  String? resturantLat;
  String? resturantLng;
  String? resturantCityName;
  String? resturantDeliveryTime;
  int? orderId;
  num? price;
  int? qty;
  int? productFeature;
  String? productFeatureName;
  String? productClean;
  String? createdAt;
  num? minOrderPrice;
  num? total;
  num? updatedTotal;
  String? reasonUpdateTotal;

  CartItemModel({
    this.id,
    this.resturantProduct,
    this.resturantId,
    this.resturantName,
    this.resturantLat,
    this.resturantLng,
    this.resturantCityName,
    this.resturantDeliveryTime,
    this.orderId,
    this.price,
    this.qty,
    this.productFeature,
    this.productFeatureName,
    this.productClean,
    this.createdAt,
    this.minOrderPrice,
    this.total,
    this.updatedTotal,
    this.reasonUpdateTotal,
  });

  CartItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resturantProduct = json['resturant_product'] != null ? ResturantProduct.fromJson(json['resturant_product']) : null;
    resturantId = json['resturant_id'];
    resturantName = json['resturant_name'];
    resturantLat = json['resturant_lat'];
    resturantLng = json['resturant_lng'];
    resturantCityName = json['resturant_city_name'];
    resturantDeliveryTime = json['resturant_delivery_time'];
    orderId = json['order_id'];
    price = json['price'];
    qty = json['qty'];
    productFeature = json['product_feature'];
    productFeatureName = json['product_feature_name'];
    productClean = json['product_clean'];
    createdAt = json['created_at'];
    minOrderPrice = json['min_order_price'];
    total = json['total'];
    updatedTotal = json['updated_total'];
    reasonUpdateTotal = json['reason_update_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (resturantProduct != null) {
      data['resturant_product'] = resturantProduct!.toJson();
    }
    data['resturant_id'] = resturantId;
    data['resturant_name'] = resturantName;
    data['resturant_lat'] = resturantLat;
    data['resturant_lng'] = resturantLng;
    data['resturant_city_name'] = resturantCityName;
    data['resturant_delivery_time'] = resturantDeliveryTime;
    data['order_id'] = orderId;
    data['price'] = price;
    data['qty'] = qty;
    data['product_feature'] = productFeature;
    data['product_feature_name'] = productFeatureName;
    data['product_clean'] = productClean;
    data['created_at'] = createdAt;
    data['min_order_price'] = minOrderPrice;
    data['total'] = total;
    data['updated_total'] = updatedTotal;
    data['reason_update_total'] = reasonUpdateTotal;
    return data;
  }
}

class ResturantProduct {
  int? id;
  int? vendorId;
  String? vendorName;
  int? resturantId;
  String? resturantName;
  String? productName;
  String? productDescription;
  List<Features>? features;
  num? productPrice;
  num? extraCombo;
  num? extraLarge;
  num? extraMedium;
  num? extraClean;
  num? extraClear;
  num? extraVacuim;
  int? categoryId;
  String? categoryName;
  int? subCategoryId;
  String? subCategoryName;
  int? productId;
  String? productTitle;
  String? status;
  String? highestRated;
  int? hasClean;
  String? productImage;
  String? createdAt;
  int? latestOrderId;
  int? latestOrderQty;
  String? latestOrderProductClean;
  int? latestOrderProductFeature;

  ResturantProduct({
    this.id,
    this.vendorId,
    this.vendorName,
    this.resturantId,
    this.resturantName,
    this.productName,
    this.productDescription,
    this.features,
    this.productPrice,
    this.extraCombo,
    this.extraLarge,
    this.extraMedium,
    this.extraClean,
    this.extraClear,
    this.extraVacuim,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.productId,
    this.productTitle,
    this.status,
    this.highestRated,
    this.hasClean,
    this.productImage,
    this.createdAt,
    this.latestOrderId,
    this.latestOrderQty,
    this.latestOrderProductClean,
    this.latestOrderProductFeature,
  });

  ResturantProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    resturantId = json['resturant_id'];
    resturantName = json['resturant_name'];
    productName = json['product_name'];
    productDescription = json['product_description'];
    if (json['features'] != null) {
      features = <Features>[];
      json['features'].forEach((v) {
        features!.add(Features.fromJson(v));
      });
    }
    productPrice = json['product_price'];
    extraCombo = json['extra_combo'];
    extraLarge = json['extra_large'];
    extraMedium = json['extra_medium'];
    extraClean = json['extra_clean'];
    extraClear = json['extra_clear'];
    extraVacuim = json['extra_vacuim'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    subCategoryId = json['sub_category_id'];
    subCategoryName = json['sub_category_name'];
    productId = json['product_id'];
    productTitle = json['product_title'];
    status = json['status'];
    highestRated = json['highest_rated'];
    hasClean = json['has_clean'];
    productImage = json['product_image'];
    createdAt = json['created_at'];
    latestOrderId = json['latest_order_id'];
    latestOrderQty = json['latest_order_qty'];
    latestOrderProductClean = json['latest_order_product_clean'];
    latestOrderProductFeature = json['latest_order_product_feature'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['vendor_name'] = vendorName;
    data['resturant_id'] = resturantId;
    data['resturant_name'] = resturantName;
    data['product_name'] = productName;
    data['product_description'] = productDescription;
    if (features != null) {
      data['features'] = features!.map((v) => v.toJson()).toList();
    }
    data['product_price'] = productPrice;
    data['extra_combo'] = extraCombo;
    data['extra_large'] = extraLarge;
    data['extra_medium'] = extraMedium;
    data['extra_clean'] = extraClean;
    data['extra_clear'] = extraClear;
    data['extra_vacuim'] = extraVacuim;
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['sub_category_id'] = subCategoryId;
    data['sub_category_name'] = subCategoryName;
    data['product_id'] = productId;
    data['product_title'] = productTitle;
    data['status'] = status;
    data['highest_rated'] = highestRated;
    data['has_clean'] = hasClean;
    data['product_image'] = productImage;
    data['created_at'] = createdAt;
    data['latest_order_id'] = latestOrderId;
    data['latest_order_qty'] = latestOrderQty;
    data['latest_order_product_clean'] = latestOrderProductClean;
    data['latest_order_product_feature'] = latestOrderProductFeature;
    return data;
  }
}
