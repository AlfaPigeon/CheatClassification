import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/widget/custom_text.dart';
import 'package:scmeet/widget/custom_text_input.dart';
import 'package:scmeet/widget/responsive.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgColor,
      body: Responsive.isDesktop(context) ? desktopScreen(_size) : mobileScreen(),
    );
  }

  Widget desktopScreen(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomText(
          fontSize: size.width / 25,
          fontWeight: FontWeight.bold,
          text: "Welcome to SC Meet",
          color: Colors.white,
        ),
        SizedBox(width: size.width / 10),
        Center(
          child: Container(
            //margin: EdgeInsets.all(20),
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: size.height / 8),
              child: Column(
                children: [
                  CustomTextInput(
                    controller: emailController,
                    icon: Icons.email_rounded,
                    obscure: false,
                    type: TextInputType.text,
                    hint: "Type your email",
                  ),
                  SizedBox(height: 20),
                  CustomTextInput(
                    controller: passwordController,
                    icon: Icons.security,
                    obscure: true,
                    type: TextInputType.text,
                    hint: "Type your password",
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget mobileScreen() {
    return Row(
      children: [],
    );
  }
}
