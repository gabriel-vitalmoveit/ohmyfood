import 'package:collection/collection.dart';

enum OrderStatus {
  draft,
  awaitingAcceptance,
  preparing,
  pickup,
  onTheWay,
  delivered,
  cancelled,
}

class OrderItemModel {
  OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
    this.addons,
  });

  final String menuItemId;
  final String name;
  final int quantity;
  final int unitPriceCents;
  final List<String>? addons;

  int get totalCents => unitPriceCents * quantity;
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.status,
    required this.items,
    required this.itemsTotalCents,
    required this.deliveryFeeCents,
    required this.serviceFeeCents,
    required this.totalCents,
    required this.createdAt,
    this.courierId,
  });

  final String id;
  final String userId;
  final String restaurantId;
  final String? courierId;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final int itemsTotalCents;
  final int deliveryFeeCents;
  final int serviceFeeCents;
  final int totalCents;
  final DateTime createdAt;

  bool get isActive =>
      !const {OrderStatus.delivered, OrderStatus.cancelled}.contains(status);

  int get subtotalCents => items
      .map((item) => item.totalCents)
      .sum;
}
