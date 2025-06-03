import 'order_item.dart';

class Order {
  final int id;
  final String orderCode;
  final double totalPrice;
  final String status;
  final String createdAt;
  final bool isPaid;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.orderCode,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.isPaid,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Flexible: kalau backend kirim 0/1 atau true/false tetap aman
    final rawPaid = json['is_paid'];
    final List<OrderItem> items =
        (json['order_items'] as List<dynamic>?)
            ?.map((item) => OrderItem.fromJson(item))
            .toList() ??
        [];

    final bool paidValue =
        (rawPaid == 1 ||
        rawPaid == true ||
        rawPaid == '1' ||
        rawPaid == 'true');

    return Order(
      id: json['id'] ?? 0,
      orderCode: json['order_code'] ?? '',
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      isPaid: paidValue,
      orderItems: items,
    );
  }
}
