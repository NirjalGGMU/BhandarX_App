// import 'package:flutter/material.dart';

// class BhandarXBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final VoidCallback onCenterTap;

//   const BhandarXBottomNav({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.onCenterTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF3949AB),
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Navigation Icons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _navIcon(Icons.home, 0),
//               _navIcon(Icons.inventory_2, 1),
//               const SizedBox(width: 50), // space for FAB
//               _navIcon(Icons.notifications, 2),
//               _navIcon(Icons.person, 3),
//             ],
//           ),

//           // Center Floating Button
//           Positioned(
//             top: -28,
//             child: GestureDetector(
//               onTap: onCenterTap,
//               child: Container(
//                 height: 60,
//                 width: 60,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.add,
//                   size: 32,
//                   color: Color(0xFF3949AB),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _navIcon(IconData icon, int index) {
//     return IconButton(
//       onPressed: () => onTap(index),
//       icon: Icon(
//         icon,
//         size: 26,
//         color: currentIndex == index
//             ? Colors.white
//             : Colors.white70,
//       ),
//     );
//   }
// }



// bhandarx_flutter/lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class BhandarXBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;

  const BhandarXBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon(Icons.home, 0),
          _navIcon(Icons.inventory_2, 1),

          // CENTER ADD BUTTON (INSIDE CONTAINER)
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: onCenterTap,
            ),
          ),

          _navIcon(Icons.notifications, 2),
          _navIcon(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final isActive = currentIndex == index;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        color: isActive ? AppColors.primary : Colors.grey,
      ),
    );
  }
}
