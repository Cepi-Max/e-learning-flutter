import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../api/product_service.dart';



class DataPadiScreen extends StatefulWidget {
  const DataPadiScreen({super.key});

  @override
  State<DataPadiScreen> createState() => _DataPadiScreenState();
}

class _DataPadiScreenState extends State<DataPadiScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
  final response = await _productService.getProducts();
  if (response.success && response.data != null && response.data!['products'] != null) {
    return response.data!['products'] as List<Product>;
  } else {
    throw Exception(response.message);
  }
}


  void _refresh() {
    setState(() {
      _futureProducts = _loadProducts();
    });
  }

  // void _deleteProduct(int id) async {
  //   final deleteResponse = await _productService.deleteProduct(id);
  //   if (deleteResponse.success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(deleteResponse.message)),
  //     );
  //     _refresh();
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(deleteResponse.message)),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Produk")),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    'https://data-padi.pemdesrias.com/public/storage/images/dataproduk/${product.image}',
                    width: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  title: Text(product.name),
                  subtitle: Text("Stok: ${product.stock} | Harga: ${product.price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/form-product',
                            arguments: {
                              'id': product.id,
                              'name': product.name,
                              'description': product.description,
                              'price': product.price,
                              'stock': product.stock,
                              'image': product.image,
                            },
                          ).then((_) => _refresh());
                        },

                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.delete),
                      //   onPressed: () => _deleteProduct(product.id),
                      // ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/form-product')
            .then((_) => _refresh()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
