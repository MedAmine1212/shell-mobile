import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_mobile/services/auth_service.dart';

import 'constants.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  _SingUpPageState createState() => _SingUpPageState();
}
  class _SingUpPageState extends State<SignUpScreen> {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool isButtonDisabled = false;
    String phoneNumber = '';
    String prefix = '';
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Signup"),
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
                      _loginInfo(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        const Text(
          "Create your Account",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, // Center-align the text
        ),
        Text("Enter details to get started"),
      ],
    );
  }

  Widget _inputFields(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InternationalPhoneNumberInput(
          validator: _validatePhoneNumber,
          onInputChanged: (PhoneNumber number) {
            phoneNumber = number.parseNumber() ?? ''; // Store the phone number
            prefix = number.dialCode ?? ''; // Store the phone number
          },
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
          initialValue: PhoneNumber(isoCode: 'TN'),
          countries: const ['TN'],
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            setSelectorButtonAsPrefixIcon: true,
            showFlags: true,
            leadingPadding:20
          ),
        ),
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
            _signup(context);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isButtonDisabled
              ? const CircularProgressIndicator( // Display loading animation
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          )
              : const Text(
            "Sign up",
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _loginInfo(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
            onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
            child: Text("Login")),
      ],
    );
  }
    String? _validatePhoneNumber(String? value) {
      if (value == null || value.isEmpty) {
        return 'Phone number is required';
      }
      return null; // Validation passed
    }
  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    final token = prefs.getString('token');
    final waitingForPassword = prefs.getString('waitingForPassword');
    if (waitingForPassword != null) {
      Future.microtask(() {
        Navigator.pushNamed(context, '/otp');
      }); // Redirect to login screen
    }else if (user != null && token != null) {
        Future.microtask(() {
          Navigator.pushNamed(context, '/home');
        }); // Redirect to login screen
      }
  }

    Future<void> _signup(BuildContext context) async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isButtonDisabled = true; // Disable the button
        });

        // Get the phone number and password
        String firstName = firstNameController.text;
        String lastName = lastNameController.text;

        // Call your authentication service here
        final authService = AuthService();
        final response = await authService.signup(phoneNumber, prefix, firstName, lastName);
        if(response != null) {
          // Handle the successful login response if needed
          final prefs = await SharedPreferences.getInstance();
          prefs.clear();
          prefs.setString('phoneNumber', response["client"]["user"]["fullPhoneNumber"]);
          prefs.setString('waitingForPassword', 'true');
          Future.microtask(() {
            Navigator.pushNamed(context, '/otp');
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