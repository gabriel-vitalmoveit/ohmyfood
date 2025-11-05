import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/mock_data.dart';

class CartItem {
  CartItem({
    required this.restaurantId,
    required this.item,
    required this.quantity,
  });

  final String restaurantId;
  final MenuItemViewModel item;
  final int quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        restaurantId: restaurantId,
        item: item,
        quantity: quantity ?? this.quantity,
      );

  int get totalCents => item.priceCents * quantity;
}

class CartState {
  const CartState({this.restaurantId, this.items = const [], this.deliveryFeeCents = 199});

  final String? restaurantId;
  final List<CartItem> items;
  final int deliveryFeeCents;

  int get itemsTotalCents => items.fold(0, (sum, item) => sum + item.totalCents);
  int get serviceFeeCents => (itemsTotalCents * 0.08).round();
  int get totalCents => itemsTotalCents + serviceFeeCents + deliveryFeeCents;

  CartState copyWith({String? restaurantId, List<CartItem>? items, int? deliveryFeeCents}) =>
      CartState(
        restaurantId: restaurantId ?? this.restaurantId,
        items: items ?? this.items,
        deliveryFeeCents: deliveryFeeCents ?? this.deliveryFeeCents,
      );
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  void addItem({required RestaurantDetailViewModel restaurant, required MenuItemViewModel item}) {
    if (state.restaurantId != null && state.restaurantId != restaurant.restaurant.id) {
      state = CartState(restaurantId: restaurant.restaurant.id, items: [CartItem(restaurantId: restaurant.restaurant.id, item: item, quantity: 1)], deliveryFeeCents: restaurant.deliveryFeeCents);
      return;
    }

    final existingIndex = state.items.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (existingIndex >= 0) {
      final updatedItems = [...state.items];
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
        restaurantId: restaurant.restaurant.id,
        deliveryFeeCents: restaurant.deliveryFeeCents,
        items: [
          ...state.items,
          CartItem(
            restaurantId: restaurant.restaurant.id,
            item: item,
            quantity: 1,
          ),
        ],
      );
    }
  }

  void updateQuantity(String itemId, int quantity) {
    final updatedItems = state.items.map((item) {
      if (item.item.id == itemId) {
        return item.copyWith(quantity: quantity.clamp(1, 99));
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void removeItem(String itemId) {
    final updatedItems = state.items.where((item) => item.item.id != itemId).toList();
    state = state.copyWith(items: updatedItems.isEmpty ? [] : updatedItems, restaurantId: updatedItems.isEmpty ? null : state.restaurantId);
  }

  void clear() {
    state = const CartState();
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});
