class AdvertisingModel {
  int? id;
  int? restaurantId;
  String? fromDate;
  String? toDate;
  String? image;
  String? createdAt;

  AdvertisingModel({
    this.id,
    this.restaurantId,
    this.fromDate,
    this.toDate,
    this.image,
    this.createdAt,
  });

  AdvertisingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['resturant_id'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    image = json['imgae'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['resturant_id'] = restaurantId;
    data['from_date'] = fromDate;
    data['to_date'] = toDate;
    data['imgae'] = image;
    data['created_at'] = createdAt;
    return data;
  }
}
