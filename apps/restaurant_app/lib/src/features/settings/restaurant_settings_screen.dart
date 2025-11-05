import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RestaurantSettingsScreen extends HookConsumerWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OhMyFoodAppScaffold(
      title: 'Definições',
      body: ListView(
        padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
        children: [
          ListTile(
            leading: const Icon(Icons.access_time_outlined),
            title: const Text('Horário de funcionamento'),
            subtitle: const Text('Seg-Dom • 11h às 23h'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delivery_dining_outlined),
            title: const Text('Tempos de preparação'),
            subtitle: const Text('Pratos principais: 15 min • Sobremesas: 5 min'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Zonas e taxas de entrega'),
            subtitle: const Text('Lisboa centro • 1.99€'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Aceitar pedidos automaticamente'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Receber alertas de stock baixo'),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Equipa e permissões'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('RGPD & auditoria'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Terminar sessão'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
