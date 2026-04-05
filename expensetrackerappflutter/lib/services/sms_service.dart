import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

Future<List<SmsMessage>> readSMS() async {
  SmsQuery query = SmsQuery();
  List<SmsMessage> messages = await query.getAllSms;

  return messages;
  // for (var msg in messages) {
  //   print('From: ${msg.sender}');
  //   print('Body: ${msg.body}');
  //   print('Date: ${msg.date}');
  // }
}
