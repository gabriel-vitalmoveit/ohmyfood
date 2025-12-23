import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../services/providers/restaurant_providers.dart';

final restaurantOrdersStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, restaurantId) async* {
  final apiClient = ref.watch(restaurantApiClientProvider);
  
  // Polling a cada 10 segundos para atualização em tempo real
  while (true) {
    try {
      final orders = await apiClient.getOrders(restaurantId);
      yield (orders as List).map((o) => o as Map<String, dynamic>).toList();
      await Future.delayed(const Duration(seconds: 10));
    } catch (e) {
      yield [];
      await Future.delayed(const Duration(seconds: 10));
    }
  }
});

class OrderBoardScreen extends HookConsumerWidget {
  const OrderBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assumir restaurant ID 1 por enquanto (em produção viria do auth)
    const restaurantId = '1';
    final ordersAsync = ref.watch(restaurantOrdersStreamProvider(restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(restaurantOrdersStreamProvider(restaurantId)),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          // Agrupar pedidos por status
          final awaitingOrders = orders.where((o) => o['status'] == 'AWAITING_ACCEPTANCE').toList();
          final preparingOrders = orders.where((o) => o['status'] == 'PREPARING').toList();
          final pickupOrders = orders.where((o) => o['status'] == 'PICKUP').toList();
          final onTheWayOrders = orders.where((o) => o['status'] == 'ON_THE_WAY').toList();
          final deliveredOrders = orders.where((o) => o['status'] == 'DELIVERED').toList();

          final columns = [
            {'title': 'Novos', 'orders': awaitingOrders, 'color': OhMyFoodColors.warning},
            {'title': 'A preparar', 'orders': preparingOrders, 'color': OhMyFoodColors.restaurantAccent},
            {'title': 'Pronto', 'orders': pickupOrders, 'color': OhMyFoodColors.primary},
            {'title': 'Com estafeta', 'orders': onTheWayOrders, 'color': OhMyFoodColors.courierAccent},
            {'title': 'Entregues', 'orders': deliveredOrders, 'color': Colors.green},
          ];

          return Padding(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((column) {
                final orders = column['orders'] as List<Map<String, dynamic>>;
                final color = column['color'] as Color;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.xs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              color: color,
                            ),
                            const SizedBox(width: OhMyFoodSpacing.xs),
                            Text(column['title'] as String, style: OhMyFoodTypography.titleMd),
                            const SizedBox(width: OhMyFoodSpacing.xs),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: color.withOpacity(0.12),
                              child: Text(
                                orders.length.toString(),
                                style: OhMyFoodTypography.caption.copyWith(color: color),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OhMyFoodSpacing.md),
                        Expanded(
                          child: orders.isEmpty
                              ? Center(
                                  child: Text(
                                    'Sem pedidos',
                                    style: OhMyFoodTypography.caption.copyWith(
                                      color: OhMyFoodColors.neutral600,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: orders.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.sm),
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    final user = order['user'] ?? {};
                                    final items = order['items'] as List? ?? [];
                                    
                                    return Card(
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () => context.push('/orders/${order['id']}'),
                                        child: Padding(
                                          padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '#${order['id'].toString().substring(0, 8)}',
                                                    style: OhMyFoodTypography.bodyBold,
                                                  ),
                                                  Text(
                                                    '${((order['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                                                    style: OhMyFoodTypography.bodyBold.copyWith(
                                                      color: color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: OhMyFoodSpacing.xs),
                                              if (user['displayName'] != null)
                                                Text(
                                                  user['displayName'],
                                                  style: OhMyFoodTypography.caption,
                                                ),
                                              const SizedBox(height: OhMyFoodSpacing.xs),
                                              ...items.take(2).map((item) => Text(
                                                    '• ${item['name']} x${item['quantity']}',
                                                    style: OhMyFoodTypography.caption,
                                                  )),
                                              if (items.length > 2)
                                                Text(
                                                  '... e mais ${items.length - 2}',
                                                  style: OhMyFoodTypography.caption.copyWith(
                                                    color: OhMyFoodColors.neutral600,
                                                  ),
                                                ),
                                              const SizedBox(height: OhMyFoodSpacing.sm),
                                              if (order['courier'] != null) ...[
                                                const Divider(height: 1),
                                                const SizedBox(height: OhMyFoodSpacing.xs),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delivery_dining,
                                                      size: 16,
                                                      color: OhMyFoodColors.courierAccent,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        'Estafeta atribuído',
                                                        style: OhMyFoodTypography.caption.copyWith(
                                                          color: OhMyFoodColors.courierAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: OhMyFoodColors.error),
              const SizedBox(height: OhMyFoodSpacing.lg),
              Text('Erro ao carregar pedidos', style: OhMyFoodTypography.titleMd),
              const SizedBox(height: OhMyFoodSpacing.sm),
              Text(error.toString(), style: OhMyFoodTypography.body),
              const SizedBox(height: OhMyFoodSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(restaurantOrdersStreamProvider(restaurantId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
