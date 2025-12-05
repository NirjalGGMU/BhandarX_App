import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3949AB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 140),
            const SizedBox(height: 30),
            const Text("BhandarX", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text("Inventory Made Simple", style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}