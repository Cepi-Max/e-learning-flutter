import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../utils/constants.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? order;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchOrderDetail();
  }

  Future<void> fetchOrderDetail() async {
    try {
      final token = await storage.read(key: AppConstants.tokenKey);
      if (token == null) {
        setState(() {
          error = AppConstants.unauthorizedMessage;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/order/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          order = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = AppConstants.serverErrorMessage;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = AppConstants.networkErrorMessage;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Order')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : order == null
                  ? const Center(child: Text('Data tidak ditemukan.'))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kode Order: ${order!['order_code']}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Total Harga: Rp${order!['total_price']}'),
                          Text('Status: ${order!['status']}'),
                          const Divider(height: 32),
                          const Text('Daftar Produk:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: order!['order_items'].length,
                              itemBuilder: (context, index) {
                                final item = order!['order_items'][index];
                                return ListTile(
                                  title: Text(item['product']['name']),
                                  subtitle: Text('Qty: ${item['quantity']} x Rp${item['price']}'),
                                  trailing: Text('Rp${item['subtotal']}'),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
    );
  }
}
