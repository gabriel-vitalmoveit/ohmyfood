import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router.dart';

class RestaurantApp extends HookConsumerWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(restaurantRouterProvider);

    return MaterialApp.router(
      title: 'OhMyFood Restaurante',
      debugShowCheckedModeBanner: false,
      theme: OhMyFoodTheme.light(seed: OhMyFoodColors.restaurantAccent),
      routerConfig: router,
    );
  }
}
