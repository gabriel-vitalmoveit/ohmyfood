import 'package:flutter/material.dart';

import 'foundations/colors.dart';
import 'foundations/typography.dart';

class OhMyFoodTheme {
  static ThemeData light({Color? seed}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed ?? OhMyFoodColors.primary,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: OhMyFoodColors.neutral50,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: OhMyFoodColors.neutral0,
        foregroundColor: OhMyFoodColors.neutral900,
        elevation: 0,
        titleTextStyle: OhMyFoodTypography.titleMd,
      ),
      cardTheme: CardThemeData(
        color: OhMyFoodColors.neutral0,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: OhMyFoodColors.neutral100,
        selectedColor: OhMyFoodColors.primarySoft,
        secondarySelectedColor: OhMyFoodColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: OhMyFoodTypography.label,
        secondaryLabelStyle: OhMyFoodTypography.label.copyWith(
          color: OhMyFoodColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OhMyFoodColors.neutral0,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: OhMyFoodColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: OhMyFoodColors.primary),
        ),
        hintStyle: OhMyFoodTypography.body.copyWith(color: OhMyFoodColors.neutral400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OhMyFoodColors.primary,
          foregroundColor: OhMyFoodColors.neutral0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: OhMyFoodTypography.bodyBold,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OhMyFoodColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      textTheme: _textTheme.apply(bodyColor: OhMyFoodColors.neutral0),
    );
  }

  static TextTheme get _textTheme => TextTheme(
        displayLarge: OhMyFoodTypography.displayLg,
        headlineMedium: OhMyFoodTypography.headline,
        titleLarge: OhMyFoodTypography.titleLg,
        titleMedium: OhMyFoodTypography.titleMd,
        bodyLarge: OhMyFoodTypography.body,
        bodyMedium: OhMyFoodTypography.body,
        bodySmall: OhMyFoodTypography.caption,
        labelLarge: OhMyFoodTypography.bodyBold,
        labelMedium: OhMyFoodTypography.label,
      );
}
