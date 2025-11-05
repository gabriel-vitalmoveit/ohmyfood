import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourierShell extends StatelessWidget {
  const CourierShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _destinations = [
    _Destination(Icons.flash_on_rounded, 'Online'),
    _Destination(Icons.list_alt_outlined, 'Pedidos'),
    _Destination(Icons.payments_outlined, 'Ganhos'),
    _Destination(Icons.person_outline, 'Perfil'),
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
