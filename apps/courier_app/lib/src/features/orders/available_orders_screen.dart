import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/providers/courier_providers.dart';
import '../../features/auth/login_screen.dart';

class AvailableOrdersScreen extends HookConsumerWidget {
  const AvailableOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(availableOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos disponíveis'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(availableOrdersProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: OhMyFoodColors.neutral400),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                  Text('Nenhum pedido disponível', style: OhMyFoodTypography.titleMd),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  Text('Fique online para receber novos pedidos', style: OhMyFoodTypography.body),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(availableOrdersProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(OhMyFoodSpacing.md),
              itemBuilder: (context, index) {
                final order = orders[index];
                final restaurant = order['restaurant'] ?? {};
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
                                  Text(restaurant['name'] ?? 'Restaurante', style: OhMyFoodTypography.bodyBold),
                                  const SizedBox(height: OhMyFoodSpacing.xs),
                                  Text('Pedido: ${order['id']}', style: OhMyFoodTypography.caption),
                                  const SizedBox(height: OhMyFoodSpacing.xs),
                                  Text(
                                    'Cliente: ${order['user']?['displayName'] ?? order['user']?['email'] ?? 'N/A'}',
                                    style: OhMyFoodTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+ ${((order['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                              style: OhMyFoodTypography.titleMd.copyWith(color: OhMyFoodColors.courierAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: OhMyFoodSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${(restaurant['lat'] as num?)?.toStringAsFixed(4) ?? 'N/A'}, ${(restaurant['lng'] as num?)?.toStringAsFixed(4) ?? 'N/A'}',
                              style: OhMyFoodTypography.caption,
                            ),
                            const SizedBox(width: OhMyFoodSpacing.md),
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text('Status: ${order['status']}', style: OhMyFoodTypography.caption),
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
                                onPressed: () async {
                                  try {
                                    final apiClient = ref.read(courierApiClientProvider);
                                    final authState = ref.read(authStateProvider);
                                    final courierId = authState.courierId;
                                    
                                    if (courierId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Erro: estafeta não encontrado'),
                                          backgroundColor: OhMyFoodColors.error,
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    // Atribuir pedido ao courier
                                    await apiClient.assignOrder(order['id'], courierId);
                                    
                                    // Refresh lista
                                    ref.invalidate(availableOrdersProvider);
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Pedido aceite com sucesso!'),
                                          backgroundColor: OhMyFoodColors.success,
                                        ),
                                      );
                                      // Navegar para detalhe do pedido
                                      context.go('/orders/${order['id']}');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      String errorMsg = 'Erro ao aceitar pedido';
                                      if (e.toString().contains('409') || e.toString().contains('já atribuído')) {
                                        errorMsg = 'Este pedido já foi atribuído a outro estafeta';
                                      } else if (e.toString().contains('403') || e.toString().contains('negado')) {
                                        errorMsg = 'Acesso negado';
                                      } else if (e.toString().contains('400') || e.toString().contains('indisponível')) {
                                        errorMsg = 'Pedido indisponível';
                                      }
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: OhMyFoodColors.error,
                                        ),
                                      );
                                      // Refresh lista mesmo em caso de erro
                                      ref.invalidate(availableOrdersProvider);
                                    }
                                  }
                                },
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
              itemCount: orders.length,
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
                onPressed: () => ref.invalidate(availableOrdersProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
