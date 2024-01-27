import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:toa/models/user_model.dart';
import 'package:toa/services/token_storage.dart';
import '../models/save_return.dart';
import './check_token_expiry.dart';

class UserApi {
  Future<SaveReturn> updatePassword(String pin) async {
    late String? baseUrl = dotenv.env['BASE_URL'];
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    // print(tokenObj);
    var token = tokenObj.values.first;
    // Convert DateTime to ISO 8601 String
    var id = await TokenStorage().readByKey("id");

    final response = await http.put(
      Uri.parse("$baseUrl/user/updatePassword"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(<String, dynamic>{
        "password": pin,
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

  Future<UserModel> getUserById() async {
    var baseUrl = dotenv.env['BASE_URL'];
    // print(token);
    Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
    var token = tokenObj.values.first;

    var id = await TokenStorage().readByKey("id");

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    final uri = Uri.parse(
      "$baseUrl/user/findById?id=$id",
    );
    // print(uri);
    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final userModel = userModelFromJson(response.body);
      return userModel;
    } else if (response.statusCode == 404) {
      throw Exception('User not registered');
    } else {
      throw Exception('Error');
    }
  }
}
