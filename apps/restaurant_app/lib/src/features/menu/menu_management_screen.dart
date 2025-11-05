import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';

class MenuManagementScreen extends HookConsumerWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OhMyFoodAppScaffold(
      title: 'Gestão de menu',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline))],
      body: ListView.builder(
        padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
        itemCount: menuEditor.length,
        itemBuilder: (context, categoryIndex) {
          final category = menuEditor[categoryIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.name, style: OhMyFoodTypography.titleMd),
                    TextButton(onPressed: () {}, child: const Text('Adicionar item')),
                  ],
                ),
                const SizedBox(height: OhMyFoodSpacing.sm),
                ...category.items.map((item) => Card(
                      child: ListTile(
                        leading: Switch(
                          value: item.available,
                          onChanged: (_) {},
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.description ?? 'Sem descrição'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${(item.priceCents / 100).toStringAsFixed(2)} €'),
                            TextButton(onPressed: () {}, child: const Text('Editar')),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
