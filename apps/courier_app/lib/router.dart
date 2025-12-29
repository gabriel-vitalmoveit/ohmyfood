import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/auth/login_screen.dart';
import 'src/features/auth/access_denied_screen.dart';
import 'src/features/dashboard/dashboard_screen.dart';
import 'src/features/earnings/earnings_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/order_detail/order_detail_screen.dart';
import 'src/features/orders/available_orders_screen.dart';
import 'src/features/profile/courier_profile_screen.dart';
import 'widgets/courier_shell.dart';

final courierOnboardingProvider = StateProvider<bool>((ref) => false);

final courierRouterProvider = Provider<GoRouter>((ref) {
  final completed = ref.watch(courierOnboardingProvider);
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: _getInitialLocation(completed, authState.isAuthenticated),
    refreshListenable: _RouterNotifier(ref),
    routes: [
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/access-denied',
        builder: (context, state) => const AccessDeniedScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const CourierOnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => CourierShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const AvailableOrdersScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/earnings',
              builder: (context, state) => const EarningsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const CourierProfileScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => CourierOrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final isLogin = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAccessDenied = state.matchedLocation == '/access-denied';
      
      // 1) Onboarding primeiro (mas nunca bloquear a rota /login)
      if (!completed && !isOnboarding && !isLogin && !isAccessDenied) {
        return '/onboarding';
      }

      // Se completou onboarding mas está na tela de onboarding
      if (completed && isOnboarding) {
        return authState.isAuthenticated ? '/dashboard' : '/login';
      }

      // 2) Auth obrigatório para todas as rotas protegidas
      if (!authState.isAuthenticated && !isLogin && !isOnboarding && !isAccessDenied) {
        return '/login';
      }

      // 3) Se está autenticado, verificar role
      if (authState.isAuthenticated) {
        if (authState.userRole != 'COURIER') {
          return isAccessDenied ? null : '/access-denied';
        }

        // Role correta: se está em login/access-denied, redirecionar para dashboard
        if (isLogin || isAccessDenied) {
          return '/dashboard';
        }
      }
      
      return null;
    },
  );
});

String _getInitialLocation(bool onboardingCompleted, bool isAuthenticated) {
  // Mostrar onboarding primeiro; depois login; depois dashboard.
  if (!onboardingCompleted) return '/onboarding';
  if (!isAuthenticated) return '/login';
  return '/dashboard';
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<bool>(courierOnboardingProvider, (_, __) => notifyListeners());
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
