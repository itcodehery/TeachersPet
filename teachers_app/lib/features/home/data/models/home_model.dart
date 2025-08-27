import 'package:teachers_app/features/home/domain/entities/home.dart';

class HomeModel {
  final String id;
  final String name;

  HomeModel({
    required this.id,
    required this.name,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  Home toEntity() {
    return Home(
      id: id,
      name: name,
    );
  }
}
