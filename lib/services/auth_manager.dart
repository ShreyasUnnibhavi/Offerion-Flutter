// lib/services/auth_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:offerion/services/api_service.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  bool _isAuthenticated = false;
  String? _token;
  int? _userId;
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  int? get userId => _userId;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _userId = prefs.getInt('user_id');

      _isAuthenticated = _token != null && _userId != null;

      if (_token != null) {
        _apiService.setToken(_token!);
        print('AuthManager initialized with token and userId: $_userId');
      }

      notifyListeners();
    } catch (e) {
      print('Error initializing AuthManager: $e');
      await logout(); // Clear any corrupted data
    }
  }

  Future<void> login(String token, {int? userId}) async {
    try {
      _token = token;
      _userId = userId;
      _isAuthenticated = true;
      _apiService.setToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      if (userId != null) {
        await prefs.setInt('user_id', userId);
      }

      print('User logged in successfully. Token stored, UserID: $userId');
      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to save login credentials');
    }
  }

  Future<void> logout() async {
    try {
      _token = null;
      _userId = null;
      _isAuthenticated = false;
      _apiService.clearToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');

      print('User logged out successfully');
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      // Still set local state to logged out even if clearing preferences fails
      _token = null;
      _userId = null;
      _isAuthenticated = false;
      _apiService.clearToken();
      notifyListeners();
    }
  }

  Future<void> updateUserId(int userId) async {
    try {
      _userId = userId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      print('User ID updated: $userId');
      notifyListeners();
    } catch (e) {
      print('Error updating user ID: $e');
    }
  }

  // Check if we have a valid session
  bool hasValidSession() {
    return _isAuthenticated && _token != null && _token!.isNotEmpty;
  }

  // Get stored credentials for debugging
  Future<Map<String, dynamic>> getStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'token': prefs.getString('auth_token'),
        'userId': prefs.getInt('user_id'),
        'isAuthenticated': _isAuthenticated,
      };
    } catch (e) {
      print('Error getting stored credentials: $e');
      return {};
    }
  }
}
