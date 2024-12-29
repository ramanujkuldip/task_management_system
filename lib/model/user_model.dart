import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? username;
  @HiveField(2)
  final String? userEmail;
  @HiveField(3)
  final bool? isLightTheme;
  @HiveField(4)
  final String? sortBy;

  UserModel({
    this.id,
    this.username,
    this.userEmail,
    this.isLightTheme,
    this.sortBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': username,
      'userEmail': userEmail,
      'isLightTheme': isLightTheme,
      'sortBy': sortBy,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['userName'],
      userEmail: map['userEmail'],
      isLightTheme: map['isLightTheme'],
      sortBy: map['sortBy'],
    );
  }
}
