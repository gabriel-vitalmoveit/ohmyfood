import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/here_maps_service.dart';

final hereMapsServiceProvider = Provider<HereMapsService>((ref) {
  return HereMapsService();
});

class TrackingMapWidget extends HookConsumerWidget {
  const TrackingMapWidget({
    super.key,
    required this.restaurantLat,
    required this.restaurantLng,
    required this.deliveryLat,
    required this.deliveryLng,
    this.courierLat,
    this.courierLng,
    required this.status,
  });

  final double restaurantLat;
  final double restaurantLng;
  final double deliveryLat;
  final double deliveryLng;
  final double? courierLat;
  final double? courierLng;
  final String status;

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
    final eta = routeData['duration'] as Duration;
    final distance = routeData['distance'] as double;

    return Stack(
      children: [
        // Mapa simplificado
        Container(
          color: OhMyFoodColors.neutral100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 64,
                  color: _getStatusColor(),
                ),
                const SizedBox(height: OhMyFoodSpacing.sm),
                Text(
                  _getStatusMessage(),
                  style: OhMyFoodTypography.bodyBold,
                ),
                const SizedBox(height: OhMyFoodSpacing.xs),
                if (status == 'ON_THE_WAY')
                  Text(
                    '${distance.toStringAsFixed(1)} km • ${_formatDuration(eta)}',
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
            OhMyFoodColors.primary,
          ),
        ),
        if (courierLat != null && courierLng != null && status == 'ON_THE_WAY')
          Positioned(
            top: 100,
            left: 100,
            child: _buildMarker(
              'Estafeta',
              Icons.delivery_dining,
              OhMyFoodColors.courierAccent,
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'AWAITING_ACCEPTANCE':
      case 'PREPARING':
        return Icons.restaurant;
      case 'PICKUP':
        return Icons.shopping_bag;
      case 'ON_THE_WAY':
        return Icons.delivery_dining;
      case 'DELIVERED':
        return Icons.check_circle;
      default:
        return Icons.location_on;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'AWAITING_ACCEPTANCE':
      case 'PREPARING':
        return OhMyFoodColors.restaurantAccent;
      case 'PICKUP':
        return OhMyFoodColors.warning;
      case 'ON_THE_WAY':
        return OhMyFoodColors.courierAccent;
      case 'DELIVERED':
        return Colors.green;
      default:
        return OhMyFoodColors.primary;
    }
  }

  String _getStatusMessage() {
    switch (status) {
      case 'AWAITING_ACCEPTANCE':
        return 'Aguardando aceitação';
      case 'PREPARING':
        return 'Restaurante a preparar';
      case 'PICKUP':
        return 'Pronto para recolha';
      case 'ON_THE_WAY':
        return 'Estafeta a caminho';
      case 'DELIVERED':
        return 'Pedido entregue';
      default:
        return 'Em processamento';
    }
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
  // Se courier está definido e está a caminho, calcular rota do courier para entrega
  if (params.courierLat != null && params.courierLng != null) {
    return await params.service.calculateRoute(
      startLat: params.courierLat!,
      startLng: params.courierLng!,
      endLat: params.deliveryLat,
      endLng: params.deliveryLng,
    );
  }
  
  // Caso contrário, calcular restaurante -> entrega
  return await params.service.calculateRoute(
    startLat: params.restaurantLat,
    startLng: params.restaurantLng,
    endLat: params.deliveryLat,
    endLng: params.deliveryLng,
  );
});

