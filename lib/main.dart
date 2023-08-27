import 'package:flutter/material.dart';
import 'package:shell_mobile/FinishSignup.dart';
import 'package:shell_mobile/Loading.dart';
import 'package:shell_mobile/OTPScreen.dart';
import 'package:shell_mobile/constants.dart';
import 'package:shell_mobile/home.dart';
import 'package:shell_mobile/login.dart'; // Import your login screen
import 'package:shell_mobile/signup.dart';

import 'forgotPassword.dart'; // Import your signup screen
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Shell mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => MyHomePage(title: 'Shell mobile'),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpScreen(),
        '/otp': (context) => OTPScreen(),
        '/forgotpassword': (context) => ForgotPasswordScreen(),
        '/finish': (context) => FinishSignup(),
        // Add more routes as needed
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          if(settings.name == '/') {
              return MaterialPageRoute(builder: (_) => Loading());
          }else if(settings.name == '/home') {
            return MaterialPageRoute(builder: (_) => HomeScreen());
          } else if (settings.name == '/login') {
            return MaterialPageRoute(builder: (_) => LoginPage());
          } else if (settings.name == '/signup') {
            return MaterialPageRoute(builder: (_) => SignUpScreen());
          } else if (settings.name == '/otp') {
            return MaterialPageRoute(builder: (_) => OTPScreen());
          } else if (settings.name == '/forgotpassword') {
            return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
          }else if (settings.name == '/finish') {
            return MaterialPageRoute(builder: (_) => FinishSignup());
          }
        },
      ),
    );
  }
}
