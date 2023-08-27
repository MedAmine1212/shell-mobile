import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> user;
  bool isLoading = true;

  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      setState(() {
        isLoading = false;
        user = jsonDecode(userData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: CircleAvatar(
                  backgroundColor: secondary,
                  radius: 60,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'User details',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              if (user != null) ...[
                ListTile(
                  leading: const Icon(
                    Icons.person_sharp,
                  ),
                  title: Text(
                    ' ${user['firstName']} ${user['lastName']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.phone,
                  ),
                  title: Text(
                    '${user['fullPhoneNumber']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.barcode_reader,
                    color: secondary,
                  ),
                  title: Text(
                    'Barcode: ${user['barCode']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("isUpdate", "true");
                      Future.microtask(() {
                        Navigator.pushNamed(context, '/finish');
                      });
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      Future.microtask(() {
                        Navigator.pushNamed(context, '/login');
                      }); // R
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String text, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}
