import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/auth/login_screen.dart';
import 'src/features/auth/access_denied_screen.dart';
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
      GoRoute(
        path: '/access-denied',
        builder: (context, state) => const AccessDeniedScreen(),
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
      final isAccessDenied = state.matchedLocation == '/access-denied';
      
      // Se não está autenticado e não está em login/access-denied, redirecionar para login
      if (!authState.isAuthenticated && !isLogin && !isAccessDenied) {
        return '/login';
      }
      
      // Se está autenticado, verificar role
      if (authState.isAuthenticated) {
        // Se role não é ADMIN, mostrar acesso negado
        if (authState.userRole != 'ADMIN') {
          if (!isAccessDenied) {
            return '/access-denied';
          }
          return null;
        }
        
        // Role correta: se está em login/access-denied, redirecionar para live
        if (isLogin || isAccessDenied) {
          return '/live';
        }
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
