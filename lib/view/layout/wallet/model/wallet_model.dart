class WalletResponse {
  List<WalletModel>? wallet;
  double? balance;
  Profile? profile;

  WalletResponse({this.wallet, this.balance, this.profile});

  WalletResponse.fromJson(Map<String, dynamic> json) {
    if (json['wallet'] != null) {
      wallet = <WalletModel>[];
      json['wallet'].forEach((v) {
        wallet!.add(WalletModel.fromJson(v));
      });
    }
    balance = double.tryParse(json['balance'].toString());
    profile = json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (wallet != null) {
      data['wallet'] = wallet!.map((v) => v.toJson()).toList();
    }
    data['balance'] = balance;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class WalletModel {
  int? id;
  num? amount;
  String? type;
  int? fromUser;
  String? fromUserName;
  int? toUser;
  String? toUserName;
  int? orderId;
  String? orderNo;
  String? payment;
  String? createdAt;

  WalletModel({
    this.id,
    this.amount,
    this.type,
    this.fromUser,
    this.fromUserName,
    this.toUser,
    this.toUserName,
    this.orderId,
    this.orderNo,
    this.payment,
    this.createdAt,
  });

  WalletModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    type = json['type'];
    fromUser = json['from_user'];
    fromUserName = json['from_user_name'];
    toUser = json['to_user'];
    toUserName = json['to_user_name'];
    orderId = json['order_id'];
    orderNo = json['order_no'];
    payment = json['payment'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['type'] = type;
    data['from_user'] = fromUser;
    data['from_user_name'] = fromUserName;
    data['to_user'] = toUser;
    data['to_user_name'] = toUserName;
    data['order_id'] = orderId;
    data['order_no'] = orderNo;
    data['payment'] = payment;
    data['created_at'] = createdAt;
    return data;
  }
}

class Profile {
  int? id;
  String? name;
  String? email;
  String? accountType;
  dynamic countryCode;
  String? mobile;
  String? gender;
  dynamic lat;
  dynamic lng;
  String? mobileCode;
  int? areaId;
  String? areaTitle;
  dynamic cart;
  String? photoProfile;
  String? mobileVerifiedAt;
  dynamic balance;
  String? createdAt;
  String? token;

  Profile({
    this.id,
    this.name,
    this.email,
    this.accountType,
    this.countryCode,
    this.mobile,
    this.gender,
    this.lat,
    this.lng,
    this.mobileCode,
    this.areaId,
    this.areaTitle,
    this.cart,
    this.photoProfile,
    this.mobileVerifiedAt,
    this.balance,
    this.createdAt,
    this.token,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    accountType = json['account_type'];
    countryCode = json['country_code'];
    mobile = json['mobile'];
    gender = json['gender'];
    lat = json['lat'];
    lng = json['lng'];
    mobileCode = json['mobile_code'];
    areaId = json['area_id'];
    areaTitle = json['area_title'];
    cart = json['cart'];
    photoProfile = json['photo_profile'];
    mobileVerifiedAt = json['mobile_verified_at'];
    balance = json['balance'];
    createdAt = json['created_at'];
    token = json['token'];
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
    data['mobile_code'] = mobileCode;
    data['area_id'] = areaId;
    data['area_title'] = areaTitle;
    data['cart'] = cart;
    data['photo_profile'] = photoProfile;
    data['mobile_verified_at'] = mobileVerifiedAt;
    data['balance'] = balance;
    data['created_at'] = createdAt;
    data['token'] = token;
    return data;
  }
}
