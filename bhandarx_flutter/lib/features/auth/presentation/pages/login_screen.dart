// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/auth_storage.dart';
import 'register_screen.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  void _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    // NEW: Check for empty fields first and show specific message
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = "Please fill email and password first");
      return;
    }

    // Validate against saved credentials
    final isValid = await AuthStorage.validateUser(email, pass);
    if (isValid) {
      // successful login -> dashboard
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    } else {
      // credentials provided but incorrect
      setState(() => _error = "Invalid email or password");
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/logo.png', height: 110),
              const SizedBox(height: 50),
              const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Sign in to continue", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              InputField(label: "Email", controller: _emailCtrl),
              InputField(label: "Password", controller: _passCtrl, isPassword: true),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),

              const SizedBox(height: 20),
              CustomButton(text: "Login", onPressed: _login),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                child: const Text("Don't have an account? Register", style: TextStyle(color: Color(0xFF3949AB))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
