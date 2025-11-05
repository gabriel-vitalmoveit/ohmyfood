import 'package:flutter/material.dart';
import 'colors.dart';

class OhMyFoodTypography {
  static const _fontFamily = 'Roboto';

  static TextStyle displayLg = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 44,
    letterSpacing: -0.5,
    color: OhMyFoodColors.neutral900,
  );

  static TextStyle headline = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: -0.2,
    color: OhMyFoodColors.neutral900,
  );

  static TextStyle titleLg = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: OhMyFoodColors.neutral900,
  );

  static TextStyle titleMd = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: OhMyFoodColors.neutral900,
  );

  static TextStyle body = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: OhMyFoodColors.neutral600,
  );

  static TextStyle bodyBold = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: OhMyFoodColors.neutral900,
  );

  static TextStyle label = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: OhMyFoodColors.neutral600,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: OhMyFoodColors.neutral400,
  );
}
