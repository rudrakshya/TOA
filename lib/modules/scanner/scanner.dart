import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../api/vehicle_api.dart';
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
  final String subHeader = "Truck owners' association";
  final TextEditingController _controller = TextEditingController();
  late String qrText = '';
  late bool isLogin = false;

  late bool initSearch = false;
  late bool searching = false;
  late bool found = false;

  late String registeredOn = "";

  @override
  void initState() {
    super.initState();
    initCheckLogin();
  }

  void initCheckLogin() async {
    var login = await checkLoggedIn();
    // print(login.toString());
    if (login == 200) {
      if (mounted) {
        setState(() {
          isLogin = true;
        });
      }
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

  Future<bool> showAlertDialog(
      BuildContext context, String title, String message) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Returning false if the dialog is dismissed by other means
  }

  void callAlert() {
    showAlertDialog(context, "Empty", "Please enter the vehicle number!");
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void search(text) async {
    if (text.isEmpty) {
      callAlert();
      return;
    }

    setState(() {
      qrText = text;
      searching = true;
      initSearch = true;
    });

    FocusScope.of(context).requestFocus(FocusNode());

    try {
      var vehicleRes = await VehicleApi().getVechicleByRegNo(text);
      // print(vehicleRes.isActive);
      setState(() {
        found = true;
        registeredOn = vehicleRes.registrationDateFormatted;
      });
      // Clear the fiel
    } catch (e) {
      // Handle exception
      if (e.toString().contains('Vehicle not registered')) {
        // _showAlert(context, "", "Vehicle not registered");
        setState(() {
          found = false;
        });
      } else {
        _showAlert(context, "", e.toString());
      }
    } finally {
      // setState(() => isBtnLoading = false);
    }

    setState(() {
      searching = false;
    });
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://toa.rudrakshyabarman.com/fomtoaPrivacy');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            // Call this method here to hide keyboard and unfocus text field
            FocusScope.of(context).requestFocus(FocusNode());
          },
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
                7, MediaQuery.of(context).size.height * 0.05, 7, 10),
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
                            search(_controller.text);
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
                      // print(result);
                      search(result);
                    }
                  },
                  child: Image.asset(
                    'assets/icons/qr_scanner.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                searching
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : found
                        ? resultFound(context)
                        : initSearch
                            ? resultNotFound(context)
                            : Container(),
                const Spacer(),
                Container(
                  // height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                  alignment: Alignment.bottomCenter,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "By using out app, you are agreed with our ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "privacy policy, ",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchPrivacyPolicy();
                            },
                        ),
                        const TextSpan(
                          text: "Read it out before using our app.",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget resultFound(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Image.asset(
            'assets/icons/check_green.png',
            scale: 3.0,
          ),
          const SizedBox(height: 10),
          Text(
            qrText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Registered on $registeredOn"),
          const Text("in association")
        ],
      ),
    );
  }

  Widget resultNotFound(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Image.asset(
            'assets/icons/error_sign.png',
            scale: 3.0,
          ),
          const SizedBox(height: 10),
          Text(
            qrText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text("Vehicle not registered"),
          const Text("in association"),
        ],
      ),
    );
  }
}
