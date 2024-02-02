import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF26404f);
  static const secondary = Color(0xFF83c1ce);
  static const darkGreen = Color(0xFF112129);
}

extension TextStyles on BuildContext {
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineSmall!;
  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get body => Theme.of(this).textTheme.bodyLarge!;
}
