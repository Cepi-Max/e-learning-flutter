import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PaymentService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _url = '${AppConstants.apiBaseUrl}/order'; // endpoint Laravel untuk order

  Future<ApiResponse> createPayment({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        return ApiResponse(success: false, message: AppConstants.unauthorizedMessage);
      }

      final response = await http.post(
  Uri.parse(_url),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'user_id': userId,
    'items': [
      {
        'product_id': productId,
        'quantity': quantity,
      }
    ]
  }),
);

print('Status: ${response.statusCode}');
print('Body: ${response.body}');


      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['snap_token'] != null) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Snap token diterima',
          data: {
            'snap_token': body['snap_token'],
          },
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
