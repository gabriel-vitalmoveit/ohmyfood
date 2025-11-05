import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class LiveOpsScreen extends HookConsumerWidget {
  const LiveOpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Operations', style: OhMyFoodTypography.titleLg),
          const SizedBox(height: OhMyFoodSpacing.lg),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: adminDashboardMetrics.length,
              separatorBuilder: (_, __) => const SizedBox(width: OhMyFoodSpacing.md),
              itemBuilder: (context, index) {
                final metric = adminDashboardMetrics[index];
                return Container(
                  width: 220,
                  padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: OhMyFoodColors.adminAccent.withOpacity(0.08),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric.label, style: OhMyFoodTypography.caption),
                      const Spacer(),
                      Text(metric.value, style: OhMyFoodTypography.titleMd),
                      if (metric.delta != null)
                        Text(metric.delta!, style: OhMyFoodTypography.caption.copyWith(color: Colors.green)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Mapa em tempo real', style: OhMyFoodTypography.bodyBold),
                              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.fullscreen), label: const Text('Expandir')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: OhMyFoodColors.neutral100,
                            child: Center(
                              child: Text('Mapa (Mapbox) placeholder', style: OhMyFoodTypography.body),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: OhMyFoodSpacing.md),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedidos críticos', style: OhMyFoodTypography.bodyBold),
                          const SizedBox(height: OhMyFoodSpacing.sm),
                          Expanded(
                            child: ListView.separated(
                              itemCount: liveOrders.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final order = liveOrders[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Pedido ${order.id} • ${order.customerName}'),
                                  subtitle: Text('Status: ${order.status} • Estafeta: ${order.courierName}'),
                                  trailing: const Icon(Icons.open_in_new),
                                  onTap: () {},
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
