// Tabel Keranjang
class Cart {
  final int id;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      items: json['items'] != null
          ? List<CartItem>.from(json['items'].map((item) => CartItem.fromJson(item)))
          : [],
    );
  }
}

// Tabel item_keranjang
class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final String createdAt;
  final String updatedAt;
  final Product product;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final int id;
  final int userId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String image;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price']),
      stock: json['stock'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}