import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'api_client.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? user;
  String? token;
  bool isLoading = false;
  String? error;
  bool initialized = false;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  bool get isAuthenticated => user != null && token != null;

  Future<void> tryAutoLogin() async {
    final savedToken = await _authService.getSavedToken();

    if (savedToken == null || savedToken.isEmpty) {
      initialized = true;
      notifyListeners();
      return;
    }

    try {
      final restoredUser = await _authService.fetchProfile(savedToken);
      user = restoredUser;
      token = savedToken;
    } catch (_) {
      await _authService.clearToken();
      user = null;
      token = null;
    } finally {
      initialized = true;
      notifyListeners();
    }
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await _authService.signup(
        name: name,
        email: email,
        password: password,
      );
      token = await _authService.getSavedToken();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await _authService.login(
        email: email,
        password: password,
      );
      token = await _authService.getSavedToken();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    user = null;
    token = null;
    error = null;
    await _authService.clearToken();
    notifyListeners();
  }
}
