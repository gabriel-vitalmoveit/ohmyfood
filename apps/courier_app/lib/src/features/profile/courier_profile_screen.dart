import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CourierProfileScreen extends HookConsumerWidget {
  const CourierProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OhMyFoodAppScaffold(
      title: 'Perfil do estafeta',
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
        children: [
          ListTile(
            leading: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d'),
            ),
            title: Text('João Ferreira', style: OhMyFoodTypography.bodyBold),
            subtitle: Text('Scooter • 912 345 678', style: OhMyFoodTypography.caption),
            trailing: TextButton(onPressed: () {}, child: const Text('Atualizar docs')),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          _SectionTitle('Verificação'),
          const ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text('Documento de identificação'),
            subtitle: Text('Aprovado • 12/2025'),
            trailing: Icon(Icons.check_circle, color: Colors.greenAccent),
          ),
          const ListTile(
            leading: Icon(Icons.credit_card_outlined),
            title: Text('IBAN PT50 •••• 9876'),
            subtitle: Text('Aprovado'),
            trailing: Icon(Icons.check_circle, color: Colors.greenAccent),
          ),
          const ListTile(
            leading: Icon(Icons.motorcycle_outlined),
            title: Text('Carta de condução'),
            subtitle: Text('A expirar 03/2026'),
            trailing: Icon(Icons.warning_amber, color: Colors.amberAccent),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          _SectionTitle('Definições de app'),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Alertas sonoros'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Modo economia de dados'),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          _SectionTitle('Suporte'),
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined),
            title: const Text('Contactar operações'),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Políticas & RGPD'),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md, vertical: OhMyFoodSpacing.sm),
      child: Text(label, style: OhMyFoodTypography.titleMd),
    );
  }
}
