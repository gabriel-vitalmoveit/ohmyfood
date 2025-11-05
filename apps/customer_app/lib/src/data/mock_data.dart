import 'package:shared_models/shared_models.dart';

class MenuItemViewModel {
  MenuItemViewModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final String? imageUrl;
  final List<String> tags;
}

class MenuCategoryViewModel {
  MenuCategoryViewModel({
    required this.name,
    required this.items,
  });

  final String name;
  final List<MenuItemViewModel> items;
}

class RestaurantDetailViewModel {
  RestaurantDetailViewModel({
    required this.restaurant,
    required this.categories,
    required this.coverImage,
    required this.rating,
    required this.reviewCount,
    required this.deliveryMinutes,
    required this.deliveryFeeCents,
    required this.isFavourite,
  });

  final RestaurantModel restaurant;
  final List<MenuCategoryViewModel> categories;
  final String coverImage;
  final double rating;
  final int reviewCount;
  final int deliveryMinutes;
  final int deliveryFeeCents;
  final bool isFavourite;
}

class OrderHistoryEntry {
  OrderHistoryEntry({
    required this.id,
    required this.restaurantName,
    required this.totalCents,
    required this.placedAt,
    required this.status,
    required this.itemsSummary,
  });

  final String id;
  final String restaurantName;
  final int totalCents;
  final DateTime placedAt;
  final OrderStatus status;
  final String itemsSummary;
}

final lisbonRestaurants = <RestaurantDetailViewModel>[
  RestaurantDetailViewModel(
    restaurant: RestaurantModel(
      id: 'tasca-bairro',
      name: 'Tasca do Bairro',
      latitude: 38.7223,
      longitude: -9.1393,
      active: true,
      categories: const ['Portuguesa', 'Tradicional'],
      averagePreparationMinutes: 18,
      coverImageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e',
    ),
    categories: [
      MenuCategoryViewModel(
        name: 'Clássicos',
        items: [
          MenuItemViewModel(
            id: 'bitoque-classico',
            name: 'Bitoque Clássico',
            description: 'Vaca grelhada, ovo estrelado, batata frita e arroz.',
            priceCents: 950,
            imageUrl: 'https://images.unsplash.com/photo-1543353071-873f17a7a088',
            tags: const ['Popular'],
          ),
          MenuItemViewModel(
            id: 'bacalhau-bras',
            name: 'Bacalhau à Brás',
            description: 'Receita tradicional com batata palha estaladiça.',
            priceCents: 890,
            tags: const ['Chef'],
          ),
        ],
      ),
      MenuCategoryViewModel(
        name: 'Sobremesas',
        items: [
          MenuItemViewModel(
            id: 'pastel-nata',
            name: 'Pastel de Nata',
            description: 'Doce conventual acabado de sair do forno.',
            priceCents: 180,
            tags: const ['Doce'],
          ),
        ],
      ),
    ],
    coverImage: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b',
    rating: 4.8,
    reviewCount: 620,
    deliveryMinutes: 28,
    deliveryFeeCents: 199,
    isFavourite: true,
  ),
  RestaurantDetailViewModel(
    restaurant: RestaurantModel(
      id: 'mercado-fresco',
      name: 'Mercado Fresco',
      latitude: 38.7139,
      longitude: -9.1366,
      active: true,
      categories: const ['Mercearia', 'Bio'],
      averagePreparationMinutes: 10,
      coverImageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    ),
    categories: [
      MenuCategoryViewModel(
        name: 'Cabazes Semanais',
        items: [
          MenuItemViewModel(
            id: 'cabaz-bio',
            name: 'Cabaz Bio Lisboa',
            description: 'Frutas e legumes locais para a semana.',
            priceCents: 1590,
            tags: const ['Sazonal'],
          ),
        ],
      ),
      MenuCategoryViewModel(
        name: 'Pequeno-Almoço',
        items: [
          MenuItemViewModel(
            id: 'granola-artesanal',
            name: 'Granola Artesanal',
            description: 'Granola com frutos secos e mel.',
            priceCents: 690,
          ),
        ],
      ),
    ],
    coverImage: 'https://images.unsplash.com/photo-1484981184820-2e84ea0b270b',
    rating: 4.6,
    reviewCount: 210,
    deliveryMinutes: 22,
    deliveryFeeCents: 99,
    isFavourite: false,
  ),
  RestaurantDetailViewModel(
    restaurant: RestaurantModel(
      id: 'farmacia-lisboa',
      name: 'Farmácia Lisboa 24h',
      latitude: 38.7091,
      longitude: -9.1333,
      active: true,
      categories: const ['Farmácia', 'Saúde'],
      averagePreparationMinutes: 8,
      coverImageUrl: 'https://images.unsplash.com/photo-1586015555751-63b16e5d3e5d',
    ),
    categories: [
      MenuCategoryViewModel(
        name: 'Essenciais',
        items: [
          MenuItemViewModel(
            id: 'kit-constipacao',
            name: 'Kit Constipação',
            description: 'Analgesia, vitamina C e spray nasal.',
            priceCents: 1490,
          ),
          MenuItemViewModel(
            id: 'pack-testes',
            name: 'Pack Testes Antigénio',
            description: '5 testes rápidos aprovados pela DGS.',
            priceCents: 990,
          ),
        ],
      ),
    ],
    coverImage: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b',
    rating: 4.9,
    reviewCount: 120,
    deliveryMinutes: 18,
    deliveryFeeCents: 0,
    isFavourite: false,
  ),
];

final homeCategories = <String>[
  'Restaurantes',
  'Mercearias',
  'Farmácias',
  'Veggie',
  'Promoções',
];

final orderHistory = <OrderHistoryEntry>[
  OrderHistoryEntry(
    id: 'ord-001',
    restaurantName: 'Tasca do Bairro',
    totalCents: 1320,
    placedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    status: OrderStatus.delivered,
    itemsSummary: 'Bitoque Clássico, Pastel de Nata',
  ),
  OrderHistoryEntry(
    id: 'ord-002',
    restaurantName: 'Mercado Fresco',
    totalCents: 1890,
    placedAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
    status: OrderStatus.delivered,
    itemsSummary: 'Cabaz Bio Lisboa',
  ),
  OrderHistoryEntry(
    id: 'ord-003',
    restaurantName: 'Farmácia Lisboa 24h',
    totalCents: 1990,
    placedAt: DateTime.now().subtract(const Duration(days: 10)),
    status: OrderStatus.cancelled,
    itemsSummary: 'Kit Constipação, Pack Testes Antigénio',
  ),
];
