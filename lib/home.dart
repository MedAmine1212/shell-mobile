import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_mobile/Bookings.dart';
import 'package:shell_mobile/Profile.dart';
import 'package:shell_mobile/Vehicles.dart';
import 'package:shell_mobile/constants.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;
  late SharedPreferences prefs;
  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if(prefs.getInt("page") != null) {
        _selectedIndex = (prefs.getInt("page") ?? 0);
        prefs.remove("page");
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }
  static const TextStyle optionStyle =
  TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    VehiclesPage(),
    BookingsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: const Text("Shell mobile"),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Vehicle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: secondary,
        onTap: _onItemTapped,
      ),
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
    } else if (user == null && token == null) {
      Future.microtask(() {
        Navigator.pushNamed(context, '/login');
      }); // Redirect to login screen
    } else if(jsonDecode(user!)["firstName"] == null || jsonDecode(user)["lastName"] == null) {
        Future.microtask(() {
        Navigator.pushNamed(context, '/finish');
        }); // Redirect to login screen
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
