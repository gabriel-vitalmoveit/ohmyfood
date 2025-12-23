import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/providers/restaurant_providers.dart';

class MenuItemDialog extends HookConsumerWidget {
  const MenuItemDialog({
    super.key,
    required this.restaurantId,
    this.item,
    required this.onSaved,
  });

  final String restaurantId;
  final Map<String, dynamic>? item;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final descriptionController = TextEditingController(text: item?['description'] ?? '');
    final priceController = TextEditingController(
      text: item != null ? ((item!['priceCents'] ?? 0) / 100).toStringAsFixed(2) : '',
    );
    final available = useState(item?['available'] ?? true);
    final isLoading = useState(false);

    return AlertDialog(
      title: Text(item == null ? 'Adicionar item' : 'Editar item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: Bitoque Clássico',
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva o prato',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Preço (€)',
                hintText: '9.50',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            Row(
              children: [
                const Text('Disponível'),
                const Spacer(),
                Switch(
                  value: available.value,
                  onChanged: (value) => available.value = value,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isLoading.value
              ? null
              : () async {
                  isLoading.value = true;
                  try {
                    final apiClient = ref.read(restaurantApiClientProvider);
                    final priceCents = (double.tryParse(priceController.text) ?? 0.0 * 100).toInt();

                    if (item == null) {
                      // Create
                      await apiClient.createMenuItem(
                        restaurantId,
                        {
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'priceCents': priceCents,
                          'available': available.value,
                        },
                      );
                    } else {
                      // Update
                      await apiClient.updateMenuItem(
                        restaurantId,
                        item!['id'],
                        {
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'priceCents': priceCents,
                          'available': available.value,
                        },
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      onSaved();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(item == null ? 'Item adicionado' : 'Item atualizado'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro: ${e.toString()}'),
                          backgroundColor: OhMyFoodColors.error,
                        ),
                      );
                    }
                  } finally {
                    isLoading.value = false;
                  }
                },
          child: isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(item == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }
}

