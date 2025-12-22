import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../auth_service.dart';
import '../auth_repository.dart';

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Estado de autenticação
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  final Ref ref;

  Future<void> _checkAuthStatus() async {
    final repository = ref.read(authRepositoryProvider);
    final isAuth = await repository.isAuthenticated();
    if (isAuth) {
      final email = await repository.getUserEmail();
      state = AuthState.authenticated(email ?? '');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final repository = ref.read(authRepositoryProvider);
      
      final response = await authService.login(email, password);
      
      await repository.saveTokens(response.tokens);
      await repository.saveUser(response.user);
      
      state = AuthState.authenticated(response.user.email);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final repository = ref.read(authRepositoryProvider);
      
      final response = await authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      await repository.saveTokens(response.tokens);
      await repository.saveUser(response.user);
      
      state = AuthState.authenticated(response.user.email);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.clearAuth();
    state = const AuthState.unauthenticated();
  }

  Future<String?> getAccessToken() async {
    final repository = ref.read(authRepositoryProvider);
    return await repository.getAccessToken();
  }
}

sealed class AuthState {
  const AuthState();
  
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(String email) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
  
  // Helper para verificar se está autenticado
  bool get isAuthenticated => this is _Authenticated;
  
  // Helper para obter email se autenticado
  String? get email => this is _Authenticated ? (this as _Authenticated).email : null;
}

class _Initial extends AuthState {
  const _Initial();
}

class _Loading extends AuthState {
  const _Loading();
}

class _Authenticated extends AuthState {
  const _Authenticated(this.email);
  final String email;
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Error extends AuthState {
  const _Error(this.message);
  final String message;
}

