import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

final onlineStatusProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineStatusProvider);
    final nextOrder = availableCourierOrders.first;

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
                    onChanged: (value) => ref.read(onlineStatusProvider.notifier).state = value,
                    activeColor: OhMyFoodColors.courierAccent,
                  ),
                ],
              ),
              const SizedBox(height: OhMyFoodSpacing.xl),
              Text('Hoje', style: OhMyFoodTypography.titleMd.copyWith(color: Colors.white)),
              const SizedBox(height: OhMyFoodSpacing.md),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Ganhos', value: '${(courierStats.earningsTodayCents / 100).toStringAsFixed(2)} €')),
                  const SizedBox(width: OhMyFoodSpacing.md),
                  Expanded(child: _StatCard(label: 'Entregas', value: '${courierStats.completedToday}')), 
                ],
              ),
              const SizedBox(height: OhMyFoodSpacing.md),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'KMs', value: courierStats.kilometers.toStringAsFixed(1))),
                  const SizedBox(width: OhMyFoodSpacing.md),
                  Expanded(child: _StatCard(label: 'Rating', value: courierStats.rating.toStringAsFixed(2))),
                ],
              ),
              const SizedBox(height: OhMyFoodSpacing.xl),
              Text('Pedido destacado', style: OhMyFoodTypography.titleMd.copyWith(color: Colors.white)),
              const SizedBox(height: OhMyFoodSpacing.md),
              Expanded(
                child: Card(
                  color: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nextOrder.pickupAddress, style: OhMyFoodTypography.bodyBold.copyWith(color: Colors.white)),
                        const SizedBox(height: OhMyFoodSpacing.xs),
                        Row(
                          children: [
                            const Icon(Icons.navigation, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('${nextOrder.distanceKm.toStringAsFixed(1)} km até ao cliente',
                                style: OhMyFoodTypography.caption.copyWith(color: Colors.white70)),
                          ],
                        ),
                        const Divider(height: OhMyFoodSpacing.xl, color: Colors.white24),
                        Text('Entrega: ${nextOrder.dropoffAddress}',
                            style: OhMyFoodTypography.body.copyWith(color: Colors.white)),
                        const SizedBox(height: OhMyFoodSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pronto em ${nextOrder.readyInMinutes} min',
                                style: OhMyFoodTypography.caption.copyWith(color: Colors.white70)),
                            Text('+ ${(nextOrder.earningCents / 100).toStringAsFixed(2)} €',
                                style: OhMyFoodTypography.bodyBold.copyWith(color: OhMyFoodColors.courierAccent)),
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
                                onPressed: () => context.go('/orders/${nextOrder.id}'),
                                child: const Text('Aceitar pedido'),
                              ),
                            ),
                          ],
                        ),
                      ],
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
