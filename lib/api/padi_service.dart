import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/padi_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PadiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _url = '${AppConstants.apiBaseUrl}/datapadi';

  Future getData() async {
    try{
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
              return ApiResponse(success: false, message: AppConstants.unauthorizedMessage);
            }

            final response = await http.get(
              Uri.parse(_url),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        final List<Padi> padis = (body['data'] as List)
            .map((item) => Padi.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Produk ditemukan',
          data: {
            'padis': padis,
          },
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? AppConstants.serverErrorMessage,
        );
      }
    } catch (e) {
      print(e.toString());
    }

  }


  Future<ApiResponse> postData(
    String nama,
    String jumlahPadi,
    String jenisPadi,
  ) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final url = Uri.parse('${AppConstants.apiBaseUrl}/datapadi');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama': nama,
          'jumlah_padi': jumlahPadi,
          'jenis_padi': jenisPadi,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil menambahkan data padi',
          data: data,
        );
      } else {
        throw Exception(data['message'] ?? 'Gagal menambahkan data padi');
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }       

  Future<ApiResponse> putData(
      int id,
      String nama,
      String jumlahPadi,
      String jenisPadi,
  ) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final url = Uri.parse('${AppConstants.apiBaseUrl}/datapadi/update/$id');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama': nama,
          'jumlah_padi': jumlahPadi,
          'jenis_padi': jenisPadi,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil mengubah data padi',
          data: data,
        );
      } else {
        throw Exception(data['message'] ?? 'Gagal mengubah data padi');
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(), 
      );
    }
  }

  Future<ApiResponse> deleteData(String id) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final url = Uri.parse('${AppConstants.apiBaseUrl}/datapadi/$id');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil menghapus data padi',
          data: data,
        );
      } else {
        throw Exception(data['message'] ?? 'Gagal menghapus data padi');
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(), 
      );
    }
  }

  Future<ApiResponse> getFilteredData(int bulan, int tahun) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }
      final url = Uri.parse('${AppConstants.apiBaseUrl}/datapadi?bulan=$bulan&tahun=$tahun');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = json.decode(response.body);

       if (response.statusCode == 200 && body['status'] == true) {
        final List<Padi> padis = (body['data'] as List)
            .map((item) => Padi.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Produk ditemukan',
          data: {
            'padis': padis,
          },
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? AppConstants.serverErrorMessage,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Terjadi kesalahan: $e');
    }
  }

}
