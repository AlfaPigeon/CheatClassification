import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/model/meeting_detail.dart';
import 'package:scmeet/model/user.dart';
import 'package:scmeet/screen/meeting_screen.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/custom_text.dart';
import 'package:scmeet/service/meeting_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? meetingId;
  TextEditingController controller = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late User user;
  String _timeString = "";
  @override
  void initState() {
    super.initState();
    Get.put(
        User(email: "kemalbayikk@gmail.com", name: "Kemal", surname: "Bayık"));
    user = Get.find();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getCurrentTime());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgColor,
      appBar: AppBar(
        backgroundColor: backgColor,
        elevation: 0,
        title: const CustomText(
          text: "Home",
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomText(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              text: "Welcome ${user.name} ${user.surname}",
              color: Colors.white),
          CustomText(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              text: _timeString,
              color: Colors.white),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              meetingCard(Icons.video_camera_back, thirdColor, "New Meeting",
                  "Set up new meeting"),
              const SizedBox(width: 30),
              meetingCard(Icons.add, secondaryColor, "Join Meeting",
                  "Join an existing meeting"),
            ],
          ),
        ],
      ),
    );
  }

  Widget meetingCard(
      IconData icon, Color color, String text, String secondText) {
    return GestureDetector(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 20),
              CustomText(
                  fontSize: 25,
                  fontWeight: FontWeight.normal,
                  text: text,
                  color: Colors.white),
              const SizedBox(height: 10),
              CustomText(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  text: secondText,
                  color: Colors.white),
            ],
          ),
        ),
      ),
      onTap: () {
        _displayTextInputDialog(
            context,
            text == "New Meeting"
                ? "Set a meeting name"
                : "Type an existing meeting name",
            text == "New Meeting" ? "Create Meeting" : "Join Meeting");
        //showTextInputDialog(context: context, textFields: dialogFields, title: text == "New Meeting" ? "Set a meeting name" : "Type a meeting name");
      },
    );
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, String title, String buttonTitle) async {
    String? valueText;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgColor,
            title: CustomText(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                text: title,
                color: Colors.white),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              controller: controller,
              decoration: InputDecoration(hoverColor: Colors.white),
              style :  GoogleFonts.montserrat(color: Colors.white),
            ),
            actions: <Widget>[
              CustomButton(
                  text: buttonTitle,
                  onTap: () {
                    setState(() {
                      meetingId = valueText;
                      Navigator.pop(context);
                      if (title == "Set a meeting name") {
                        startMeetingFunction();
                      } else {
                        joinMeetingFunction();
                      }
                    });
                  },
                  width: MediaQuery.of(context).size.width / 2)
            ],
          );
        });
  }

  void joinMeetingFunction() async {
    final meetingId = controller.text;
    validateMeeting(meetingId);
  }

  void startMeetingFunction() async {
    var response = await startMeeting();
    final body = json.decode(response.body);
    final meetingId = body['meetingId'];
    validateMeeting(meetingId);
  }

  void validateMeeting(String meetingId) async {
    try {
      http.Response response = await joinMeeting(meetingId);
      var data = json.decode(response.body);
      //final meetingDetail = MeetingDetail.fromJson(data);
      join(data);
    } catch (err) {
      const snackbar = SnackBar(content: Text('Invalid MeetingId'));
      // ignore: deprecated_member_use
      scaffoldKey.currentState?.showSnackBar(snackbar);
    }
  }

  void join(var data) {
    final meetingDetail = MeetingDetail.fromJson(data);
    Get.to(MeetingScreen(
        meetingId: meetingDetail.id,
        name: "${user.name} ${user.surname}",
        meetingDetail: meetingDetail));
  }

  _getCurrentTime() {
    setState(() {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
      _timeString = formattedDate;
    });
  }
}
