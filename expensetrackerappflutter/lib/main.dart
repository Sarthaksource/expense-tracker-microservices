import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:expensetrackerappflutter/home_screen.dart';
import 'package:expensetrackerappflutter/login_screen.dart';
import 'package:expensetrackerappflutter/signup_screen.dart';
import 'package:expensetrackerappflutter/splash_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(ExpenseTracker());
}

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        '/': (context) => SplashScreen(),
        "/login" : (context) => LoginScreen(),
        "/signup" : (context) => SignupScreen(),
        "/home" : (context) => HomeScreen(),
      },      
    );
  }
}