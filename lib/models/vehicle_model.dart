// To parse this JSON data, do
//
//     final vehicleModel = vehicleModelFromJson(jsonString);

import 'dart:convert';

List<VehicleModel> vehicleModelFromJson(String str) => List<VehicleModel>.from(
    json.decode(str).map((x) => VehicleModel.fromJson(x)));

String vehicleModelToJson(List<VehicleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VehicleModel {
  String id;
  String regNo;
  String ownerName;
  String mobileNumber;
  DateTime registrationDate;
  String registrationDateFormatted;
  String isActive;

  VehicleModel({
    required this.id,
    required this.regNo,
    required this.ownerName,
    required this.mobileNumber,
    required this.registrationDate,
    required this.registrationDateFormatted,
    required this.isActive,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json["id"],
        regNo: json["reg_no"],
        ownerName: json["owner_name"],
        mobileNumber: json["mobile_number"],
        registrationDate: DateTime.parse(json["registration_date"]),
        registrationDateFormatted: json["registration_date_formatted"],
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reg_no": regNo,
        "owner_name": ownerName,
        "mobile_number": mobileNumber,
        "registration_date": registrationDate.toIso8601String(),
        "registration_date_formatted": registrationDateFormatted,
        "is_active": isActive,
      };
}
