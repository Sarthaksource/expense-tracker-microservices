import 'package:permission_handler/permission_handler.dart';

Future<bool> requestSmsPermission() async {
  var permission = await Permission.sms.request();
  return permission.isGranted;
}