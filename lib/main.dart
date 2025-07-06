import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';
import 'screens/mahasiswa/welcome_mahasiswa_screen.dart';
import 'screens/dosen/welcome_dosen_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Edu Sohib For Learning Collage',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/mahasiswa': (context) => const StudentWelcomePage(),
          '/dosen': (context) => const LecturerWelcomePage(),
        },
      ),
    );
  }
}
