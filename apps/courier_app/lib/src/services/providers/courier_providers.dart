import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../api_client.dart';

final courierApiClientProvider = Provider<CourierApiClient>((ref) {
  return CourierApiClient();
});

// Courier location provider
final courierLocationProvider = StateProvider<Map<String, double>?>((ref) => null);

// Available orders provider
final availableOrdersProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiClient = ref.watch(courierApiClientProvider);
  final location = ref.watch(courierLocationProvider);
  
  try {
    return await apiClient.getAvailableOrders(
      lat: location?['lat'],
      lng: location?['lng'],
      maxDistance: 10.0,
    );
  } catch (e) {
    return [];
  }
});

