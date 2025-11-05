import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/campaigns/campaigns_screen.dart';
import 'src/features/entities/entities_screen.dart';
import 'src/features/finance/finance_screen.dart';
import 'src/features/live_ops/live_ops_screen.dart';
import 'src/features/settings/admin_settings_screen.dart';
import 'widgets/admin_shell.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/live',
    routes: [
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
  );
});
