import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF26404f);
  static const secondary = Color(0xFF83c1ce);
  static const darkGreen = Color(0xFF112129);
}

extension TextStyles on BuildContext {
  TextStyle get headlineMedium =>
      Theme.of(this).textTheme.headlineSmall!.copyWith(color: Colors.white);
  TextStyle get headlineLarge =>
      Theme.of(this).textTheme.headlineLarge!.copyWith(color: Colors.white);
  TextStyle get body =>
      Theme.of(this).textTheme.bodyLarge!.copyWith(color: Colors.white);
}
