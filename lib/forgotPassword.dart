import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_mobile/constants.dart';
import 'package:shell_mobile/services/auth_service.dart';
import 'dart:async';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isButtonDisabled = false;
  String phoneNumber = '';
  late SharedPreferences prefs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _startTimer() {
    prefs.setBool('isResendEnabled', false);
    _timer = Timer(const Duration(minutes: 3), () {
      prefs.setBool('isResendEnabled', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: const Text("Account recovery"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(context),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      InternationalPhoneNumberInput(
                        validator: _validatePhoneNumber,
                        onInputChanged: (PhoneNumber number) {
                          phoneNumber = number.phoneNumber ?? ''; // Store the phone number
                        },
                        inputDecoration: InputDecoration(
                          hintText: "Phone number",
                          fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          filled: true,
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
                          showFlags: true,
                          leadingPadding: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonDisabled
                            ? null
                            : () {
                          bool isResendEnabled = prefs.getBool('isResendEnabled') ?? true;
                          if (isResendEnabled) {
                            _resetPassword(context);
                          } else {
                            Fluttertoast.showToast(
                              msg: "You have requested too many codes, try later",
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 2,
                              gravity: ToastGravity.SNACKBAR,
                              backgroundColor: secondary,
                              textColor: Colors.white,
                              fontSize: 16,
                              webShowClose: true,
                            );
                          }
                        },
                        child: isButtonDisabled
                            ? const CircularProgressIndicator( // Display loading animation
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        )
                            : const Text(
                          "Send new password",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      _cancelReset(context),
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isButtonDisabled = true;
      });
      final authService = AuthService();
      final response = await authService.resetPassword(phoneNumber, false, "");
      if (response != null) {
        _startTimer();
        Fluttertoast.showToast(
          msg: "A new password has been sent to this number",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 5,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: primary,
          textColor: Colors.white,
          fontSize: 16,
          webShowClose: true,
        );
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('phoneNumber', phoneNumber);
        prefs.setString('isReset', "true");
        Future.microtask(() {
          Navigator.pushNamed(context, '/otp');
        });
      } else {
        setState(() {
          isButtonDisabled = false;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Phone number required",
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

  Widget _cancelReset(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  Widget _header(context) {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 150,
          height: 150,
        ),
        const Text(
          "Reset password",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text("Type in your phone number"),
      ],
    );
  }
}
