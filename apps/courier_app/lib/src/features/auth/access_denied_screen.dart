import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AccessDeniedScreen extends HookConsumerWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(OhMyFoodSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: OhMyFoodColors.error,
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                Text(
                  'Acesso Negado',
                  style: OhMyFoodTypography.titleLg.copyWith(
                    color: OhMyFoodColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.md),
                Text(
                  'Esta conta não tem permissão para aceder à aplicação de estafeta.',
                  style: OhMyFoodTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OhMyFoodSpacing.xl),
                ElevatedButton(
                  onPressed: () async {
                    final authRepository = ref.read(authRepositoryProvider);
                    await authRepository.clearAuth();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OhMyFoodSpacing.xl,
                      vertical: OhMyFoodSpacing.md,
                    ),
                    backgroundColor: OhMyFoodColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terminar Sessão'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

