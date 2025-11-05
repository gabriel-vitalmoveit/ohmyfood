import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class EarningsScreen extends HookConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxValue = weeklyEarnings.values.reduce((a, b) => a > b ? a : b).toDouble();

    return OhMyFoodAppScaffold(
      title: 'Ganhos',
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Esta semana', style: OhMyFoodTypography.label),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  Text('${_formatCents(weeklyEarnings.values.fold(0, (sum, value) => sum + value))} €',
                      style: OhMyFoodTypography.titleLg),
                  const SizedBox(height: OhMyFoodSpacing.md),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyEarnings.entries
                          .map((entry) => Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: ((entry.value / maxValue) * 120).clamp(10.0, 120.0),
                                      decoration: BoxDecoration(
                                        color: OhMyFoodColors.courierAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    const SizedBox(height: OhMyFoodSpacing.xs),
                                    Text(entry.key, style: OhMyFoodTypography.caption),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Saldo disponível'),
              subtitle: Text('${_formatCents(2380)} € prontos a levantar'),
              trailing: ElevatedButton(onPressed: () {}, child: const Text('Levantar')), 
            ),
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Histórico de pagamentos'),
                  subtitle: Text('Últimos 3 depósitos'),
                ),
                const Divider(height: 0),
                ...[
                  ('15 OUT 2025', 56.40, 'Transferido via SEPA'),
                  ('12 OUT 2025', 48.20, 'Transferido via SEPA'),
                  ('09 OUT 2025', 62.75, 'Transferido via SEPA'),
                ].map(
                  (entry) => ListTile(
                    title: Text('${entry.$1} • ${entry.$2.toStringAsFixed(2)} €'),
                    subtitle: Text(entry.$3),
                    trailing: const Icon(Icons.receipt_long_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCents(int cents) => (cents / 100).toStringAsFixed(2);
}
