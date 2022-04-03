import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/controller/authentication_controller.dart';
import 'package:scmeet/model/user.dart';
import 'package:scmeet/screen/home_screen.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/custom_text.dart';
import 'package:scmeet/widget/custom_text_input.dart';
import 'package:http/http.dart' as http;

class AuthenticationForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController surnameController;

  const AuthenticationForm(
      {Key? key,
      required this.emailController,
      required this.passwordController,
      required this.nameController,
      required this.surnameController})
      : super(key: key);

  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  final authController = Get.put(AuthenticationController());
  bool isLoading = false;
  User user = Get.find();

  signIn() async {
    setState(() {
      isLoading = true;
    });
    var data;
    PostgreSQLConnection connection;
    await http.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAZfm-YeX--7DV2Ues9A6tR8ljtj5AGYNc"),
        body: {
          "email": widget.emailController.text,
          "password": widget.passwordController.text,
          "returnSecureToken": "true"
        }).then((response) {
      data = jsonDecode(response.body);
    });
    print("data ${data}");

    if (data["localId"] != null) {
      connection = PostgreSQLConnection(
          "manny.db.elephantsql.com",
          5432,
          "yudejpbv",
          username: "yudejpbv",
          password: "8gCcTUmsAZsaYCO4igdMjHJtYaFyrBSK",
          timeoutInSeconds: 20);
      await connection.open();
      List<List<dynamic>> results = await connection.query(
          "SELECT * FROM users WHERE id = '${data["localId"]}'");

      print(results[0][1]);
      user.setUserData(widget.emailController.text, results[0][1], results[0][2], data["localId"]); 
      Get.to(const HomeScreen());
    } else {
      Get.defaultDialog(
            title: data["error"]["message"],
            middleText: "Please enter valid credientials");
    }

    setState(() {
      isLoading = false;
    });
  }

  signUp() async {
    PostgreSQLConnection connection;

    setState(() {
      isLoading = true;
    });

    var data;
    await http.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAZfm-YeX--7DV2Ues9A6tR8ljtj5AGYNc"),
        body: {
          "email": widget.emailController.text,
          "password": widget.passwordController.text,
          "returnSecureToken": "true"
        }).then((response) {
      data = jsonDecode(response.body);
    });
    print("data ${data}");

    if (data["localId"] != null) {
      connection = PostgreSQLConnection(
          "manny.db.elephantsql.com",
          5432,
          "yudejpbv",
          username: "yudejpbv",
          password: "8gCcTUmsAZsaYCO4igdMjHJtYaFyrBSK",
          timeoutInSeconds: 20);
      await connection.open();
      List<List<dynamic>> results = await connection.query(
          "INSERT INTO users(id,name,surname,email) VALUES ('${data["localId"]}', '${widget.nameController.text}', '${widget.surnameController.text}' , '${widget.emailController.text}')");
      
      user.setUserData(widget.emailController.text, widget.nameController.text, widget.surnameController.text, data["localId"]); 
      Get.to(const HomeScreen());
    } else {
      Get.defaultDialog(
            title: data["error"]["message"],
            middleText: "Please enter valid credientials");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Obx(() => authController.authenticationFormState.value
        ? loginForm(size)
        : registerForm(size));
  }

  Widget loginForm(Size size) {
    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: size.height / 8),
          child: Column(
            children: [
              CustomTextInput(
                controller: widget.emailController,
                icon: Icons.email_rounded,
                obscure: false,
                type: TextInputType.text,
                hint: "Type your email",
              ),
              const SizedBox(height: 20),
              CustomTextInput(
                controller: widget.passwordController,
                icon: Icons.security,
                obscure: true,
                type: TextInputType.text,
                hint: "Type your password",
              ),
              const SizedBox(height: 20),
              Obx(() => CustomButton(
                  text: authController.authenticationFormState.value
                      ? "Login"
                      : "Register",
                  onTap: () {
                    signIn();
                    //Get.to(const HomeScreen());
                  },
                  width: MediaQuery.of(context).size.width / 1.2)),
              const SizedBox(height: 10),
              Obx(
                () => GestureDetector(
                    onTap: () {
                      authController.updateAuthFormState(
                          !authController.authenticationFormState.value);
                    },
                    child: CustomText(
                      color: thirdColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      text: authController.authenticationFormState.value
                          ? "Don't you have an account yet?"
                          : "Do you already have an account?",
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  registerForm(Size size) {
    return Center(
      child: Container(
        width: 300,
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: size.height / 8),
          child: Column(
            children: [
              CustomTextInput(
                controller: widget.emailController,
                icon: Icons.email_rounded,
                obscure: false,
                type: TextInputType.text,
                hint: "Type your email",
              ),
              const SizedBox(height: 20),
              CustomTextInput(
                controller: widget.passwordController,
                icon: Icons.security,
                obscure: true,
                type: TextInputType.text,
                hint: "Type your password",
              ),
              const SizedBox(height: 20),
              CustomTextInput(
                controller: widget.nameController,
                icon: Icons.person,
                obscure: false,
                type: TextInputType.text,
                hint: "Type your name",
              ),
              const SizedBox(height: 20),
              CustomTextInput(
                controller: widget.surnameController,
                icon: Icons.person,
                obscure: false,
                type: TextInputType.text,
                hint: "Type your surname",
              ),
              const SizedBox(height: 20),
              Obx(
                () => CustomButton(
                  text: authController.authenticationFormState.value
                      ? "Login"
                      : "Register",
                  onTap: () {
                

                    signUp();
                    //Get.to(const HomeScreen());
                  },
                  width: MediaQuery.of(context).size.width / 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => GestureDetector(
                    onTap: () {
                      authController.updateAuthFormState(
                          !authController.authenticationFormState.value);
                    },
                    child: CustomText(
                      color: thirdColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      text: authController.authenticationFormState.value
                          ? "Don't you have an account yet?"
                          : "Do you already have an account?",
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
