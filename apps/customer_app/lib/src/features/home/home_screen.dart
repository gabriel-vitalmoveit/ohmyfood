import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OhMyFoodColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: OhMyFoodColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.items.length.toString(),
                      style: OhMyFoodTypography.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _HeroBanner(),
                const SizedBox(height: OhMyFoodSpacing.lg),
                _SearchBar(),
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
                  trailing: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: OhMyFoodColors.primary,
                    ),
                    child: const Text('Ver todas'),
                  ),
                  child: SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
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
                      for (int i = 0; i < restaurants.length; i++)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (i * 100)),
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
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: OhMyFoodSpacing.md),
                            child: _RestaurantCard(restaurant: restaurants[i]),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: OhMyFoodSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _selectedCategoryProvider = StateProvider<String>((ref) => 'Todos');

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OhMyFoodColors.primary,
            OhMyFoodColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: OhMyFoodColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entregando agora em',
                  style: OhMyFoodTypography.label.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Lisboa • Alameda',
                      style: OhMyFoodTypography.bodyBold.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Mudar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
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
        decoration: InputDecoration(
          hintText: 'Pesquisar restaurantes, pratos ou farmácias',
          prefixIcon: const Icon(Icons.search, color: OhMyFoodColors.neutral400),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: OhMyFoodColors.neutral100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, size: 20),
              color: OhMyFoodColors.neutral600,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = [
      [OhMyFoodColors.primary, OhMyFoodColors.primaryDark],
      [OhMyFoodColors.courierAccent, const Color(0xFF1E7CD6)],
      [OhMyFoodColors.restaurantAccent, const Color(0xFF6B3DB8)],
    ];
    final titles = ['-30% em Lisboa', 'Entrega grátis no Mercado', 'Farmácias 24h'];
    final subtitles = ['Usa o código LISBOA30', 'Pedidos acima de 15€', 'Até às 8h de amanhã'];
    final icons = [Icons.local_offer, Icons.delivery_dining, Icons.local_pharmacy];

    return Container(
      width: 280,
      padding: const EdgeInsets.all(OhMyFoodSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index % colors.length],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[index % colors.length][0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icons[index % icons.length],
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            titles[index % titles.length],
            style: OhMyFoodTypography.titleLg.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitles[index % subtitles.length],
            style: OhMyFoodTypography.body.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends HookConsumerWidget {
  const _RestaurantCard({required this.restaurant});

  final RestaurantDetailViewModel restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OhMyFoodCard(
      onTap: () => context.go('/home/restaurants/${restaurant.restaurant.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: restaurant.coverImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: OhMyFoodColors.neutral200,
                      highlightColor: OhMyFoodColors.neutral100,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: OhMyFoodColors.neutral200,
                      child: const Icon(Icons.restaurant, color: OhMyFoodColors.neutral400),
                    ),
                  ),
                  if (restaurant.isFavourite)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: OhMyFoodSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.restaurant.name,
                    style: OhMyFoodTypography.bodyBold.copyWith(
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OhMyFoodColors.primarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: OhMyFoodColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: OhMyFoodTypography.caption.copyWith(
                                color: OhMyFoodColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${restaurant.deliveryMinutes} min',
                        style: OhMyFoodTypography.caption.copyWith(
                          color: OhMyFoodColors.neutral600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: OhMyFoodTypography.caption.copyWith(
                          color: OhMyFoodColors.neutral400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(restaurant.deliveryFeeCents / 100).toStringAsFixed(2)}€',
                        style: OhMyFoodTypography.caption.copyWith(
                          color: OhMyFoodColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: restaurant.restaurant.categories.take(2).map((category) {
                      return OhMyFoodBadge.info(category);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
