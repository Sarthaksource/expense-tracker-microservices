import 'dart:convert';

import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final BASE_URL = AppConfig.baseUrl;
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _username = "";
  String _password = "";
  String _phoneNumber = "";
  bool _isPasswordVisible = false;

  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Join ExpenseTracker",
                      style: TextStyle(
                        color: Colors.purple.shade900,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Sign Up to get started",
                      style: TextStyle(fontSize: 12, height: 1),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text("First Name"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your first name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => {_firstName = value},
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Last Name"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your last name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => {_lastName = value},
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Username"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your username",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => {_username = value},
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Email"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => {_email = value},
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Password"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          iconSize: 20,
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        _password = value;
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    onPressed: () async {
                      await signupRequest();
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      "Sign Up",
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(width: 1.5, color: Colors.purple.shade900),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    onPressed: () => {
                      Navigator.pushReplacementNamed(context, '/login'),
                    },
                    child: Text(
                      style: TextStyle(fontSize: 16, color: Colors.purple.shade900),
                      "Log In",
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signupRequest() async {
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/v1/signup"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode({
        "first_name": _firstName,
        "last_name": _lastName,
        "email": _email,
        "phone_number": _phoneNumber,
        "password": _password,
        "username": _username,
      }),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await storage.write(key: "refreshToken", value: data['token']);
      await storage.write(key: "accessToken", value: data['accessToken']);
      await storage.write(key: "userId", value: data['userId']);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print(response.statusCode);
    }
  }
}