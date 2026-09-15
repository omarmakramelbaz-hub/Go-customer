class SliderModel {
  int? id;
  String? title;
  int? resturantId;
  List<Imgaes>? imgaes;
  String? createdAt;

  SliderModel({this.id, this.title, this.resturantId, this.imgaes, this.createdAt});

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
        id: json['id'],
        title: json['title'],
        resturantId: json['resturant_id'],
        imgaes: json['imgaes'] == null ? [] : List<Imgaes>.from(json['imgaes']!.map((x) => Imgaes.fromJson(x))),
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'resturant_id': resturantId,
        'imgaes': imgaes == null ? [] : List<dynamic>.from(imgaes!.map((x) => x.toJson())),
        'created_at': createdAt,
      };
}

class Imgaes {
  int? id;
  String? url;
  String? createdAt;

  Imgaes({this.id, this.url, this.createdAt});

  factory Imgaes.fromJson(Map<String, dynamic> json) => Imgaes(
        id: json['id'],
        url: json['url'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'created_at': createdAt};
}
