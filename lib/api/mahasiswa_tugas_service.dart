import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import 'materi_service.dart'; // Menggunakan kembali kelas ApiResponse

class TugasService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<ApiResponse> getTugasList() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        return ApiResponse(success: false, message: 'Token tidak ditemukan');
      }

      // CATATAN: Endpoint disesuaikan untuk mahasiswa.
      // Pastikan endpoint ini benar sesuai dengan API Anda.
      final response = await http.get(
        Uri.parse('$baseUrl/dosen/tugas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Data tugas berhasil dimuat',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Gagal memuat data tugas',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // Anda bisa menambahkan fungsi getTugasDetail(int tugasId) di sini nanti
  // jika diperlukan, dengan struktur yang sama seperti di atas.
}
