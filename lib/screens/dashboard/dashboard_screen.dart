import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'datapadi_screen.dart';
import 'order_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Padi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${user?.name ?? 'Pengguna'}!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Lokasi: ${user?.lokasi ?? '-'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Menu Utama',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Menu Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Data Produk',
                    Icons.agriculture,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DataPadiScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Orderan Masuk',
                    Icons.receipt_long,
                    () {
                      // Ganti ini ke tampilan order jika sudah tersedia
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderListScreen()));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Halaman orderan akan segera hadir')),
                      // );
                    },
                  ),
                  // Tambahan menu lain bisa ditaruh di sini
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
