class ProfileModel {
  int? id;
  String? name;
  String? email;
  String? accountType;
  int? countryCode;
  String? mobile;
  String? gender;
  String? lat;
  String? lng;
  String? countryName;
  String? cityName;
  String? address;
  String? mobileCode;
  int? areaId;
  String? areaTitle;
  int? cart;
  String? photoProfile;
  String? mobileVerifiedAt;
  num? balance;
  int? resturantId;
  String? resturantLat;
  String? resturantLng;
  String? resturantCity;
  String? resturantName;
  String? resturantLogo;
  String? resturantAreaId;
  String? resturantAreaName;
  String? myresturantHasMenu;
  String? resturantParentId;
  String? parentHasMenu;
  String? delegateStatus;
  String? vendorStatus;
  String? createdAt;
  String? token;
  int? notificaionsCount;
  int? goDriveBlock;
  dynamic kmPrice;

  num? tax;
  num? serviceFees;
  List<UserAddresses>? userAddresses;
  String? appBannerBackgroundColor;
  int? otpFirstOrder;
  int? otpFirstNo;
  int? appMultiVendor;

  ProfileModel({
    this.id,
    this.name,
    this.email,
    this.accountType,
    this.countryCode,
    this.mobile,
    this.gender,
    this.lat,
    this.lng,
    this.countryName,
    this.cityName,
    this.address,
    this.mobileCode,
    this.areaId,
    this.areaTitle,
    this.cart,
    this.photoProfile,
    this.mobileVerifiedAt,
    this.balance,
    this.resturantId,
    this.resturantLat,
    this.resturantLng,
    this.resturantCity,
    this.resturantName,
    this.resturantLogo,
    this.resturantAreaId,
    this.resturantAreaName,
    this.myresturantHasMenu,
    this.resturantParentId,
    this.parentHasMenu,
    this.delegateStatus,
    this.vendorStatus,
    this.createdAt,
    this.token,
    this.kmPrice,
    this.userAddresses,
    this.notificaionsCount,
    this.goDriveBlock,
    this.appBannerBackgroundColor,
    this.otpFirstOrder,
    this.otpFirstNo,
    this.appMultiVendor,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    accountType = json['account_type'];
    countryCode = json['country_code'];
    mobile = json['mobile'];
    gender = json['gender'];
    lat = json['lat'];
    lng = json['lng'];
    countryName = json['country_name'];
    cityName = json['city_name'];
    address = json['address'];
    mobileCode = json['mobile_code'];
    areaId = json['area_id'];
    areaTitle = json['area_title'];
    cart = json['cart'];
    photoProfile = json['photo_profile'];
    mobileVerifiedAt = json['mobile_verified_at'];
    balance = json['balance'];
    resturantId = json['resturant_id'];
    resturantLat = json['resturant_lat'];
    resturantLng = json['resturant_lng'];
    resturantCity = json['resturant_city'];
    resturantName = json['resturant_name'];
    resturantLogo = json['resturant_logo'];
    resturantAreaId = json['resturant_area_id'];
    resturantAreaName = json['resturant_area_name'];
    myresturantHasMenu = json['myresturant_has_menu'];
    resturantParentId = json['resturant_parent_id'];
    parentHasMenu = json['parent_has_menu'];
    delegateStatus = json['delegate_status'];
    vendorStatus = json['vendor_status'];
    createdAt = json['created_at'];
    token = json['token'];
    notificaionsCount = json['notificaions_count'];
    goDriveBlock = json['go_drive_block'];
    appBannerBackgroundColor = json['app_banner_background_color'];
    otpFirstOrder = json['otp_first_order'];
    otpFirstNo = json['otp_first_no'];
    appMultiVendor = json['app_multi_vendor'];
    kmPrice = json['km_price'];
    tax = json['tax'];
    serviceFees = json['service_fees'];
    if (json['user_addresses'] != null) {
      userAddresses = <UserAddresses>[];
      json['user_addresses'].forEach((v) {
        userAddresses!.add(UserAddresses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['account_type'] = accountType;
    data['country_code'] = countryCode;
    data['mobile'] = mobile;
    data['gender'] = gender;
    data['lat'] = lat;
    data['lng'] = lng;
    data['country_name'] = countryName;
    data['city_name'] = cityName;
    data['address'] = address;
    data['mobile_code'] = mobileCode;
    data['area_id'] = areaId;
    data['area_title'] = areaTitle;
    data['cart'] = cart;
    data['photo_profile'] = photoProfile;
    data['mobile_verified_at'] = mobileVerifiedAt;
    data['balance'] = balance;
    data['resturant_id'] = resturantId;
    data['resturant_lat'] = resturantLat;
    data['resturant_lng'] = resturantLng;
    data['resturant_city'] = resturantCity;
    data['resturant_name'] = resturantName;
    data['resturant_logo'] = resturantLogo;
    data['resturant_area_id'] = resturantAreaId;
    data['resturant_area_name'] = resturantAreaName;
    data['myresturant_has_menu'] = myresturantHasMenu;
    data['resturant_parent_id'] = resturantParentId;
    data['parent_has_menu'] = parentHasMenu;
    data['delegate_status'] = delegateStatus;
    data['vendor_status'] = vendorStatus;
    data['created_at'] = createdAt;
    data['token'] = token;
    data['km_price'] = kmPrice;
    data['notificaions_count'] = notificaionsCount;
    data['go_drive_block'] = goDriveBlock;
    data['app_banner_background_color'] = appBannerBackgroundColor;
    data['otp_first_order'] = otpFirstOrder;
    data['otp_first_no'] = otpFirstNo;
    data['tax'] = tax;
    data['service_fees'] = serviceFees;
    data['app_multi_vendor'] = appMultiVendor;
    if (userAddresses != null) {
      data['user_addresses'] = userAddresses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserAddresses {
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
  int? cityId;
  String? address;
  String? createdAt;

  UserAddresses({
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
    this.cityId,
    this.address,
    this.createdAt,
  });

  UserAddresses.fromJson(Map<String, dynamic> json) {
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
    cityId = json['city_id'];

    address = json['address'];
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
    data['city_id'] = cityId;
    data['address'] = address;
    data['created_at'] = createdAt;
    return data;
  }
}
