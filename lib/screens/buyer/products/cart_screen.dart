import 'package:flutter/material.dart';
import 'payment_screen.dart'; 
import '../layouts/app_template.dart';
import '../../../api/order_service.dart';
import '../../../api/cart_service.dart';
import '../../../api/api_service.dart';
import '../../../models/cart_item_model.dart';
import '../../../utils/currency_formatter.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onCartUpdated;

  const CartScreen({super.key, required this.onCartUpdated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}


class _CartScreenState extends State<CartScreen> {
  late Future<ApiResponse> _cartFuture;
  final Set<int> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  void _fetchCartData() {
    setState(() {
      _cartFuture = CartService().getCarts();
    });
  }

  double _calculateTotal(Cart cart) {
    return cart.items.fold(0, (sum, item) {
      if (_selectedItemIds.contains(item.id)) {
        double price = item.product.price;
        return sum + (price * item.quantity);
      }
      return sum;
    });
  }

  Future<void> _removeSelectedItems() async {
    if (_selectedItemIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus barang yang dipilih?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Hapus"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await CartService().removeSelectedItems(_selectedItemIds.toList());

    setState(() {
      _fetchCartData();
    }); 
    widget.onCartUpdated();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 56, 142, 60),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AppTemplate()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _removeSelectedItems,
          ),
        ],
      ),
      body: FutureBuilder<ApiResponse>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || !snapshot.data!.success) {
            return Center(child: Text("Gagal: ${snapshot.data?.message ?? 'Unknown error'}"));
          }

          final cart = snapshot.data!.data!['cart'] as Cart;

          if (cart.items.isEmpty) {
            return const Center(child: Text("Keranjang masih kosong."));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final double total = item.product.price * item.quantity;
                    final bool isChecked = _selectedItemIds.contains(item.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedItemIds.add(item.id);
                                  } else {
                                    _selectedItemIds.remove(item.id);
                                  }
                                });
                              },
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(
                                'https://data-padi.pemdesrias.com/public/storage/images/dataproduk/${item.product.image}',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: item.quantity > 1
                                            ? () async {
                                                final res = await CartService().updateCartItem(item.id, item.quantity - 1);
                                                if (res.success) {
                                                  setState(_fetchCartData);
                                                  widget.onCartUpdated();
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                                                }
                                              }
                                            : null,
                                      ),
                                      Text('${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () async {
                                          final res = await CartService().updateCartItem(item.id, item.quantity + 1);
                                          if (res.success) {
                                            setState(_fetchCartData);
                                            widget.onCartUpdated();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(formatRupiah(item.product.price),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(formatRupiah(total),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(formatRupiah(_calculateTotal(cart)),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 56, 142, 60),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text(
                        "Checkout",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    onPressed: _selectedItemIds.isEmpty
                      ? null
                      : () async {
                          final selectedItems = cart.items
                              .where((item) => _selectedItemIds.contains(item.id))
                              .map((item) => {
                                    'product_id': item.product.id,
                                    'quantity': item.quantity,
                                    'price': item.product.price,
                                  })
                              .toList();

                          final userId = cart.userId;

                          final res = await OrderService().createOrder(
                            userId: userId,
                            items: selectedItems,
                          );

                          if (res.success) {
                            final snapToken = res.data?['snap_token'];
                            // Setelah order berhasil, refresh cart supaya kosong
                            setState(() {
                              _selectedItemIds.clear(); // kosongkan selected items
                              _fetchCartData(); // fetch cart dari backend, seharusnya kosong kalau backend hapus item
                            });
                            widget.onCartUpdated(); // optional, kalau parent perlu tahu cart berubah

                            if (snapToken != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MidtransPaymentPage(snapToken: snapToken),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Snap token tidak tersedia')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.message ?? 'Order gagal!')),
                            );
                          }
                        },
                    ),
                  ),
                ],
              ),
            ),

            ],
          );
        },
      ),
    );
  }
}
