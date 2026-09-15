class NotificationsModel {
  String? type;
  String? id;
  Data? data;
  String? createdAt;

  NotificationsModel({this.type, this.id, this.data, this.createdAt});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class Data {
  String? title;
  String? logo;
  String? text;
  String? createdAt;
  DataNotification? data;

  Data({this.title, this.logo, this.text, this.createdAt, this.data});

  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    logo = json['logo'];
    text = json['text'];
    createdAt = json['created_at'];
    data = json['data'] != null ? DataNotification.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['logo'] = logo;
    data['text'] = text;
    data['created_at'] = createdAt;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DataNotification {
  int? notificationType;
  int? id;
  String? orderNo;
  String? orderType;
  int? resturantId;

  DataNotification({this.notificationType, this.id, this.orderNo, this.resturantId, this.orderType});

  DataNotification.fromJson(Map<String, dynamic> json) {
    notificationType = json['notification_type'];
    id = json['order_id'];
    orderNo = json['order_no'];
    orderType = json['order_type'];
    resturantId = json['resturant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notification_type'] = notificationType;
    data['order_id'] = id;
    data['order_no'] = orderNo;
    data['resturant_id'] = resturantId;
    data['order_type'] = orderType;
    return data;
  }
}
