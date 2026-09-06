import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static const _tokenKey = 'opamp_lab_token';

  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient();

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post(
      '/api/auth/signup',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    await _saveToken(data['token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post(
      '/api/auth/login',
      {
        'email': email,
        'password': password,
      },
    );
    await _saveToken(data['token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> fetchProfile(String token) async {
    final data = await _apiClient.get(
      '/api/auth/profile',
      token: token,
    );
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
