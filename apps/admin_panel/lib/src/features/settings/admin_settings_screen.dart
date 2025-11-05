import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdminSettingsScreen extends HookConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: ListView(
        children: [
          Text('Configurações da plataforma', style: OhMyFoodTypography.titleLg),
          const SizedBox(height: OhMyFoodSpacing.lg),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Modo manutenção (frontend)'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Alerta automático de SLA'),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Gestão de acessos'),
            subtitle: const Text('Admins, Operações, Financeiro'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notificações de incidentes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Políticas & RGPD'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
