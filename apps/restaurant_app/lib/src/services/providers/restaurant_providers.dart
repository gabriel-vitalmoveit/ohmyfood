import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../api_client.dart';
import '../auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final restaurantApiClientProvider = Provider<RestaurantApiClient>((ref) {
  return RestaurantApiClient();
});

// Stats provider - usa /me endpoint
final restaurantStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(restaurantApiClientProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final token = await authRepository.getAccessToken();
  
  try {
    return await apiClient.getStats(token: token);
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

// Orders provider - usa /me endpoint
final restaurantOrdersProvider = FutureProvider.family<List<dynamic>, String?>((ref, status) async {
  final apiClient = ref.watch(restaurantApiClientProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final token = await authRepository.getAccessToken();
  
  try {
    return await apiClient.getOrders(status: status, token: token);
  } catch (e) {
    return [];
  }
});

