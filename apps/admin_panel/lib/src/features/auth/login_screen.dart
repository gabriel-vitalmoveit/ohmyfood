import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
  );
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;
  final String? userRole;
  final String? userEmail;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
    this.userRole,
    this.userEmail,
  });

  bool get hasError => errorMessage != null;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? userId,
    String? userRole,
    String? userEmail,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository) : super(AuthState()) {
    _checkAuth();
  }

  final AuthRepository _authRepository;
  final AuthService _authService = AuthService();

  Future<void> _checkAuth() async {
    final token = await _authRepository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final userId = await _authRepository.getUserId();
      final userRole = await _authRepository.getUserRole();
      final userEmail = await _authRepository.getUserEmail();
      
      // Verificar se role é ADMIN
      if (userRole == 'ADMIN') {
        state = state.copyWith(
          isAuthenticated: true,
          userId: userId,
          userRole: userRole,
          userEmail: userEmail,
        );
      } else {
        // Role incorreta, limpar auth
        await _authRepository.clearAuth();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.login(email, password);
      
      // Verificar se role é ADMIN
      if (response.user.role != 'ADMIN') {
        throw AuthException('Acesso negado: esta conta não é de administrador');
      }

      // Salvar tokens
      await _authRepository.saveTokens(response.tokens.toJson());
      
      // Obter dados completos do usuário
      final meData = await _authService.getMe(response.tokens.accessToken);
      
      // Salvar dados do usuário
      await _authRepository.saveUserData(meData);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        userId: meData['id'],
        userRole: meData['role'],
        userEmail: meData['email'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('AuthException: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.clearAuth();
    state = AuthState();
  }
}

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
        context.go('/live');
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
                'Admin - Entrar',
                style: OhMyFoodTypography.titleMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OhMyFoodSpacing.xl * 2),
              
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
              
              ElevatedButton(
                onPressed: authState.isLoading
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
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

