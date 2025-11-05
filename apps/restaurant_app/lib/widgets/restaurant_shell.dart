import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantShell extends StatelessWidget {
  const RestaurantShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _destinations = [
    _Destination(Icons.dashboard_outlined, 'Dashboard'),
    _Destination(Icons.receipt_long_outlined, 'Pedidos'),
    _Destination(Icons.restaurant_menu_outlined, 'Menu'),
    _Destination(Icons.insights_outlined, 'Insights'),
    _Destination(Icons.settings_outlined, 'Definições'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(icon: Icon(destination.icon), label: destination.label),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.label);

  final IconData icon;
  final String label;
}
