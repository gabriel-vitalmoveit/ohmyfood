import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_models/shared_models.dart';
import '../config/app_config.dart';

// Temporary user ID - should come from auth later
const String _tempUserId = 'temp-user-1';

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiUrl;

  final String _baseUrl;

  Future<List<RestaurantModel>> getRestaurants({String? category}) async {
    try {
      final uri = Uri.parse('$_baseUrl/restaurants').replace(
        queryParameters: category != null ? {'category': category} : null,
      );
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RestaurantModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    } catch (e) {
      // Fallback to mock data if API is not available
      return [];
    }
  }

  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/restaurants/$id'));
      
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
      final response = await http.get(Uri.parse('$_baseUrl/restaurants/$restaurantId/menu'));
      
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
      final response = await http.get(Uri.parse('$_baseUrl/orders/user/$userId'));
      
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
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create order: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

