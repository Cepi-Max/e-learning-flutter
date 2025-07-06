import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login
  Future<ApiResponse> login(String email, String password) async {
    print(baseUrl);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token dan data user ke secure storage
        await _storage.write(
          key: AppConstants.tokenKey,
          value: responseData['token'],
        );
        await _storage.write(
          key: AppConstants.userKey,
          value: jsonEncode(responseData['user']),
        );

        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Login berhasil',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Login gagal',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<ApiResponse> logout() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token != null) {
        try {
          await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );
        } catch (e) {
          // Ignore API errors during logout
        }
      }

      // Hapus data lokal
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.userKey);

      return ApiResponse(success: true, message: 'Logout berhasil');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan saat logout: ${e.toString()}',
      );
    }
  }
}
