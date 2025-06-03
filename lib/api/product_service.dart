import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/product_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class ProductService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _url = '${AppConstants.apiBaseUrl}/product';

  // GET all products
  Future<ApiResponse> getProducts() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.body.isEmpty) {
        return ApiResponse(
          success: false,
          message: "Respons kosong dari server",
        );
      }

      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['status'] == true) {
        final List<Product> products = (body['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Produk ditemukan',
          data: {'products': products},
        );
      }

      return ApiResponse(
        success: false,
        message: body['message'] ?? AppConstants.serverErrorMessage,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: "${AppConstants.networkErrorMessage} (${e.toString()})",
      );
    }
  }

  // POST (create) product
  Future<ApiResponse> postData(
    String name,
    String desc,
    String price,
    String stock,
    String imageUrl, {
    File? file,
  }) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final request = http.MultipartRequest('POST', Uri.parse(_url))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['description'] = desc
        ..fields['price'] = price
        ..fields['stock'] = stock;

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.fields['image'] = imageUrl;
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final body = json.decode(responseBody);

      if (streamedResponse.statusCode == 200 || body['status'] == true) {
        return ApiResponse(success: true, message: body['message']);
      }

      return ApiResponse(
        success: false,
        message: body['message'] ?? "Gagal menambahkan produk",
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: "Terjadi kesalahan: ${e.toString()}",
      );
    }
  }

  // PUT (update) product
  Future<ApiResponse> putData(
    int id,
    String name,
    String desc,
    String price,
    String stock,
    String imageUrl, {
    File? file,
  }) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final request = http.MultipartRequest('POST', Uri.parse('$_url/$id'))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['_method'] = 'PUT'
        ..fields['name'] = name
        ..fields['description'] = desc
        ..fields['price'] = price
        ..fields['stock'] = stock;

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.fields['image'] = imageUrl;
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final body = json.decode(responseBody);

      if (streamedResponse.statusCode == 200 || body['status'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? "Produk berhasil diperbarui",
        );
      }

      String errorMessage = body['message'] ?? "Gagal memperbarui produk";

      if (body['errors'] != null) {
        final errors = body['errors'] as Map<String, dynamic>;
        errorMessage = errors.entries
            .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
            .join('\n');
      }

      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: "Terjadi kesalahan: ${e.toString()}",
      );
    }
  }
}
