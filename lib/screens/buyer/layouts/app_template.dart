import 'package:flutter/material.dart';
import '../../../api/cart_service.dart';
import '../products/product_list_screen.dart';
import '../products/cart_screen.dart';
import '../../profile/profile_screen.dart';

class AppTemplate extends StatefulWidget {
  const AppTemplate({super.key});

  @override
  State<AppTemplate> createState() => _AppTemplateState();
}

class _AppTemplateState extends State<AppTemplate> {
  int _selectedIndex = 0;
  int _cartItemCount = 0;  

  List<Widget> get _pages => [
    ProductScreen(),
    CartScreen(onCartUpdated: _fetchCartData),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCartData(); 
  }

  
  // Fungsi untuk mengambil data cart
  Future<void> _fetchCartData() async {
    final response = await CartService().getCarts();  
    if (response.success) {
      setState(() {
        _cartItemCount = response.data?['totalItems'] ?? 0;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0 || index == 1) {
      _fetchCartData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: const Color(0xff757575),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (_cartItemCount > 0)  // Tampilkan badge hanya jika ada item
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartItemCount',  // Tampilkan jumlah item
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String label;
  const PlaceholderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
    );
  }
}
