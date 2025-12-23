import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CourierApiClient {
  CourierApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiUrl;

  final String _baseUrl;

  Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getAvailableOrders({
    double? lat,
    double? lng,
    double? maxDistance,
    String? token,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lng != null) queryParams['lng'] = lng.toString();
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance.toString();

      final uri = Uri.parse('$_baseUrl/orders/available/courier')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final headers = await _getHeaders(token: token);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load order: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> assignOrder(String orderId, String courierId, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/assign-courier'),
        headers: headers,
        body: json.encode({'courierId': courierId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to assign order: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to update order: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

