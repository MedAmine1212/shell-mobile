import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_mobile/services/auth_service.dart';
import '../constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isButtonDisabled = false;
  String phoneNumber = '';
  TextEditingController passwordController = TextEditingController();
  @override
  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: const Text("Login"),
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
                      _inputField(context),
                      const SizedBox(height: 6),
                      _forgotPassword(context),
                      _signup(context),
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
          "Welcome Back",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const Text("Enter your credentials to login"),
      ],
    );
  }
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null; // Validation passed
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InternationalPhoneNumberInput(
          validator: _validatePhoneNumber,
          onInputChanged: (PhoneNumber number) {
            phoneNumber = number.phoneNumber ?? ''; // Store the phone number
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
          formatInput: false,
          keyboardType: TextInputType.phone,
          initialValue: PhoneNumber(isoCode: 'TN'),
          countries: const ['TN'],
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            setSelectorButtonAsPrefixIcon: true,
            leadingPadding:20
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isButtonDisabled
              ? null
              : () {
           _login(context);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            fixedSize: const Size(double.infinity, 55),
          ),
          child: isButtonDisabled
              ? const CircularProgressIndicator( // Display loading animation
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          )
              : const Text(
            "Login",
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        )
      ],
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/forgotpassword');
      },
      child: const Text("Forgot password?"),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text("Sign Up"),
        ),
      ],
    );
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

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isButtonDisabled = true; // Disable the button
      });

    // Get the phone number and password
    String password = passwordController.text;

    // Call your authentication service here
    final authService = AuthService();
      final response = await authService.login(phoneNumber, password);
      if(response != null) {
        // Handle the successful login response if needed
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user', json.encode(response["user"]));
        prefs.setString('token', response["access_token"]);
        if(response["user"]["firstName"] == null || response["user"]["lastName"] == null) {
          prefs.remove("isUpdate");
          Future.microtask(() {
            Navigator.pushNamed(context, '/finish');
          });
        } else {
          Future.microtask(() {
            Navigator.pushNamed(context, '/home');
          });
        }

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
