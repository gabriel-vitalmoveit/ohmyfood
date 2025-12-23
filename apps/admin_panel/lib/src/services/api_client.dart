import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_repository.dart';

class AdminApiClient {
  AdminApiClient({String? baseUrl, AuthRepository? authRepository})
      : _baseUrl = baseUrl ?? AppConfig.apiUrl,
        _authRepository = authRepository;

  final String _baseUrl;
  final AuthRepository? _authRepository;

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authRepository != null) {
      final token = await _authRepository.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<List<dynamic>> getRestaurants() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/restaurants'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<void> approveRestaurant(String restaurantId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/restaurants/$restaurantId/approve'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to approve restaurant: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> suspendRestaurant(String restaurantId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/restaurants/$restaurantId/suspend'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to suspend restaurant: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getCouriers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/couriers'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load couriers: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<void> approveCourier(String courierId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/couriers/$courierId/approve'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to approve courier: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> suspendCourier(String courierId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/couriers/$courierId/suspend'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to suspend courier: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getLiveOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/live-orders'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load live orders: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/orders'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/orders/$orderId/cancel'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

