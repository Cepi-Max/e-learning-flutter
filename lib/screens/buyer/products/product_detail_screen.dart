import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import '../../../models/product_model.dart';
import '../../../api/api_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../api/cart_service.dart';


class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Produk",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80), // biar konten ga ketutupan tombol
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://data-padi.pemdesrias.com/public/storage/images/dataproduk/${product.image}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 10),
                  Text(
                    formatRupiah(product.price),
                    style: TextStyle(
                      fontSize: 25, 
                      color: const Color.fromARGB(255, 206, 48, 48),
                      fontWeight: FontWeight.bold
                      ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10), // atas & bawah
                    child: Text(
                      product.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Stok: ${product.stock} kg',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          items: [
                            {'product_id': product.id, 'quantity': 1},
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Beli Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    ApiResponse response = await CartService().addToCart(
                      productId: product.id,
                      quantity: 1,
                    );

                    if (response.success) {
                      // Berhasil
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.message)),
                      );
                    } else {
                      // Gagal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal: ${response.message}")),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_cart, color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
