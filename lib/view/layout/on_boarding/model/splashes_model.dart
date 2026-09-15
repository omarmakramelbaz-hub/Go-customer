class SplashesModel {
  int? id;
  String? title;
  String? image;
  String? createdAt;

  SplashesModel({this.id, this.title, this.image, this.createdAt});

  SplashesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['created_at'] = createdAt;
    return data;
  }
}
