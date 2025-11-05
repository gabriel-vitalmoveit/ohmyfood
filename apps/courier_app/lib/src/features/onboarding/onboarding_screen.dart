import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../router.dart';

class CourierOnboardingScreen extends HookConsumerWidget {
  const CourierOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = const [
      ('Ganha ao teu ritmo', 'Escolhe quando ficas online, recebe pedidos e maximiza ganhos.'),
      ('Documentos em segurança', 'Envio de CC/BI, carta de condução e IBAN verificados pela equipa OhMyFood.'),
      ('Ferramentas integradas', 'Mapbox otimizado, chat e suporte 24/7 prontos para o teu turno.'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OhMyFood Riders', style: OhMyFoodTypography.displayLg.copyWith(color: Colors.white)),
              const SizedBox(height: OhMyFoodSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: OhMyFoodColors.courierAccent.withOpacity(0.12),
                        child: Text('${index + 1}', style: OhMyFoodTypography.bodyBold),
                      ),
                      title: Text(step.$1, style: OhMyFoodTypography.titleMd.copyWith(color: Colors.white)),
                      subtitle: Text(step.$2, style: OhMyFoodTypography.body.copyWith(color: Colors.white70)),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                  itemCount: steps.length,
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(courierOnboardingProvider.notifier).state = true;
                    context.go('/dashboard');
                  },
                  child: const Text('Entrar em serviço'),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.sm),
              TextButton(
                onPressed: () {},
                child: const Text('Ver requisitos completos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
