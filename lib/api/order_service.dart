import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/order_model.dart';
import '../utils/constants.dart'; // Pastikan path benar
import 'api_service.dart'; // ApiResponse
// import model Order jika mau

class OrderService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _url = '${AppConstants.apiBaseUrl}/order';
  Future<List<Order>> getUserOrders() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) throw Exception("Unauthorized");

      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List rawData = body['data'];
        return rawData.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat pesanan (${response.statusCode})');
      }
    } catch (e) {
      throw Exception("Gagal memuat data: ${e.toString()}");
    }
  }

  Future<ApiResponse> createOrder({
    required int userId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        return ApiResponse(
          success: false,
          message: AppConstants.unauthorizedMessage,
        );
      }

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId, 'items': items}),
      );

      print('OrderService response.body: ${response.body}'); // Tambahin ini!
      // final body = json.decode(response.body);

      final body = json.decode(response.body);
      print('OrderService response.statusCode: ${response.statusCode}');
      print('OrderService response.body: ${response.body}');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['snap_token'] != null) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Order berhasil!',
          data: {'order': body['order'], 'snap_token': body['snap_token']},
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? AppConstants.serverErrorMessage,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '${AppConstants.networkErrorMessage} (${e.toString()})',
      );
    }
  }
}
