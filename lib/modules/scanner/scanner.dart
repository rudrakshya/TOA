import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../scanner/qr_scanner.dart';
import '../../api/check_token_expiry.dart';
import '../../services/token_storage.dart';
import '../login/login.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final String header = "Federation of Malda";
  final String subHeader = "Truck owner's association";
  final TextEditingController _controller = TextEditingController();
  late String qrText = '';
  late bool isLogin = false;
  @override
  void initState() {
    super.initState();
    initCheckLogin();
  }

  void initCheckLogin() async {
    var login = await checkLoggedIn();
    // print(login.toString());
    if (login == 200) {
      setState(() {
        isLogin = true;
      });
    }
  }

  Future<int> checkLoggedIn() async {
    var token = await TokenStorage().readByKey("token");
    // print(baseUrl);
    if (token != "null") {
      Map<String, dynamic> tokenObj = await CheckTokenExpiry().checkExpiry();
      // print(tokenObj.values.first);
      token = tokenObj.values.first;
    } else {
      return 401;
    }

    late String? baseUrl = dotenv.env['BASE_URL'];

    if (token != "null") {
      try {
        final response = await http.post(
          Uri.parse("$baseUrl/login/isCustomerAuthenticated"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            "accept": "application/json"
          },
          body: jsonEncode(<String, dynamic>{"token": token}),
        );

        // print("status: ${response.statusCode}");
        // print(response.body);
        if (response.statusCode == 200) {
          if (response.body == "1") {
            // If the app is opened from a notification and has a location data
            return 200;
          } else {
            return 401;
          }
        } else {
          return 401;
        }
      } catch (e) {
        return 404;
      }
    } else {
      return 401;
    }
  }

  void navigateToDashBoard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Call this method here to hide keyboard and unfocus text field
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade100, Colors.white],
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                7, MediaQuery.of(context).size.height * 0.05, 7, 0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    isLogin
                        ? navigateToDashBoard()
                        : Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isLogin ? const Text("Dashboard") : const Text("Login"),
                      isLogin
                          ? const Icon(Icons.dashboard)
                          : const Icon(Icons.login_sharp),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AutoSizeText(
                  header,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                  ),
                ),
                AutoSizeText(
                  subHeader,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: TextFormField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Enter vehicle reg no.',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 25, // Set your desired font size here
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () {
                            debugPrint(
                                'Button pressed with text: ${_controller.text}');
                          },
                          child: const Text(
                            'Search',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text("OR"),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const QRScanner(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        qrText = result; // Set the scanned QR text
                      });
                    }
                  },
                  child: Image.asset(
                    'assets/icons/qr_scanner.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                Text(qrText)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
