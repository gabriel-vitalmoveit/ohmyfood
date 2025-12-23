import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/api_client.dart';
import '../../services/providers/courier_providers.dart';
import '../../widgets/order_map_widget.dart';

final orderDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, orderId) async {
  final apiClient = ref.watch(courierApiClientProvider);
  try {
    return await apiClient.getOrderById(orderId);
  } catch (e) {
    return null;
  }
});

class CourierOrderDetailScreen extends HookConsumerWidget {
  const CourierOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final courierLocation = ref.watch(courierLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do pedido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: OhMyFoodColors.error),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                  Text('Pedido não encontrado', style: OhMyFoodTypography.titleMd),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          final restaurant = order['restaurant'] ?? {};
          final user = order['user'] ?? {};
          final restaurantLat = (restaurant['lat'] as num?)?.toDouble() ?? 38.7369;
          final restaurantLng = (restaurant['lng'] as num?)?.toDouble() ?? -9.1377;
          
          // Por enquanto, usar coordenadas do restaurante como destino (em produção viria do endereço do cliente)
          final deliveryLat = restaurantLat + 0.01;
          final deliveryLng = restaurantLng + 0.01;

          const statuses = ['AWAITING_ACCEPTANCE', 'PREPARING', 'PICKUP', 'ON_THE_WAY', 'DELIVERED'];
          final currentStatus = order['status'] as String? ?? 'AWAITING_ACCEPTANCE';
          final currentIndex = statuses.indexOf(currentStatus).clamp(0, statuses.length - 1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mapa
                OrderMapWidget(
                  restaurantLat: restaurantLat,
                  restaurantLng: restaurantLng,
                  deliveryLat: deliveryLat,
                  deliveryLng: deliveryLng,
                  courierLat: courierLocation?['lat'],
                  courierLng: courierLocation?['lng'],
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                
                // Informações do pedido
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Restaurante', style: OhMyFoodTypography.label),
                        const SizedBox(height: OhMyFoodSpacing.xs),
                        Text(
                          restaurant['name'] ?? 'N/A',
                          style: OhMyFoodTypography.bodyBold,
                        ),
                        const SizedBox(height: OhMyFoodSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$restaurantLat, $restaurantLng',
                                style: OhMyFoodTypography.caption,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: OhMyFoodSpacing.lg),
                        Text('Cliente', style: OhMyFoodTypography.label),
                        const SizedBox(height: OhMyFoodSpacing.xs),
                        Text(
                          user['displayName'] ?? user['email'] ?? 'N/A',
                          style: OhMyFoodTypography.bodyBold,
                        ),
                        if (user['phone'] != null) ...[
                          const SizedBox(height: OhMyFoodSpacing.xs),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                user['phone'],
                                style: OhMyFoodTypography.caption,
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: OhMyFoodSpacing.lg),
                        Text('Total', style: OhMyFoodTypography.label),
                        const SizedBox(height: OhMyFoodSpacing.xs),
                        Text(
                          '${((order['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                          style: OhMyFoodTypography.titleMd.copyWith(
                            color: OhMyFoodColors.courierAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                
                // Itens do pedido
                if (order['items'] != null) ...[
                  Text('Itens do pedido', style: OhMyFoodTypography.titleMd),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  ...((order['items'] as List?) ?? []).map((item) => Card(
                        child: ListTile(
                          title: Text(item['name'] ?? 'Item'),
                          subtitle: Text('Quantidade: ${item['quantity']}'),
                          trailing: Text(
                            '${((item['unitPrice'] ?? 0) / 100).toStringAsFixed(2)} €',
                            style: OhMyFoodTypography.bodyBold,
                          ),
                        ),
                      )),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                ],
                
                // Progresso
                Text('Progresso', style: OhMyFoodTypography.titleMd),
                const SizedBox(height: OhMyFoodSpacing.sm),
                ...statuses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final status = entry.value;
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
                }),
                const SizedBox(height: OhMyFoodSpacing.lg),
                
                // Ações
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, ref, orderId, currentStatus),
                    child: Text(_nextActionLabel(currentStatus)),
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Reportar problema'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: OhMyFoodColors.error),
              const SizedBox(height: OhMyFoodSpacing.lg),
              Text('Erro ao carregar pedido', style: OhMyFoodTypography.titleMd),
              const SizedBox(height: OhMyFoodSpacing.sm),
              Text(error.toString(), style: OhMyFoodTypography.body),
              const SizedBox(height: OhMyFoodSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, WidgetRef ref, String orderId, String currentStatus) async {
    final nextStatus = _getNextStatus(currentStatus);
    if (nextStatus == null) return;

    try {
      final apiClient = ref.read(courierApiClientProvider);
      await apiClient.updateOrderStatus(orderId, nextStatus);
      ref.invalidate(orderDetailProvider(orderId));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status atualizado para: ${_statusLabel(nextStatus)}'),
            backgroundColor: OhMyFoodColors.courierAccent,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: OhMyFoodColors.error,
          ),
        );
      }
    }
  }

  String? _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'AWAITING_ACCEPTANCE':
        return 'PREPARING';
      case 'PREPARING':
        return 'PICKUP';
      case 'PICKUP':
        return 'ON_THE_WAY';
      case 'ON_THE_WAY':
        return 'DELIVERED';
      default:
        return null;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'AWAITING_ACCEPTANCE':
        return 'Aguardando aceitação';
      case 'PREPARING':
        return 'Restaurante a preparar';
      case 'PICKUP':
        return 'Recolher pedido';
      case 'ON_THE_WAY':
        return 'A caminho do cliente';
      case 'DELIVERED':
        return 'Entrega concluída';
      default:
        return status;
    }
  }

  String _nextActionLabel(String status) {
    switch (status) {
      case 'AWAITING_ACCEPTANCE':
        return 'Aceitar pedido';
      case 'PREPARING':
        return 'Confirmar recolha';
      case 'PICKUP':
        return 'Definir como a caminho';
      case 'ON_THE_WAY':
        return 'Marcar como entregue';
      case 'DELIVERED':
        return 'Pedido concluído';
      default:
        return 'Atualizar estado';
    }
  }
}
