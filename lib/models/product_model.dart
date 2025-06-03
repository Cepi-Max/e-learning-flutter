class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tidak ada nama',
      description: json['description'] ?? 'Deskripsi tidak tersedia',
      price: _parsePrice(json['price']), 
      stock: json['stock'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0; 
    if (price is double) return price; 
    if (price is String) {
      try {
        return double.parse(price); 
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0; 
  }
}
