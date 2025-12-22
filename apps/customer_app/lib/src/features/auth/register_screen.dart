import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/providers/auth_providers.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  static const routeName = 'register';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final displayNameController = useTextEditingController();
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final authState = ref.watch(authStateProvider);

    // Redirecionar se autenticado
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: OhMyFoodSpacing.md),
              Text(
                'Junta-te ao OhMyFood',
                style: OhMyFoodTypography.titleLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OhMyFoodSpacing.xl),
              
              // Display Name Field
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome (opcional)',
                  hintText: 'O teu nome',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.lg),
              
              // Email Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'exemplo@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.lg),
              
              // Password Field
              TextField(
                controller: passwordController,
                obscureText: obscurePassword.value,
                decoration: InputDecoration(
                  labelText: 'Palavra-passe',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => obscurePassword.value = !obscurePassword.value,
                  ),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.lg),
              
              // Confirm Password Field
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword.value,
                decoration: InputDecoration(
                  labelText: 'Confirmar palavra-passe',
                  hintText: 'Repete a palavra-passe',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => obscureConfirmPassword.value = !obscureConfirmPassword.value,
                  ),
                ),
              ),
              const SizedBox(height: OhMyFoodSpacing.md),
              
              // Error Message
              if (authState.hasError && authState.errorMessage != null)
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
                          authState.errorMessage!,
                          style: OhMyFoodTypography.body.copyWith(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: OhMyFoodSpacing.lg),
              
              // Register Button
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        final email = emailController.text.trim();
                        final password = passwordController.text;
                        final confirmPassword = confirmPasswordController.text;
                        final displayName = displayNameController.text.trim();
                        
                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('As palavras-passe não coincidem')),
                          );
                          return;
                        }
                        
                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('A palavra-passe deve ter pelo menos 6 caracteres')),
                          );
                          return;
                        }
                        
                        ref.read(authStateProvider.notifier).register(
                              email: email,
                              password: password,
                              displayName: displayName.isEmpty ? null : displayName,
                            );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.md),
                  backgroundColor: OhMyFoodColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Criar conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              
              const SizedBox(height: OhMyFoodSpacing.md),
              
              // Login Link
              TextButton(
                onPressed: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    style: OhMyFoodTypography.body,
                    children: [
                      const TextSpan(text: 'Já tens conta? '),
                      TextSpan(
                        text: 'Entra',
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

