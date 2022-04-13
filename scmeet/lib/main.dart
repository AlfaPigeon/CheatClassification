import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scmeet/controller/meeting_controller.dart';
import 'package:scmeet/model/user.dart';
import 'package:scmeet/screen/authentication_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(User());
    Get.put(MeetingController(), permanent: true);
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationScreen(),
    );
  }
}

