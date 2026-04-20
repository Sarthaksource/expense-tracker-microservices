import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrefUtils {
  static const storage = FlutterSecureStorage();

  static Future<String> getPrefKey(String baseKey) async {
    String? userId = await storage.read(key: "userId");
    return "${userId ?? 'guest'}_$baseKey";
  }
}