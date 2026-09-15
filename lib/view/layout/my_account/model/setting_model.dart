class SettingModel {
  String? email;
  String? mobile;
  String? address;
  int? adminId;
  String? adminDeviceToken;
  String? logo;
  String? favicon;
  String? twitterLink;
  String? facebookLink;
  String? instagramLink;
  String? googleLink;
  String? privacy;
  String? terms;
  String? contactText;
  String? walletCardActivate;
  String? paymentCardActivate;
  int? countResturantNotHide;
  String? appBannerBackgroundColor;
  String? delegateVendorSmallInfo;
  String? default01;
  String? default12;
  String? default23;

  SettingModel({
    this.email,
    this.mobile,
    this.address,
    this.adminId,
    this.adminDeviceToken,
    this.logo,
    this.favicon,
    this.twitterLink,
    this.facebookLink,
    this.instagramLink,
    this.googleLink,
    this.privacy,
    this.terms,
    this.contactText,
    this.walletCardActivate,
    this.paymentCardActivate,
    this.countResturantNotHide,
    this.appBannerBackgroundColor,
    this.delegateVendorSmallInfo,
    this.default01,
    this.default12,
    this.default23,
  });

  SettingModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    mobile = json['mobile'];
    address = json['address'];
    adminId = json['admin_id'];
    adminDeviceToken = json['admin_device_token'];
    logo = json['logo'];
    favicon = json['favicon'];
    twitterLink = json['twitter_link'];
    facebookLink = json['facebook_link'];
    instagramLink = json['instagram_link'];
    googleLink = json['google_link'];
    privacy = json['privacy'];
    terms = json['terms'];
    contactText = json['contact_text'];
    walletCardActivate = json['wallet_card_activate'];
    paymentCardActivate = json['payment_card_activate'];
    countResturantNotHide = json['count_resturant_not_hide'];
    appBannerBackgroundColor = json['app_banner_background_color'];
    delegateVendorSmallInfo = json['delegate_vendor_small_info'];
    default01 = json['default_0_1'];
    default12 = json['default_1_2'];
    default23 = json['default_2_3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['mobile'] = mobile;
    data['address'] = address;
    data['admin_id'] = adminId;
    data['admin_device_token'] = adminDeviceToken;
    data['logo'] = logo;
    data['favicon'] = favicon;
    data['twitter_link'] = twitterLink;
    data['facebook_link'] = facebookLink;
    data['instagram_link'] = instagramLink;
    data['google_link'] = googleLink;
    data['privacy'] = privacy;
    data['terms'] = terms;
    data['contact_text'] = contactText;
    data['wallet_card_activate'] = walletCardActivate;
    data['payment_card_activate'] = paymentCardActivate;
    data['count_resturant_not_hide'] = countResturantNotHide;
    data['app_banner_background_color'] = appBannerBackgroundColor;
    data['delegate_vendor_small_info'] = delegateVendorSmallInfo;
    data['default_0_1'] = default01;
    data['default_1_2'] = default12;
    data['default_2_3'] = default23;
    return data;
  }
}
