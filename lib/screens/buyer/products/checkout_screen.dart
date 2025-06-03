import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../utils/constants.dart';
import '../../../api/order_service.dart';
  import 'dart:convert'; 

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const CheckoutScreen({super.key, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isLoading = false;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storage = FlutterSecureStorage();
    final userJson = await storage.read(key: AppConstants.userKey); // Ambil dari 'user_data'
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        // Sesuaikan field sesuai respon login, biasanya 'id'
        setState(() {
          userId = userMap['id'] ?? userMap['user_id']; // fallback
        });
      } catch (e) {
        print("Gagal parsing user_data: $e");
        setState(() {
          userId = null;
        });
      }
    }
  }

Future<void> _checkout() async {
  print("=== Mulai Checkout ===");
  if (userId == null) {
    print("User belum login (userId null)");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User belum login!')),
    );
    return;
  }
  setState(() => isLoading = true);

  print("Kirim order ke OrderService...");
  final orderService = OrderService();
  final response = await orderService.createOrder(
    userId: userId!,
    items: widget.items,
  );
  print("Order response: success=${response.success}, message=${response.message}, data=${response.data}");
  setState(() => isLoading = false);

  if (response.success && response.data?['snap_token'] != null) {
    final snapToken = response.data!['snap_token'];
    print('Order berhasil, Snap token: $snapToken');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransPaymentPage(snapToken: snapToken),
      ),
    );
  } else {
    print('Order gagal atau snap_token tidak ada');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Data Pesanan:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.items.map((e) => Text('Produk ID: ${e['product_id']}, Qty: ${e['quantity']}')),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    // ...
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _checkout,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: isLoading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Bayar Sekarang'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

  class MidtransPaymentPage extends StatefulWidget {
    final String snapToken;
    const MidtransPaymentPage({required this.snapToken});

    @override
    State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
  }

  class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
    late final WebViewController _controller;

    @override
    void initState() {
      super.initState();
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest navigation) {
              if (navigation.url.contains('finish')) {
                // Kembali ke halaman utama atau tampilkan dialog sukses
                Navigator.of(context).popUntil((route) => route.isFirst);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(
          Uri.parse('https://app.midtrans.com/snap/v2/vtweb/${widget.snapToken}'),
        );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran')),
        body: WebViewWidget(controller: _controller),
      );
    }
  }
