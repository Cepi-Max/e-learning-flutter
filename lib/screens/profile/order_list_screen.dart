import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../api/order_service.dart';
import '../../models/order_model.dart';
import 'detail_order.dart';

class OrderListScreen extends StatefulWidget {
  final int userId;

  const OrderListScreen({super.key, required this.userId});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Menunggu',
    'Dikemas',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: fetchUserOrders(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }
                final orders = snapshot.data ?? [];
                final filteredOrders = _filterOrders(orders);

                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildOrdersList(filteredOrders);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1B5E20),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Pesanan Saya',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => setState(() {}),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final isSelected = _filterOptions[index] == _selectedFilter;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                _filterOptions[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1B5E20),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF1B5E20),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
              elevation: isSelected ? 4 : 0,
              shadowColor: const Color(0xFF1B5E20).withOpacity(0.3),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = _filterOptions[index];
                });
                HapticFeedback.lightImpact();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF1B5E20),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      index * 0.1,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
              ),
              child: _buildModernOrderCard(orders[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernOrderCard(Order order, int index) {
    final statusInfo = _getStatusInfo(order.status);
    final isPaid = order.isPaid == true || order.isPaid == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    DetailOrderScreen(order: order),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.grain_rounded,
                        color: Color(0xFF1B5E20),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusInfo['color'].withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusInfo['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusInfo['text'],
                            style: TextStyle(
                              color: statusInfo['color'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFE65100),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRupiah(order.totalPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF1B5E20),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Payment Status & Action Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFF1B5E20).withOpacity(0.1)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPaid
                                ? const Color(0xFF1B5E20).withOpacity(0.3)
                                : const Color(0xFFE57373).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPaid
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              color: isPaid
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFE57373),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isPaid ? 'Lunas' : 'Belum Bayar',
                              style: TextStyle(
                                color: isPaid
                                    ? const Color(0xFF1B5E20)
                                    : const Color(0xFFE57373),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B5E20).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        DetailOrderScreen(order: order),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              ),
                                            ),
                                        child: child,
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Detail',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF1B5E20),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat pesanan...',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE57373),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan saat memuat data pesanan. Silakan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF1B5E20),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'Semua'
                  ? 'Belum Ada Pesanan'
                  : 'Tidak Ada Pesanan $_selectedFilter',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'Semua'
                  ? 'Anda belum memiliki pesanan apapun. Mulai berbelanja sekarang!'
                  : 'Tidak ada pesanan dengan status $_selectedFilter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_selectedFilter == 'Semua') return orders;

    return orders.where((order) {
      switch (_selectedFilter) {
        case 'Menunggu':
          return order.status.toLowerCase() == 'pending';
        case 'Dikemas':
          return order.status.toLowerCase() == 'shipped';
        case 'Dikirim':
          return order.status.toLowerCase() == 'delivered';
        case 'Selesai':
          return order.status.toLowerCase() == 'completed';
        case 'Dibatalkan':
          return order.status.toLowerCase() == 'canceled';
        default:
          return true;
      }
    }).toList();
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'text': 'Menunggu', 'color': const Color(0xFFFF9800)};
      case 'shipped':
        return {'text': 'Dikemas', 'color': const Color(0xFF2196F3)};
      case 'delivered':
        return {'text': 'Dikirim', 'color': const Color(0xFF1B5E20)};
      case 'completed':
        return {'text': 'Selesai', 'color': const Color(0xFF4CAF50)};
      case 'canceled':
        return {'text': 'Dibatalkan', 'color': const Color(0xFFE57373)};
      default:
        return {'text': status, 'color': const Color(0xFF9E9E9E)};
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return "${dt.day} ${months[dt.month]} ${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  String _formatRupiah(dynamic value) {
    try {
      final number = value is double
          ? value
          : double.tryParse(value.toString()) ?? 0;
      return "Rp${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    } catch (_) {
      return "Rp0";
    }
  }

  Future<List<Order>> fetchUserOrders(int userId) async {
    return await OrderService().getUserOrders();
  }
}
