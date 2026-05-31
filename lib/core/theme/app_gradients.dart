import 'package:flutter/material.dart';

import 'app_theme.dart';

abstract class AppGradients {
  AppGradients._();

  static const primaryVertical = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const primaryDiagonal = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const amberWarm = LinearGradient(
    colors: [AppColors.secondary, Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGreen = LinearGradient(
    colors: [AppColors.successLight, Color(0xFFC8E6C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dangerRed = LinearGradient(
    colors: [AppColors.errorLight, Color(0xFFFFCDD2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const infoBlue = LinearGradient(
    colors: [AppColors.infoLight, Color(0xFFB3E5FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkOverlay = LinearGradient(
    colors: [Color(0x80000000), Color(0x40000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
