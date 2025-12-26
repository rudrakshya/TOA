import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:toa/api/vehicle_api.dart';

class CreateVehicle extends StatefulWidget {
  final String regNo;
  final String ownerName;
  final String mobileNumber;
  final int id;

  const CreateVehicle({
    super.key,
    required this.regNo,
    required this.ownerName,
    required this.mobileNumber,
    required this.id,
  });

  @override
  State<CreateVehicle> createState() => _CreateVehicleState();
}

class _CreateVehicleState extends State<CreateVehicle> {
  late String appBarHeader = "Add new Vehicle";
  final TextEditingController _vehicleRegNo = TextEditingController();
  final TextEditingController _ownerFullName = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _location = TextEditingController();
  late DateTime selectedDate = DateTime.now();
  late bool _validateVehicle = true;
  late bool _validateOwner = true;
  late bool _validateMobile = true;
  late bool isBtnLoading = false;
  late int id = 0;

  @override
  void initState() {
    _vehicleRegNo.text = widget.regNo;
    _ownerFullName.text = widget.ownerName;
    _mobileNumber.text = widget.mobileNumber;
    // print("id:  ${widget.id}");
    id = widget.id;
    super.initState();
  }

  bool _validateField() {
    if (_vehicleRegNo.text.isEmpty) {
      setState(() {
        _validateVehicle = false;
      });
      return false;
    } else if (_ownerFullName.text.isEmpty) {
      setState(() {
        _validateOwner = false;
        _validateVehicle = true;
      });
      return false;
    } else if (_mobileNumber.text.length != 10) {
      setState(() {
        _validateMobile = false;
        _validateOwner = true;
        _validateVehicle = true;
      });
      return false;
    } else {
      setState(() {
        _validateVehicle = true;
        _validateOwner = true;
        _validateMobile = true;
      });
      return true;
    }
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

  void callAlert(title, message) {
    _showAlert(context, title, message);
  }

  void _submit() async {
    if (_validateField()) {
      setState(() => isBtnLoading = true);

      try {
        var res = await VehicleApi().save(
          _vehicleRegNo.text,
          _ownerFullName.text,
          _mobileNumber.text,
          selectedDate,
          _location.text,
        );

        if (res.status == 200) {
          // Clear the fields
          _vehicleRegNo.clear();
          _ownerFullName.clear();
          _mobileNumber.clear();
          _location.clear();
          // You can also reset the selectedDate if needed

          // Show success alert
          callAlert("Success", "Vehicle successfully added.");
        } else {
          // Handle error
          callAlert("Error", "Failed to add vehicle: ${res.res}");
        }
      } catch (e) {
        // Handle exception
        _showAlert(context, "Exception", e.toString());
      } finally {
        setState(() => isBtnLoading = false);
      }
    }
  }

  void _update() async {
    if (_validateField()) {
      setState(() => isBtnLoading = true);

      try {
        var res = await VehicleApi().update(
          _vehicleRegNo.text,
          _ownerFullName.text,
          _mobileNumber.text,
          selectedDate,
          id,
          _location.text,
        );

        if (res.status == 200) {
          // Clear the fields
          _vehicleRegNo.clear();
          _ownerFullName.clear();
          _mobileNumber.clear();
          _location.clear();
          setState(() {
            id = 0;
          });
          // You can also reset the selectedDate if needed

          // Show success alert
          callAlert("Success", "Vehicle successfully updated.");
        } else {
          // Handle error
          callAlert("Error", "Failed to update vehicle: ${res.res}");
        }
      } catch (e) {
        // Handle exception
        _showAlert(context, "Exception", e.toString());
      } finally {
        setState(() => isBtnLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
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
          title: AutoSizeText(
            appBarHeader,
            minFontSize: 12,
            maxFontSize: 18,
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Vehicle reg no.",
                          hintText: "WB65X XXXX",
                          errorText: _validateVehicle ? null : "Required",
                        ),
                        controller: _vehicleRegNo,
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (value) => _validateField(),
                      ),
                      TextField(
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Owner full name",
                          hintText: "firstname lastname",
                          errorText: _validateOwner ? null : "Required",
                        ),
                        controller: _ownerFullName,
                        autofocus: true,
                        onChanged: (value) => _validateField(),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      TextField(
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Mobile number",
                          hintText: "99XXXXXXXX",
                          errorText: _validateMobile ? null : "Required",
                        ),
                        controller: _mobileNumber,
                        autofocus: true,
                        onChanged: (value) => _validateField(),
                        maxLength: 10,
                      ),
                      // DatePicker TextField
                      TextFormField(
                        readOnly: true, // To prevent manual editing
                        decoration: const InputDecoration(
                          labelText: 'Registration Date',
                          hintText: 'Select a date',
                        ),
                        controller: TextEditingController(
                            text: formatDate(selectedDate)),
                        onTap: () => _selectDate(context),
                      ),
                      TextField(
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Location (Optional)",
                          hintText: "Enter location",
                        ),
                        controller: _location,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isBtnLoading ? Colors.white10 : Colors.blue,
                minimumSize: const Size(double.infinity, 50), // Button width
              ),
              onPressed: id == 0 ? _submit : _update,
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
