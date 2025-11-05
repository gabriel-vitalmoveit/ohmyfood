import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/analytics/analytics_screen.dart';
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

  return GoRouter(
    initialLocation: completed ? '/dashboard' : '/onboarding',
    refreshListenable: _RestaurantRouterNotifier(ref),
    routes: [
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
      final onboarding = state.matchedLocation == '/onboarding';
      if (!completed && !onboarding) return '/onboarding';
      if (completed && onboarding) return '/dashboard';
      return null;
    },
  );
});

class _RestaurantRouterNotifier extends ChangeNotifier {
  _RestaurantRouterNotifier(this.ref) {
    ref.listen<bool>(restaurantOnboardingProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
