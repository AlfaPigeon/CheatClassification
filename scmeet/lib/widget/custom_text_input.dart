import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';

class CustomTextInput extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscure;
  final TextInputType type;
  //final Function()? onEditingComplete;
  //final String? Function(String? text)? validator;

  const CustomTextInput(
      {Key? key,
      required this.hint,
      required this.controller,
      required this.icon,
      required this.obscure,
      required this.type,
      //required this.onEditingComplete,
      //required this.validator
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //validator: validator,
      //onEditingComplete:
      //    onEditingComplete ?? () => FocusScope.of(context).nextFocus(),
      obscureText: obscure,
      controller: controller,
      decoration: InputDecoration(
        errorStyle: myTextStyle(15, FontWeight.normal, Colors.red),
        prefixIcon: Icon(
          icon ?? Icons.mail,
          color: Color(0xff7c807f),
        ),
        hintText: hint,
        hintStyle: myTextStyle(15, FontWeight.normal, secondaryColor),
        filled: true,
        fillColor: Color(0xffe7edeb),
        enabledBorder: buildBorder,
        border: buildBorder,
        errorBorder: buildBorder,
        focusedBorder: buildBorder,
        disabledBorder: buildBorder,
        focusedErrorBorder: buildBorder,
      ),
    );
  }

  OutlineInputBorder get buildBorder => OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
          // color: AppConstants.PRIMARY_COLOR,
          color: thirdColor,
          width: 0));
}