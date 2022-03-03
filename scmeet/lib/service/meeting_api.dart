import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scmeet/model/user.dart';

// ignore: constant_identifier_names
const String MEETING_API_URL = 'http://3.65.205.17:8081/meeting';

Future<http.Response> startMeeting() async {
  User user = Get.find();
  var userId = user.email; // WILL CHANGE
  var client = http.Client();
  var response =
      await client.post(Uri.parse('$MEETING_API_URL/start'), body: {'name':"hostName",'userId': userId});
  return response;
}

Future<http.Response> joinMeeting(String meetingId) async {
  var response = await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetingId'));
  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }
  throw UnsupportedError('Not a valid meeting');
}
