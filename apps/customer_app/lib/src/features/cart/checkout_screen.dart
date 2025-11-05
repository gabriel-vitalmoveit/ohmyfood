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
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Morada de entrega', style: OhMyFoodTypography.titleMd),
            const SizedBox(height: OhMyFoodSpacing.sm),
            _InfoCard(
              icon: Icons.home_rounded,
              title: 'Alameda Dom Afonso Henriques 5B',
              subtitle: '3.º Esquerdo • Campainha: OHMYFOOD',
              actionLabel: 'Editar',
              onAction: () {},
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text('Pagamento', style: OhMyFoodTypography.titleMd),
            const SizedBox(height: OhMyFoodSpacing.sm),
            _InfoCard(
              icon: Icons.credit_card,
              title: 'Visa •••• 1234',
              subtitle: 'Expira 04/27',
              actionLabel: 'Alterar',
              onAction: () {},
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            _PaymentSelector(onSelected: (option) {}),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text('Resumo', style: OhMyFoodTypography.titleMd),
            const SizedBox(height: OhMyFoodSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: cart.itemsTotalCents),
                    _SummaryRow(label: 'Taxa de serviço', value: cart.serviceFeeCents),
                    _SummaryRow(label: 'Entrega', value: cart.deliveryFeeCents),
                    const Divider(),
                    _SummaryRow(label: 'Total a pagar', value: cart.totalCents, emphasize: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações para o restaurante',
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pagamento confirmado! Pedido em preparação.')),
                  );
                  context.go('/tracking/ord-preview');
                },
                child: Text('Confirmar pagamento ${(cart.totalCents / 100).toStringAsFixed(2)} €'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: OhMyFoodColors.primarySoft,
              child: Icon(icon, color: OhMyFoodColors.primaryDark),
            ),
            const SizedBox(width: OhMyFoodSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: OhMyFoodTypography.bodyBold),
                  const SizedBox(height: OhMyFoodSpacing.xs),
                  Text(subtitle, style: OhMyFoodTypography.caption),
                ],
              ),
            ),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
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
    return Column(
      children: [
        RadioListTile<String>(
          value: 'stripe',
          groupValue: selected,
          onChanged: (value) => _select(value!),
          title: const Text('Cartão (Stripe)'),
          subtitle: const Text('Visa, Mastercard, Apple Pay, Google Pay'),
        ),
        RadioListTile<String>(
          value: 'mbway',
          groupValue: selected,
          onChanged: (value) => _select(value!),
          title: const Text('MB WAY'),
          subtitle: const Text('Confirme no seu telemóvel'),
        ),
        RadioListTile<String>(
          value: 'multibanco',
          groupValue: selected,
          onChanged: (value) => _select(value!),
          title: const Text('Referência Multibanco'),
          subtitle: const Text('Recebe referência válida por 60 minutos'),
        ),
      ],
    );
  }

  void _select(String value) {
    setState(() => selected = value);
    widget.onSelected(value);
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
