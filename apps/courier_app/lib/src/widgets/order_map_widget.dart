import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/here_maps_service.dart';

final hereMapsServiceProvider = Provider<HereMapsService>((ref) {
  return HereMapsService();
});

class OrderMapWidget extends HookConsumerWidget {
  const OrderMapWidget({
    super.key,
    required this.restaurantLat,
    required this.restaurantLng,
    required this.deliveryLat,
    required this.deliveryLng,
    this.courierLat,
    this.courierLng,
  });

  final double restaurantLat;
  final double restaurantLng;
  final double deliveryLat;
  final double deliveryLng;
  final double? courierLat;
  final double? courierLng;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapsService = ref.watch(hereMapsServiceProvider);
    final routeAsync = ref.watch(_routeProvider((
      service: mapsService,
      restaurantLat: restaurantLat,
      restaurantLng: restaurantLng,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      courierLat: courierLat,
      courierLng: courierLng,
    )));

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: OhMyFoodColors.neutral200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OhMyFoodColors.neutral400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: routeAsync.when(
          data: (routeData) => _buildMapContent(context, routeData),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildMapError(context, error),
        ),
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, Map<String, dynamic> routeData) {
    return Stack(
      children: [
        // Mapa simplificado (em produção, usar HERE Maps SDK)
        Container(
          color: OhMyFoodColors.neutral100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: OhMyFoodColors.neutral400),
                const SizedBox(height: OhMyFoodSpacing.sm),
                Text(
                  'Mapa da rota',
                  style: OhMyFoodTypography.body,
                ),
                const SizedBox(height: OhMyFoodSpacing.xs),
                Text(
                  '${routeData['distance'].toStringAsFixed(1)} km • ${_formatDuration(routeData['duration'])}',
                  style: OhMyFoodTypography.caption,
                ),
              ],
            ),
          ),
        ),
        // Marcadores
        Positioned(
          top: 20,
          left: 20,
          child: _buildMarker(
            'Restaurante',
            Icons.restaurant,
            OhMyFoodColors.restaurantAccent,
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildMarker(
            'Entrega',
            Icons.location_on,
            OhMyFoodColors.courierAccent,
          ),
        ),
        if (courierLat != null && courierLng != null)
          Positioned(
            top: 100,
            left: 100,
            child: _buildMarker(
              'Você',
              Icons.person_pin_circle,
              OhMyFoodColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildMarker(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: OhMyFoodTypography.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMapError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: OhMyFoodColors.error),
          const SizedBox(height: OhMyFoodSpacing.sm),
          Text(
            'Erro ao carregar mapa',
            style: OhMyFoodTypography.body,
          ),
          const SizedBox(height: OhMyFoodSpacing.xs),
          Text(
            error.toString(),
            style: OhMyFoodTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}min';
  }
}

final _routeProvider = FutureProvider.family<Map<String, dynamic>, ({
  HereMapsService service,
  double restaurantLat,
  double restaurantLng,
  double deliveryLat,
  double deliveryLng,
  double? courierLat,
  double? courierLng,
})>((ref, params) async {
  // Se courier está definido, calcular rota do courier para restaurante primeiro
  if (params.courierLat != null && params.courierLng != null) {
    // Calcular rota completa: courier -> restaurante -> entrega
    final route1 = await params.service.calculateRoute(
      startLat: params.courierLat!,
      startLng: params.courierLng!,
      endLat: params.restaurantLat,
      endLng: params.restaurantLng,
    );
    
    final route2 = await params.service.calculateRoute(
      startLat: params.restaurantLat,
      startLng: params.restaurantLng,
      endLat: params.deliveryLat,
      endLng: params.deliveryLng,
    );
    
    return {
      'distance': (route1['distance'] as double) + (route2['distance'] as double),
      'duration': (route1['duration'] as Duration) + (route2['duration'] as Duration),
    };
  }
  
  // Caso contrário, calcular apenas restaurante -> entrega
  return await params.service.calculateRoute(
    startLat: params.restaurantLat,
    startLng: params.restaurantLng,
    endLat: params.deliveryLat,
    endLng: params.deliveryLng,
  );
});

