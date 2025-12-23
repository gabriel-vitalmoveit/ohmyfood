import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RestaurantApiClient {
  RestaurantApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiUrl;

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

  Future<Map<String, dynamic>> getStats({String? restaurantId, String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      // Tentar /me primeiro, fallback para endpoint antigo se 404
      var response = await http.get(
        Uri.parse('$_baseUrl/restaurants/me/stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      // Se 404 e restaurantId fornecido, tentar endpoint antigo (compatibilidade)
      if (response.statusCode == 404 && restaurantId != null) {
        response = await http.get(
          Uri.parse('$_baseUrl/restaurants/$restaurantId/stats'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load stats: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getOrders({String? restaurantId, String? status, String? token}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final headers = await _getHeaders(token: token);
      // Tentar /me primeiro, fallback para endpoint antigo se 404
      var uri = Uri.parse('$_baseUrl/restaurants/me/orders')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      
      // Se 404 e restaurantId fornecido, tentar endpoint antigo (compatibilidade)
      if (response.statusCode == 404 && restaurantId != null) {
        uri = Uri.parse('$_baseUrl/orders/restaurant/$restaurantId')
            .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
        response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      }

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

  Future<void> updateOrderStatus(String orderId, String status, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Menu management
  Future<List<dynamic>> getMenuItems(String restaurantId, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.get(
        Uri.parse('$_baseUrl/restaurants/$restaurantId/menu'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load menu: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createMenuItem(String restaurantId, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.post(
        Uri.parse('$_baseUrl/restaurants/$restaurantId/menu'),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create menu item: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMenuItem(String restaurantId, String itemId, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.put(
        Uri.parse('$_baseUrl/restaurants/$restaurantId/menu/$itemId'),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to update menu item: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMenuItem(String restaurantId, String itemId, {String? token}) async {
    try {
      final headers = await _getHeaders(token: token);
      final response = await http.delete(
        Uri.parse('$_baseUrl/restaurants/$restaurantId/menu/$itemId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete menu item: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

