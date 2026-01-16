// lib/features/auth/presentation/pages/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../presentation/view_model/auth_view_model.dart';
import '../../presentation/state/auth_state.dart'; // ← Import this!
import 'register_screen.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen for state changes (success → dashboard, error → snackbar)
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      }
      if (next.errorMessage != null && next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset('assets/images/logo.png', height: 110),
                  const SizedBox(height: 50),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Sign in to continue",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  InputField(label: "Email", controller: _emailCtrl),
                  InputField(
                    label: "Password",
                    controller: _passCtrl,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Login",
                    isLoading: authState.status == AuthStatus.loading,
                    onPressed: authState.status == AuthStatus.loading
                        ? () {}
                        : () {
                            final email = _emailCtrl.text.trim();
                            final pass = _passCtrl.text;
                  
                            if (email.isEmpty || pass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill email and password"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                  
                            ref
                                .read(authViewModelProvider.notifier)
                                .login(email: email, password: pass);
                          },
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RegisterScreen.routeName,
                    ),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Color(0xFF3949AB)),
                    ),
                  ),
                ],
              ),
            ),

            // Full-screen loading overlay
            if (authState.status == AuthStatus.loading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



// // lib/screens/login_screen.dart

// import 'package:flutter/material.dart';
// import '../../../../core/widgets/input_field.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../services/auth_storage.dart';
// import 'register_screen.dart';
// import '../../../dashboard/presentation/pages/dashboard_screen.dart';

// class LoginScreen extends StatefulWidget {
//   static const routeName = '/login';
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   String? _error;

//   void _login() async {
//     final email = _emailCtrl.text.trim();
//     final pass = _passCtrl.text;

//     // NEW: Check for empty fields first and show specific message
//     if (email.isEmpty || pass.isEmpty) {
//       setState(() => _error = "Please fill email and password first");
//       return;
//     }

//     // Validate against saved credentials
//     final isValid = await AuthStorage.validateUser(email, pass);
//     if (isValid) {
//       // successful login -> dashboard
//       Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
//     } else {
//       // credentials provided but incorrect
//       setState(() => _error = "Invalid email or password");
//     }
//   }

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               Image.asset('assets/images/logo.png', height: 110),
//               const SizedBox(height: 50),
//               const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//               const Text("Sign in to continue", style: TextStyle(color: Colors.grey)),
//               const SizedBox(height: 40),

//               InputField(label: "Email", controller: _emailCtrl),
//               InputField(label: "Password", controller: _passCtrl, isPassword: true),

//               if (_error != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
//                 ),

//               const SizedBox(height: 20),
//               CustomButton(text: "Login", onPressed: _login),

//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
//                 child: const Text("Don't have an account? Register", style: TextStyle(color: Color(0xFF3949AB))),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





// // lib/features/auth/presentation/pages/login_screen.dart
// import 'package:flutter/material.dart';
// import '../../../../core/widgets/input_field.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../services/auth_service.dart';
// import 'register_screen.dart';
// import '../../../dashboard/presentation/pages/dashboard_screen.dart';

// class LoginScreen extends StatefulWidget {
//   static const routeName = '/login';
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();

//   String? _error;
//   bool _loading = false;

//   void _login() async {
//     final email = _emailCtrl.text.trim();
//     final pass = _passCtrl.text;

//     if (email.isEmpty || pass.isEmpty) {
//       setState(() => _error = "Please fill email and password first");
//       return;
//     }

//     setState(() {
//       _error = null;
//       _loading = true;
//     });

//     bool success = await AuthService().login(email, pass);

//     if (success) {
//       Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
//     } else {
//       setState(() => _error = "Invalid email or password");
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               Image.asset('assets/images/logo.png', height: 110),
//               const SizedBox(height: 50),
//               const Text(
//                 "Welcome Back",
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//               ),
//               const Text("Sign in to continue", style: TextStyle(color: Colors.grey)),
//               const SizedBox(height: 40),
//               InputField(label: "Email", controller: _emailCtrl),
//               InputField(label: "Password", controller: _passCtrl, isPassword: true),
//               if (_error != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
//                 ),
//               const SizedBox(height: 20),
//               CustomButton(
//                 text: _loading ? "Logging in..." : "Login",
//                 onPressed: _loading ? () {} : _login,
//               ),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
//                 child: const Text(
//                   "Don't have an account? Register",
//                   style: TextStyle(color: Color(0xFF3949AB)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








// // lib/screens/login_screen.dart

// import 'package:flutter/material.dart';
// import '../../../../core/widgets/input_field.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../services/auth_service.dart';
// import 'register_screen.dart';
// import '../../../dashboard/presentation/pages/dashboard_screen.dart';

// class LoginScreen extends StatefulWidget {
//   static const routeName = '/login';
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   String? _error;

//   void _login() async {
//     final email = _emailCtrl.text.trim();
//     final pass = _passCtrl.text;

//     // NEW: Check for empty fields first and show specific message
//     if (email.isEmpty || pass.isEmpty) {
//       setState(() => _error = "Please fill email and password first");
//       return;
//     }

//     // Validate against saved credentials
//     final isValid = await AuthService.validateUser(email, pass);
//     if (isValid) {
//       // successful login -> dashboard
//       Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
//     } else {
//       // credentials provided but incorrect
//       setState(() => _error = "Invalid email or password");
//     }
//   }

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               Image.asset('assets/images/logo.png', height: 110),
//               const SizedBox(height: 50),
//               const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//               const Text("Sign in to continue", style: TextStyle(color: Colors.grey)),
//               const SizedBox(height: 40),

//               InputField(label: "Email", controller: _emailCtrl),
//               InputField(label: "Password", controller: _passCtrl, isPassword: true),

//               if (_error != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
//                 ),

//               const SizedBox(height: 20),
//               CustomButton(text: "Login", onPressed: _login),

//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
//                 child: const Text("Don't have an account? Register", style: TextStyle(color: Color(0xFF3949AB))),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
