// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class OnboardingScreen extends StatefulWidget {
//   static const routeName = '/onboarding';
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _controller = PageController();
//   int currentIndex = 0;

//   final List<Map<String, dynamic>> pages = [
//     {
//       "icon": Icons.inventory_2_rounded,
//       "title": "Manage Stock Easily",
//       "subtitle": "Track items, quantities and categories without hassle."
//     },
//     {
//       "icon": Icons.analytics_outlined,
//       "title": "Smart Insights",
//       "subtitle": "View reports and analysis for better decisions."
//     },
//     {
//       "icon": Icons.shopping_cart_checkout_rounded,
//       "title": "Faster Billing",
//       "subtitle": "Speed up sales and reduce errors in your business."
//     }
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _controller,
//                 itemCount: pages.length,
//                 onPageChanged: (index) {
//                   setState(() => currentIndex = index);
//                 },
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(pages[index]["icon"], size: 140, color: Color(0xFF1E3A8A)),
//                         const SizedBox(height: 40),
//                         Text(
//                           pages[index]["title"],
//                           style: const TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 15),
//                         Text(
//                           pages[index]["subtitle"],
//                           style: const TextStyle(
//                             fontSize: 15,
//                             color: Colors.grey,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Dots
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 pages.length,
//                 (index) => AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: const EdgeInsets.all(4),
//                   height: 10,
//                   width: currentIndex == index ? 26 : 10,
//                   decoration: BoxDecoration(
//                     color:
//                         currentIndex == index ? Colors.blue : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Button
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1E3A8A),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//                 onPressed: () {
//                   if (currentIndex == pages.length - 1) {
//                     Navigator.pushReplacementNamed(
//                         context, LoginScreen.routeName);
//                   } else {
//                     _controller.nextPage(
//                         duration: const Duration(milliseconds: 600),
//                         curve: Curves.easeInOut);
//                   }
//                 },
//                 child: Text(
//                   currentIndex == pages.length - 1 ? "Get Started" : "Next",
//                   style: const TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final pages = [
    {"title": "Welcome to BhandarX", "desc": "Smart inventory management"},
    {"title": "Track Products Easily", "desc": "Add, edit, and organize items"},
    {"title": "Stay Updated", "desc": "Get low-stock alerts instantly"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 200),
                      const SizedBox(height: 60),
                      Text(pages[i]["title"]!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(pages[i]["desc"]!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(pages.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _current == i ? 24 : 10, height: 10, decoration: BoxDecoration(color: _current == i ? const Color(0xFF3949AB) : Colors.grey[300], borderRadius: BorderRadius.circular(12))))),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  if (_current == pages.length - 1) {
                    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3949AB), minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(_current == pages.length - 1 ? "Get Started" : "Next", style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}