class RestaurantsNearYouHomeModel {
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
  String? resturantPhone;
  String? lat;
  String? lng;
  String? countryName;
  String? cityName;
  String? createdAt;
  int? cityId;
  String? cityname;
  String? underContract;
  num? serviceFees;
  String? closeAt;
  String? openAt;
  dynamic minOrderPrice;
  num? kmPrice;
  num? default_0_1;
  num? default_1_2;
  num? default_2_3;

  RestaurantsNearYouHomeModel({
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
    this.resturantPhone,
    this.lat,
    this.lng,
    this.countryName,
    this.cityName,
    this.createdAt,
    this.cityId,
    this.cityname,
    this.underContract,
    this.serviceFees,
    this.closeAt,
    this.openAt,
    this.minOrderPrice,
    this.kmPrice,
    this.default_0_1,
    this.default_1_2,
    this.default_2_3,
  });

  RestaurantsNearYouHomeModel.fromJson(Map<String, dynamic> json) {
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
    resturantPhone = json['resturant_phone'];
    lat = json['lat'];
    lng = json['lng'];
    countryName = json['country_name'];
    cityName = json['city_name'];
    createdAt = json['created_at'];
    cityId = json['city_id'];
    cityname = json['cityname'];
    underContract = json['under_contract'];
    serviceFees = json['service_fees'];
    closeAt = json['close_at'];
    openAt = json['open_at'];
    minOrderPrice = json['min_order_price'];
    kmPrice = json['km_price'];
    default_0_1 = json['default_0_1'];
    default_1_2 = json['default_1_2'];
    default_2_3 = json['default_2_3'];
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
    data['resturant_phone'] = resturantPhone;
    data['lat'] = lat;
    data['lng'] = lng;
    data['country_name'] = countryName;
    data['city_name'] = cityName;
    data['created_at'] = createdAt;
    data['city_id'] = cityId;
    data['cityname'] = cityname;
    data['under_contract'] = underContract;
    data['service_fees'] = serviceFees;
    data['close_at'] = closeAt;
    data['open_at'] = openAt;
    data['min_order_price'] = minOrderPrice;
    data['km_price'] = kmPrice;
    data['default_0_1'] = default_0_1;
    data['default_1_2'] = default_1_2;
    data['default_2_3'] = default_2_3;
    return data;
  }
}
