import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _destinations = [
    _AdminDestination('Live Ops', Icons.map_outlined),
    _AdminDestination('Entidades', Icons.people_outline),
    _AdminDestination('Campanhas', Icons.campaign_outlined),
    _AdminDestination('Financeiro', Icons.attach_money_outlined),
    _AdminDestination('Definições', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final destination in _destinations)
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.icon, color: Theme.of(context).colorScheme.primary),
                  label: Text(destination.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
