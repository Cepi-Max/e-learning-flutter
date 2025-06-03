import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../utils/constants.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final storage = const FlutterSecureStorage();
  List<dynamic> orders = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      // Ambil token dari secure storage
      final token = await storage.read(key: AppConstants.tokenKey);

      if (token == null) {
        setState(() {
          error = AppConstants.unauthorizedMessage;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data['data'];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          error = AppConstants.unauthorizedMessage;
          isLoading = false;
        });
      } else {
        setState(() {
          error = AppConstants.serverErrorMessage;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() {
        error = AppConstants.networkErrorMessage;
        isLoading = false;
      });
    }
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text('Kode: ${order['order_code']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: Rp${order['total_price']}'),
            Text('Status: ${order['status']}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order['id']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orderan Masuk'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : orders.isEmpty
                  ? const Center(child: Text('Tidak ada orderan.'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return buildOrderCard(orders[index]);
                      },
                    ),
    );
  }
}
