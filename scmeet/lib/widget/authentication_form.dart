// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final TextEditingController hostKeyController;

  const AuthenticationForm(
      {Key? key,
      required this.emailController,
      required this.passwordController,
      required this.nameController,
      required this.surnameController,
      required this.hostKeyController})
      : super(key: key);

  @override
  _AuthenticationFormState createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm> {
  final authController = Get.put(AuthenticationController());
  bool isLoading = false;
  bool? isHost = false;
  String isHostString = "0"; //DEFAULT STUDENT INDEX IN HOST_KEYS TABLE
  User user = Get.find();

  signIn() async {
    setState(() {
      isLoading = true;
    });
    var data;
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

    if (data["localId"] != null) {
      var sqldata;
      await http.post(Uri.parse("http://kemalbayik.com/signin.php"), 
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
      body: {
        "id": data["localId"],
      }).then((response) {
        sqldata = jsonDecode(response.body);
      });
      user.setUserData(
          widget.emailController.text,
          sqldata["name"],
          sqldata["surname"],
          data["localId"],
          sqldata["is_host"],
          sqldata["company"]);
      Get.off(const HomeScreen());
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
    setState(() {
      isLoading = true;
    });

    if (isHost!) {
      var keydata;
      await http
          .post(Uri.parse("http://kemalbayik.com/host_key_check.php"), body: {
        "host_key": widget.hostKeyController.text,
      }).then((response) {
        keydata = jsonDecode(response.body);
      });
      if (!keydata["error"]) {
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
        if (data["localId"] != null) {
          var sqldata;
          await http.post(Uri.parse("http://kemalbayik.com/signup.php"), body: {
            "host_key": widget.hostKeyController.text,
            "id": data["localId"],
            "name": widget.nameController.text,
            "surname": widget.surnameController.text,
            "email": widget.emailController.text,
            "is_host": isHostString
          }).then((response) {
            sqldata = jsonDecode(response.body);
          });
          user.setUserData(
              widget.emailController.text,
              widget.nameController.text,
              widget.surnameController.text,
              data["localId"],
              isHostString,
              sqldata["company"]);
          Get.to(const HomeScreen());
        } else {
          Get.defaultDialog(
              title: data["error"]["message"],
              middleText: "Please enter valid credientials");
        }
      } else {
        Get.defaultDialog(
            title: keydata["message"],
            middleText: "Please enter valid credientials");
      }
    } else {
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

      if (data["localId"] != null) {
        var sqldata;
        await http.post(Uri.parse("http://kemalbayik.com/signup.php"), body: {
          "host_key": widget.hostKeyController.text,
          "id": data["localId"],
          "name": widget.nameController.text,
          "surname": widget.surnameController.text,
          "email": widget.emailController.text,
          "is_host": isHostString
        }).then((response) {
          sqldata = jsonDecode(response.body);
        });
        user.setUserData(
            widget.emailController.text,
            widget.nameController.text,
            widget.surnameController.text,
            data["localId"],
            isHostString,
            sqldata["company"]);
        Get.to(const HomeScreen());
      } else {
        Get.defaultDialog(
            title: data["error"]["message"],
            middleText: "Please enter valid credientials");
      }
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
        height: 700,
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
              isHost!
                  ? CustomTextInput(
                      controller: widget.hostKeyController,
                      icon: Icons.key_outlined,
                      obscure: false,
                      type: TextInputType.text,
                      hint: "Type your host key",
                    )
                  : const SizedBox(),
              SizedBox(height: isHost! ? 20 : 0),
              Row(
                children: <Widget>[
                  const SizedBox(
                    width: 10,
                  ),
                  const CustomText(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      text: "I am host",
                      color: Colors.white),
                  Checkbox(
                    checkColor: thirdColor,
                    activeColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => const BorderSide(width: 2.0, color: Colors.white),
                    ),
                    value: isHost,
                    onChanged: (bool? value) {
                      setState(() {
                        isHost = value;
                        isHost! ? isHostString = "1" : isHostString = "0";
                      });
                    },
                  ),
                ],
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
