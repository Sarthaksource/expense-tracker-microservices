import 'dart:convert';

import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:expensetrackerappflutter/config/constants.dart';
import 'package:expensetrackerappflutter/form.dart';
import 'package:expensetrackerappflutter/login_screen.dart';
import 'package:expensetrackerappflutter/models/field_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BASE_URL = AppConfig.baseUrl;
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Profile"),
        backgroundColor: Colors.purple.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Align(
          alignment: AlignmentGeometry.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    backgroundImage: NetworkImage("https://picsum.photos/200"),
                    radius: 70,
                  ),
                ),
              ),
              SizedBox(height: 20),
              DynamicForm(
                fields: {
                  "amountLimit": FieldConfig(
                    label: "Amount Limit",
                    type: "number",
                  ),
                  "currency": FieldConfig(
                    label: "Currency",
                    type: "dropdown",
                    options: getCurrencyCodes(),
                  ),
                },
                // fields: {"amountLimit": "Amount Limit", "currency": "Currency"},
                onSubmit: (data) async {
                  await setExpenseInfo(data);
                  Navigator.pop(context, data);
                },
              ),

              SizedBox(height: 15),
              TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(width: 1.5, color: Colors.purple.shade900),
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                onPressed: () => {logoutUser()},
                child: Text(
                  style: TextStyle(fontSize: 16, color: Colors.purple.shade900),
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

    final double? amount = double.tryParse(
      data["amountLimit"]?.toString() ?? "",
    );

    final response = await http.post(
      Uri.parse("$BASE_URL/expense/v1/addExpenseInfo"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "amount_limit": data['amountLimit'],
        "currency": data['currency'],
      }),
    );

    if (response.statusCode == 200) {
      if (amount == null) {
        await storage.write(key: "amountLimit", value: "0");
      } else {
        await storage.write(
          key: "amountLimit",
          value: data['amountLimit'].toString(),
        );
      }
      final currencySymbol = getCurrencySymbol(data['currency']);
      await storage.write(key: "currency", value: currencySymbol);
    }
  }
}
