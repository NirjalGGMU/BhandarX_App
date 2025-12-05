// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_storage.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

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

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = "Please fill all fields");
      return;
    }

    final user = await AuthStorage.getUser();
    if (user == null) {
      setState(() => _error = "No account found. Register first!");
      return;
    }

    if (user["email"] != email || user["password"] != pass) {
      setState(() => _error = "Wrong email or password");
      return;
    }

    Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
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

              // Fixed — now works perfectly
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