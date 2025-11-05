import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router.dart';

class AdminPanelApp extends HookConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'OhMyFood Admin',
      debugShowCheckedModeBanner: false,
      theme: OhMyFoodTheme.light(seed: OhMyFoodColors.adminAccent),
      routerConfig: router,
    );
  }
}
