import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OhMyFood Admin',
      theme: OhMyFoodTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('OhMyFood Admin - Live Ops'),
        ),
      ),
    );
  }
}
