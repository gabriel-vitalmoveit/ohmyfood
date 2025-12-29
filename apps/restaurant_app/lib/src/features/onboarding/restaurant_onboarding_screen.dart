import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router.dart';

final onboardingStepProvider = StateProvider<int>((ref) => 0);
final onboardingDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

class RestaurantOnboardingScreen extends HookConsumerWidget {
  const RestaurantOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(onboardingStepProvider);
    final totalSteps = 3;

    return Scaffold(
      backgroundColor: OhMyFoodColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(onboardingStepProvider.notifier).state = currentStep - 1;
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Passo ${currentStep + 1} de $totalSteps',
                        style: OhMyFoodTypography.caption,
                      ),
                      Text(
                        '${((currentStep + 1) / totalSteps * 100).toInt()}%',
                        style: OhMyFoodTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  LinearProgressIndicator(
                    value: (currentStep + 1) / totalSteps,
                    backgroundColor: OhMyFoodColors.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(OhMyFoodColors.restaurantAccent),
                  ),
                ],
              ),
            ),

            // Step content
            Expanded(
              child: _buildStepContent(context, ref, currentStep),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
              child: Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(onboardingStepProvider.notifier).state = currentStep - 1;
                        },
                        child: const Text('Anterior'),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: OhMyFoodSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentStep < totalSteps - 1) {
                          ref.read(onboardingStepProvider.notifier).state = currentStep + 1;
                        } else {
                          // Finalizar onboarding
                          ref.read(restaurantOnboardingProvider.notifier).state = true;
                          // Onboarding concluído -> seguir para login (dashboard só após autenticação)
                          context.go('/login');
                        }
                      },
                      child: Text(currentStep < totalSteps - 1 ? 'Próximo' : 'Finalizar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, WidgetRef ref, int step) {
    switch (step) {
      case 0:
        return _Step1RestaurantData(ref: ref);
      case 1:
        return _Step2Menu(ref: ref);
      case 2:
        return _Step3Payment(ref: ref);
      default:
        return const SizedBox();
    }
  }
}

class _Step1RestaurantData extends HookConsumerWidget {
  const _Step1RestaurantData({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 64,
            color: OhMyFoodColors.restaurantAccent,
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Text(
            'Dados do restaurante',
            style: OhMyFoodTypography.displayLg,
          ),
          const SizedBox(height: OhMyFoodSpacing.sm),
          Text(
            'Configure as informações básicas do seu restaurante.',
            style: OhMyFoodTypography.body,
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nome do restaurante',
              hintText: 'Ex: Tasca do Bairro',
            ),
            onChanged: (value) {
              ref.read(onboardingDataProvider.notifier).state = {
                ...data,
                'name': value,
              };
            },
          ),
          const SizedBox(height: OhMyFoodSpacing.md),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Descrição',
              hintText: 'Descreva o seu restaurante',
            ),
            maxLines: 3,
            onChanged: (value) {
              ref.read(onboardingDataProvider.notifier).state = {
                ...data,
                'description': value,
              };
            },
          ),
          const SizedBox(height: OhMyFoodSpacing.md),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Telefone',
              hintText: '+351 912 345 678',
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              ref.read(onboardingDataProvider.notifier).state = {
                ...data,
                'phone': value,
              };
            },
          ),
        ],
      ),
    );
  }
}

class _Step2Menu extends HookConsumerWidget {
  const _Step2Menu({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: OhMyFoodColors.restaurantAccent,
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Text(
            'Menu e disponibilidade',
            style: OhMyFoodTypography.displayLg,
          ),
          const SizedBox(height: OhMyFoodSpacing.sm),
          Text(
            'Você pode adicionar itens ao menu depois. Por agora, vamos configurar o tempo médio de preparação.',
            style: OhMyFoodTypography.body,
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tempo médio de preparação',
                    style: OhMyFoodTypography.bodyBold,
                  ),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  Text(
                    'Quanto tempo em média leva para preparar um pedido?',
                    style: OhMyFoodTypography.caption,
                  ),
                  const SizedBox(height: OhMyFoodSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Minutos',
                            hintText: '15',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final data = ref.read(onboardingDataProvider);
                            ref.read(onboardingDataProvider.notifier).state = {
                              ...data,
                              'averagePrepMin': int.tryParse(value) ?? 15,
                            };
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Text(
            'Você pode gerenciar seu menu completo na seção "Menu" após finalizar o onboarding.',
            style: OhMyFoodTypography.caption.copyWith(
              color: OhMyFoodColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step3Payment extends HookConsumerWidget {
  const _Step3Payment({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: OhMyFoodColors.restaurantAccent,
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Text(
            'Pagamentos & faturação',
            style: OhMyFoodTypography.displayLg,
          ),
          const SizedBox(height: OhMyFoodSpacing.sm),
          Text(
            'Configure seus dados bancários para receber pagamentos.',
            style: OhMyFoodTypography.body,
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          TextField(
            decoration: const InputDecoration(
              labelText: 'IBAN',
              hintText: 'PT50 0000 0000 0000 0000 0000 0',
            ),
            onChanged: (value) {
              final data = ref.read(onboardingDataProvider);
              ref.read(onboardingDataProvider.notifier).state = {
                ...data,
                'iban': value,
              };
            },
          ),
          const SizedBox(height: OhMyFoodSpacing.md),
          TextField(
            decoration: const InputDecoration(
              labelText: 'NIF',
              hintText: '123456789',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final data = ref.read(onboardingDataProvider);
              ref.read(onboardingDataProvider.notifier).state = {
                ...data,
                'nif': value,
              };
            },
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Card(
            color: OhMyFoodColors.primarySoft,
            child: Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: OhMyFoodColors.primary),
                  const SizedBox(width: OhMyFoodSpacing.sm),
                  Expanded(
                    child: Text(
                      'Os pagamentos são processados semanalmente. Você receberá um email com o comprovativo.',
                      style: OhMyFoodTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
