import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class RestaurantOrderDetailScreen extends HookConsumerWidget {
  const RestaurantOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = activeOrders.firstWhere((element) => element.id == orderId);

    return Scaffold(
      appBar: AppBar(title: Text('Pedido ${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cliente', style: OhMyFoodTypography.caption),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    Text(order.customerName, style: OhMyFoodTypography.bodyBold),
                    const SizedBox(height: OhMyFoodSpacing.md),
                    Text('Items', style: OhMyFoodTypography.caption),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    ...order.items.map((item) => Text('• $item', style: OhMyFoodTypography.body)),
                    const SizedBox(height: OhMyFoodSpacing.md),
                    Text('Notas do cliente', style: OhMyFoodTypography.caption),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    Text('Sem cebola, extra molho à parte.', style: OhMyFoodTypography.body),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text('Tempo estimado', style: OhMyFoodTypography.caption),
            const SizedBox(height: OhMyFoodSpacing.xs),
            Text('${order.etaMinutes} minutos', style: OhMyFoodTypography.bodyBold),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Recusar pedido'),
                  ),
                ),
                const SizedBox(width: OhMyFoodSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Marcar como pronto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
