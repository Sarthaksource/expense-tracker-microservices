import 'dart:convert';

import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BASE_URL = AppConfig.baseUrl;
  String _username = "";
  String _password = "";
  bool _isPasswordVisible = false;
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.5),
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          Text("E", style: TextStyle(fontSize: 60)),
                          Text("T", style: TextStyle(fontSize: 60)),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "ExpenseTracker",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Colors.purple.shade900,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Log In to continue",
                      style: TextStyle(fontSize: 12, height: 1),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text("Username"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter username",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => {_username = value},
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Password"),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Enter password",
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
                      await loginRequest();
                    },
                    child: Text(
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      "Log In",
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
                      Navigator.pushReplacementNamed(context, '/signup'),
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple.shade900,
                      ),
                      "Sign Up",
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

  Future<void> loginRequest() async {
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/v1/login"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode({"username": _username, "password": _password}),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await storage.write(key: "refreshToken", value: data['token']);
      await storage.write(key: "accessToken", value: data['accessToken']);
      await storage.write(key: "userId", value: data['userId']);

      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}