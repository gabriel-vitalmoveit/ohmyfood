import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/providers/courier_providers.dart';

final onlineStatusProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineStatusProvider);
    final ordersAsync = ref.watch(availableOrdersProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OhMyFoodSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1517841905240-472988babdf9'),
                  ),
                  const SizedBox(width: OhMyFoodSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('João Ferreira', style: OhMyFoodTypography.bodyBold.copyWith(color: Colors.white)),
                        Text(online ? 'Disponível para pedidos' : 'Offline',
                            style: OhMyFoodTypography.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Switch(
                    value: online,
                    onChanged: (value) {
                      ref.read(onlineStatusProvider.notifier).state = value;
                      if (value) {
                        // Atualizar localização quando ficar online
                        ref.read(courierLocationProvider.notifier).state = {'lat': 38.7369, 'lng': -9.1377};
                        ref.invalidate(availableOrdersProvider);
                      }
                    },
                    activeColor: OhMyFoodColors.courierAccent,
                  ),
                ],
              ),
              const SizedBox(height: OhMyFoodSpacing.xl),
              Text('Hoje', style: OhMyFoodTypography.titleMd.copyWith(color: Colors.white)),
              const SizedBox(height: OhMyFoodSpacing.md),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Ganhos', value: '0.00 €')),
                  const SizedBox(width: OhMyFoodSpacing.md),
                  Expanded(child: _StatCard(label: 'Entregas', value: '0')),
                ],
              ),
              const SizedBox(height: OhMyFoodSpacing.xl),
              Text('Pedidos disponíveis', style: OhMyFoodTypography.titleMd.copyWith(color: Colors.white)),
              const SizedBox(height: OhMyFoodSpacing.md),
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Card(
                        color: Colors.white10,
                        child: Padding(
                          padding: const EdgeInsets.all(OhMyFoodSpacing.xl),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, size: 48, color: Colors.white70),
                                const SizedBox(height: OhMyFoodSpacing.md),
                                Text('Nenhum pedido disponível', style: OhMyFoodTypography.body.copyWith(color: Colors.white70)),
                                const SizedBox(height: OhMyFoodSpacing.sm),
                                Text('Fique online para receber pedidos', style: OhMyFoodTypography.caption.copyWith(color: Colors.white54)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final nextOrder = orders.first;
                    return Card(
                      color: Colors.white10,
                      child: Padding(
                        padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextOrder['restaurant']?['name'] ?? 'Restaurante',
                              style: OhMyFoodTypography.bodyBold.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: OhMyFoodSpacing.xs),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  '${(nextOrder['restaurant']?['lat'] as num?)?.toStringAsFixed(4) ?? 'N/A'}, ${(nextOrder['restaurant']?['lng'] as num?)?.toStringAsFixed(4) ?? 'N/A'}',
                                  style: OhMyFoodTypography.caption.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                            const Divider(height: OhMyFoodSpacing.xl, color: Colors.white24),
                            Text(
                              'Pedido: ${nextOrder['id']}',
                              style: OhMyFoodTypography.body.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: OhMyFoodSpacing.sm),
                            Text(
                              'Cliente: ${nextOrder['user']?['displayName'] ?? nextOrder['user']?['email'] ?? 'N/A'}',
                              style: OhMyFoodTypography.body.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: OhMyFoodSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status: ${nextOrder['status']}',
                                  style: OhMyFoodTypography.caption.copyWith(color: Colors.white70),
                                ),
                                Text(
                                  '+ ${((nextOrder['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                                  style: OhMyFoodTypography.bodyBold.copyWith(color: OhMyFoodColors.courierAccent),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => context.go('/orders'),
                                    child: const Text('Ver lista completa'),
                                  ),
                                ),
                                const SizedBox(width: OhMyFoodSpacing.md),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/orders/${nextOrder['id']}'),
                                    child: const Text('Aceitar pedido'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (error, stack) => Card(
                    color: Colors.white10,
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.xl),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.white70),
                            const SizedBox(height: OhMyFoodSpacing.md),
                            Text('Erro ao carregar pedidos', style: OhMyFoodTypography.body.copyWith(color: Colors.white70)),
                            const SizedBox(height: OhMyFoodSpacing.sm),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(availableOrdersProvider),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: OhMyFoodTypography.caption.copyWith(color: Colors.white70)),
          const SizedBox(height: OhMyFoodSpacing.sm),
          Text(value, style: OhMyFoodTypography.titleLg.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
