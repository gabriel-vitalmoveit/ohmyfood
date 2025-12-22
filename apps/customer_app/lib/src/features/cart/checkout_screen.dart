import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../cart/controllers/cart_controller.dart';

class CheckoutScreen extends HookConsumerWidget {
  const CheckoutScreen({super.key});

  static const routeName = 'checkout';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Morada de entrega',
              style: OhMyFoodTypography.titleMd.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.sm),
            _InfoCard(
              icon: Icons.home_rounded,
              iconColor: OhMyFoodColors.primary,
              title: 'Alameda Dom Afonso Henriques 5B',
              subtitle: '3.º Esquerdo • Campainha: OHMYFOOD',
              actionLabel: 'Editar',
              onAction: () {},
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text(
              'Pagamento',
              style: OhMyFoodTypography.titleMd.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.sm),
            _InfoCard(
              icon: Icons.credit_card,
              iconColor: OhMyFoodColors.courierAccent,
              title: 'Visa •••• 1234',
              subtitle: 'Expira 04/27',
              actionLabel: 'Alterar',
              onAction: () {},
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            _PaymentSelector(onSelected: (option) {}),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text(
              'Resumo',
              style: OhMyFoodTypography.titleMd.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.sm),
            Container(
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
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: cart.itemsTotalCents),
                    _SummaryRow(label: 'Taxa de serviço', value: cart.serviceFeeCents),
                    _SummaryRow(label: 'Entrega', value: cart.deliveryFeeCents),
                    const Divider(height: 32),
                    _SummaryRow(
                      label: 'Total a pagar',
                      value: cart.totalCents,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Container(
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
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Observações para o restaurante',
                  hintText: 'Ex: Sem cebola, porta da frente...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(OhMyFoodSpacing.md),
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Pagamento confirmado! Pedido em preparação.'),
                        ],
                      ),
                      backgroundColor: OhMyFoodColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  context.go('/tracking/ord-preview');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirmar pagamento ${(cart.totalCents / 100).toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: OhMyFoodSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OhMyFoodTypography.bodyBold.copyWith(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: OhMyFoodTypography.caption.copyWith(
                      color: OhMyFoodColors.neutral600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: OhMyFoodColors.primary,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSelector extends StatefulWidget {
  const _PaymentSelector({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  State<_PaymentSelector> createState() => _PaymentSelectorState();
}

class _PaymentSelectorState extends State<_PaymentSelector> {
  String selected = 'stripe';

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _PaymentOption(
            value: 'stripe',
            groupValue: selected,
            icon: Icons.credit_card,
            iconColor: OhMyFoodColors.primary,
            title: 'Cartão (Stripe)',
            subtitle: 'Visa, Mastercard, Apple Pay, Google Pay',
            onChanged: (value) => _select(value!),
          ),
          const Divider(height: 1),
          _PaymentOption(
            value: 'mbway',
            groupValue: selected,
            icon: Icons.phone_android,
            iconColor: OhMyFoodColors.courierAccent,
            title: 'MB WAY',
            subtitle: 'Confirme no seu telemóvel',
            onChanged: (value) => _select(value!),
          ),
          const Divider(height: 1),
          _PaymentOption(
            value: 'multibanco',
            groupValue: selected,
            icon: Icons.receipt_long,
            iconColor: OhMyFoodColors.restaurantAccent,
            title: 'Referência Multibanco',
            subtitle: 'Recebe referência válida por 60 minutos',
            onChanged: (value) => _select(value!),
          ),
        ],
      ),
    );
  }

  void _select(String value) {
    setState(() => selected = value);
    widget.onSelected(value);
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? OhMyFoodColors.primarySoft.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: OhMyFoodSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OhMyFoodTypography.bodyBold.copyWith(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: OhMyFoodTypography.caption.copyWith(
                      color: OhMyFoodColors.neutral600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: OhMyFoodColors.primary,
            ),
          ],
        ),
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
          Text(label, style: style),
          Text(
            '${(value / 100).toStringAsFixed(2)} €',
            style: style,
          ),
        ],
      ),
    );
  }
}
