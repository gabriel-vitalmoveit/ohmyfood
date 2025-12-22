import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  AuthService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiUrl;

  final String _baseUrl;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return AuthResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException('Credenciais inválidas');
      } else {
        throw AuthException('Erro ao fazer login: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro de conexão: ${e.toString()}');
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'displayName': displayName,
          'role': 'CUSTOMER',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw AuthException(error['message'] ?? 'Erro ao criar conta');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro de conexão: ${e.toString()}');
    }
  }

  // TODO: Implementar quando backend adicionar endpoint de refresh
  // Future<AuthTokens> refreshToken(String refreshToken) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/auth/refresh'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $refreshToken',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return AuthTokens.fromJson(data['tokens']);
  //     } else {
  //       throw AuthException('Erro ao renovar token');
  //     }
  //   } catch (e) {
  //     if (e is AuthException) rethrow;
  //     throw AuthException('Erro de conexão: ${e.toString()}');
  //   }
  // }
}

class AuthResponse {
  AuthResponse({
    required this.user,
    required this.tokens,
  });

  final UserData user;
  final AuthTokens tokens;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserData.fromJson(json['user']),
      tokens: AuthTokens.fromJson(json['tokens']),
    );
  }
}

class UserData {
  UserData({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
  });

  final String id;
  final String email;
  final String role;
  final String? displayName;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      displayName: json['displayName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'displayName': displayName,
    };
  }
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  
  @override
  String toString() => message;
}

