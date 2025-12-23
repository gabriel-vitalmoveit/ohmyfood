import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_models/shared_models.dart';
import '../config/app_config.dart';
import 'auth_repository.dart';
import 'auth_service.dart';

class ApiClient {
  ApiClient({
    String? baseUrl,
    AuthRepository? authRepository,
  })  : _baseUrl = baseUrl ?? AppConfig.apiUrl,
        _authRepository = authRepository ?? AuthRepository();

  final String _baseUrl;
  final AuthRepository? _authRepository;

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Adicionar token de autenticação se disponível
    if (_authRepository != null) {
      final token = await _authRepository.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<void> _refreshTokenIfNeeded() async {
    if (_authRepository == null) return;
    
    try {
      final refreshToken = await _authRepository.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return;

      final authService = AuthService();
      final newTokens = await authService.refreshToken(refreshToken);
      
      // Salvar novos tokens
      await _authRepository.saveTokens(newTokens);
    } catch (e) {
      // Se refresh falhar, limpar autenticação
      await _authRepository.clearAuth();
    }
  }

  Future<List<RestaurantModel>> getRestaurants({
    String? category,
    String? search,
    int? take,
    int? skip,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'Todos') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (take != null) {
        queryParams['take'] = take.toString();
      }
      if (skip != null) {
        queryParams['skip'] = skip.toString();
      }

      final uri = Uri.parse('$_baseUrl/restaurants').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final headers = await _getHeaders();
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      
      // Se receber 401, tentar refresh token e repetir
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.get(uri, headers: newHeaders).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RestaurantModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    } catch (e) {
      // Log error but don't throw - return empty list for graceful degradation
      print('Error loading restaurants: $e');
      return [];
    }
  }

  // Paginated version
  Future<Map<String, dynamic>> getRestaurantsPaginated({
    String? category,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'Todos') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      queryParams['take'] = pageSize.toString();
      queryParams['skip'] = (page * pageSize).toString();

      final uri = Uri.parse('$_baseUrl/restaurants').replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.get(uri, headers: newHeaders).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final restaurants = data.map((json) => RestaurantModel.fromJson(json)).toList();
        
        return {
          'items': restaurants,
          'hasMore': restaurants.length == pageSize, // Assume more if we got full page
          'page': page,
        };
      }
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    } catch (e) {
      print('Error loading restaurants: $e');
      return {
        'items': <RestaurantModel>[],
        'hasMore': false,
        'page': page,
      };
    }
  }

  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$_baseUrl/restaurants/$id'), headers: headers);
      
      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load restaurant: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMenuItems(String restaurantId) async {
    try {
      // Backend usa: /api/restaurants/:restaurantId/menu
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$_baseUrl/restaurants/$restaurantId/menu'), headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load menu: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<List<OrderModel>> getUserOrders() async {
    try {
      final headers = await _getHeaders();
      // Tentar /me primeiro, fallback para endpoint antigo se 404
      var response = await http.get(
        Uri.parse('$_baseUrl/orders/me'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      // Se 404, tentar endpoint antigo (compatibilidade)
      if (response.statusCode == 404) {
        final userId = _authRepository != null ? await _authRepository!.getUserId() : null;
        if (userId != null) {
          response = await http.get(
            Uri.parse('$_baseUrl/orders/user/$userId'),
            headers: headers,
          ).timeout(const Duration(seconds: 10));
        }
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.get(
          Uri.parse('$_baseUrl/orders/me'),
          headers: newHeaders,
        ).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((json) => OrderModel.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      // Usar POST /api/orders (sem userId na URL - userId vem do token)
      final headers = await _getHeaders();
      var response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: headers,
        body: json.encode(orderData),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.post(
          Uri.parse('$_baseUrl/orders'),
          headers: newHeaders,
          body: json.encode(orderData),
        ).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      final errorBody = response.body;
      try {
        final error = json.decode(errorBody);
        throw Exception(error['message'] ?? 'Failed to create order: ${response.statusCode}');
      } catch (_) {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final headers = await _getHeaders();
      var response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.get(
          Uri.parse('$_baseUrl/orders/$orderId'),
          headers: newHeaders,
        ).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load order: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // Addresses
  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      var response = await http.get(
        Uri.parse('$_baseUrl/users/me/addresses'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.get(
          Uri.parse('$_baseUrl/users/me/addresses'),
          headers: newHeaders,
        ).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      throw Exception('Failed to load addresses: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData) async {
    try {
      final headers = await _getHeaders();
      var response = await http.post(
        Uri.parse('$_baseUrl/users/me/addresses'),
        headers: headers,
        body: json.encode(addressData),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.post(
          Uri.parse('$_baseUrl/users/me/addresses'),
          headers: newHeaders,
          body: json.encode(addressData),
        ).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create address: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    try {
      final headers = await _getHeaders();
      var response = await http.put(
        Uri.parse('$_baseUrl/users/me/addresses/$addressId'),
        headers: headers,
        body: json.encode(addressData),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.put(
          Uri.parse('$_baseUrl/users/me/addresses/$addressId'),
          headers: newHeaders,
          body: json.encode(addressData),
        ).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to update address: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      var response = await http.delete(
        Uri.parse('$_baseUrl/users/me/addresses/$addressId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        response = await http.delete(
          Uri.parse('$_baseUrl/users/me/addresses/$addressId'),
          headers: newHeaders,
        ).timeout(const Duration(seconds: 10));
      }
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

