import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationShell extends StatelessWidget {
  const BottomNavigationShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _destinations = [
    _BottomNavDestination(icon: Icons.home_rounded, label: 'Início'),
    _BottomNavDestination(icon: Icons.receipt_long_rounded, label: 'Pedidos'),
    _BottomNavDestination(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }

  void _onDestinationSelected(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }
}

class _BottomNavDestination {
  const _BottomNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
