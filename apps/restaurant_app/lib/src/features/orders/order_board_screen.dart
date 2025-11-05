import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/mock_data.dart';

class OrderBoardScreen extends HookConsumerWidget {
  const OrderBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = <String, List<KitchenOrder>>{
      'Novos': activeOrders.where((o) => o.status == OrderStatus.awaitingAcceptance).toList(),
      'A preparar': activeOrders.where((o) => o.status == OrderStatus.preparing).toList(),
      'Pickup': activeOrders.where((o) => o.status == OrderStatus.pickup).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de pedidos'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.print_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_alt)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns.entries.map((entry) {
            final orders = entry.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(entry.key, style: OhMyFoodTypography.titleMd),
                        const SizedBox(width: OhMyFoodSpacing.xs),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: OhMyFoodColors.restaurantAccent.withOpacity(0.12),
                          child: Text(orders.length.toString(), style: OhMyFoodTypography.caption),
                        ),
                      ],
                    ),
                    const SizedBox(height: OhMyFoodSpacing.md),
                    Expanded(
                      child: ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.sm),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            child: ListTile(
                              title: Text('Pedido ${order.id}'),
                              subtitle: Text(order.items.join(', ')),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${(order.totalCents / 100).toStringAsFixed(2)} €',
                                      style: OhMyFoodTypography.bodyBold),
                                  Text('${order.etaMinutes} min', style: OhMyFoodTypography.caption),
                                ],
                              ),
                              onTap: () => context.go('/orders/${order.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
