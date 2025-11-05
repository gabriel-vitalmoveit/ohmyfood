import 'package:flutter/material.dart';

class OhMyFoodColors {
  static const primary = Color(0xFFFF6F21);
  static const secondary = Color(0xFF1C1C1C);
  static const neutral = Color(0xFFF5F5F5);
}

class OhMyFoodTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: OhMyFoodColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: OhMyFoodColors.neutral,
        fontFamily: 'Roboto',
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: OhMyFoodColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      );
}

class OhMyFoodButton extends StatelessWidget {
  const OhMyFoodButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: OhMyFoodColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
