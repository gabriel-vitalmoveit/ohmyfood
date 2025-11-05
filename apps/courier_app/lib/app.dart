import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router.dart';

class CourierApp extends HookConsumerWidget {
  const CourierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(courierRouterProvider);

    return MaterialApp.router(
      title: 'OhMyFood Estafeta',
      debugShowCheckedModeBanner: false,
      theme: OhMyFoodTheme.dark().copyWith(
        colorScheme: OhMyFoodTheme.dark().colorScheme.copyWith(primary: OhMyFoodColors.courierAccent),
      ),
      routerConfig: router,
    );
  }
}
