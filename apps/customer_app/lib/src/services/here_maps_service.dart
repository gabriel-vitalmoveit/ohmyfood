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
      return _calculateSimpleRoute(startLat, startLng, endLat, endLng);
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/routes?'
        'origin=$startLat,$startLng&'
        'destination=$endLat,$endLng&'
        'transportMode=$transportMode&'
        'return=summary&'
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
            
            final polyline = <Map<String, double>>[];
            final start = route['sections']?[0]?['departure'] as Map?;
            final end = route['sections']?[sections.length - 1]?['arrival'] as Map?;
            
            if (start != null) {
              final lat = (start['place']?['location']?['lat'] as num?)?.toDouble();
              final lng = (start['place']?['location']?['lng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                polyline.add({'lat': lat, 'lng': lng});
              }
            }
            
            if (end != null) {
              final lat = (end['place']?['location']?['lat'] as num?)?.toDouble();
              final lng = (end['place']?['location']?['lng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                polyline.add({'lat': lat, 'lng': lng});
              }
            }
            
            return {
              'distance': (summary['length'] ?? 0) / 1000.0,
              'duration': Duration(seconds: summary['duration'] ?? 0),
              'polyline': polyline.isNotEmpty ? polyline : [
                {'lat': startLat, 'lng': startLng},
                {'lat': endLat, 'lng': endLng},
              ],
            };
          }
        }
      }
      return _calculateSimpleRoute(startLat, startLng, endLat, endLng);
    } catch (e) {
      return _calculateSimpleRoute(startLat, startLng, endLat, endLng);
    }
  }

  Map<String, dynamic> _calculateSimpleRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distance = _haversineDistance(startLat, startLng, endLat, endLng);
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

  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371;
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

