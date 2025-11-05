import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_models/shared_models.dart';

class TrackingScreen extends HookConsumerWidget {
  const TrackingScreen({required this.orderId, super.key});

  static const routeName = 'tracking';

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const statusTimeline = [
      OrderStatus.awaitingAcceptance,
      OrderStatus.preparing,
      OrderStatus.pickup,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];
    final currentIndex = 3;
    final displayId = orderId.length > 6 ? '${orderId.substring(0, 6)}…' : orderId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$displayId'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [OhMyFoodColors.primarySoft, OhMyFoodColors.neutral100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.delivery_dining, color: OhMyFoodColors.primaryDark, size: 32),
                    ),
                    const SizedBox(height: OhMyFoodSpacing.sm),
                    Text('Estafeta a 6 min de si', style: OhMyFoodTypography.bodyBold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e'),
                ),
                const SizedBox(width: OhMyFoodSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('João Ferreira', style: OhMyFoodTypography.bodyBold),
                      Text('Scooter • Placa 12-AB-34', style: OhMyFoodTypography.caption),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                ),
              ],
            ),
            const SizedBox(height: OhMyFoodSpacing.xl),
            Text('Linha temporal', style: OhMyFoodTypography.titleMd),
            const SizedBox(height: OhMyFoodSpacing.md),
            Column(
              children: [
                for (var i = 0; i < statusTimeline.length; i++)
                  _TimelineTile(
                    status: statusTimeline[i],
                    isCompleted: i <= currentIndex,
                    isCurrent: i == currentIndex,
                  ),
              ],
            ),
            const SizedBox(height: OhMyFoodSpacing.xl),
            Text('Resumo do pedido', style: OhMyFoodTypography.titleMd),
            const SizedBox(height: OhMyFoodSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tasca do Bairro', style: OhMyFoodTypography.bodyBold),
                    const SizedBox(height: OhMyFoodSpacing.sm),
                    Text('• Bitoque Clássico x1\n• Pastel de Nata x2', style: OhMyFoodTypography.body),
                    const Divider(height: OhMyFoodSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pagamento', style: OhMyFoodTypography.bodyBold),
                        Text('Cartão Visa •••• 1234', style: OhMyFoodTypography.body),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OhMyFoodSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('Ligar estafeta'),
                ),
              ),
              const SizedBox(width: OhMyFoodSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Ajuda 24/7'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.status, required this.isCompleted, required this.isCurrent});

  final OrderStatus status;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final statusLabel = {
      OrderStatus.awaitingAcceptance: 'A aguardar aceitação',
      OrderStatus.preparing: 'A ser preparado',
      OrderStatus.pickup: 'Pronto para recolha',
      OrderStatus.onTheWay: 'A caminho',
      OrderStatus.delivered: 'Entregue',
    }[status]!
        .toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? OhMyFoodColors.primary : OhMyFoodColors.neutral200,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: isCompleted ? OhMyFoodColors.primary : OhMyFoodColors.neutral200,
            ),
          ],
        ),
        const SizedBox(width: OhMyFoodSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusLabel,
                    style: isCurrent
                        ? OhMyFoodTypography.bodyBold
                        : OhMyFoodTypography.body.copyWith(color: OhMyFoodColors.neutral600)),
                const SizedBox(height: OhMyFoodSpacing.xs),
                Text(
                  isCurrent ? 'Previsto para chegar em 6 minutos' : 'Atualizado há 5 min',
                  style: OhMyFoodTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
