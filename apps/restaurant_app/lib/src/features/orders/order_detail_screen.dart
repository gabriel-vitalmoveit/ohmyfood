import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/providers/restaurant_providers.dart';

final restaurantOrderDetailProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, orderId) async* {
  final apiClient = ref.watch(restaurantApiClientProvider);
  
  // Polling a cada 5 segundos para atualização em tempo real
  while (true) {
    try {
      final order = await apiClient.getOrderById(orderId);
      yield order;
      
      // Se pedido foi entregue ou cancelado, parar polling
      final status = order['status'] as String?;
      if (status == 'DELIVERED' || status == 'CANCELLED' || status == 'ON_THE_WAY') {
        // Parar quando entregar ao estafeta
        break;
      }
      
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      yield null;
      await Future.delayed(const Duration(seconds: 5));
    }
  }
});

class RestaurantOrderDetailScreen extends HookConsumerWidget {
  const RestaurantOrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(restaurantOrderDetailProvider(orderId));
    final displayId = orderId.length > 8 ? '${orderId.substring(0, 8)}…' : orderId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$displayId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(restaurantOrderDetailProvider(orderId)),
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

          final status = order['status'] as String? ?? 'AWAITING_ACCEPTANCE';
          final user = order['user'] ?? {};
          final items = order['items'] as List? ?? [];
          final courier = order['courier'] as Map<String, dynamic>?;

          // Timeline de status até entregar ao estafeta
          const restaurantStatusTimeline = [
            'AWAITING_ACCEPTANCE',
            'PREPARING',
            'PICKUP',
            'ON_THE_WAY', // Quando entregar ao estafeta
          ];
          final currentIndex = restaurantStatusTimeline.indexOf(status).clamp(0, restaurantStatusTimeline.length - 1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações do cliente
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              Text(user['phone'], style: OhMyFoodTypography.caption),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                
                // Itens do pedido
                Text('Itens do pedido', style: OhMyFoodTypography.titleMd),
                const SizedBox(height: OhMyFoodSpacing.sm),
                ...items.map((item) => Card(
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
                
                // Timeline de status
                Text('Status do pedido', style: OhMyFoodTypography.titleMd),
                const SizedBox(height: OhMyFoodSpacing.md),
                Column(
                  children: [
                    for (var i = 0; i < restaurantStatusTimeline.length; i++)
                      _TimelineTile(
                        status: restaurantStatusTimeline[i],
                        isCompleted: i <= currentIndex,
                        isCurrent: i == currentIndex,
                      ),
                  ],
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                
                // Estafeta (se atribuído)
                if (courier != null) ...[
                  Card(
                    color: OhMyFoodColors.courierAccent.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.delivery_dining, color: OhMyFoodColors.courierAccent),
                          const SizedBox(width: OhMyFoodSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estafeta atribuído',
                                  style: OhMyFoodTypography.bodyBold,
                                ),
                                Text(
                                  courier['displayName'] ?? 'Estafeta',
                                  style: OhMyFoodTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                ],
                
                // Total
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: OhMyFoodTypography.bodyBold),
                        Text(
                          '${((order['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                          style: OhMyFoodTypography.titleMd.copyWith(
                            color: OhMyFoodColors.restaurantAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.xl),
                
                // Ações
                if (status == 'AWAITING_ACCEPTANCE') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(context, ref, orderId, 'CANCELLED'),
                          child: const Text('Recusar pedido'),
                        ),
                      ),
                      const SizedBox(width: OhMyFoodSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(context, ref, orderId, 'PREPARING'),
                          child: const Text('Aceitar pedido'),
                        ),
                      ),
                    ],
                  ),
                ] else if (status == 'PREPARING') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, ref, orderId, 'PICKUP'),
                      child: const Text('Marcar como pronto'),
                    ),
                  ),
                ] else if (status == 'PICKUP' && courier == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Aguardando estafeta'),
                    ),
                  ),
                ] else if (status == 'ON_THE_WAY') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Pedido com estafeta'),
                    ),
                  ),
                ],
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
                onPressed: () => ref.invalidate(restaurantOrderDetailProvider(orderId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String orderId, String status) async {
    try {
      final apiClient = ref.read(restaurantApiClientProvider);
      await apiClient.updateOrderStatus(orderId, status);
      ref.invalidate(restaurantOrderDetailProvider(orderId));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status atualizado: ${_statusLabel(status)}'),
            backgroundColor: OhMyFoodColors.restaurantAccent,
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

  String _statusLabel(String status) {
    switch (status) {
      case 'AWAITING_ACCEPTANCE':
        return 'A aguardar aceitação';
      case 'PREPARING':
        return 'A ser preparado';
      case 'PICKUP':
        return 'Pronto para recolha';
      case 'ON_THE_WAY':
        return 'Com estafeta';
      case 'DELIVERED':
        return 'Entregue';
      case 'CANCELLED':
        return 'Cancelado';
      default:
        return status;
    }
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
  });

  final String status;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final statusLabel = {
      'AWAITING_ACCEPTANCE': 'A aguardar aceitação',
      'PREPARING': 'A ser preparado',
      'PICKUP': 'Pronto para recolha',
      'ON_THE_WAY': 'Entregue ao estafeta',
    }[status] ?? status;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? OhMyFoodColors.restaurantAccent : OhMyFoodColors.neutral200,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: OhMyFoodColors.restaurantAccent, width: 3)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (status != 'ON_THE_WAY')
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? OhMyFoodColors.restaurantAccent : OhMyFoodColors.neutral200,
              ),
          ],
        ),
        const SizedBox(width: OhMyFoodSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: isCurrent
                      ? OhMyFoodTypography.bodyBold
                      : OhMyFoodTypography.body.copyWith(
                          color: isCompleted ? OhMyFoodColors.neutral600 : OhMyFoodColors.neutral600,
                        ),
                ),
                const SizedBox(height: OhMyFoodSpacing.xs),
                Text(
                  isCurrent
                      ? 'Em progresso...'
                      : isCompleted
                          ? 'Concluído'
                          : 'Aguardando',
                  style: OhMyFoodTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
