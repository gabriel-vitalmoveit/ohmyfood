import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OhMyFood Cliente',
      theme: OhMyFoodTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('OhMyFood Cliente - MVP'),
        ),
      ),
    );
  }
}
