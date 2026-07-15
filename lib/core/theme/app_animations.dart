import 'package:flutter/animation.dart';

/// Central animation-duration and curve tokens so every transition in
/// Pyago moves with the same rhythm.
class AppDurations {
  const AppDurations._();

  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration deliberate = Duration(milliseconds: 600);

  /// Stagger delay between items in cascading list animations.
  static const Duration stagger = Duration(milliseconds: 80);

  /// Major screen/hero transitions.
  static const Duration hero = Duration(milliseconds: 500);
}

class AppCurves {
  const AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
}
