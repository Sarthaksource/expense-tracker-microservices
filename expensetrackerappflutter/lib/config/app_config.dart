// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AppConfig {
//   static String baseUrl = "";

//   static Future<void> load() async {
//     final res = await http.get(
//       Uri.parse("https://raw.githubusercontent.com/Sarthaksource/ExpenseTrackerBackend/refs/heads/main/config.json"),
//     );

//     final data = json.decode(res.body);
//     baseUrl = data['BASE_URL'];
//   }
// }


class AppConfig {
  static String baseUrl = "";

  static Future<void> load() async {
    baseUrl = "http://10.0.2.2:8000";
  }
}