import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';
import 'package:shared_models/shared_models.dart';

class OrdersScreen extends HookConsumerWidget {
  const OrdersScreen({super.key});

  static const routeName = 'orders';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OhMyFoodAppScaffold(
      title: 'Os meus pedidos',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded)),
      ],
      body: orderHistory.isEmpty
          ? const OhMyFoodEmptyState(
              title: 'Ainda sem pedidos',
              message: 'Experimente fazer o seu primeiro pedido em Lisboa!',
            )
          : ListView.separated(
              itemCount: orderHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.sm),
              itemBuilder: (context, index) {
                final order = orderHistory[index];
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
                                  Text(order.restaurantName, style: OhMyFoodTypography.bodyBold),
                                  const SizedBox(height: OhMyFoodSpacing.xs),
                                  Text(order.itemsSummary, style: OhMyFoodTypography.caption),
                                ],
                              ),
                            ),
                            Text('${(order.totalCents / 100).toStringAsFixed(2)} €',
                                style: OhMyFoodTypography.bodyBold),
                          ],
                        ),
                        const SizedBox(height: OhMyFoodSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDate(order.placedAt), style: OhMyFoodTypography.caption),
                            OhMyFoodBadge.info(_statusLabel(order.status)),
                          ],
                        ),
                        const SizedBox(height: OhMyFoodSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.go('/tracking/${order.id}'),
                                child: const Text('Ver tracking'),
                              ),
                            ),
                            const SizedBox(width: OhMyFoodSpacing.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('Repetir pedido'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
      default:
        return 'Em progresso';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
