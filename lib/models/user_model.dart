// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String id;
  String fullName;
  String username;
  String userType;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        fullName: json["full_name"],
        username: json["username"],
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "username": username,
        "user_type": userType,
      };
}
