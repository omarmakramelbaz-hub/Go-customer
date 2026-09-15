class AddressModel {
  int? id;
  String? areaName;
  String? mobile;
  String? apartmentNo;
  String? floorNo;
  String? streetName;
  String? badge;
  String? addressName;
  String? type;
  String? lat;
  String? lng;
  String? countryName;
  String? cityName;
  String? address;
  int? cityId;
  String? cityname;
  String? createdAt;

  AddressModel({
    this.id,
    this.areaName,
    this.mobile,
    this.apartmentNo,
    this.floorNo,
    this.streetName,
    this.badge,
    this.addressName,
    this.type,
    this.lat,
    this.lng,
    this.countryName,
    this.cityName,
    this.address,
    this.cityId,
    this.cityname,
    this.createdAt,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    areaName = json['area_name'];
    mobile = json['mobile'];
    apartmentNo = json['apartment_no'];
    floorNo = json['floor_no'];
    streetName = json['street_name'];
    badge = json['badge'];
    addressName = json['address_name'];
    type = json['type'];
    lat = json['lat'];
    lng = json['lng'];
    countryName = json['country_name'];
    cityName = json['city_name'];
    address = json['address'];
    cityId = json['city_id'];
    cityname = json['cityname'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['area_name'] = areaName;
    data['mobile'] = mobile;
    data['apartment_no'] = apartmentNo;
    data['floor_no'] = floorNo;
    data['street_name'] = streetName;
    data['badge'] = badge;
    data['address_name'] = addressName;
    data['type'] = type;
    data['lat'] = lat;
    data['lng'] = lng;
    data['country_name'] = countryName;
    data['city_name'] = cityName;
    data['address'] = address;
    data['city_id'] = cityId;
    data['cityname'] = cityname;
    data['created_at'] = createdAt;
    return data;
  }
}
