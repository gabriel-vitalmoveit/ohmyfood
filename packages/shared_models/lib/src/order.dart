import 'package:collection/collection.dart';

enum OrderStatus {
  draft,
  awaitingAcceptance,
  preparing,
  pickup,
  onTheWay,
  delivered,
  cancelled;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return OrderStatus.draft;
      case 'awaitingacceptance':
      case 'awaiting_acceptance':
        return OrderStatus.awaitingAcceptance;
      case 'preparing':
        return OrderStatus.preparing;
      case 'pickup':
        return OrderStatus.pickup;
      case 'ontheway':
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.draft;
    }
  }
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemId: json['menuItemId'] as String? ?? json['menuItem']?['id'] as String? ?? '',
      name: json['name'] as String? ?? json['menuItem']?['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPriceCents: (json['unitPriceCents'] as num?)?.toInt() ?? 
                      (json['menuItem']?['priceCents'] as num?)?.toInt() ?? 0,
      addons: (json['addons'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      restaurantId: json['restaurantId'] as String,
      status: OrderStatus.fromString(json['status'] as String? ?? 'draft'),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
      itemsTotalCents: (json['itemsTotalCents'] as num?)?.toInt() ?? 0,
      deliveryFeeCents: (json['deliveryFeeCents'] as num?)?.toInt() ?? 0,
      serviceFeeCents: (json['serviceFeeCents'] as num?)?.toInt() ?? 0,
      totalCents: (json['totalCents'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      courierId: json['courierId'] as String?,
    );
  }
}
