// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String id;
  String userType;
  String isActive;
  String token;
  String refreshToken;

  LoginModel({
    required this.id,
    required this.userType,
    required this.isActive,
    required this.token,
    required this.refreshToken,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        id: json["id"],
        userType: json["user_type"],
        isActive: json["is_active"],
        token: json["token"],
        refreshToken: json["refresh_token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "is_active": isActive,
        "token": token,
        "refresh_token": refreshToken,
      };
}
