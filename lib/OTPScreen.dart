import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_mobile/constants.dart';
import 'package:shell_mobile/services/auth_service.dart';
import 'dart:async';
class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}
  class _OTPScreenState extends State<OTPScreen> {
    bool isButtonDisabled = false;
    bool isLoading = true;
    String password = '';
    bool isUpdate = false;
    bool isValidation = false;
    String headerText = "Verify phone number"; // Initialize with a default value
    String titleText = "Verify phone number"; // Initialize with a default value
    String headerSubText = "Please enter the password sent to your phone number."; // Initialize with a default value
    String resendText = "Didn't receive a password ?"; // Initialize with a default value
    String snackBarMessage = "A new password has been sent to this number"; // Initialize with a default value
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    late SharedPreferences prefs;
    Timer? _timer;
    Future<void> _setHeaderText() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if(prefs.getString('newPhoneNumber') != null) {
          titleText = "Verify your new phone number";
          headerText = "Verify phone number";
          headerSubText = "Please enter the password sent to your new phone number.";
          resendText = "Didn't receive a code ?";
          snackBarMessage = "A new code has been sent to this number";
          isValidation = true;
        } else {
          headerText = prefs.getString('isReset') != null ? "Recover account" : prefs.getString('isUpdate') != null ? "Let's verify it's you" : "Verify phone number";
          if(headerText == "Let's verify it's you") {
            titleText = "Security check";
          } else {
            titleText = headerText;
          }
          headerSubText = prefs.getString('isUpdate') != null ? "Enter your password" : "Please enter the password sent to your phone number.";
          isUpdate = prefs.getString('isUpdate') != null;
        }
        isLoading = false;
      });
    }
    @override
    void initState() {
      super.initState();
      _initSharedPreferences();
      _setHeaderText();
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: secondary), // Show loading indicator
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: Text(headerText),
      ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24,0,24,0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        OtpTextField(
                          numberOfFields: 6,
                          borderColor: primary,
                          focusedBorderColor: primary,
                          showFieldAsBox: false,
                          borderWidth: 4.0,
                          onCodeChanged: (String code) {
                            password = code;
                          },
                          onSubmit: (String code) {
                            password = code;
                            _confirmSignup(context);
                          },
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        if (!isUpdate) _resendCode(context),
                        _cancelSignUp(context),
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


    Widget _resendCode(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(resendText),
        TextButton(
            onPressed: () {
              bool isResendEnabled = prefs.getBool('isResendEnabled') ?? true;
              if (isResendEnabled) {
                _resetPassword(context);
              } else {
                Fluttertoast.showToast(
                  msg: "You have requested to many codes, try later",
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
            child: const Text("Resend")),
      ],
    );
  }
  Widget _cancelSignUp(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              if(isUpdate || isValidation) {
                prefs.remove("updateUser");
                prefs.remove("phoneNumber");
                prefs.remove("newPhoneNumber");
                prefs.remove("isUpdate");
                Future.microtask(() {
                  Navigator.pushNamed(context, '/home');
                });
              } else {
                prefs.clear();
                Future.microtask(() {
                  Navigator.pushNamed(context, '/login');
                });
              }
            },
            child: const Text("Cancel")),
      ],
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
      setState(() {
        isButtonDisabled = true;
        isLoading = true;// Disable the button
      });
      final prefs = await SharedPreferences.getInstance();
      String? phoneNumber = prefs.getString('phoneNumber');
      if (phoneNumber != null) {
        _startTimer();
        final authService = AuthService();
        String? newPhone = "";
        if(isValidation) {
          phoneNumber = jsonDecode(prefs.getString("user")??"")["fullPhoneNumber"];
          newPhone = prefs.getString('phoneNumber');
        }
        final response = await authService.resetPassword(phoneNumber!, isValidation, newPhone!);
        if (response != null) {
          Fluttertoast.showToast(
            msg: snackBarMessage,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 5,
            gravity: ToastGravity.SNACKBAR,
            textColor: Colors.white,
            fontSize: 16,
            webShowClose: true,
          );
        } else {
          fireError();
        }
        setState(() {
          isButtonDisabled = false;
          isLoading = false; // Re-enable the button
        });
      } else {
        prefs.clear();
        fireError();
        Future.microtask(() {
          Navigator.pushNamed(context, '/login');
        }); // Redirect to login screen
      }
  }
    Future<void> _confirmSignup(BuildContext context) async {
      if (_formKey.currentState!.validate() && password.length == 6) {
        setState(() {
          isButtonDisabled = true; // Disable the button
          isLoading = true;
        });

        final prefs = await SharedPreferences.getInstance();
        final phoneNumber = prefs.getString('phoneNumber');
        if (phoneNumber != null) {
          final authService = AuthService();
          if(isValidation) {

            String initialPhone = jsonDecode(prefs.getString('user')?? '')["fullPhoneNumber"];
            final response = await authService.validateAndUpdate(initialPhone, password, prefs.getString("updateUser")??'');
            if(response != null) {
              // Handle the successful login response if needed
              prefs.setString('user', json.encode(response["user"]));
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
              Future.microtask(() {
                Navigator.pushNamed(context, '/home');
              });
            } else {
              setState(() {
                isButtonDisabled = false; // Re-enable the button
                isLoading = false;
              });
            }
          } else if(isUpdate) {
            String initialPhone = jsonDecode(prefs.getString('user')?? '')["fullPhoneNumber"];
            final response = await authService.validateUser(initialPhone, password, phoneNumber);
            if (response != null) {
              // Handle the successful login response if needed
              prefs.setString('newPhoneNumber', "true");
              Future.microtask(() {
                Navigator.pushNamed(context, '/otp');
              });
            } else {
              setState(() {
                isButtonDisabled = false; // Re-enable the button
                isLoading = false;
                Navigator.pushNamed(context, '/finish');
              });
            }
          } else {
            final response = await authService.login(phoneNumber, password);
            if (response != null) {
              // Handle the successful login response if needed
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();
              prefs.setString('user', json.encode(response["user"]));
              prefs.setString('token', response["access_token"]);
              Future.microtask(() {
                Navigator.pushNamed(context, '/home');
              });
            } else {
              setState(() {
                isButtonDisabled = false; // Re-enable the button
                isLoading = false;
              });
            }
          }
        } else {
          fireError();
          if(isUpdate || isValidation) {
            prefs.remove("updateUser");
            prefs.remove("phoneNumber");
            prefs.remove("newPhoneNumber");
            prefs.remove("isUpdate");
            prefs.setInt("page", 2);
            Future.microtask(() {
              Navigator.pushNamed(context, '/home');
            });
          } else {
            prefs.clear();
            Future.microtask(() {
              Navigator.pushNamed(context, '/login');
            });
          }
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
    void fireError() {
      Fluttertoast.showToast(
        msg: "Error, try again",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: secondary,
        textColor: Colors.white,
        fontSize: 16,
        webShowClose: true,
      );
    }
    Widget _header(context) {
      return Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            'assets/logo.png', // Replace with the path to your logo asset
            width: 150, // Adjust the width as needed
            height: 150, // Adjust the height as needed
          ),
          Text(
            titleText,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, // Center-align the text
          ),
          Text(
            headerSubText,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center, // Center-align the text
          ),
        ],
      );
    }
}
