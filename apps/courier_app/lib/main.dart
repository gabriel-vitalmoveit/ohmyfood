import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CourierApp());
}

class CourierApp extends StatelessWidget {
  const CourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OhMyFood Estafeta',
      theme: OhMyFoodTheme.dark,
      home: const Scaffold(
        body: Center(
          child: Text('OhMyFood Estafeta - MVP'),
        ),
      ),
    );
  }
}
