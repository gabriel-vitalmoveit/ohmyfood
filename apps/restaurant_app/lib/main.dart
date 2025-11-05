import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OhMyFood Restaurante',
      theme: OhMyFoodTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('OhMyFood Restaurante - MVP'),
        ),
      ),
    );
  }
}
