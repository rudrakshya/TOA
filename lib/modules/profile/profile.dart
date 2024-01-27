import 'package:flutter/material.dart';
import 'package:toa/api/user_api.dart';
import 'package:toa/services/token_storage.dart';

import '../scanner/scanner.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String mobileNumber = "";
  late String fullName = "";
  late String userType = "";

  final TextEditingController _password = TextEditingController();
  late bool _validate = true;

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  void getProfile() async {
    try {
      var user = await UserApi().getUserById();
      setState(() {
        fullName = user.fullName;
        mobileNumber = user.username;
        userType = user.userType;
      });
    } catch (e) {
      Exception(e.toString());
    } finally {}
  }

  bool _validateField() {
    if (_password.text.length != 4) {
      setState(() {
        _validate = false;
      });
      return false;
    } else {
      setState(() {
        _validate = true;
      });
      return true;
    }
  }

  void updatePassword() async {
    if (_validateField()) {
      var passwordRes = await UserApi().updatePassword(_password.text);

      if (passwordRes.status == 200) {
        setState(() {
          _password.text = "";
        });
        callAlert();
      }
    }
  }

  void callAlert() {
    showSimpleDialog(context);
  }

  void showSimpleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Updated'),
          content: const Text('Login PIN successfully updated'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    await TokenStorage().deleteAll();
    navigateDashboard();
  }

  void navigateDashboard() {
    // Navigator.pushReplacementNamed(context, '/');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Scanner(),
      ), // Replace with your destination Widget
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Call this method here to hide keyboard and unfocus text field
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          actions: [
            Row(
              children: [
                const Text("Logout"),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: logout,
                ),
              ],
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(mobileNumber),
              Text(fullName),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.25,
                  10,
                  MediaQuery.of(context).size.width * 0.25,
                  5,
                ),
                child: TextField(
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Pin (4 digit)",
                    hintText: "XXXX",
                    errorText: _validate ? null : "Required",
                  ),
                  controller: _password,
                  autofocus: true,
                  maxLength: 4,
                  onChanged: (value) => _validateField(),
                ),
              ),
              ElevatedButton(
                onPressed: updatePassword,
                child: const Text("Update PIN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
