import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/widget/custom_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              meetingCard(Icons.video_camera_back, thirdColor, "New Meeting", "Set up new meeting"),
              const SizedBox(width: 30),
              meetingCard(Icons.add, secondaryColor, "Join Meeting", "Join an existing meeting"),
            ],
          ),
        ],
      ),
    );
  }


  Widget meetingCard(IconData icon, Color color, String text, String secondText) {
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
              CustomText(fontSize: 25, fontWeight: FontWeight.normal, text: text, color: Colors.white),
              const SizedBox(height: 10),
              CustomText(fontSize: 13, fontWeight: FontWeight.w300, text: secondText, color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }
}