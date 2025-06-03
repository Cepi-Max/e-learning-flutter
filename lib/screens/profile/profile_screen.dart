import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../buyer/layouts/app_template.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/farmer/datapadi_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

// Ganti dengan halaman yang bener
import 'profile_detail_screen.dart'; // Data Saya
import 'order_list_screen.dart';       // Pesanan Saya

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if (user?.role == 'admin') {
                    return const DashboardScreen();
                  } else if (user?.role == 'petani') {
                    return const DataPadiScreen();
                  } else if (user?.role == 'user') {
                    return const AppTemplate();
                  } else {
                    return const LoginScreen();
                  }
                },
              ),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // ====== MENU LIST ======
                _buildMenu(context,
                  icon: Icons.account_circle_outlined,
                  title: 'Data Saya',
                  subtitle: 'Lihat & edit data diri',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileDetailScreen(user: user)),
                    );
                  },
                ),
                _buildMenu(context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Pesanan Saya',
                  subtitle: 'Lihat riwayat pesanan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderListScreen(userId: user.id)),
                    );
                  },
                ),
                // =======================
              ],
            ),
    );
  }

  Widget _buildMenu(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700], size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
