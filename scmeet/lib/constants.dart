import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color backgColor = const Color.fromRGBO(1, 31, 38, 1);
Color secondaryColor = const Color.fromRGBO(2, 94, 115, 1);
Color thirdColor = const Color.fromRGBO(242, 167, 27, 1);
Color iconColor = const Color(0xff7c807f);
Color textInputColor = const Color(0xffe7edeb);

TextStyle myTextStyle(double fontSize, FontWeight fontWeight, Color color) {
  return GoogleFonts.montserrat(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color
  );
}
