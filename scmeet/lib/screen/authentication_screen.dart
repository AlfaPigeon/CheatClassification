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
  TextEditingController hostKeyController = TextEditingController();

  bool isLoading = false; 
  // ignore: prefer_typing_uninitialized_variables
  var connection;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return isLoading
        ? Container(
          color: secondaryColor,
          child: const Center(
            child: SizedBox( 
              width: 200 , 
              height: 200, 
              child: CircularProgressIndicator(
                strokeWidth: 15.0,
                backgroundColor: Color.fromARGB(255, 51, 84, 116),
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(235, 200, 163, 112))
              )
            )
          ),
        )
        : Scaffold(
            body: Container(
              width: double.infinity,
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
            surnameController: surnameController,
            hostKeyController: hostKeyController,),
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
              color:Color.fromARGB(235, 200, 163, 112),
            ),
            //SizedBox(height: 10),
            AuthenticationForm(
                emailController: emailController,
                passwordController: passwordController,
                nameController: nameController,
                surnameController: surnameController,
                hostKeyController: hostKeyController,),
          ],
        ),
      ),
    );
  }
}
