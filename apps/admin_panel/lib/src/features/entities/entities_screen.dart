import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class EntitiesScreen extends HookConsumerWidget {
  const EntitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestão de entidades', style: OhMyFoodTypography.titleLg),
          const SizedBox(height: OhMyFoodSpacing.lg),
          Wrap(
            spacing: OhMyFoodSpacing.md,
            children: entitiesSnapshot.entries
                .map(
                  (entry) => Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    backgroundColor: OhMyFoodColors.adminAccent.withOpacity(0.1),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: OhMyFoodSpacing.xl),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _EntityTable(title: 'Restaurantes', columns: const ['Nome', 'Estado', 'Pedidos hoje'])),
                const SizedBox(width: OhMyFoodSpacing.md),
                Expanded(child: _EntityTable(title: 'Estafetas', columns: const ['Nome', 'Documento', 'Status'])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntityTable extends StatelessWidget {
  const _EntityTable({required this.title, required this.columns});

  final String title;
  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: OhMyFoodTypography.bodyBold),
                TextButton(onPressed: () {}, child: const Text('Ver todos')),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: columns.map((column) => DataColumn(label: Text(column))).toList(),
                rows: List.generate(
                  5,
                  (index) => DataRow(cells: columns.map((column) => DataCell(Text('$column #${index + 1}'))).toList()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
