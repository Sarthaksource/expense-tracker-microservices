import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:expensetrackerappflutter/config/constants.dart';
import 'package:expensetrackerappflutter/form.dart';
import 'package:expensetrackerappflutter/login_screen.dart';
import 'package:expensetrackerappflutter/services/permission_service.dart';
import 'package:expensetrackerappflutter/utils/pref_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _profilePicUrl;
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionKey = await PrefUtils.getPrefKey("readMessagesPermission");
    final limitKey = await PrefUtils.getPrefKey("amountLimit");
    final currencyKey = await PrefUtils.getPrefKey("currencyCode");
    final profilePicKey = await PrefUtils.getPrefKey("profilePic");

    String storedPermission = prefs.getString(permissionKey) ?? "false";
    String? storedAmount = prefs.getString(limitKey);
    String? storedCurrencyCode = prefs.getString(currencyKey);
    String? storedProfilePic = prefs.getString(profilePicKey);

    bool isToggleOn = storedPermission == "true";

    if (isToggleOn) {
      var status = await Permission.sms.status;

      if (!status.isGranted) {
        isToggleOn = false;

        // keep storage in sync
        await prefs.setString("readMessagesPermission", "false");
      }
    }

    if (mounted) {
      setState(() {
        _initialReadPermission = isToggleOn;
        _initialAmount = storedAmount == "0" ? "" : storedAmount;
        _initialCurrencyCode = storedCurrencyCode;
        _profilePicUrl = storedProfilePic;
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
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _pickAndUploadProfilePic,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey.shade300,
                              child: ClipOval(
                                child: _isUploading
                                    ? _buildLoader()
                                    : (_profilePicUrl == null ||
                                          _profilePicUrl!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.grey.shade600,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: _profilePicUrl!,
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            _buildLoader(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                              ),
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
                            String permissionString =
                                (data['readMessagesPermission'] == true)
                                ? "true"
                                : "false";
                            if (permissionString == "true") {
                              bool granted = await requestSmsPermission();
                              if (!granted) {
                                permissionString = "false";
                                if (mounted) {
                                  _showErrorSnackBar("SMS permission denied");
                                }
                              }
                            }
                            data['readMessagesPermission'] = permissionString;
                            await setExpenseInfo(data);
                            bool didTurnOnSms =
                                !_initialReadPermission &&
                                permissionString == "true";
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
              ],
            ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(color: Colors.purple.shade900),
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

  Future<void> _pickAndUploadProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dygd5yjsc/image/upload'),
      );
      request.fields['upload_preset'] = 'profile_pic_upload_preset';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        String imageUrl = jsonData['secure_url'];
        final profilePicKey = await PrefUtils.getPrefKey("profilePic");

        setState(() => _profilePicUrl = imageUrl);
        prefs.setString(profilePicKey, imageUrl);
        await _syncUserToBackend(imageUrl);
      } else {
        _showErrorSnackBar("Cloud upload failed");
      }
    } catch (e) {
      _showErrorSnackBar("Image upload failed");
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _syncUserToBackend(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = await storage.read(key: "accessToken");
    String? userId = await storage.read(key: "userId");

    final firstNameKey = await PrefUtils.getPrefKey("firstName");
    final lastNameKey = await PrefUtils.getPrefKey("lastName");
    final emailKey = await PrefUtils.getPrefKey("email");
    final phoneKey = await PrefUtils.getPrefKey("phoneNumber");

    String firstName = prefs.getString(firstNameKey) ?? "";
    String lastName = prefs.getString(lastNameKey) ?? "";
    String email = prefs.getString(emailKey) ?? "";
    String phoneString = prefs.getString(phoneKey) ?? "";

    try {
      final response = await http.post(
        Uri.parse("$BASE_URL/user/v1/createUpdate"),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "user_id": userId,
          "first_name": firstName,
          "last_name": lastName,
          "phone_number": int.tryParse(phoneString) ?? 0,
          "email": email,
          "profile_picture": base64Image,
        }),
      );

      if (response.statusCode != 200 && mounted) {
        _showErrorSnackBar("Failed to sync profile picture to cloud.");
      }
    } catch (e) {
      print("Network error syncing image: $e");
    }
  }

  Future<void> setExpenseInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final limitKey = await PrefUtils.getPrefKey("amountLimit");
    final currencyKey = await PrefUtils.getPrefKey("currencyCode");

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
        await prefs.setString(limitKey, amount.toString());
        await prefs.setString(currencyKey, data['currencyCode']);

        final permissionKey = await PrefUtils.getPrefKey(
          "readMessagesPermission",
        );
        prefs.setString(
          permissionKey,
          data['readMessagesPermission'] ?? "false",
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
          _showErrorSnackBar(
            "Failed to save profile (${response.statusCode}).",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Network error. Please check your connection.");
      }
    }
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
