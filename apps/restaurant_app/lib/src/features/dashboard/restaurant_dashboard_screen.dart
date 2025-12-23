import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/providers/restaurant_providers.dart';

class RestaurantDashboardScreen extends HookConsumerWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(restaurantStatsProvider);
    final ordersAsync = ref.watch(restaurantOrdersProvider(null));

    return OhMyFoodAppScaffold(
      title: 'Tasca do Bairro',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))],
      body: statsAsync.when(
        data: (stats) => ordersAsync.when(
          data: (orders) => _buildContent(context, ref, stats, orders),
          loading: () => _buildLoading(context, ref, stats),
          error: (error, stack) => _buildError(context, ref, error),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, ref, error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> stats, List<dynamic> orders) {
    final highlightOrder = orders.isNotEmpty ? orders.first : null;

    return ListView(
      padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
          child: Text('Hoje', style: OhMyFoodTypography.titleMd),
        ),
        const SizedBox(height: OhMyFoodSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: OhMyFoodSpacing.md,
            crossAxisSpacing: OhMyFoodSpacing.md,
            children: [
              _MetricCard(
                label: 'Pedidos hoje',
                value: '${stats['ordersToday'] ?? 0}',
              ),
              _MetricCard(
                label: 'Tempo médio',
                value: '${stats['avgPrepMin'] ?? 15} min',
              ),
              _MetricCard(
                label: 'Ticket médio',
                value: '${((stats['avgTicket'] ?? 0) / 100).toStringAsFixed(2)} €',
              ),
              _MetricCard(
                label: 'Receita hoje',
                value: '${((stats['revenueToday'] ?? 0) / 100).toStringAsFixed(2)} €',
              ),
            ],
          ),
        ),
        if (highlightOrder != null) ...[
          const SizedBox(height: OhMyFoodSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
            child: Text('Em destaque', style: OhMyFoodTypography.titleMd),
          ),
          const SizedBox(height: OhMyFoodSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido ${highlightOrder['id']}', style: OhMyFoodTypography.bodyBold),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    Text(
                      'Cliente: ${highlightOrder['user']?['displayName'] ?? highlightOrder['user']?['email'] ?? 'N/A'}',
                      style: OhMyFoodTypography.caption,
                    ),
                    const SizedBox(height: OhMyFoodSpacing.sm),
                    ...((highlightOrder['items'] as List?) ?? []).map((item) => Text(
                          '• ${item['name']} x${item['quantity']}',
                          style: OhMyFoodTypography.body,
                        )),
                    const SizedBox(height: OhMyFoodSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${highlightOrder['status']}',
                          style: OhMyFoodTypography.caption,
                        ),
                        Text(
                          '${((highlightOrder['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                          style: OhMyFoodTypography.bodyBold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: OhMyFoodSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
          child: Text('Fila atual', style: OhMyFoodTypography.titleMd),
        ),
        const SizedBox(height: OhMyFoodSpacing.md),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: OhMyFoodColors.neutral400),
                      const SizedBox(height: OhMyFoodSpacing.md),
                      Text('Nenhum pedido no momento', style: OhMyFoodTypography.body),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
              child: Card(
                child: ListTile(
                  title: Text(
                    'Pedido ${order['id']} • ${order['user']?['displayName'] ?? order['user']?['email'] ?? 'N/A'}',
                  ),
                  subtitle: Text(
                    (order['items'] as List?)?.map((item) => '${item['name']} x${item['quantity']}').join(', ') ?? '',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (order['status'] as String?)?.toUpperCase() ?? '',
                        style: OhMyFoodTypography.caption,
                      ),
                      Text(
                        '${((order['total'] ?? 0) / 100).toStringAsFixed(2)} €',
                        style: OhMyFoodTypography.bodyBold,
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              ),
            ),
          ),
        const SizedBox(height: OhMyFoodSpacing.xl),
      ],
    );
  }

  Widget _buildLoading(BuildContext context, WidgetRef ref, Map<String, dynamic> stats) {
    return ListView(
      padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
          child: Text('Hoje', style: OhMyFoodTypography.titleMd),
        ),
        const SizedBox(height: OhMyFoodSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: OhMyFoodSpacing.md,
            crossAxisSpacing: OhMyFoodSpacing.md,
            children: [
              _MetricCard(label: 'Pedidos hoje', value: '${stats['ordersToday'] ?? 0}'),
              _MetricCard(label: 'Tempo médio', value: '${stats['avgPrepMin'] ?? 15} min'),
              _MetricCard(label: 'Ticket médio', value: '${((stats['avgTicket'] ?? 0) / 100).toStringAsFixed(2)} €'),
              _MetricCard(label: 'Receita hoje', value: '${((stats['revenueToday'] ?? 0) / 100).toStringAsFixed(2)} €'),
            ],
          ),
        ),
        const SizedBox(height: OhMyFoodSpacing.xl),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: OhMyFoodColors.error),
          const SizedBox(height: OhMyFoodSpacing.md),
          Text('Erro ao carregar dados', style: OhMyFoodTypography.titleMd),
          const SizedBox(height: OhMyFoodSpacing.sm),
          Text(error.toString(), style: OhMyFoodTypography.body),
          const SizedBox(height: OhMyFoodSpacing.lg),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(restaurantStatsProvider);
              ref.invalidate(restaurantOrdersProvider(null));
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: OhMyFoodTypography.caption),
            const SizedBox(height: OhMyFoodSpacing.sm),
            Text(value, style: OhMyFoodTypography.titleMd),
          ],
        ),
      ),
    );
  }
}
