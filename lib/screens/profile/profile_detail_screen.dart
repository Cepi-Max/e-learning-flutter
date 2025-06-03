import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ProfileDetailScreen extends StatelessWidget {
  final User user;

  const ProfileDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Warna tema utama
    final primaryColor = Colors.green[700];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 56,
              backgroundColor: primaryColor!.withOpacity(0.13),
              child: Icon(
                Icons.person,
                color: primaryColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 22),
            // Nama
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(
              user.role.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),

            Divider(color: Colors.grey[300], thickness: 1.2),

            // DATA
            _buildInfoTile(context, icon: Icons.email_outlined, title: 'Email', value: user.email),
            _buildInfoTile(context, icon: Icons.location_on_outlined, title: 'Lokasi', value: user.lokasi),
            _buildInfoTile(context, icon: Icons.phone_iphone_rounded, title: 'No. Telepon', value: user.phone_number),
            _buildInfoTile(context, icon: Icons.verified_user_rounded, title: 'Role', value: user.role),
            const SizedBox(height: 32),

            // Tombol edit profil (opsional)
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     icon: const Icon(Icons.edit, size: 20),
            //     label: const Text('Edit Profil', style: TextStyle(fontSize: 16)),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: primaryColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //     ),
            //     onPressed: () {
            //       // Navigasi ke halaman edit profil
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            offset: const Offset(1, 2),
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 27),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
