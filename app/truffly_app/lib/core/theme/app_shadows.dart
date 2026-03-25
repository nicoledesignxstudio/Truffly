import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> authField = [
    BoxShadow(
      color: Color(0x12151618),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> truffleCard = [
    BoxShadow(
      color: Color(0x1A151618),
      offset: Offset(0, 2),
      blurRadius: 7,
      spreadRadius: 0,
    ),
  ];
}
