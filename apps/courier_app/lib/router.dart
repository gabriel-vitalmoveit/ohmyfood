import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  return GoRouter(
    initialLocation: completed ? '/dashboard' : '/onboarding',
    refreshListenable: _RouterNotifier(ref),
    routes: [
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
      final onboarding = state.matchedLocation == '/onboarding';
      if (!completed && !onboarding) return '/onboarding';
      if (completed && onboarding) return '/dashboard';
      return null;
    },
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<bool>(courierOnboardingProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
