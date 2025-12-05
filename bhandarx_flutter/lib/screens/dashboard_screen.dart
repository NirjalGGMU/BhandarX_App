import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text("Home"),
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF2196F3))))],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2196F3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('assets/images/logo.png', height: 60),
                  const SizedBox(height: 12),
                  const Text("BhandarX", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home, color: Color(0xFF2196F3)), title: const Text("Home")),
            ListTile(leading: const Icon(Icons.inventory, color: Color(0xFF2196F3)), title: const Text("Inventory")),
            ListTile(leading: const Icon(Icons.people, color: Color(0xFF2196F3)), title: const Text("Employees")),
            ListTile(leading: const Icon(Icons.receipt_long, color: Color(0xFF2196F3)), title: const Text("Transactions")),
          ],
        ),
      ),
      body: const Center(child: Text("Home", style: TextStyle(fontSize: 28, color: Colors.black54, fontWeight: FontWeight.w600))),
    );
  }
}