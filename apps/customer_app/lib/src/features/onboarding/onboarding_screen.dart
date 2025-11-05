import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  static const routeName = 'onboarding';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = PageController();
    final slides = [
      _OnboardingSlide(
        title: 'Entregas deliciosas em Lisboa',
        description: 'Restaurantes, mercearias e farmácias num só lugar.',
        illustration: 'assets/hero_order.svg',
      ),
      _OnboardingSlide(
        title: 'Acompanhe cada etapa em tempo real',
        description: 'Tracking preciso, chat com estafeta e alertas instantâneos.',
        illustration: 'assets/hero_tracking.svg',
      ),
      _OnboardingSlide(
        title: 'Pagamentos simples e seguros',
        description: 'Cartão, MB WAY ou Multibanco. Tudo integrado no app.',
        illustration: 'assets/hero_payment.svg',
      ),
    ];

    return Scaffold(
      backgroundColor: OhMyFoodColors.neutral0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _skip(context, ref),
                  child: const Text('Saltar'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: slides.length,
                  itemBuilder: (context, index) => slides[index],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      double page = 0;
                      if (controller.hasClients && controller.page != null) {
                        page = controller.page!;
                      }
                      final isActive = (controller.hasClients ? (page.round() == index) : index == 0);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive ? OhMyFoodColors.primary : OhMyFoodColors.neutral200,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _skip(context, ref),
                  child: const Text('Começar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skip(BuildContext context, WidgetRef ref) {
    ref.read(onboardingCompletedProvider.notifier).state = true;
    context.go('/home');
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;
  final String illustration;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Icon(Icons.delivery_dining_rounded, size: 160, color: OhMyFoodColors.primarySoft),
          ),
        ),
        Text(title, style: OhMyFoodTypography.titleLg, textAlign: TextAlign.center),
        const SizedBox(height: OhMyFoodSpacing.sm),
        Text(
          description,
          style: OhMyFoodTypography.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: OhMyFoodSpacing.xl),
      ],
    );
  }
}
