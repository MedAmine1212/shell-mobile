import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'dart:convert';

import '../main.dart';
class ConsultationsService {
  final baseUrl = '$apiBaseUrl/consultation';
  Future<Map<String, dynamic>?> getConsultationsHistory() async {
    final url = Uri.parse('$baseUrl/history');

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
    final response = await http.get(url, headers: headers);
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
}