import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class AuthRepository {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserId = 'auth_user_id';

  Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, tokens.accessToken);
    await prefs.setString(_keyRefreshToken, tokens.refreshToken);
  }

  Future<void> saveUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserId, user.id);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserId);
  }
}

