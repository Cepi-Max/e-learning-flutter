import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../models/pengumpulan_model.dart';
import 'materi_service.dart'; // Menggunakan kembali kelas ApiResponse

class PengumpulanService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  /// Mendapatkan token dari storage
  Future<String?> _getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  /// Mendapatkan headers untuk request
  Future<Options> _getOptions() async {
    final token = await _getToken();
    return Options(
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  /// Mendapatkan data pengumpulan berdasarkan tugas ID
  Future<ApiResponse<Pengumpulan?>> getPengumpulanByTugasId(int tugasId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/mahasiswa/pengumpulan-tugas/$tugasId',
        options: await _getOptions(),
      );

      if (response.statusCode == 200 && response.data?['data'] != null) {
        return ApiResponse<Pengumpulan?>(
          success: true,
          message: response.data['message'] ?? 'Data berhasil diambil',
          data: Pengumpulan.fromJson(response.data['data']),
        );
      } else {
        // API mengembalikan 200 tapi tidak ada data, artinya belum mengumpulkan.
        return ApiResponse<Pengumpulan?>(
          success: true,
          message: 'Belum ada pengumpulan untuk tugas ini',
          data: null,
        );
      }
    } on DioException catch (e) {
      // Jika 404, sudah pasti belum ada pengumpulan.
      if (e.response?.statusCode == 404) {
        return ApiResponse<Pengumpulan?>(
          success: true,
          message: 'Belum ada pengumpulan untuk tugas ini',
          data: null,
        );
      }
      return ApiResponse<Pengumpulan?>(
        success: false,
        message:
            e.response?.data?['message'] ?? 'Gagal mengambil data pengumpulan.',
      );
    } catch (e) {
      return ApiResponse<Pengumpulan?>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Mengirimkan data pengumpulan tugas ke server.
  Future<ApiResponse<Pengumpulan?>> submitTugas({
    required int tugasId,
    required String filePath,
    required BuildContext context,
  }) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) {
        return ApiResponse<Pengumpulan?>(
          success: false,
          message: 'User tidak ditemukan. Silakan login ulang.',
        );
      }

      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        'mahasiswa_id': user.id,
        'tugas_id': tugasId,
        'file_tugas': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ), // DIPERBAIKI: Nama field 'file_tugas'
      });

      final response = await _dio.post(
        '$baseUrl/mahasiswa/pengumpulan-tugas',
        data: formData,
        options: await _getOptions(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse<Pengumpulan?>(
          success: true,
          message: response.data['message'] ?? 'Tugas berhasil dikumpulkan',
          data: Pengumpulan.fromJson(response.data['data']),
        );
      } else {
        return ApiResponse<Pengumpulan?>(
          success: false,
          message: response.data['message'] ?? 'Gagal mengumpulkan tugas',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<Pengumpulan?>(
        success: false,
        message: e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan.',
      );
    } catch (e) {
      return ApiResponse<Pengumpulan?>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Memperbarui file tugas yang sudah dikumpulkan.
  Future<ApiResponse<Pengumpulan?>> updateTugas({
    required int pengumpulanId,
    required String filePath,
  }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'file_tugas': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ), // DIPERBAIKI: Nama field 'file_tugas'
      });

      // DIPERBAIKI: Menggunakan endpoint yang konsisten
      final response = await _dio.post(
        '$baseUrl/mahasiswa/pengumpulan-tugas/$pengumpulanId',
        data: formData,
        options: await _getOptions(),
      );

      if (response.statusCode == 200) {
        return ApiResponse<Pengumpulan?>(
          success: true,
          message: response.data['message'] ?? 'Jawaban berhasil diperbarui',
          data: Pengumpulan.fromJson(response.data['data']),
        );
      } else {
        return ApiResponse<Pengumpulan?>(
          success: false,
          message: response.data['message'] ?? 'Gagal memperbarui jawaban',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<Pengumpulan?>(
        success: false,
        message: e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan.',
      );
    } catch (e) {
      return ApiResponse<Pengumpulan?>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Menghapus pengumpulan tugas
  Future<ApiResponse> deletePengumpulan(int pengumpulanId) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/mahasiswa/pengumpulan-tugas/$pengumpulanId', // DIPERBAIKI: Menggunakan endpoint yang konsisten
        options: await _getOptions(),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'Pengumpulan berhasil dihapus',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Gagal menghapus pengumpulan',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  bool validateFile(String filePath) {}
}
