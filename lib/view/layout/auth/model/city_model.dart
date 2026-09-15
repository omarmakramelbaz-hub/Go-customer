// import 'package:hive/hive.dart';

// @HiveType(typeId: 0) // Assign a unique typeId
// class CityModel extends HiveObject {
//   @HiveField(0)
//   final int id;

//   @HiveField(1)
//   final String? title;

//   CityModel({required this.id, this.title});

//   factory CityModel.fromJson(Map<String, dynamic> json) {
//     return CityModel(
//       id: json['id'],
//       title: json['title'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//     };
//   }
// }
