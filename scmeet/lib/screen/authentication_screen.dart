import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/widget/authentication_form.dart';
import 'package:scmeet/widget/custom_text.dart';
import 'package:scmeet/widget/responsive.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/background5.png'),
          ),
        ),
        child: Responsive.isDesktop(context)
            ? desktopScreen(_size)
            : mobileScreen(_size),
      ),
    );
  }

  Widget desktopScreen(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomText(
          fontSize: size.width / 30,
          fontWeight: FontWeight.bold,
          text: "Welcome to Online \nExam Inspection Platform",
          color: fifthcolor,
        ),
        SizedBox(width: size.width / 10),
        AuthenticationForm(
            emailController: emailController,
            passwordController: passwordController,
            nameController: nameController,
            surnameController: surnameController),
      ],
    );
  }

  Widget mobileScreen(Size size) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              fontSize: size.width / 15,
              fontWeight: FontWeight.bold,
              text: "Welcome to Online \nExam Inspection Platform",
              color: Colors.white,
            ),
            //SizedBox(height: 10),
            AuthenticationForm(
                emailController: emailController,
                passwordController: passwordController,
                nameController: nameController,
                surnameController: surnameController),
          ],
        ),
      ),
    );
  }
}
