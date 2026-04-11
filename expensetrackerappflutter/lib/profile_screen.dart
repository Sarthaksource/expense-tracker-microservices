import 'dart:convert';

import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:expensetrackerappflutter/config/constants.dart';
import 'package:expensetrackerappflutter/form.dart';
import 'package:expensetrackerappflutter/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BASE_URL = AppConfig.baseUrl;
  final storage = FlutterSecureStorage();

  bool _isLoading = true;
  bool _initialReadPermission = false;
  String? _initialAmount;
  String? _initialCurrencyCode;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    String? storedPermission = await storage.read(key: "readMessagesPermission");
    String? storedAmount = await storage.read(key: "amountLimit");
    String? storedCurrencyCode = await storage.read(key: "currencyCode");

    bool isToggleOn = storedPermission == 'true';
    if (isToggleOn) {
      var status = await Permission.sms.status;
      if (!status.isGranted) {
        isToggleOn = false;
        await storage.write(key: "readMessagesPermission", value: "false");
      }
    }
    if (mounted) {
      setState(() {
        _initialReadPermission = isToggleOn;
        _initialAmount = storedAmount == "0" ? "" : storedAmount;
        _initialCurrencyCode = storedCurrencyCode; 
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Profile"),
        backgroundColor: Colors.purple.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(30),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://picsum.photos/200",
                          ),
                          radius: 70,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ProfileForm(
                      currencyOptions: getCurrencyCodes(),
                      initialReadPermission: _initialReadPermission,
                      initialAmount: _initialAmount,
                      initialCurrencyCode: _initialCurrencyCode,
                      onSubmit: (data) async {
                        await setExpenseInfo(data);                        
                        bool newPermission = data['readMessagesPermission'] == true;                        
                        bool didTurnOnSms = !_initialReadPermission && newPermission;                        
                        Navigator.pop(context, didTurnOnSms);
                      },
                    ),

                    SizedBox(height: 15),
                    TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(
                          width: 1.5,
                          color: Colors.purple.shade900,
                        ),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () => {logoutUser()},
                      child: Text(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple.shade900,
                        ),
                        "Log Out",
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void logoutUser() async {
    await storage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> setExpenseInfo(Map<String, dynamic> data) async {
    String? accessToken = await storage.read(key: "accessToken");

    final String amountString = data["amountLimit"]?.toString() ?? "";
    final double? amount = double.tryParse(amountString);

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/expense/v1/addExpenseInfo"),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "amount_limit": data['amountLimit'],
          "currency": data['currencyCode'],
        }),
      );

      if (response.statusCode == 200) {
        await storage.write(
          key: "amountLimit",
          value: amount == null ? "0" : amountString,
        );
        await storage.write(
          key: "currencyCode",
          value: data['currencyCode'],
        );
        await storage.write(
          key: "readMessagesPermission",
          value: data['readMessagesPermission'].toString(),
        );

      } else if (response.statusCode == 401) {
        bool refreshed = await getRefreshToken();
        if (refreshed) {
          return await setExpenseInfo(data);
        } else {
          logoutUser(); 
        }
      } else {
        if (mounted) {
          _showErrorSnackBar("Failed to save profile (${response.statusCode}).");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Network error. Please check your connection.");
      }
    }
  }

  // --- Helper method for a clean, modern SnackBar ---
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<bool> getRefreshToken() async {
    String? refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) {
      print("getRefreshToken: No refresh token found");
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/auth/v1/refreshToken"),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({"token": refreshToken}),
      );
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await storage.write(key: "refreshToken", value: data['token']);
        await storage.write(key: "accessToken", value: data['accessToken']);
        await storage.write(key: "userId", value: data['userId'].toString());
        return true;
      }
    } catch (e) {
      print("Refresh token network error: $e");
    }
    return false;
  }
}
