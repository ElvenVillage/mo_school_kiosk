import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF26404f);
  static const secondary = Color(0xFF83c1ce);
  static const darkGreen = Color(0xFF112129);
}

extension MobileLayout on BuildContext {
  bool get useMobileLayout => MediaQuery.of(this).size.shortestSide < 600;
}

extension TextStyles on BuildContext {
  TextStyle get headlineMedium {
    final width = MediaQuery.of(this).size.width;

    final theme = Theme.of(this).textTheme.headlineSmall!;
    return theme.copyWith(
        color: Colors.white, fontSize: width / 1980 * theme.fontSize!);
  }

  TextStyle get headlineLarge {
    final width = MediaQuery.of(this).size.width;

    final theme = Theme.of(this).textTheme.headlineLarge!;
    return theme.copyWith(
        color: Colors.white, fontSize: width / 1980 * theme.fontSize!);
  }

  TextStyle get body {
    final width = MediaQuery.of(this).size.width;

    final theme = Theme.of(this).textTheme.bodyLarge!;
    return theme.copyWith(
        color: Colors.white, fontSize: width / 1980 * theme.fontSize!);
  }
}
