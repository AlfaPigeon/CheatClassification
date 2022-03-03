import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final double width;

  const CustomButton({Key? key, required this.text, required this.onTap, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            style: myTextStyle(14, FontWeight.bold, Colors.white),
          ),
        ));
  }
}
