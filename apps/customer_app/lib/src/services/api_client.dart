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

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$_baseUrl/orders/user/$userId'), headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(String userId, Map<String, dynamic> orderData) async {
    try {
      // Backend usa: POST /api/orders/user/:userId
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/user/$userId'),
        headers: headers,
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 401) {
        await _refreshTokenIfNeeded();
        final newHeaders = await _getHeaders();
        final retryResponse = await http.post(
          Uri.parse('$_baseUrl/orders/user/$userId'),
          headers: newHeaders,
          body: json.encode(orderData),
        );
        if (retryResponse.statusCode == 201 || retryResponse.statusCode == 200) {
          return json.decode(retryResponse.body);
        }
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create order: ${response.statusCode}');
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
}

