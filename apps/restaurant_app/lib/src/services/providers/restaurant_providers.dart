import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../api_client.dart';

final restaurantApiClientProvider = Provider<RestaurantApiClient>((ref) {
  return RestaurantApiClient();
});

// Restaurant ID - em produção viria do auth
final restaurantIdProvider = StateProvider<String?>((ref) => 'demo-restaurant');

// Stats provider
final restaurantStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(restaurantApiClientProvider);
  final restaurantId = ref.watch(restaurantIdProvider);
  if (restaurantId == null) throw Exception('Restaurant ID not set');
  
  try {
    return await apiClient.getStats(restaurantId);
  } catch (e) {
    // Retornar stats vazios em caso de erro
    return {
      'ordersToday': 0,
      'cancelledToday': 0,
      'avgPrepMin': 15,
      'avgTicket': 0,
      'revenueToday': 0,
      'topItems': [],
      'hourlyOrders': List.filled(12, 0),
    };
  }
});

// Orders provider
final restaurantOrdersProvider = FutureProvider.family<List<dynamic>, String?>((ref, status) async {
  final apiClient = ref.watch(restaurantApiClientProvider);
  final restaurantId = ref.watch(restaurantIdProvider);
  if (restaurantId == null) return [];
  
  try {
    return await apiClient.getOrders(restaurantId, status: status);
  } catch (e) {
    return [];
  }
});

