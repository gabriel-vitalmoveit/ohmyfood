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
        appBar: AppBar(
          title: const Text('Carrinho'),
          elevation: 0,
        ),
        body: OhMyFoodEmptyState(
          title: 'Carrinho vazio',
          message: 'Adicione pratos deliciosos e volte a esta página.',
          action: ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Explorar restaurantes'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Limpar carrinho?'),
                  content: const Text('Tem a certeza que deseja remover todos os itens?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clear();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: OhMyFoodColors.error,
                      ),
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(OhMyFoodSpacing.md),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.item.name,
                                  style: OhMyFoodTypography.bodyBold.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(item.item.priceCents / 100).toStringAsFixed(2)} €',
                                  style: OhMyFoodTypography.body.copyWith(
                                    color: OhMyFoodColors.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _QuantityStepper(
                            quantity: item.quantity,
                            onChanged: (value) => controller.updateQuantity(item.item.id, value),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => controller.removeItem(item.item.id),
                            icon: const Icon(Icons.delete_outline),
                            color: OhMyFoodColors.error,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: OhMyFoodSpacing.sm),
              itemCount: cart.items.length,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(OhMyFoodSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Subtotal',
                  value: cart.itemsTotalCents,
                ),
                _SummaryRow(
                  label: 'Taxa de serviço',
                  value: cart.serviceFeeCents,
                ),
                _SummaryRow(
                  label: 'Entrega',
                  value: cart.deliveryFeeCents,
                ),
                const Divider(height: OhMyFoodSpacing.xl),
                _SummaryRow(
                  label: 'Total',
                  value: cart.totalCents,
                  emphasize: true,
                ),
                const SizedBox(height: OhMyFoodSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/home/cart/checkout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Ir para checkout'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: OhMyFoodColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.remove,
                  size: 18,
                  color: quantity > 1 ? OhMyFoodColors.neutral900 : OhMyFoodColors.neutral400,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              quantity.toString(),
              style: OhMyFoodTypography.bodyBold.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(quantity + 1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: OhMyFoodColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
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
        ? OhMyFoodTypography.titleMd.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )
        : OhMyFoodTypography.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: style,
          ),
          Text(
            '${(value / 100).toStringAsFixed(2)} €',
            style: style,
          ),
        ],
      ),
    );
  }
}
