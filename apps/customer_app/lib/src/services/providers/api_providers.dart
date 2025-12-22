import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../api_client.dart';

// Provider para ApiClient (singleton)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider para lista de restaurantes
final restaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final restaurants = await apiClient.getRestaurants();
    return restaurants;
  } catch (e) {
    // Se falhar, retorna lista vazia (pode adicionar tratamento de erro melhor)
    return [];
  }
});

// Provider para restaurante por ID
final restaurantProvider = FutureProvider.family<RestaurantModel?, String>((ref, restaurantId) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final restaurant = await apiClient.getRestaurantById(restaurantId);
    return restaurant;
  } catch (e) {
    return null;
  }
});

// Provider para menu items de um restaurante
final menuItemsProvider = FutureProvider.family<List<dynamic>, String>((ref, restaurantId) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final menuItems = await apiClient.getMenuItems(restaurantId);
    return menuItems;
  } catch (e) {
    return [];
  }
});

// Temporary user ID - should come from auth later
final currentUserIdProvider = StateProvider<String>((ref) => 'temp-user-1');

// Provider para pedidos do usuário
final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  try {
    final orders = await apiClient.getUserOrders(userId);
    return orders;
  } catch (e) {
    return [];
  }
});

// Provider para criar pedido (StateNotifier para melhor controle)
final createOrderNotifierProvider = StateNotifierProvider<CreateOrderNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return CreateOrderNotifier(ref);
});

class CreateOrderNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  CreateOrderNotifier(this.ref) : super(const AsyncValue.data(null));
  
  final Ref ref;

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      final userId = ref.read(currentUserIdProvider);
      final order = await apiClient.createOrder(userId, orderData);
      state = AsyncValue.data(order);
      // Invalida a lista de pedidos após criar novo pedido
      ref.invalidate(userOrdersProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

