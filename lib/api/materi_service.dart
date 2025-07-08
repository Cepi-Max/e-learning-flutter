import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

// DIPERBAIKI: Kelas ApiResponse sekarang menggunakan tipe generik <T>
// Perubahan ini akan memperbaiki error di file lain yang menggunakan kelas ini.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data; // Tipe data sekarang dinamis

  ApiResponse({required this.success, required this.message, this.data});
}

class MateriService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<ApiResponse<Map<String, dynamic>?>> getMateriList() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        // DIUBAH: Menggunakan ApiResponse<Map<String, dynamic>?> agar konsisten
        return ApiResponse<Map<String, dynamic>?>(
          success: false,
          message: 'Token tidak ditemukan',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dosen/materi'), // Sesuaikan endpoint jika perlu
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>?>(
          success: true,
          message: 'Data materi berhasil dimuat',
          data: responseData,
        );
      } else {
        return ApiResponse<Map<String, dynamic>?>(
          success: false,
          message: responseData['message'] ?? 'Gagal memuat data materi',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>?>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>?>> getMateriDetail(
    int materiId,
  ) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        return ApiResponse<Map<String, dynamic>?>(
          success: false,
          message: 'Token tidak ditemukan',
        );
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/dosen/materi/$materiId',
        ), // Sesuaikan endpoint jika perlu
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>?>(
          success: true,
          message: 'Detail materi berhasil dimuat',
          data: responseData,
        );
      } else {
        return ApiResponse<Map<String, dynamic>?>(
          success: false,
          message: responseData['message'] ?? 'Gagal memuat detail materi',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>?>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
