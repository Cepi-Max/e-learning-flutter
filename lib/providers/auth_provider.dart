import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  User? _user;
  String? _token;
  String _errorMessage = '';
  
  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get token => _token;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;
  
  // Check if user is logged in from storage
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      final userData = await _storage.read(key: AppConstants.userKey);
      
      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(json.decode(userData));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error checking authentication status';
      notifyListeners();
      return false;
    }
  }
  
  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response.success && response.data != null) {
        _token = response.data?['token'];
        _user = User.fromJson(response.data?['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat login';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.logout();
    } catch (e) {
    }
    
    _token = null;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
