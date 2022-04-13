import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scmeet/constants.dart';
import 'package:scmeet/controller/meeting_controller.dart';
import 'package:scmeet/model/meeting_detail.dart';
import 'package:scmeet/model/user.dart';
import 'package:scmeet/screen/authentication_screen.dart';
import 'package:scmeet/screen/meeting_screen.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/custom_text.dart';
import 'package:scmeet/service/meeting_api.dart';
import 'package:scmeet/widget/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? meetingId;
  TextEditingController controller = TextEditingController();
  User user = Get.find();
  MeetingController meetingController = Get.find();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  void getAllUsers() async {
    var request = http
        .get(Uri.parse('http://kemalbayik.com/get_all_users.php'))
        .then((response) {
      final data = jsonDecode(response.body);
      print(data);
      List<User> tempUsers = [];
      if (data["success"] != null) {
        for(int i = 0; i < data["id"].length; i++) {
          print(data["name"][i]);
          User tempUser = User();
          tempUser.setUserData(data["email"][i],data["name"][i], data["surname"][i], data["id"][i],data["is_host"][i] ,"Default");
          tempUsers.add(tempUser);
        }
      } 

      meetingController.allUsers = tempUsers;
      print("all users ========> ${meetingController.allUsers[1].name}");
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: fourthColor,
      body: Stack(children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background6.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user.isHost == "1"
                ? CustomText(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    text: user.company.toString(),
                    color: Colors.white)
                : const Text(""),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    text: "WELCOME ${user.name} ${user.surname}\n",
                    color: Colors.white),
                const SizedBox(width: 50),
                CustomButton(
                    text: "Log Out",
                    onTap: () {
                      Get.off(const AuthenticationScreen());
                    },
                    width: MediaQuery.of(context).size.width / 10)
              ],
            ),
            Responsive.isDesktop(context)
                ? desktopScreen(_size)
                : mobileScreen(_size),
          ],
        ),
      ]),
    );
  }

  desktopScreen(Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        user.isHost == "1"
            ? meetingCard(Icons.video_camera_back, fifthcolor, "New Exam Room",
                "Set up new exam room")
            : const SizedBox(),
        const SizedBox(width: 30),
        meetingCard(Icons.add, secondaryColor, "Join Exam Room",
            "Join an existing exam room"),
      ],
    );
  }

  mobileScreen(Size size) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          user.isHost == "1"
              ? meetingCard(Icons.video_camera_back, fifthcolor,
                  "New Exam Room", "Set up new exam room")
              : const SizedBox(),
          const SizedBox(height: 30),
          meetingCard(Icons.add, secondaryColor, "Join Exam Room",
              "Join an existing exam room"),
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
                  color: Colors.white)
            ],
          ),
        ),
      ),
      onTap: () {
        _displayTextInputDialog(
            context,
            text == "New Exam Room"
                ? "Set up new exam room"
                : "Type an existing exam room ID",
            text == "New Exam Room" ? "Create Meeting" : "Join Meeting");
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
            title: Text(title),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              controller: controller,
              //decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              CustomButton(
                  text: buttonTitle,
                  onTap: () {
                    setState(() {
                      meetingId = valueText;
                      Navigator.pop(context);
                      if (title == "Set up new exam room") {
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
}
