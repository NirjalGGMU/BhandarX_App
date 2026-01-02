// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/auth_storage.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  void _register() async {
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    // Empty field validation
    if (fullName.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _error = "All fields are required");
      return;
    }

    // Password strength validation
    if (pass.length < 8 || !RegExp(r'[!@#$%^&*]').hasMatch(pass)) {
      setState(() => _error = "Password: 8+ chars + 1 special symbol");
      return;
    }

    // Confirm password validation
    if (pass != confirm) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    // Save user (frontend only)
    await AuthStorage.saveUser(email, pass);

    // 🔥 FIXED — Redirect to LOGIN, NOT DASHBOARD
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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

              const Text(
                "Create Account",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Join BhandarX",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // FULL NAME FIELD
              InputField(label: "Full Name", controller: _fullNameCtrl),

              // EMAIL FIELD
              InputField(label: "Email", controller: _emailCtrl),

              // PASSWORD FIELD
              InputField(label: "Password", controller: _passCtrl, isPassword: true),

              // CONFIRM PASSWORD FIELD
              InputField(label: "Confirm Password", controller: _confirmCtrl, isPassword: true),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 20),

              CustomButton(text: "Create Account", onPressed: _register),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Already have account? Login",
                  style: TextStyle(color: Color(0xFF3949AB)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


