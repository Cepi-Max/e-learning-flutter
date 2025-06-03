import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';
import '../screens/farmer/datapadi_screen.dart';
import '../screens/farmer/tambah_padi_screen.dart';
import '../screens/dashboard/form_produk_screen.dart';
import '../screens/dashboard/order_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Toko Padi',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/datapadi': (context) => const DataPadiScreen(),
          '/tambah-data-padi': (context) => const FormTambahPadiScreen(),
          '/form-product': (context) => FormProductScreen(),
          '/order-list': (context) => const OrderListScreen(),

          // Tambahin rute lainnya
        },
      ),
    );
  }
}