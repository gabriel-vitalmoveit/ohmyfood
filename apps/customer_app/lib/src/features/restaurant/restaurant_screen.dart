import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';
import '../cart/controllers/cart_controller.dart';

class RestaurantScreen extends HookConsumerWidget {
  const RestaurantScreen({required this.restaurantId, super.key});

  static const routeName = 'restaurant-detail';

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = lisbonRestaurants.firstWhere((element) => element.restaurant.id == restaurantId);
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(restaurant.coverImage, fit: BoxFit.cover),
                  Container(color: Colors.black26),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(restaurant.restaurant.name,
                              style: OhMyFoodTypography.titleLg.copyWith(color: Colors.white)),
                          const SizedBox(height: OhMyFoodSpacing.xs),
                          Text(
                            '${restaurant.rating.toStringAsFixed(1)} ★ (${restaurant.reviewCount}) • ${restaurant.deliveryMinutes} min • ${(restaurant.deliveryFeeCents / 100).toStringAsFixed(2)}€ entrega',
                            style: OhMyFoodTypography.body.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md, vertical: OhMyFoodSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = restaurant.categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, style: OhMyFoodTypography.titleMd),
                        const SizedBox(height: OhMyFoodSpacing.md),
                        ...category.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.md),
                              child: _MenuItemTile(
                                item: item,
                                onAdd: () => controller.addItem(restaurant: restaurant, item: item),
                              ),
                            )),
                      ],
                    ),
                  );
                },
                childCount: restaurant.categories.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(OhMyFoodSpacing.md),
                child: ElevatedButton(
                  onPressed: () => context.go('/home/cart'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${cart.items.length} artigos'),
                      Text('${(cart.totalCents / 100).toStringAsFixed(2)} € ▸'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item, required this.onAdd});

  final MenuItemViewModel item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: OhMyFoodTypography.bodyBold),
                  const SizedBox(height: OhMyFoodSpacing.xs),
                  Text(item.description, style: OhMyFoodTypography.caption),
                  const SizedBox(height: OhMyFoodSpacing.sm),
                  Text('${(item.priceCents / 100).toStringAsFixed(2)} €', style: OhMyFoodTypography.bodyBold),
                ],
              ),
            ),
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: OhMyFoodSpacing.md),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.sm, vertical: OhMyFoodSpacing.xs)),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
