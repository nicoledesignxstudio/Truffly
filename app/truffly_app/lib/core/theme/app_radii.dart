import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const double auth = 30;
  static const double dialog = 12;
  static const double circle = 999;

  static const BorderRadius authBorderRadius =
      BorderRadius.all(Radius.circular(auth));
  static const BorderRadius dialogBorderRadius =
      BorderRadius.all(Radius.circular(dialog));
  static const BorderRadius circularBorderRadius =
      BorderRadius.all(Radius.circular(circle));
}
