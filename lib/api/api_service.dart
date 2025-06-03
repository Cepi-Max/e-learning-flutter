// File: lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
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
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
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
      
      return ApiResponse(
        success: true,
        message: 'Logout berhasil',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan saat logout: ${e.toString()}',
      );
    }
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../utils/constants.dart';
// import 'endpoints.dart';
// import '../models/user_model.dart';
// import '../models/product_model.dart';

// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? data;
//   final int? statusCode;

//   ApiResponse({
//     required this.success,
//     required this.message,
//     this.data,
//     this.statusCode,
//   });
// }

// class ApiService {
//   final storage = const FlutterSecureStorage();
  
//   // Headers with token
//   Future<Map<String, String>> _getHeaders() async {
//     final token = await storage.read(key: AppConstants.tokenKey);
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // Handle API responses
//   ApiResponse _handleResponse(http.Response response) {
//     final body = json.decode(response.body);
    
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return ApiResponse(
//         success: true,
//         message: body['message'] ?? 'Success',
//         data: body,
//         statusCode: response.statusCode,
//       );
//     } else {
//       return ApiResponse(
//         success: false,
//         message: body['message'] ?? 'An error occurred',
//         statusCode: response.statusCode,
//       );
//     }
//   }

//   // Login user
//   Future<ApiResponse> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.login}'),
//         headers: await _getHeaders(),
//         body: json.encode({
//           'email': email,
//           'password': password,
//           'device_name': 'android',
//         }),
//       );
      
//       final apiResponse = _handleResponse(response);
      
//       if (apiResponse.success && apiResponse.data != null) {
//         // Save token and user data
//         await storage.write(
//           key: AppConstants.tokenKey, 
//           value: apiResponse.data['token'],
//         );
        
//         await storage.write(
//           key: AppConstants.userKey, 
//           value: json.encode(apiResponse.data['user']),
//         );
//       }
      
//       return apiResponse;
//     } catch (e) {
//       return ApiResponse(
//         success: false,
//         message: AppConstants.networkErrorMessage,
//       );
//     }
//   }

//   // Logout user
//   Future<ApiResponse> logout() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.logout}'),
//         headers: await _getHeaders(),
//       );
      
//       // Clear local storage regardless of server response
//       await storage.delete(key: AppConstants.tokenKey);
//       await storage.delete(key: AppConstants.userKey);
      
//       return _handleResponse(response);
//     } catch (e) {
//       // Still clear storage on error
//       await storage.delete(key: AppConstants.tokenKey);
//       await storage.delete(key: AppConstants.userKey);
      
//       return ApiResponse(
//         success: false,
//         message: AppConstants.networkErrorMessage,
//       );
//     }
//   }

//   // Get user profile
//   Future<ApiResponse<User>> getProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.profile}'),
//         headers: await _getHeaders(),
//       );
      
//       final apiResponse = _handleResponse(response);
      
//       if (apiResponse.success && apiResponse.data != null) {
//         final user = User.fromJson(apiResponse.data['user']);
//         return ApiResponse(
//           success: true,
//           message: apiResponse.message,
//           data: user,
//         );
//       }
      
//       return ApiResponse(
//         success: false,
//         message: apiResponse.message,
//         statusCode: apiResponse.statusCode,
//       );
//     } catch (e) {
//       return ApiResponse(
//         success: false,
//         message: AppConstants.networkErrorMessage,
//       );
//     }
//   }

//   // Get all products
//   Future<ApiResponse<List<Product>>> getProducts() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}'),
//         headers: await _getHeaders(),
//       );
      
//       final responseData = json.decode(response.body);
      
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         if (responseData['status'] == true) {
//           final List<dynamic> productsJson = responseData['data'];
//           final List<Product> products = productsJson
//               .map((json) => Product.fromJson(json))
//               .toList();
          
//           return ApiResponse(
//             success: true,
//             message: responseData['message'] ?? 'Success',
//             data: products,
//             statusCode: response.statusCode,
//           );
//         }
//       }
      
//       return ApiResponse(
//         success: false,
//         message: responseData['message'] ?? 'An error occurred',
//         statusCode: response.statusCode,
//       );
//     } catch (e) {
//       return ApiResponse(
//         success: false,
//         message: AppConstants.networkErrorMessage,
//       );
//     }
//   }
  
//   // Get product details
//   Future<ApiResponse<Product>> getProductDetails(int productId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}/$productId'),
//         headers: await _getHeaders(),
//       );
      
//       final apiResponse = _handleResponse(response);
      
//       if (apiResponse.success && apiResponse.data != null) {
//         final product = Product.fromJson(apiResponse.data['data']);
//         return ApiResponse(
//           success: true,
//           message: apiResponse.message,
//           data: product,
//         );
//       }
      
//       return ApiResponse(
//         success: false,
//         message: apiResponse.message,
//         statusCode: apiResponse.statusCode,
//       );
//     } catch (e) {
//       return ApiResponse(
//         success: false,
//         message: AppConstants.networkErrorMessage,
//       );
//     }
//   }
// }
