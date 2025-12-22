import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/providers/auth_providers.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userEmail = authState.email ?? 'Usuário';
    
    return OhMyFoodAppScaffold(
      title: 'Perfil',
      body: ListView(
        padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: OhMyFoodColors.primary,
              child: Text(
                userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                style: OhMyFoodTypography.titleMd.copyWith(color: Colors.white),
              ),
            ),
            title: Text(userEmail, style: OhMyFoodTypography.bodyBold),
            subtitle: Text(userEmail, style: OhMyFoodTypography.caption),
            trailing: TextButton(onPressed: () {}, child: const Text('Editar')),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          _SectionTitle('Preferências'),
          SwitchListTile(
            title: const Text('Notificações push'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Alertas via SMS'),
            subtitle: const Text('Receber atualização sobre pedidos urgentes'),
            value: false,
            onChanged: (_) {},
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          _SectionTitle('Pagamentos'),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Visa •••• 1234'),
            subtitle: const Text('Expira 04/27'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('MB WAY 912 345 678'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          _SectionTitle('Segurança & RGPD'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Consentimentos RGPD'),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Exportar dados pessoais'),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Eliminar conta'),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: OhMyFoodSpacing.xl),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Centro de suporte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Terminar sessão', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Terminar sessão'),
                  content: const Text('Tens a certeza que queres terminar a sessão?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Terminar'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
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
      padding: const EdgeInsets.symmetric(
        vertical: OhMyFoodSpacing.sm,
        horizontal: OhMyFoodSpacing.xs,
      ),
      child: Text(label, style: OhMyFoodTypography.titleMd),
    );
  }
}
