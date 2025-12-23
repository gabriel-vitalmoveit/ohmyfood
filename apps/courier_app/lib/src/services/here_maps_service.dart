import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class HereMapsService {
  HereMapsService({String? apiKey}) : _apiKey = apiKey ?? AppConfig.hereMapsApiKey;

  final String _apiKey;
  static const String _baseUrl = 'https://router.hereapi.com/v8';

  /// Calcula rota entre dois pontos usando HERE Routing API
  Future<Map<String, dynamic>> calculateRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String transportMode = 'car',
  }) async {
    if (_apiKey.isEmpty) {
      // Fallback para cálculo simples se não houver API key
      return _calculateSimpleRoute(startLat, startLng, endLat, endLng);
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/routes?'
        'origin=$startLat,$startLng&'
        'destination=$endLat,$endLng&'
        'transportMode=$transportMode&'
        'return=summary,polyline&'
        'apikey=$_apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final sections = route['sections'] as List?;
          
          if (sections != null && sections.isNotEmpty) {
            final section = sections[0];
            final summary = section['summary'] ?? {};
            
            return {
              'distance': (summary['length'] ?? 0) / 1000.0, // converter para km
              'duration': Duration(seconds: summary['duration'] ?? 0),
              'polyline': _extractPolyline(section),
            };
          }
        }
      }
      // Fallback em caso de erro
      return _calculateSimpleRoute(startLat, startLng, endLat, endLng);
    } catch (e) {
      // Fallback em caso de erro
      return _calculateSimpleRoute(startLat, startLng, endLat, endLng);
    }
  }

  /// Calcula ETA (Estimated Time of Arrival)
  Future<Duration> calculateETA({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final route = await calculateRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );
      return route['duration'] as Duration;
    } catch (e) {
      // Retornar ETA padrão em caso de erro
      return const Duration(minutes: 15);
    }
  }

  /// Calcula distância entre dois pontos
  Future<double> calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final route = await calculateRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );
      return route['distance'] as double;
    } catch (e) {
      // Fallback para cálculo simples (Haversine)
      return _haversineDistance(startLat, startLng, endLat, endLng);
    }
  }

  /// Extrai polyline da rota
  List<Map<String, double>> _extractPolyline(Map<String, dynamic> section) {
    final polyline = <Map<String, double>>[];
    final polylineData = section['polyline'] as String?;
    
    if (polylineData != null) {
      // HERE Maps usa formato polyline encoded
      // Por simplicidade, retornamos apenas start e end points
      // Em produção, usar biblioteca para decodificar polyline
      final actions = section['actions'] as List?;
      if (actions != null) {
        for (final action in actions) {
          final location = action['location'] as Map?;
          if (location != null) {
            final lat = (location['lat'] as num?)?.toDouble();
            final lng = (location['lng'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              polyline.add({'lat': lat, 'lng': lng});
            }
          }
        }
      }
    }
    
    return polyline;
  }

  /// Cálculo simples de rota (fallback)
  Map<String, dynamic> _calculateSimpleRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distance = _haversineDistance(startLat, startLng, endLat, endLng);
    // Assumir velocidade média de 30 km/h em cidade
    final durationSeconds = (distance / 30.0 * 3600).toInt();
    
    return {
      'distance': distance,
      'duration': Duration(seconds: durationSeconds),
      'polyline': [
        {'lat': startLat, 'lng': startLng},
        {'lat': endLat, 'lng': endLng},
      ],
    };
  }

  /// Cálculo de distância usando fórmula de Haversine
  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}
