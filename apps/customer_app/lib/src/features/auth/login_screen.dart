import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/providers/auth_providers.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  static const routeName = 'login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final authState = ref.watch(authStateProvider);

    // Redirecionar se autenticado
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: OhMyFoodSpacing.xl),
              // Logo/Title
              Text(
                'OhMyFood',
                style: OhMyFoodTypography.displayLg.copyWith(
                  color: OhMyFoodColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OhMyFoodSpacing.sm),
              Text(
                'Entra na tua conta',
                style: OhMyFoodTypography.titleMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OhMyFoodSpacing.xl * 2),
              
              // Email Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'exemplo@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.lg),
              
              // Password Field
              TextField(
                controller: passwordController,
                obscureText: obscurePassword.value,
                decoration: InputDecoration(
                  labelText: 'Palavra-passe',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => obscurePassword.value = !obscurePassword.value,
                  ),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.md),
              
              // Error Message
              if (authState is _Error)
                Container(
                  padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: OhMyFoodSpacing.sm),
                      Expanded(
                        child: Text(
                          (authState as _Error).message,
                          style: OhMyFoodTypography.body.copyWith(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: OhMyFoodSpacing.lg),
              
              // Login Button
              ElevatedButton(
                onPressed: authState is _Loading
                    ? null
                    : () {
                        ref.read(authStateProvider.notifier).login(
                              emailController.text.trim(),
                              passwordController.text,
                            );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.md),
                  backgroundColor: OhMyFoodColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: authState is _Loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              
              const SizedBox(height: OhMyFoodSpacing.md),
              
              // Register Link
              TextButton(
                onPressed: () => context.push('/register'),
                child: RichText(
                  text: TextSpan(
                    style: OhMyFoodTypography.body,
                    children: [
                      const TextSpan(text: 'Ainda não tens conta? '),
                      TextSpan(
                        text: 'Regista-te',
                        style: OhMyFoodTypography.bodyBold.copyWith(
                          color: OhMyFoodColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

