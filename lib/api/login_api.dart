import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';

class LoginApi {
  Future<LoginModel> getLogin(String mobileNo, String pin) async {
    // print(mobileNo);
    // print(pin);
    var baseUrl = dotenv.env['BASE_URL'];

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/getLogin"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "accept": "application/json"
        },
        body: jsonEncode(
            <String, dynamic>{"username": mobileNo, "password": pin}),
      );

      if (response.statusCode == 200) {
        final loginModel = loginModelFromJson(response.body);
        return loginModel;
      } else if (response.statusCode == 401) {
        // Handle invalid login
        throw Exception('Invalid login credentials.');
      } else {
        // Handle other server-side errors
        var responseData = json.decode(response.body);
        var serverMessage = responseData['message'] ?? 'Error occurred.';
        throw Exception(serverMessage);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on FormatException {
      throw Exception('Bad response format.');
    } catch (e) {
      // Handle any other type of exception
      throw Exception('Error: ${e.toString()}');
    }
  }
}
