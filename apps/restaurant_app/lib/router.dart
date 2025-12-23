import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/analytics/analytics_screen.dart';
import 'src/features/auth/login_screen.dart';
import 'src/features/dashboard/restaurant_dashboard_screen.dart';
import 'src/features/menu/menu_management_screen.dart';
import 'src/features/onboarding/restaurant_onboarding_screen.dart';
import 'src/features/orders/order_board_screen.dart';
import 'src/features/orders/order_detail_screen.dart';
import 'src/features/settings/restaurant_settings_screen.dart';
import 'widgets/restaurant_shell.dart';

final restaurantOnboardingProvider = StateProvider<bool>((ref) => false);

final restaurantRouterProvider = Provider<GoRouter>((ref) {
  final completed = ref.watch(restaurantOnboardingProvider);
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: _getInitialLocation(completed, authState.isAuthenticated),
    refreshListenable: _RestaurantRouterNotifier(ref),
    routes: [
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const RestaurantOnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => RestaurantShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const RestaurantDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderBoardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuManagementScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const RestaurantSettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => RestaurantOrderDetailScreen(orderId: state.pathParameters['id']!),
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

class _RestaurantRouterNotifier extends ChangeNotifier {
  _RestaurantRouterNotifier(this.ref) {
    ref.listen<bool>(restaurantOnboardingProvider, (_, __) => notifyListeners());
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
