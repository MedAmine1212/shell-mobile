import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'dart:convert';

import '../main.dart';
class AuthService {
  Future<Map<String, dynamic>?> login(String phoneNumber, String password) async {
    final url = Uri.parse('$apiBaseUrl/authenticate');
    final response = await http.post(url, body: {
      'phoneNumber': phoneNumber,
      'password': password,
    });
    return handleResponse(response);
  }

  Future<Map<String, dynamic>?> resetPassword(String phoneNumber, bool isValidation, String newPhone) async {
    final url = Uri.parse('$apiBaseUrl/resetPassword');

    final response = await http.post(url, body: {
      'phoneNumber': phoneNumber,
      'isValidation': isValidation.toString(),
      'newPhone': newPhone,
    });
    return handleResponse(response);
  }

  Future<Map<String, dynamic>?> signup(String phone, String prefix, String firstName, String lastName) async {
    final url = Uri.parse('$apiBaseWebUrl/addClient');
    final response = await http.post(url, body: {
      'phone': phone,
      'prefix': prefix,
      'firstName': firstName,
      'lastName': lastName,
    });
    return handleResponse(response);
  }

  Future<Map<String, dynamic>?> updateUser(Map<String, String> payload) async {
    final url = Uri.parse('$apiBaseUrl/user/update/-1');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if(token == null) {
      fatalError();
      return null;
    }
    final bearerToken = "Bearer $token";
    Map<String, String> headers = {
      'Authorization': bearerToken,
    };
    final response = await http.put(url, headers: headers, body: payload);
    return handleResponse(response);
  }

  void fatalError() {
    Fluttertoast.showToast(
      msg: "You are not logged in",
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: secondary,
      textColor: Colors.white,
      fontSize: 16,
      webShowClose: true,
    );
    Future.microtask(() {
      navigatorKey.currentState?.pushNamed('/login');
    });
  }

  Map<String, dynamic>? handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String responseBody = response.body;
    print(responseBody);
    final Map<String, dynamic> jsonRes = json.decode(responseBody);
    if (statusCode != 200) {
      Fluttertoast.showToast(
        msg: jsonRes['error'],
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: secondary,
        textColor: Colors.white,
        fontSize: 16,
        webShowClose: true,
      );
      return null;
    } else {
      return jsonRes;
    }
  }

  Future<Map<String, dynamic>?> validateUser(String initialPhone, String password, String phoneNumber) async {
    final url = Uri.parse('$apiBaseUrl/validateUser');
    final response = await http.post(url, body: {
      'phoneNumber': initialPhone,
      'password': password,
      'newPhone': phoneNumber,
    });
    return handleResponse(response);
  }

  Future<Map<String, dynamic>?> validateAndUpdate(String initialPhone, String password, String newUserData) async{
      final url = Uri.parse('$apiBaseUrl/validateAndUpdate');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if(token == null) {
        fatalError();
        return null;
      }
      final bearerToken = "Bearer $token";
      Map<String, String> headers = {
        'Authorization': bearerToken,
      };

      final response = await http.post(url, headers: headers, body: {
        'phoneNumber': initialPhone,
        'code': password,
        'newUserData': newUserData,
      });
      return handleResponse(response);
  }
}