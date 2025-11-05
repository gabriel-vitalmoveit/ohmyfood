import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router.dart';

class RestaurantOnboardingScreen extends HookConsumerWidget {
  const RestaurantOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OhMyFoodColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bem-vindo ao painel restaurante', style: OhMyFoodTypography.displayLg),
              const SizedBox(height: OhMyFoodSpacing.md),
              Text(
                'Finalize o setup para começar a receber pedidos em Lisboa.',
                style: OhMyFoodTypography.body,
              ),
              const SizedBox(height: OhMyFoodSpacing.xl),
              _StepTile(
                icon: Icons.storefront_outlined,
                title: 'Dados do restaurante',
                description: 'Horários, zonas de entrega e contactos atualizados.',
                completed: true,
              ),
              _StepTile(
                icon: Icons.receipt_long_outlined,
                title: 'Menu e disponibilidade',
                description: 'Ative pratos e configure tempos de preparação.',
                completed: false,
              ),
              _StepTile(
                icon: Icons.payment_outlined,
                title: 'Pagamentos & faturação',
                description: 'Verifique IBAN e NIF para liquidações semanais.',
                completed: false,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(restaurantOnboardingProvider.notifier).state = true;
                    context.go('/dashboard');
                  },
                  child: const Text('Ir para o dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.icon,
    required this.title,
    required this.description,
    this.completed = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: OhMyFoodSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: completed ? OhMyFoodColors.restaurantAccent : OhMyFoodColors.neutral100,
          child: Icon(icon, color: completed ? Colors.white : OhMyFoodColors.neutral600),
        ),
        title: Text(title, style: OhMyFoodTypography.bodyBold),
        subtitle: Text(description, style: OhMyFoodTypography.body),
        trailing: completed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
