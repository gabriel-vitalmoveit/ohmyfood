import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router.dart';

class CustomerApp extends HookConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'OhMyFood Cliente',
      debugShowCheckedModeBanner: false,
      theme: OhMyFoodTheme.light(),
      routerConfig: router,
    );
  }
}
