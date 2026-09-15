import 'highst_rated_model.dart';

class DetailsRestaurantModel {
  int? id;
  int? vendorId;
  String? vendorName;
  String? vendorEmail;
  String? name;
  String? status;
  num? avgRate;
  String? address;
  String? logo;
  String? bgImage;
  String? deliveryTime;
  String? lat;
  String? lng;
  int? isFav;
  int? serviceFees;
  dynamic closeAt;
  String? openAt;
  dynamic minOrderPrice;
  int? kmPrice;
  num? default_0_1;
  num? default_1_2;
  num? default_2_3;
  List<ResturantAreas>? resturantAreas;
  List<ResturantCategorys>? resturantCategorys;
  List<ResturantItems>? resturantItems;
  String? createdAt;
  String? underContract;
  List<HighestRated>? highestRated;

  DetailsRestaurantModel({
    this.id,
    this.vendorId,
    this.vendorName,
    this.vendorEmail,
    this.name,
    this.status,
    this.avgRate,
    this.address,
    this.logo,
    this.bgImage,
    this.deliveryTime,
    this.lat,
    this.lng,
    this.isFav,
    this.serviceFees,
    this.closeAt,
    this.openAt,
    this.minOrderPrice,
    this.kmPrice,
    this.default_0_1,
    this.default_1_2,
    this.default_2_3,
    this.resturantAreas,
    this.resturantCategorys,
    this.resturantItems,
    this.createdAt,
    this.underContract,
    this.highestRated,
  });

  DetailsRestaurantModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    vendorEmail = json['vendor_email'];
    name = json['name'];
    status = json['status'];
    avgRate = json['avg_rate'];
    address = json['address'];
    logo = json['logo'];
    bgImage = json['bg_image'];
    deliveryTime = json['delivery_time'];
    lat = json['lat'];
    lng = json['lng'];
    isFav = json['is_fav'];
    serviceFees = json['service_fees'];
    closeAt = json['close_at'];
    openAt = json['open_at'];
    minOrderPrice = json['min_order_price'];
    kmPrice = json['km_price'];
    default_0_1 = json['default_0_1'];
    default_1_2 = json['default_1_2'];
    default_2_3 = json['default_2_3'];
    if (json['resturant_areas'] != null) {
      resturantAreas = <ResturantAreas>[];
      json['resturant_areas'].forEach((v) {
        resturantAreas!.add(ResturantAreas.fromJson(v));
      });
    }
    if (json['resturant_categorys'] != null) {
      resturantCategorys = <ResturantCategorys>[];
      json['resturant_categorys'].forEach((v) {
        resturantCategorys!.add(ResturantCategorys.fromJson(v));
      });
    }
    if (json['resturant_items'] != null) {
      resturantItems = <ResturantItems>[];
      json['resturant_items'].forEach((v) {
        resturantItems!.add(ResturantItems.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    underContract = json['under_contract'];
    if (json['highest_rated'] != null) {
      highestRated = <HighestRated>[];
      json['highest_rated'].forEach((v) {
        highestRated!.add(HighestRated.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['vendor_name'] = vendorName;
    data['vendor_email'] = vendorEmail;
    data['name'] = name;
    data['status'] = status;
    data['avg_rate'] = avgRate;
    data['address'] = address;
    data['logo'] = logo;
    data['bg_image'] = bgImage;
    data['delivery_time'] = deliveryTime;
    data['lat'] = lat;
    data['lng'] = lng;
    data['is_fav'] = isFav;
    data['service_fees'] = serviceFees;
    data['close_at'] = closeAt;
    data['open_at'] = openAt;
    data['min_order_price'] = minOrderPrice;
    data['km_price'] = kmPrice;
    data['default_0_1'] = default_0_1;
    data['default_1_2'] = default_1_2;
    data['default_2_3'] = default_2_3;
    if (resturantAreas != null) {
      data['resturant_areas'] = resturantAreas!.map((v) => v.toJson()).toList();
    }
    if (resturantCategorys != null) {
      data['resturant_categorys'] = resturantCategorys!.map((v) => v.toJson()).toList();
    }
    if (resturantItems != null) {
      data['resturant_items'] = resturantItems!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['under_contract'] = underContract;
    if (highestRated != null) {
      data['highest_rated'] = highestRated!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ResturantAreas {
  int? id;
  int? addedBy;
  int? resturantId;
  String? expectedDelivery;
  String? createdAt;
  String? updatedAt;
  int? areaId;
  String? type;

  ResturantAreas({
    this.id,
    this.addedBy,
    this.resturantId,
    this.expectedDelivery,
    this.createdAt,
    this.updatedAt,
    this.areaId,
    this.type,
  });

  ResturantAreas.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addedBy = json['added_by'];
    resturantId = json['resturant_id'];
    expectedDelivery = json['expected_delivery'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    areaId = json['area_id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['added_by'] = addedBy;
    data['resturant_id'] = resturantId;
    data['expected_delivery'] = expectedDelivery;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['area_id'] = areaId;
    data['type'] = type;
    return data;
  }
}

class ResturantCategorys {
  int? id;
  String? name;
  int? parentId;
  String? parentName;
  int? resturantProductsCount;
  String? createdAt;

  ResturantCategorys({this.id, this.name, this.parentId, this.parentName, this.resturantProductsCount, this.createdAt});

  ResturantCategorys.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentId = json['parent_id'];
    parentName = json['parent_name'];
    resturantProductsCount = json['resturant_products_count'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['parent_id'] = parentId;
    data['parent_name'] = parentName;
    data['resturant_products_count'] = resturantProductsCount;
    data['created_at'] = createdAt;
    return data;
  }
}

class ResturantItems {
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
  int? hasClean;
  String? productImage;
  String? createdAt;
  int? latestOrderId;
  int? latestOrderQty;
  dynamic latestOrderProductClean;
  dynamic latestOrderProductFeature;

  ResturantItems({
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
    this.hasClean,
    this.productImage,
    this.createdAt,
    this.latestOrderId,
    this.latestOrderQty,
    this.latestOrderProductClean,
    this.latestOrderProductFeature,
  });

  ResturantItems.fromJson(Map<String, dynamic> json) {
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

class Features {
  int? id;
  String? name;
  String? createdAt;

  Features({this.id, this.name, this.createdAt});

  Features.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['created_at'] = createdAt;
    return data;
  }
}
