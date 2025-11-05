import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class FinanceScreen extends HookConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financeiro & reconciliação', style: OhMyFoodTypography.titleLg),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Row(
            children: financeSnapshot
                .map(
                  (metric) => Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(metric['title']!, style: OhMyFoodTypography.caption),
                            const SizedBox(height: OhMyFoodSpacing.sm),
                            Text(metric['value']!, style: OhMyFoodTypography.titleMd),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reembolsos pendentes', style: OhMyFoodTypography.bodyBold),
                        TextButton(onPressed: () {}, child: const Text('Exportar CSV')),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) => ListTile(
                          title: Text('Pedido #R${index + 1200} • 18.40 €'),
                          subtitle: const Text('Motivo: atraso estafeta'),
                          trailing: FilledButton(onPressed: () {}, child: const Text('Resolver')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
