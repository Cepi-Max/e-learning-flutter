import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dosen/welcome_dosen_screen.dart';
import '../../providers/auth_provider.dart';
import '../mahasiswa/welcome_mahasiswa_screen.dart';
import 'login_screen.dart';

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

    await Future.delayed(const Duration(seconds: 2));

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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100);
              },
            ),
            // const SizedBox(height: 20),
            // const CircularProgressIndicator(),
            // const SizedBox(height: 20),
            // const Text(
            //   'Edu Sohib',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
          ],
        ),
      ),
    );
  }
}
