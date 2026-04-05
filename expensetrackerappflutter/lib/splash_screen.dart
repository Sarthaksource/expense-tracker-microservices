import 'dart:convert';

import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final BASE_URL = AppConfig.baseUrl;
  final storage = FlutterSecureStorage();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    isLoggedIn = await checkLoggedIn();
    if(isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    else {
      var refreshed = await getRefreshToken();
      isLoggedIn = refreshed;
      if(refreshed) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.purple.shade900,
          ),
        ),
      ),
    );
  }

  Future<bool> checkLoggedIn() async {
    String? accessToken = await storage.read(key: "accessToken");

    if (accessToken == null) {
      print("Missing token");
      return false;
    }
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/v1/ping"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $accessToken' 
      },
    );

    return (response.statusCode==200);
  }

  Future<bool> getRefreshToken() async {
    String? refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) {
      print("No refresh token found");
      return false;
    }
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/v1/refreshToken"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: jsonEncode({
        "token": refreshToken 
      })
    );
    if(response.statusCode==200) {
      var data = jsonDecode(response.body);
      await storage.write(key: "refreshToken", value: data['token']);
      await storage.write(key: "accessToken", value: data['accessToken']);
      await storage.write(key: "userId", value: data['userId']);

      return true;
    }
    return false;
  }
}