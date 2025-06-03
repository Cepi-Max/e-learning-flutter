import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/cart_item_model.dart';
import 'api_service.dart';

class CartService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _url = '${AppConstants.apiBaseUrl}/cart';

  Future<ApiResponse> getCarts() async {
    try {
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
      
      if (response.statusCode == 200) {
        final Cart cart = Cart.fromJson(body);
        int totalItems = cart.items.fold(0, (sum, item) => sum + item.quantity);
        // print('total cart: $totalItems');
        return ApiResponse(
          success: true,
          message: 'Berhasil mengambil data keranjang.',
          data: {
            'cart': cart, 
            'totalItems': totalItems, 
          },
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? AppConstants.serverErrorMessage,
        );
      }
    } catch (e) {
      print('Error in getCarts: $e');
      return ApiResponse(
        success: false,
        message: '${AppConstants.networkErrorMessage} (${e.toString()})',
      );
    }
  }
  
  Future<ApiResponse> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(success: false, message: AppConstants.unauthorizedMessage);
      }

      final url = Uri.parse('${AppConstants.apiBaseUrl}/cart');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Berhasil menambahkan ke keranjang',
          data: data,
        );
      } else {
        throw Exception(data['message'] ?? 'Gagal menambahkan ke keranjang');
      }
    } catch (e) {
      print('Error addToCart: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // menghapus berdasarkan list yg dipilih
  Future<ApiResponse> removeSelectedItems(List<int> itemIds) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/cart/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_ids': itemIds,
        }),
      );

      final responseData = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 && responseData['success'] == true,
        message: responseData['message'] ?? 'Gagal menghapus item',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }


  
  // Metode untuk mengupdate jumlah item di keranjang
  Future<ApiResponse> updateCartItem(int itemId, int quantity) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(success: false, message: AppConstants.unauthorizedMessage);
      }

      final response = await http.post(
        Uri.parse('$_url/update/$itemId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'quantity': quantity,
        }),
      );

      final body = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Jumlah produk berhasil diperbarui.',
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
  
  // Metode untuk menghapus item dari keranjang
  Future<ApiResponse> removeFromCart(int itemId) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        return ApiResponse(success: false, message: AppConstants.unauthorizedMessage);
      }

      final response = await http.delete(
        Uri.parse('$_url/remove/$itemId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Produk berhasil dihapus dari keranjang.',
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

