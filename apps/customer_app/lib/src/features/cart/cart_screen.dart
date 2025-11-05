import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../cart/controllers/cart_controller.dart';

class CartScreen extends HookConsumerWidget {
  const CartScreen({super.key});

  static const routeName = 'cart';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carrinho')),
        body: OhMyFoodEmptyState(
          title: 'Carrinho vazio',
          message: 'Adicione pratos deliciosos e volte a esta página.',
          action: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Explorar restaurantes'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        actions: [
          TextButton(
            onPressed: controller.clear,
            child: const Text('Limpar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.item.name, style: OhMyFoodTypography.bodyBold),
                                const SizedBox(height: OhMyFoodSpacing.xs),
                                Text('${(item.item.priceCents / 100).toStringAsFixed(2)} €',
                                    style: OhMyFoodTypography.body.copyWith(color: OhMyFoodColors.neutral600)),
                              ],
                            ),
                          ),
                          _QuantityStepper(
                            quantity: item.quantity,
                            onChanged: (value) => controller.updateQuantity(item.item.id, value),
                          ),
                          IconButton(
                            onPressed: () => controller.removeItem(item.item.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.sm),
                itemCount: cart.items.length,
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            _SummaryRow(label: 'Subtotal', value: cart.itemsTotalCents),
            _SummaryRow(label: 'Taxa de serviço', value: cart.serviceFeeCents),
            _SummaryRow(label: 'Entrega', value: cart.deliveryFeeCents),
            const Divider(height: OhMyFoodSpacing.xl),
            _SummaryRow(label: 'Total', value: cart.totalCents, emphasize: true),
            const SizedBox(height: OhMyFoodSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/home/cart/checkout'),
                child: const Text('Ir para checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(quantity.toString(), style: OhMyFoodTypography.bodyBold),
        IconButton(
          onPressed: () => onChanged(quantity + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final int value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? OhMyFoodTypography.bodyBold.copyWith(fontSize: 18)
        : OhMyFoodTypography.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${(value / 100).toStringAsFixed(2)} €', style: style),
        ],
      ),
    );
  }
}
