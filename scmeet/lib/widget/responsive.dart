import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop; // Web and Desktop are the same

  const Responsive({Key? key, required this.mobile, required this.desktop})
      : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 850;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    if (_size.width >= 850) {
      return desktop;
    } else {
      return mobile;
    }
  }
}
