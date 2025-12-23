import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../services/api_client.dart';
import '../../services/providers/api_providers.dart';
import '../../services/here_maps_service.dart';
import '../../widgets/tracking_map_widget.dart';

final orderTrackingProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, orderId) async* {
  final apiClient = ref.watch(apiClientProvider);
  
  // Polling a cada 5 segundos para atualização em tempo real
  while (true) {
    try {
      final order = await apiClient.getOrderById(orderId);
      yield order;
      
      // Se pedido foi entregue ou cancelado, parar polling
      final status = order['status'] as String?;
      if (status == 'DELIVERED' || status == 'CANCELLED') {
        break;
      }
      
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      yield null;
      await Future.delayed(const Duration(seconds: 5));
    }
  }
});

class TrackingScreen extends HookConsumerWidget {
  const TrackingScreen({required this.orderId, super.key});

  static const routeName = 'tracking';

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderTrackingProvider(orderId));
    final displayId = orderId.length > 8 ? '${orderId.substring(0, 8)}…' : orderId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$displayId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(orderTrackingProvider(orderId)),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          final status = order['status'] as String? ?? 'DRAFT';
          final restaurant = order['restaurant'] ?? {};
          final courier = order['courier'] as Map<String, dynamic>?;
          final restaurantLat = (restaurant['lat'] as num?)?.toDouble() ?? 38.7369;
          final restaurantLng = (restaurant['lng'] as num?)?.toDouble() ?? -9.1377;
          
          // Por enquanto, usar coordenadas do restaurante como destino (em produção viria do endereço do cliente)
          final deliveryLat = restaurantLat + 0.01;
          final deliveryLng = restaurantLng + 0.01;

          const statusTimeline = [
            'AWAITING_ACCEPTANCE',
            'PREPARING',
            'PICKUP',
            'ON_THE_WAY',
            'DELIVERED',
          ];
          final currentIndex = statusTimeline.indexOf(status).clamp(0, statusTimeline.length - 1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mapa de tracking
                TrackingMapWidget(
                  restaurantLat: restaurantLat,
                  restaurantLng: restaurantLng,
                  deliveryLat: deliveryLat,
                  deliveryLng: deliveryLng,
                  courierLat: null, // Em produção, viria da localização do courier
                  courierLng: null,
                  status: status,
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                
                // Informações do estafeta (se atribuído)
                if (courier != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e'),
                          ),
                          const SizedBox(width: OhMyFoodSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  courier['displayName'] ?? 'Estafeta',
                                  style: OhMyFoodTypography.bodyBold,
                                ),
                                Text(
                                  status == 'ON_THE_WAY' ? 'A caminho' : 'Aguardando',
                                  style: OhMyFoodTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          if (courier['phone'] != null)
                            FilledButton.icon(
                              onPressed: () {
                                // Abrir app de telefone
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text('Ligar'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                ],
                
                // Linha temporal de status
                Text('Status do pedido', style: OhMyFoodTypography.titleMd),
                const SizedBox(height: OhMyFoodSpacing.md),
                Column(
                  children: [
                    for (var i = 0; i < statusTimeline.length; i++)
                      _TimelineTile(
                        status: statusTimeline[i],
                        isCompleted: i <= currentIndex,
                        isCurrent: i == currentIndex,
                      ),
                  ],
                ),
                const SizedBox(height: OhMyFoodSpacing.xl),
                
                // Resumo do pedido
                Text('Resumo do pedido', style: OhMyFoodTypography.titleMd),
                const SizedBox(height: OhMyFoodSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant['name'] ?? 'Restaurante',
                          style: OhMyFoodTypography.bodyBold,
                        ),
                        const SizedBox(height: OhMyFoodSpacing.sm),
                        if (order['items'] != null)
                          ...((order['items'] as List?) ?? []).map((item) => Text(
                                '• ${item['name']} x${item['quantity']}',
                                style: OhMyFoodTypography.body,
                              )),
                        const Divider(height: OhMyFoodSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: OhMyFoodTypography.bodyBold),
                            Text(
                              '${((order['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                              style: OhMyFoodTypography.titleMd.copyWith(
                                color: OhMyFoodColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
              Text('Erro ao carregar tracking', style: OhMyFoodTypography.titleMd),
              const SizedBox(height: OhMyFoodSpacing.sm),
              Text(error.toString(), style: OhMyFoodTypography.body),
              const SizedBox(height: OhMyFoodSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderTrackingProvider(orderId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OhMyFoodSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Ajuda 24/7'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      'ON_THE_WAY': 'A caminho',
      'DELIVERED': 'Entregue',
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
                color: isCompleted ? OhMyFoodColors.primary : OhMyFoodColors.neutral200,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: OhMyFoodColors.primary, width: 3)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (status != 'DELIVERED')
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? OhMyFoodColors.primary : OhMyFoodColors.neutral200,
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
