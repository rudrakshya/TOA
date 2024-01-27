import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/token_storage.dart';

class CheckTokenExpiry {
  Future<Map<String, dynamic>> checkExpiry() async {
    var token = await TokenStorage().readByKey("token");
    // print(token);
    bool isTokenExpired = true;
    try {
      isTokenExpired = JwtDecoder.isExpired(token);
    } catch (e) {
      Exception(e.toString());
      TokenStorage().deleteAll();
    }

    if (!isTokenExpired) {
      // The user should authenticate
      Map<String, dynamic> tokenObj = json.decode(jsonEncode({"token": token}));
      // print(1);
      return tokenObj;
    } else {
      var baseUrl = dotenv.env['BASE_URL'];
      var refreshToken = await TokenStorage().readByKey("refresh_token");

      // print(baseUrl);
      final response = await http.post(
        Uri.parse("$baseUrl/login/refreshToken"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "accept": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          "refresh_token": refreshToken,
          "user_type": "",
        }),
      );
      // print(response.body);
      if (response.statusCode == 200) {
        // print(2);
        Map<String, dynamic> resposneJson = jsonDecode(response.body);
        // print(resposneJson.values.first);
        await TokenStorage().addNewItem('token', resposneJson.values.first);
        return resposneJson;
      } else {
        TokenStorage().deleteAll();
        // Provide a more specific error message based on the status code
        var errorMessage =
            'Failed to refresh token. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    }
  }
}
