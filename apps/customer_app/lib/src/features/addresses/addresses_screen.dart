import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/providers/api_providers.dart';

final addressesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    return await apiClient.getAddresses();
  } catch (e) {
    return [];
  }
});

class AddressesScreen extends HookConsumerWidget {
  const AddressesScreen({super.key});

  static const routeName = 'addresses';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moradas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/addresses/new'),
          ),
        ],
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 64, color: OhMyFoodColors.neutral400),
                  const SizedBox(height: OhMyFoodSpacing.lg),
                  Text('Sem moradas', style: OhMyFoodTypography.titleMd),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/addresses/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar morada'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.sm),
            itemBuilder: (context, index) {
              final address = addresses[index];
              final isDefault = address['isDefault'] == true;
              
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: isDefault ? OhMyFoodColors.primary : OhMyFoodColors.neutral400,
                  ),
                  title: Text(
                    address['label'] ?? 'Morada',
                    style: OhMyFoodTypography.bodyBold,
                  ),
                  subtitle: Text(
                    '${address['street']} ${address['number']}, ${address['postalCode']} ${address['city']}',
                    style: OhMyFoodTypography.caption,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: OhMyFoodColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Padrão',
                            style: OhMyFoodTypography.caption.copyWith(color: OhMyFoodColors.primary),
                          ),
                        ),
                      const SizedBox(width: OhMyFoodSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context.push('/addresses/${address['id']}'),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/addresses/${address['id']}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: OhMyFoodColors.error),
              const SizedBox(height: OhMyFoodSpacing.lg),
              Text('Erro ao carregar moradas', style: OhMyFoodTypography.titleMd),
              const SizedBox(height: OhMyFoodSpacing.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(addressesProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

