import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return SafeArea(
      child: Scaffold(
        body: Center( // Center the entire content vertically and horizontally
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center children vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center children horizontally
                children: [
                  Image.asset(
                    'assets/logo.gif', // Replace with the path to your logo asset
                    width: 400, // Adjust the width as needed
                    height: 400, // Adjust the height as needed
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _checkLoginStatus(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1)); // Delay for 1 second
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    final token = prefs.getString('token');
    final waitingForPassword = prefs.getString('waitingForPassword');
    if (waitingForPassword != null) {
      Future.microtask(() {
        Navigator.pushNamed(context, '/otp');
      }); // Redirect to OTP screen
    } else if (user == null && token == null) {
      Future.microtask(() {
        Navigator.pushNamed(context, '/login');
      }); // Redirect to login screen
    } else if(jsonDecode(user!)["firstName"] == null || jsonDecode(user)["lastName"] == null) {
      Future.microtask(() {
        Navigator.pushNamed(context, '/finish');
      }); // Redirect to login screen
    } else {
      Future.microtask(() {
        Navigator.pushNamed(context, '/home');
      }); // Redirect to home screen
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Future.microtask(() {
      Navigator.pushNamed(context, '/');
    });
  }
}
