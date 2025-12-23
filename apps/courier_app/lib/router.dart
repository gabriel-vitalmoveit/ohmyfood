import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/auth/login_screen.dart';
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
      
      // Se não está autenticado e não está em login/onboarding, redirecionar para login
      if (!authState.isAuthenticated && !isLogin && !isOnboarding) {
        return '/login';
      }
      
      // Se está autenticado e está em login, redirecionar para dashboard
      if (authState.isAuthenticated && isLogin) {
        return '/dashboard';
      }
      
      // Se não completou onboarding e não está em onboarding/login
      if (!completed && !isOnboarding && !isLogin) {
        return '/onboarding';
      }
      
      // Se completou onboarding mas está na tela de onboarding
      if (completed && isOnboarding) {
        return authState.isAuthenticated ? '/dashboard' : '/login';
      }
      
      return null;
    },
  );
});

String _getInitialLocation(bool onboardingCompleted, bool isAuthenticated) {
  if (!isAuthenticated) return '/login';
  if (!onboardingCompleted) return '/onboarding';
  return '/dashboard';
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<bool>(courierOnboardingProvider, (_, __) => notifyListeners());
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
