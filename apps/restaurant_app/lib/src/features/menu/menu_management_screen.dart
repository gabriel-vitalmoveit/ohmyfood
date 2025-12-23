import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/api_client.dart';
import '../../services/providers/restaurant_providers.dart';
import 'menu_item_dialog.dart';

final menuItemsProvider = FutureProvider.family<List<dynamic>, String>((ref, restaurantId) async {
  final apiClient = ref.watch(restaurantApiClientProvider);
  try {
    return await apiClient.getMenuItems(restaurantId);
  } catch (e) {
    return [];
  }
});

class MenuManagementScreen extends HookConsumerWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantId = ref.watch(restaurantIdProvider);
    final menuAsync = restaurantId != null
        ? ref.watch(menuItemsProvider(restaurantId))
        : const AsyncValue.loading();

    return OhMyFoodAppScaffold(
      title: 'Gestão de menu',
      actions: [
        IconButton(
          onPressed: () => _showAddItemDialog(context, ref, restaurantId),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
      body: menuAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: OhMyFoodColors.neutral400),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                  Text('Nenhum item no menu', style: OhMyFoodTypography.titleMd),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  Text('Adicione itens ao seu menu para começar', style: OhMyFoodTypography.body),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(context, ref, restaurantId),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar item'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (restaurantId != null) {
                ref.invalidate(menuItemsProvider(restaurantId));
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: OhMyFoodSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OhMyFoodSpacing.md,
                    vertical: OhMyFoodSpacing.xs,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: Switch(
                        value: item['available'] ?? true,
                        onChanged: (value) async {
                          await _toggleAvailability(context, ref, restaurantId, item['id'], value);
                        },
                      ),
                      title: Text(item['name'] ?? 'Sem nome'),
                      subtitle: Text(item['description'] ?? 'Sem descrição'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${((item['priceCents'] ?? 0) / 100).toStringAsFixed(2)} €',
                            style: OhMyFoodTypography.bodyBold,
                          ),
                          const SizedBox(width: OhMyFoodSpacing.sm),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Excluir', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditItemDialog(context, ref, restaurantId, item);
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(context, ref, restaurantId, item);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: OhMyFoodColors.error),
              const SizedBox(height: OhMyFoodSpacing.lg),
              Text('Erro ao carregar menu', style: OhMyFoodTypography.titleMd),
              const SizedBox(height: OhMyFoodSpacing.sm),
              Text(error.toString(), style: OhMyFoodTypography.body),
              const SizedBox(height: OhMyFoodSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  if (restaurantId != null) {
                    ref.invalidate(menuItemsProvider(restaurantId));
                  }
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, String? restaurantId) {
    if (restaurantId == null) return;
    showDialog(
      context: context,
      builder: (context) => MenuItemDialog(
        restaurantId: restaurantId,
        onSaved: () {
          ref.invalidate(menuItemsProvider(restaurantId));
        },
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, WidgetRef ref, String? restaurantId, Map<String, dynamic> item) {
    if (restaurantId == null) return;
    showDialog(
      context: context,
      builder: (context) => MenuItemDialog(
        restaurantId: restaurantId,
        item: item,
        onSaved: () {
          ref.invalidate(menuItemsProvider(restaurantId));
        },
      ),
    );
  }

  Future<void> _toggleAvailability(
    BuildContext context,
    WidgetRef ref,
    String? restaurantId,
    String itemId,
    bool available,
  ) async {
    if (restaurantId == null) return;

    try {
      final apiClient = ref.read(restaurantApiClientProvider);
      await apiClient.updateMenuItem(restaurantId, itemId, {'available': available});
      ref.invalidate(menuItemsProvider(restaurantId));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(available ? 'Item ativado' : 'Item desativado'),
            duration: const Duration(seconds: 2),
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
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String? restaurantId,
    Map<String, dynamic> item,
  ) {
    if (restaurantId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Tem certeza que deseja excluir "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final apiClient = ref.read(restaurantApiClientProvider);
                await apiClient.deleteMenuItem(restaurantId, item['id']);
                ref.invalidate(menuItemsProvider(restaurantId));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item excluído')),
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
              }
            },
            style: TextButton.styleFrom(foregroundColor: OhMyFoodColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
