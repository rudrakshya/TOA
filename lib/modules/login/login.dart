import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toa/api/login_api.dart';

import '../../services/token_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  late bool isBtnLoading = false;

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration:
          const Duration(seconds: 3), // Duration the SnackBar will be shown
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void callSnackBar(errorMessage) {
    _showSnackBar(context, errorMessage);
  }

  void navigateToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> login() async {
    // print(_mobileController.text);
    // print(_pinController.text);
    var mobileNo = _mobileController.text;
    var pin = _pinController.text;
    // print(mobileNo);
    if (mobileNo.length != 10) {
      _showSnackBar(context, "Mobile number should be 10 digit");
      return;
    } else if (pin.length != 4) {
      _showSnackBar(context, "PIN should be 4 digit");
      return;
    } else {
      setState(() {
        isBtnLoading = true;
      });
      // var loginRes = await LoginApi().getLogin(mobileNo, pin);
      // print(loginRes.isActive);
      // print(loginRes.userType);
      try {
        var loginRes = await LoginApi().getLogin(mobileNo, pin);
        // Handle successful login, navigate or display success message
        // For example:
        // Navigator.pushReplacementNamed(context, '/home');
        // print(loginRes.isActive);
        if (loginRes.isActive == "1") {
          await TokenStorage().addNewItem('token', loginRes.token.toString());
          await TokenStorage()
              .addNewItem('refresh_token', loginRes.refreshToken.toString());
          await TokenStorage().addNewItem('id', loginRes.id.toString());
          await TokenStorage()
              .addNewItem('user_type', loginRes.userType.toString());
          navigateToHome();
        } else {
          var errorMessage = "User is not activated!";
          callSnackBar(errorMessage);
        }
        setState(() {
          isBtnLoading = false;
        });
      } catch (e) {
        String errorMessage = "An error occurred. Please try again.";
        if (e is SocketException) {
          errorMessage =
              "No Internet connection. Please check your connection.";
        } else if (e.toString().contains('Invalid login credentials.')) {
          errorMessage = "Invalid login credentials. Please try again.";
        } else if (e is FormatException) {
          errorMessage = "Unexpected error occurred. Please try again later.";
        }
        _showSnackBar(context, errorMessage);
        setState(() {
          isBtnLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Unfocus all text fields when tapping outside
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade100, Colors.white10],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
                25, 100, 25, 25), // Padding around the screen
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                buildInputField(
                  _mobileController,
                  'Mobile Number',
                  TextInputType.phone,
                  isObscure: false,
                ),
                const SizedBox(height: 20),
                buildInputField(
                  _pinController,
                  '4-Digit PIN',
                  TextInputType.number,
                  maxLength: 4,
                  isObscure: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement login logic
                    isBtnLoading ? null : login();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        isBtnLoading ? Colors.white10 : Colors.blue,
                    minimumSize:
                        const Size(double.infinity, 50), // Button width
                  ),
                  child: isBtnLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 50), // Button width
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios),
                      Text('Back'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    int? maxLength,
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: isObscure,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
