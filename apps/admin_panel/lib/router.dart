import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/auth/login_screen.dart';
import 'src/features/campaigns/campaigns_screen.dart';
import 'src/features/entities/entities_screen.dart';
import 'src/features/finance/finance_screen.dart';
import 'src/features/live_ops/live_ops_screen.dart';
import 'src/features/settings/admin_settings_screen.dart';
import 'widgets/admin_shell.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/live' : '/login',
    refreshListenable: _AdminRouterNotifier(ref),
    routes: [
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdminShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/live', builder: (context, state) => const LiveOpsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/entities', builder: (context, state) => const EntitiesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/campaigns', builder: (context, state) => const CampaignsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/finance', builder: (context, state) => const FinanceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const AdminSettingsScreen()),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLogin = state.matchedLocation == '/login';
      
      // Se não está autenticado e não está em login, redirecionar para login
      if (!authState.isAuthenticated && !isLogin) {
        return '/login';
      }
      
      // Se está autenticado e está em login, redirecionar para live
      if (authState.isAuthenticated && isLogin) {
        return '/live';
      }
      
      return null;
    },
  );
});

class _AdminRouterNotifier extends ChangeNotifier {
  _AdminRouterNotifier(this.ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
