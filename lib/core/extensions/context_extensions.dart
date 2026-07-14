import 'package:flutter/material.dart';

/// Convenience accessors so widgets read `context.textTheme` /
/// `context.colors` instead of the verbose Theme.of(context) chain.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  EdgeInsets get safePadding => MediaQuery.paddingOf(this);

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
