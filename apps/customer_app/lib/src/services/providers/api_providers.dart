import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_models/shared_models.dart';
import '../api_client.dart';
import 'auth_providers.dart';

// Provider para ApiClient (singleton) - agora com auth
final apiClientProvider = Provider<ApiClient>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ApiClient(authRepository: authRepository);
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

// User ID do usuário autenticado
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  // Verificar se está autenticado
  if (!authState.isAuthenticated) return null;
  
  final repository = ref.read(authRepositoryProvider);
  return await repository.getUserId();
});

// Provider para pedidos do usuário
final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final userIdAsync = ref.watch(currentUserIdProvider);
  final userId = await userIdAsync.value;
  if (userId == null) return [];
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
      final userIdAsync = ref.read(currentUserIdProvider);
      
      // Aguardar userId
      final userId = await userIdAsync.future;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      final order = await apiClient.createOrder(userId, orderData);
      state = AsyncValue.data(order);
      // Invalida a lista de pedidos após criar novo pedido
      ref.invalidate(userOrdersProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

