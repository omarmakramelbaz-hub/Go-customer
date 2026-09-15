class LastSearchModel {
  int? id;
  String? search;
  String? searchableType;
  int? userId;
  String? createdAt;
  String? updatedAt;
  int? resturantId;

  LastSearchModel({
    this.id,
    this.search,
    this.searchableType,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.resturantId,
  });

  LastSearchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    search = json['search'];
    searchableType = json['searchable_type'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    resturantId = json['resturant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['search'] = search;
    data['searchable_type'] = searchableType;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['resturant_id'] = resturantId;
    return data;
  }
}
