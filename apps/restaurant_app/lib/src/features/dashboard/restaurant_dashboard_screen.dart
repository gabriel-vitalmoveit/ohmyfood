import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class RestaurantDashboardScreen extends HookConsumerWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightOrder = activeOrders.first;

    return OhMyFoodAppScaffold(
      title: 'Tasca do Bairro',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))],
      body: ListView(
        padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
        children: [
          Text('Hoje', style: OhMyFoodTypography.titleMd),
          const SizedBox(height: OhMyFoodSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: OhMyFoodSpacing.md,
            crossAxisSpacing: OhMyFoodSpacing.md,
            children: restaurantMetrics.entries
                .map((entry) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key, style: OhMyFoodTypography.caption),
                            const SizedBox(height: OhMyFoodSpacing.sm),
                            Text(entry.value, style: OhMyFoodTypography.titleMd),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          Text('Em destaque', style: OhMyFoodTypography.titleMd),
          const SizedBox(height: OhMyFoodSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedido ${highlightOrder.id}', style: OhMyFoodTypography.bodyBold),
                  const SizedBox(height: OhMyFoodSpacing.xs),
                  Text('Cliente: ${highlightOrder.customerName}', style: OhMyFoodTypography.caption),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  ...highlightOrder.items.map((item) => Text('• $item', style: OhMyFoodTypography.body)),
                  const SizedBox(height: OhMyFoodSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pronto em ${highlightOrder.etaMinutes} min', style: OhMyFoodTypography.caption),
                      Text('${(highlightOrder.totalCents / 100).toStringAsFixed(2)} €',
                          style: OhMyFoodTypography.bodyBold),
                    ],
                  ),
                  const SizedBox(height: OhMyFoodSpacing.md),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Pausar loja'))),
                      const SizedBox(width: OhMyFoodSpacing.md),
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Chamar estafeta'))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          Text('Fila atual', style: OhMyFoodTypography.titleMd),
          const SizedBox(height: OhMyFoodSpacing.md),
          ...activeOrders.map(
            (order) => Card(
              child: ListTile(
                title: Text('Pedido ${order.id} • ${order.customerName}'),
                subtitle: Text('${order.items.join(', ')}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order.status.name.toUpperCase(), style: OhMyFoodTypography.caption),
                    Text('${order.etaMinutes} min', style: OhMyFoodTypography.bodyBold),
                  ],
                ),
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
