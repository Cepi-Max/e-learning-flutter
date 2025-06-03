import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../buyer/layouts/app_template.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/farmer/datapadi_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

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
              (route) => false, // Menghapus semua route sebelumnya
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Tambahkan aksi pengaturan di sini
            },
          ),
        ],
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(20),
        //   ),
        // ),
      ),

      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  _buildProfileItem(context, 'Email Saya', user.email),
                  if (user.role == 'admin')
                    _buildProfileItem(context, 'Lokasi Gudang', user.lokasi),
                  _buildProfileItem(context, 'No telepon', user.phone_number),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
