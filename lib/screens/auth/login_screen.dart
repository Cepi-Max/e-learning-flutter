import 'package:flutter/material.dart';
import '../../screens/farmer/datapadi_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../buyer/layouts/app_template.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        'assets/images/logo.jpg',
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error); 
                        },
                        height: 200,
                      ),
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.green[700],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Masukkan email anda',
                          labelStyle: TextStyle(color: Colors.black), 
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        cursorColor: Colors.green[700],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password anda',
                          labelStyle: const TextStyle(color: Colors.black),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleLogin(authProvider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('LOGIN'),
                      ),
                      const SizedBox(height: 16),
                      if (authProvider.errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.red.shade100,
                          child: Text(
                            authProvider.errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      final success = await authProvider.login(email, password);
      
      if (success && mounted) {
        
        // Login berhasil, cek role dan arahkan ke halaman yang sesuai
        final role = authProvider.user?.role ?? '';
        
        if (role.toLowerCase() == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else if (role.toLowerCase() == 'user') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppTemplate()),
        );
      } else if (role.toLowerCase() == 'petani') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DataPadiScreen()),
        );
      }
        // } else {
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (_) => const AppTemplate()),
        //   );
        // }
      }
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../utils/validators.dart';
// import '../../widgets/buttons/primary_button.dart';
// import '../../widgets/inputs/text_input.dart';
// import '../dashboard/dashboard_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       FocusScope.of(context).unfocus();
      
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final success = await authProvider.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );
      
//       if (success && mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const DashboardScreen()),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
    
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.eco,
//                     size: 80,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'DataPadi',
//                     style: Theme.of(context).textTheme.displayLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Masuk untuk melanjutkan',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 32),
//                   TextInput(
//                     controller: _emailController,
//                     label: 'Email',
//                     validator: Validators.validateEmail,
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 16),
//                   TextInput(
//                     controller: _passwordController,
//                     label: 'Password',
//                     obscureText: _obscurePassword,
//                     validator: Validators.validatePassword,
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   if (authProvider.errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Text(
//                         authProvider.errorMessage,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   const SizedBox(height: 24),
//                   PrimaryButton(
//                     text: 'Masuk',
//                     onPressed: _login,
//                     isLoading: authProvider.isLoading,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }