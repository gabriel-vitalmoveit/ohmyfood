import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_data.dart';
import '../cart/controllers/cart_controller.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final cart = ref.watch(cartControllerProvider);

    final restaurants = lisbonRestaurants.where((restaurant) {
      if (selectedCategory == 'Todos') return true;
      return restaurant.restaurant.categories.contains(selectedCategory);
    }).toList();

    return OhMyFoodAppScaffold(
      title: 'Olá, Ana 👋',
      actions: [
        IconButton(
          onPressed: () => context.go('/home/cart'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: -4,
                  top: -4,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: OhMyFoodColors.primary,
                    child: Text(
                      cart.items.length.toString(),
                      style: OhMyFoodTypography.caption.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CurrentLocationBanner(
                  address: 'Lisboa • Alameda',
                  onChange: () {},
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar restaurantes, pratos ou farmácias',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.lg),
                OhMyFoodSection(
                  title: 'Categorias',
                  child: OhMyFoodChipPicker<String>(
                    items: const ['Todos', ...homeCategories],
                    selected: selectedCategory,
                    onSelected: (value) => ref.read(_selectedCategoryProvider.notifier).state = value,
                  ),
                ),
                OhMyFoodSection(
                  title: 'Campanhas do dia',
                  trailing: TextButton(onPressed: () {}, child: const Text('Ver todas')),
                  child: SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _PromoCard(index: index),
                      separatorBuilder: (_, __) => const SizedBox(width: OhMyFoodSpacing.md),
                      itemCount: 3,
                    ),
                  ),
                ),
                OhMyFoodSection(
                  title: 'Sugestões para si',
                  child: Column(
                    children: [
                      for (final restaurant in restaurants)
                        Padding(
                          padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.md),
                          child: _RestaurantListTile(restaurant: restaurant),
                        ),
                    ],
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

final _selectedCategoryProvider = StateProvider<String>((ref) => 'Todos');

class _CurrentLocationBanner extends StatelessWidget {
  const _CurrentLocationBanner({required this.address, required this.onChange});

  final String address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OhMyFoodSpacing.md),
      decoration: BoxDecoration(
        color: OhMyFoodColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: OhMyFoodColors.primary,
            child: Icon(Icons.location_on, color: Colors.white),
          ),
          const SizedBox(width: OhMyFoodSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entregando agora em', style: OhMyFoodTypography.label),
                Text(address, style: OhMyFoodTypography.bodyBold),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Mudar')),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = [OhMyFoodColors.primary, OhMyFoodColors.courierAccent, OhMyFoodColors.restaurantAccent];
    final titles = ['-30% em Lisboa', 'Entrega grátis no Mercado', 'Farmácias 24h'];
    final subtitles = ['Usa o código LISBOA30', 'Pedidos acima de 15€', 'Até às 8h de amanhã'];

    return Container(
      width: 260,
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titles[index % titles.length],
            style: OhMyFoodTypography.titleLg.copyWith(color: Colors.white),
          ),
          Text(
            subtitles[index % subtitles.length],
            style: OhMyFoodTypography.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _RestaurantListTile extends HookConsumerWidget {
  const _RestaurantListTile({required this.restaurant});

  final RestaurantDetailViewModel restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OhMyFoodCard(
      onTap: () => context.go('/home/restaurants/${restaurant.restaurant.id}'),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          restaurant.coverImage,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
        ),
      ),
      title: restaurant.restaurant.name,
      subtitle:
          '${restaurant.rating.toStringAsFixed(1)} ★ • ${restaurant.deliveryMinutes} min • ${(restaurant.deliveryFeeCents / 100).toStringAsFixed(2)}€ entrega',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          OhMyFoodBadge.info(restaurant.restaurant.categories.first),
          const SizedBox(height: OhMyFoodSpacing.xs),
          Text('${restaurant.reviewCount} reviews', style: OhMyFoodTypography.caption),
        ],
      ),
    );
  }
}
