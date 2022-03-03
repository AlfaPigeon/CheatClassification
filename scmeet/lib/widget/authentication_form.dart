import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/controller/authentication_controller.dart';
import 'package:scmeet/screen/home_screen.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/custom_text.dart';
import 'package:scmeet/widget/custom_text_input.dart';

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
                    if (authController.authenticationFormState.value) {
                      //LOGIN
                      Get.to(const HomeScreen());
                    } else {
                      //REGISTER
                      Get.to(const HomeScreen());
                    }
                  })),
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
        width: 400,
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
              Obx(() => CustomButton(
                  text: authController.authenticationFormState.value
                      ? "Login"
                      : "Register",
                  onTap: () {
                    if (authController.authenticationFormState.value) {
                      //LOGIN
                      Get.to(const HomeScreen());
                    } else {
                      //REGISTER
                      Get.to(const HomeScreen());
                    }
                  })),
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
