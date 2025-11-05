import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/mock_data.dart';

class CourierOrderDetailScreen extends HookConsumerWidget {
  const CourierOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = availableCourierOrders.firstWhere((element) => element.id == orderId);
    const statuses = [
      OrderStatus.preparing,
      OrderStatus.pickup,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];
    final currentIndex = statuses.indexOf(order.status).clamp(0, statuses.length - 1);

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
                    Text('Pickup', style: OhMyFoodTypography.label),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    Text(order.pickupAddress, style: OhMyFoodTypography.bodyBold),
                    const SizedBox(height: OhMyFoodSpacing.md),
                    Text('Entrega', style: OhMyFoodTypography.label),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    Text(order.dropoffAddress, style: OhMyFoodTypography.bodyBold),
                    const SizedBox(height: OhMyFoodSpacing.md),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(order.customerName, style: OhMyFoodTypography.caption),
                        const SizedBox(width: OhMyFoodSpacing.md),
                        const Icon(Icons.support_agent_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text('Suporte 24/7', style: OhMyFoodTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text('Progresso', style: OhMyFoodTypography.titleMd),
            const SizedBox(height: OhMyFoodSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  final isCompleted = index <= currentIndex;
                  final label = _statusLabel(status);
                  return ListTile(
                    leading: Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? OhMyFoodColors.courierAccent : OhMyFoodColors.neutral400,
                    ),
                    title: Text(label),
                    subtitle: Text(index == currentIndex ? 'Passo atual' : ''),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(_nextActionLabel(statuses[currentIndex])),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.sm),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Reportar problema'),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return 'Restaurante a preparar';
      case OrderStatus.pickup:
        return 'Recolher pedido';
      case OrderStatus.onTheWay:
        return 'A caminho do cliente';
      case OrderStatus.delivered:
        return 'Entrega concluída';
      default:
        return status.name;
    }
  }

  String _nextActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return 'Confirmar recolha';
      case OrderStatus.pickup:
        return 'Definir como a caminho';
      case OrderStatus.onTheWay:
        return 'Marcar como entregue';
      case OrderStatus.delivered:
        return 'Pedido concluído';
      default:
        return 'Atualizar estado';
    }
  }
}
