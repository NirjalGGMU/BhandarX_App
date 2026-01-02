// import 'package:flutter/material.dart';

// class DashboardScreen extends StatelessWidget {
//   static const routeName = '/dashboard';
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("BhandarX Dashboard"),
//         backgroundColor: const Color(0xFF1E3A8A),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: GridView.count(
//           crossAxisCount: 2,
//           childAspectRatio: 1.2,
//           crossAxisSpacing: 20,
//           mainAxisSpacing: 20,
//           children: [
//             dashItem(Icons.inventory_rounded, "Products"),
//             dashItem(Icons.category_outlined, "Categories"),
//             dashItem(Icons.add_shopping_cart, "Add Stock"),
//             dashItem(Icons.remove_shopping_cart, "Reduce Stock"),
//             dashItem(Icons.analytics, "Reports"),
//             dashItem(Icons.settings, "Settings"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget dashItem(IconData icon, String title) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             spreadRadius: 1,
//           )
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 48, color: Color(0xFF1E3A8A)),
//           const SizedBox(height: 10),
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class DashboardScreen extends StatelessWidget {
//   static const routeName = '/dashboard';
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E3A8A), // changed color
//         foregroundColor: Colors.white,
//         title: const Text("Home"),
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(Icons.person, color: Color(0xFF1E3A8A)), // changed color
//             ),
//           )
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Color(0xFF1E3A8A)), // changed color
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Image.asset('assets/images/logo.png', height: 60),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "BhandarX",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home, color: Color(0xFF1E3A8A)), // changed color
//               title: const Text("Home"),
//             ),
//             ListTile(
//               leading: const Icon(Icons.inventory, color: Color(0xFF1E3A8A)), // changed color
//               title: const Text("Inventory"),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people, color: Color(0xFF1E3A8A)), // changed color
//               title: const Text("Employees"),
//             ),
//             ListTile(
//               leading: const Icon(Icons.receipt_long, color: Color(0xFF1E3A8A)), // changed color
//               title: const Text("Transactions"),
//             ),
//           ],
//         ),
//       ),
//       body: const Center(
//         child: Text(
//           "Welcome to Dashboard!",
//           style: TextStyle(
//             fontSize: 28,
//             color: Colors.black54,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }



// Laest code befor now

// import 'package:flutter/material.dart';
// import '../widgets/bottom_nav_bar.dart';

// class DashboardScreen extends StatefulWidget {
//   static const routeName = '/dashboard';
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _currentIndex = 0;

//   void _onNavTap(int index) {
//     setState(() => _currentIndex = index);
//   }

//   void _onAddPressed() {
//     // Future: Navigate to Add Inventory screen
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Add new inventory")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dashboard"),
//       ),

//       body: Center(
//         child: Text(
//           "Current Tab: $_currentIndex",
//           style: const TextStyle(fontSize: 22),
//         ),
//       ),

//       bottomNavigationBar: BhandarXBottomNav(
//         currentIndex: _currentIndex,
//         onTap: _onNavTap,
//         onCenterTap: _onAddPressed,
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../themes/app_colors.dart';


// class DashboardScreen extends StatefulWidget {
// static const routeName = '/dashboard';
// const DashboardScreen({super.key});


// @override
// State<DashboardScreen> createState() => _DashboardScreenState();
// }


// class _DashboardScreenState extends State<DashboardScreen> {
// int _currentIndex = 0;


// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(
// title: const Text('Dashboard'),
// ),


// drawer: Drawer(
// child: ListView(
// children: const [
// DrawerHeader(
// decoration: BoxDecoration(color: AppColors.primary),
// child: Text('BhandarX',
// style: TextStyle(color: Colors.white, fontSize: 22)),
// ),
// ListTile(leading: Icon(Icons.home), title: Text('Home')),
// ListTile(leading: Icon(Icons.inventory), title: Text('Inventory')),
// ListTile(leading: Icon(Icons.people), title: Text('Employees')),
// ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
// ],
// ),
// ),


// body: Center(
// child: Text(
// 'Welcome to Dashboard',
// style: Theme.of(context).textTheme.headlineMedium,
// ),
// ),


// bottomNavigationBar: BhandarXBottomNav(
// currentIndex: _currentIndex,
// onTap: (index) => setState(() => _currentIndex = index),
// ),
// );
// }
// }


// bhandarx_flutter/lib/screens/dashboard_screen.dart
// import 'package:flutter/material.dart';
// import '../themes/app_colors.dart';

// class DashboardScreen extends StatefulWidget {
//   static const routeName = '/dashboard';
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = const [
//     Center(child: Text("Dashboard")),
//     Center(child: Text("Inventory")),
//     Center(child: Text("Profile")),
//     Center(child: Text("Settings")),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("BhandarX")),

//       // Drawer (unchanged, still professional)
//       drawer: Drawer(
//         child: ListView(
//           children: const [
//             DrawerHeader(
//               decoration: BoxDecoration(color: AppColors.primary),
//               child: Text(
//                 "BhandarX",
//                 style: TextStyle(color: Colors.white, fontSize: 22),
//               ),
//             ),
//             ListTile(leading: Icon(Icons.dashboard), title: Text("Dashboard")),
//             ListTile(leading: Icon(Icons.inventory), title: Text("Inventory")),
//             ListTile(leading: Icon(Icons.people), title: Text("Employees")),
//             ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
//             Divider(),
//             ListTile(leading: Icon(Icons.logout), title: Text("Logout")),
//           ],
//         ),
//       ),

//       body: _pages[_currentIndex],

//       // 🔥 Modern Bottom Navigation
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   Widget _buildBottomNav() {
//     return Container(
//       height: 72,
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _navIcon(Icons.dashboard, 0),
//               _navIcon(Icons.inventory_2, 1),
//               const SizedBox(width: 60), // space for FAB
//               _navIcon(Icons.person, 2),
//               _navIcon(Icons.settings, 3),
//             ],
//           ),

//           // Center Floating Action
//           Positioned(
//             top: -26,
//             child: GestureDetector(
//               onTap: () {
//                 // Add inventory action
//               },
//               child: Container(
//                 height: 58,
//                 width: 58,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.primary.withOpacity(0.4),
//                       blurRadius: 12,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(Icons.add, color: Colors.white, size: 30),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _navIcon(IconData icon, int index) {
//     final bool isActive = _currentIndex == index;

//     return IconButton(
//       onPressed: () => setState(() => _currentIndex = index),
//       icon: Icon(
//         icon,
//         size: 26,
//         color: isActive ? AppColors.primary : Colors.grey,
//       ),
//     );
//   }
// }


// bhandarx_flutter/lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("BhandarX"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Good Evening 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // FEATURE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.inventory_2, color: Colors.white, size: 32),
                  SizedBox(height: 10),
                  Text(
                    "Inventory Overview",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track stock, sales & updates easily",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QUICK ACTIONS
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _dashboardCard(Icons.inventory, "Inventory"),
                  _dashboardCard(Icons.receipt_long, "Transactions"),
                  _dashboardCard(Icons.people, "Employees"),
                  _dashboardCard(Icons.analytics, "Reports"),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BhandarXBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onCenterTap: () {
          // Add new inventory action
        },
      ),
    );
  }

  Widget _dashboardCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  "BhandarX",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Inventory Management",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(leading: Icon(Icons.home), title: Text("Home")),
          ListTile(leading: Icon(Icons.inventory), title: Text("Inventory")),
          ListTile(leading: Icon(Icons.people), title: Text("Employees")),
          ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
          const Spacer(),
          ListTile(leading: const Icon(Icons.logout), title: const Text("Logout")),
        ],
      ),
    );
  }
}
