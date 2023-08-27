import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_mobile/services/auth_service.dart';

import 'constants.dart';

class FinishSignup extends StatefulWidget {
  const FinishSignup({Key? key}) : super(key: key);

  @override
  _FinishSignupState createState() => _FinishSignupState();
}

class _FinishSignupState extends State<FinishSignup> {
  late Map<String, dynamic> user;
  bool isLoading = true;
  bool isUpdate = false;
  String title = "Finish setting up profile";
  String buttonText = "Submit";
  String phoneNumber = '';
  String prefix = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isButtonDisabled = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      user = jsonDecode(userData);
      setState(() {
        if(prefs.getString("isUpdate") != null) {
          firstNameController.text = user["firstName"];
          lastNameController.text = user["lastName"];
          phoneNumber = user["phone"];
          prefix = user["prefix"];
          isUpdate = true;
          title = prefs.getString("isUpdate") != null ? 'Update profile' : 'Finish setting up profile';
          buttonText = prefs.getString("isUpdate") != null ? 'Update' : 'Submit';
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: secondary), // Show loading indicator
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _inputFields(context),
                    const SizedBox(height: 30),
                    TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          if(prefs.getString("isUpdate") != null) {
                            Future.microtask(() {
                              Navigator.pushNamed(context, '/home');
                              prefs.setInt("page", 2);
                            });
                          } else {
                            prefs.clear();
                            Future.microtask(() {
                              Navigator.pushNamed(context, '/login');
                            }); // R
                          }

                        },
                        child: const Text("Cancel")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null; // Validation passed
  }

  Widget _phoneInput(context) {
    return InternationalPhoneNumberInput(
      validator: _validatePhoneNumber,
      onInputChanged: (PhoneNumber number) {
        phoneNumber = number.parseNumber() ?? ''; // Store the phone number
        prefix = number.dialCode ?? ''; // Store the phone number
      },
      initialValue: PhoneNumber(
        isoCode: 'TN',
        dialCode: prefix, // Set the initial prefix (dial code)
        phoneNumber: phoneNumber, // Set the initial phone number
      ),
      inputDecoration: InputDecoration(
        hintText: "Phone number",
        fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
        filled: true,
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      formatInput: false, // Set to true if you want to format the input
      keyboardType: TextInputType.phone,
      countries: const ['TN'],
      selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          setSelectorButtonAsPrefixIcon: true,
          showFlags: true,
          leadingPadding:20
      ),
    );
  }
  Widget _header(context) {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png', // Replace with the path to your logo asset
          width: 150, // Adjust the width as needed
          height: 150, // Adjust the height as needed
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, // Center-align the text
        ),
        const Text("Enter details to proceed"),
      ],
    );
  }

  Widget _inputFields(context) {
    List<Widget> inputFields = [];

    if (isUpdate) {
      inputFields.add(_phoneInput(context));
      inputFields.add(const SizedBox(height: 10));
    }
    inputFields.addAll([
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        controller: firstNameController,
        decoration: InputDecoration(
          hintText: "Firstname",
          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
          filled: true,
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Firstname is required';
          }
          return null;
        },
      ),
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        controller: lastNameController,
        decoration: InputDecoration(
          hintText: "Lastname",
          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
          filled: true,
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'lastname is required';
          }
          return null;
        },
      ),
      const SizedBox(
        height: 20,
      ),
      ElevatedButton(
        onPressed: isButtonDisabled
            ? null
            : () {
          _updateUser(context);
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isButtonDisabled
            ? const CircularProgressIndicator( // Display loading animation
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        )
            : Text(
          buttonText,
          style: const TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: inputFields
    );
  }


  Future<void> _updateUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isButtonDisabled = true; // Disable the button
      });

      // Get the phone number and password
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;

      // Call your authentication service here
      Map<String, String> payload = <String, String>{};
      bool phoneNumberChanged = false;
      if(isUpdate) {
        if (phoneNumber != user["phone"]) {
          payload.putIfAbsent('phone', () => phoneNumber);
          payload.putIfAbsent('prefix', () => prefix);
          phoneNumberChanged = true;
        }
      }
      if(firstName != user["firstName"]) {
        payload.putIfAbsent('firstName', () => firstName);
      }
      if(lastName != user["lastName"]) {
        payload.putIfAbsent('lastName', () => lastName);
      }
      if(payload.isEmpty) {
        setState(() {
          isButtonDisabled = false; // Re-enable the button
        });
        Fluttertoast.showToast(
          msg: "But, you have to change something first !",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: secondary,
          textColor: Colors.white,
          fontSize: 16,
          webShowClose: true,
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if(phoneNumberChanged) {
        prefs.setString("updateUser", jsonEncode(payload));
        prefs.setString("phoneNumber", prefix+phoneNumber);
        prefs.remove("newPhoneNumber");
        Future.microtask(() {
          Navigator.pushNamed(context, '/otp');
        });
        return;
      }
      final authService = AuthService();
      final response = await authService.updateUser(payload);
      if(response != null) {
        // Handle the successful login response if needed
        prefs.setString('user', json.encode(response["user"]));
        prefs.remove("isUpdate");
        Fluttertoast.showToast(
          msg: "User details updated",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16,
          webShowClose: true,
        );
        prefs.setInt("page", 2);
        Future.microtask(() {
          Navigator.pushNamed(context, '/home');
        });
      } else {
        setState(() {
          isButtonDisabled = false; // Re-enable the button
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Fields required",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: secondary,
        textColor: Colors.white,
        fontSize: 16,
        webShowClose: true,
      );
    }
  }

}
