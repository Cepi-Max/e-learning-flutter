import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dosen/welcome_dosen_screen.dart';
import '../mahasiswa/welcome_mahasiswa_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // LANGSUNG cek auth, tanpa delay 2 detik
    final isAuthenticated = await authProvider.checkAuthStatus();
    final userRole = authProvider.user?.role.toLowerCase();

    if (!mounted) return;

    if (isAuthenticated && userRole != null) {
      if (userRole == 'mahasiswa') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentWelcomePage()),
        );
      } else if (userRole == 'dosen') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LecturerWelcomePage()),
        );
      }
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image(
              image: AssetImage('assets/images/logo.jpg'),
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),

            // Spinner
            CircularProgressIndicator(),

            SizedBox(height: 10),

            // Teks loading
            // Text('Memuat aplikasi...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
