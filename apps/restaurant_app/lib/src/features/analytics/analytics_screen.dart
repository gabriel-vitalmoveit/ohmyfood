import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnalyticsScreen extends HookConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = const [
      ('12:00', 24),
      ('13:00', 38),
      ('14:00', 31),
      ('19:00', 42),
      ('20:00', 55),
      ('21:00', 47),
    ];
    final maxValue = data.map((e) => e.$2).reduce((a, b) => a > b ? a : b).toDouble();

    return OhMyFoodAppScaffold(
      title: 'Insights',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pico de pedidos (Hoje)', style: OhMyFoodTypography.titleMd),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data
                          .map(
                            (entry) => Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: ((entry.$2 / maxValue) * 150).clamp(10.0, 150.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: OhMyFoodColors.restaurantAccent,
                                    ),
                                  ),
                                  const SizedBox(height: OhMyFoodSpacing.xs),
                                  Text(entry.$1, style: OhMyFoodTypography.caption),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.trending_up_outlined),
                  title: Text('Itens mais vendidos'),
                  subtitle: Text('Bitoque Clássico • 124 pedidos esta semana'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.local_fire_department_outlined),
                  title: Text('Tempo médio de preparação'),
                  subtitle: Text('16 min • -2 min vs semana anterior'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.star_outline),
                  title: Text('Satisfação dos clientes'),
                  subtitle: Text('4.8 ★ • 320 reviews nos últimos 30 dias'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
