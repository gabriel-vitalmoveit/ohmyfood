import 'package:shared_models/shared_models.dart';

class KitchenOrder {
  KitchenOrder({
    required this.id,
    required this.customerName,
    required this.status,
    required this.items,
    required this.totalCents,
    required this.createdAt,
    required this.etaMinutes,
  });

  final String id;
  final String customerName;
  final OrderStatus status;
  final List<String> items;
  final int totalCents;
  final DateTime createdAt;
  final int etaMinutes;
}

class MenuCategoryEditorModel {
  MenuCategoryEditorModel({required this.name, required this.items});

  final String name;
  final List<MenuItemEditorModel> items;
}

class MenuItemEditorModel {
  MenuItemEditorModel({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.available,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int priceCents;
  final bool available;
  final String? description;
  final String? imageUrl;
}

final activeOrders = <KitchenOrder>[
  KitchenOrder(
    id: 'ord-501',
    customerName: 'Miguel Santos',
    status: OrderStatus.preparing,
    items: const ['Bitoque Clássico x1', 'Sopa do Dia x1'],
    totalCents: 1380,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    etaMinutes: 12,
  ),
  KitchenOrder(
    id: 'ord-502',
    customerName: 'Rita Martins',
    status: OrderStatus.awaitingAcceptance,
    items: const ['Pastel de Nata x3'],
    totalCents: 540,
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    etaMinutes: 5,
  ),
  KitchenOrder(
    id: 'ord-500',
    customerName: 'João Costa',
    status: OrderStatus.pickup,
    items: const ['Francesinha x1', 'Refrigerante x2'],
    totalCents: 1820,
    createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
    etaMinutes: 2,
  ),
];

final menuEditor = <MenuCategoryEditorModel>[
  MenuCategoryEditorModel(
    name: 'Pratos principais',
    items: [
      MenuItemEditorModel(
        id: 'bitoque',
        name: 'Bitoque Clássico',
        priceCents: 950,
        available: true,
        description: 'Vaca grelhada, ovo estrelado e batata frita estaladiça.',
      ),
      MenuItemEditorModel(
        id: 'francesinha',
        name: 'Francesinha à Moda do Porto',
        priceCents: 1120,
        available: true,
        description: 'Molho caseiro com toque picante.',
      ),
      MenuItemEditorModel(
        id: 'sopa-do-dia',
        name: 'Sopa do Dia',
        priceCents: 320,
        available: false,
        description: 'Hoje: Creme de legumes',
      ),
    ],
  ),
  MenuCategoryEditorModel(
    name: 'Sobremesas',
    items: [
      MenuItemEditorModel(
        id: 'pastel-nata',
        name: 'Pastel de Nata',
        priceCents: 180,
        available: true,
        description: 'Servido com canela e açúcar em pó.',
      ),
      MenuItemEditorModel(
        id: 'mousse-chocolate',
        name: 'Mousse de Chocolate',
        priceCents: 240,
        available: true,
      ),
    ],
  ),
];

const restaurantMetrics = {
  'Tempo médio prep.': '16 min',
  'Ticket médio': '18.40 €',
  'Avaliações': '4.8 ★',
  'Cancelamentos': '2% semana',
};
