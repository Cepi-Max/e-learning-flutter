import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_detail_screen.dart';
import '../../../models/product_model.dart';
import '../../../api/product_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/login_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    
    if (context.mounted) {
      // Navigasi ke halaman login setelah logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false, 
      );
    }
  }

  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String? error;

 @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      final response = await ProductService().getProducts();

      if (response.success) {
        final List<Product> products = response.data?['products'] ?? [];
        setState(() {
          allProducts = products;
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        setState(() {
          error = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    final filtered = allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          onChanged: _filterProducts,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Cari produk padi...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            isDense: true, // Mengurangi tinggi
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context, authProvider),
          )
        ],
      ),
      body: isLoading
    ? Center(child: CircularProgressIndicator())
    : error != null
        ? Center(child: Text('Error: $error'))
        : filteredProducts.isEmpty
            ? Center(child: Text(
                'Produk tidak ditemukan..',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ))
            : GridView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 200,
                ),
                itemBuilder: (context, index) {
                  final p = filteredProducts[index];
                  return ProductCard(product: p);
                },
              ),
    );
  }
}


class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar produk dengan ukuran tetap
            SizedBox(
              height: 130, // Atur tinggi tetap
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                child: Image.network(
                  'https://data-padi.pemdesrias.com/public/storage/images/dataproduk/${product.image}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            // Nama & harga
            Padding(
              padding: EdgeInsets.all(9.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formatRupiah(product.price),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

