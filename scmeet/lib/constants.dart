import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color backgColor = const Color.fromRGBO(1, 31, 38, 1);
Color secondaryColor = const Color.fromARGB(255, 14, 30, 56);
Color thirdColor = const Color.fromRGBO(242, 167, 27, 1);
Color fourthColor = const Color.fromARGB(255, 51, 84, 116);
Color fifthcolor = const Color.fromARGB(235, 200, 163, 112);
Color iconColor = const Color(0xff7c807f);
Color textInputColor = const Color(0xffe7edeb);
Color logout = Color.fromARGB(235, 150, 29, 20);

TextStyle myTextStyle(double fontSize, FontWeight fontWeight, Color color) {
  return GoogleFonts.montserrat(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color
  );
}
