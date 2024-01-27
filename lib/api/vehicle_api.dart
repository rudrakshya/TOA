import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:toa/models/save_return.dart';
import 'package:http/http.dart' as http;

import '../models/vehicle_model.dart';
import './check_token_expiry.dart';

class VehicleApi {
  Future<SaveReturn> save(
    String regNo,
    String ownerName,
    String mobile,
    DateTime regDatetime,
  ) async {
    late String? baseUrl = dotenv.env['BASE_URL'];
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    // print(tokenObj);
    var token = tokenObj.values.first;
    // Convert DateTime to ISO 8601 String
    String formattedDate = DateFormat('yyyy-MM-dd').format(regDatetime);

    final response = await http.post(
      Uri.parse("$baseUrl/vehicle/save"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(<String, dynamic>{
        "reg_no": regNo,
        "owner_name": ownerName,
        "mobile_number": mobile,
        "registration_date": formattedDate,
      }),
    );

    // print(response.body);
    if (response.statusCode == 200) {
      SaveReturn resposneJson = SaveReturn.fromJson(jsonDecode(response.body));
      return resposneJson;
    } else if (response.statusCode == 403) {
      throw Exception(response.body);
    } else {
      throw Exception('Error');
    }
  }

  Future<SaveReturn> update(
    String regNo,
    String ownerName,
    String mobile,
    DateTime regDatetime,
    int id,
  ) async {
    late String? baseUrl = dotenv.env['BASE_URL'];
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    // print(tokenObj);
    var token = tokenObj.values.first;
    // Convert DateTime to ISO 8601 String
    String formattedDate = DateFormat('yyyy-MM-dd').format(regDatetime);

    final response = await http.put(
      Uri.parse("$baseUrl/vehicle/update"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(<String, dynamic>{
        "reg_no": regNo,
        "owner_name": ownerName,
        "mobile_number": mobile,
        "registration_date": formattedDate,
        "id": id,
      }),
    );

    // print(response.body);
    if (response.statusCode == 200) {
      SaveReturn resposneJson = SaveReturn.fromJson(jsonDecode(response.body));
      return resposneJson;
    } else if (response.statusCode == 403) {
      throw Exception(response.body);
    } else {
      throw Exception('Error');
    }
  }

  Future<List<VehicleModel>> getVechicle(
    int page,
  ) async {
    var baseUrl = dotenv.env['BASE_URL'];
    // print(token);
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    var token = tokenObj.values.first;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    final uri = Uri.parse(
      "$baseUrl/vehicle/findAll?page=$page",
    );
    // print(uri);
    final response = await http.get(
      uri,
      headers: headers,
    );

    // print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((e) => VehicleModel.fromJson(e)).toList();
    } else {
      throw Exception('Error');
    }
  }

  Future<VehicleModel> getVechicleByRegNo(String regNo) async {
    var baseUrl = dotenv.env['BASE_URL'];
    // print(token);
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    var token = tokenObj.values.first;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    final uri = Uri.parse(
      "$baseUrl/scanner/findByRegNo?reg_no=$regNo",
    );
    // print(uri);
    final response = await http.get(
      uri,
      headers: headers,
    );

    // print(response.body);
    if (response.statusCode == 200) {
      // List jsonResponse = json.decode(response.body);
      VehicleModel vehicleModelFromJson(String str) =>
          VehicleModel.fromJson(json.decode(str));

      // String vehicleModelToJson(VehicleModel data) =>
      //     json.encode(data.toJson());
      final vehicleModel = vehicleModelFromJson(response.body);
      return vehicleModel;
    } else if (response.statusCode == 404) {
      throw Exception('Vehicle not registered');
    } else {
      throw Exception('Error');
    }
  }

  Future<bool> delete(String id) async {
    late String? baseUrl = dotenv.env['BASE_URL'];
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    // print(tokenObj);
    var token = tokenObj.values.first;
    // Convert DateTime to ISO 8601 String

    final response = await http.delete(
      Uri.parse("$baseUrl/vehicle/delete/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception(response.body);
    } else {
      throw Exception('Error');
    }
  }
}
