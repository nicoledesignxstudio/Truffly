import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> authField = [
    BoxShadow(
      color: AppColors.black10,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
}
