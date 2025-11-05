import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class AvailableOrdersScreen extends HookConsumerWidget {
  const AvailableOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos disponíveis'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        itemBuilder: (context, index) {
          final order = availableCourierOrders[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.pickupAddress, style: OhMyFoodTypography.bodyBold),
                            const SizedBox(height: OhMyFoodSpacing.xs),
                            Text('Entrega: ${order.dropoffAddress}', style: OhMyFoodTypography.caption),
                          ],
                        ),
                      ),
                      Text('+ ${(order.earningCents / 100).toStringAsFixed(2)} €',
                          style: OhMyFoodTypography.titleMd.copyWith(color: OhMyFoodColors.courierAccent)),
                    ],
                  ),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text('Pronto em ${order.readyInMinutes} min', style: OhMyFoodTypography.caption),
                      const SizedBox(width: OhMyFoodSpacing.md),
                      const Icon(Icons.directions_bike_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text('${order.distanceKm.toStringAsFixed(1)} km', style: OhMyFoodTypography.caption),
                    ],
                  ),
                  const SizedBox(height: OhMyFoodSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Recusar'),
                        ),
                      ),
                      const SizedBox(width: OhMyFoodSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.go('/orders/${order.id}'),
                          child: const Text('Aceitar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.md),
        itemCount: availableCourierOrders.length,
      ),
    );
  }
}
