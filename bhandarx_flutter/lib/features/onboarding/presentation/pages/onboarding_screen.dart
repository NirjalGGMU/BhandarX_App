import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.inventory_2_rounded,
      "title": "Manage Stock Easily",
      "subtitle": "Track items, quantities and categories without hassle."
    },
    {
      "icon": Icons.analytics_outlined,
      "title": "Smart Insights",
      "subtitle": "View reports and analysis for better decisions."
    },
    {
      "icon": Icons.shopping_cart_checkout_rounded,
      "title": "Faster Billing",
      "subtitle": "Speed up sales and reduce errors in your business."
    }
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
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(pages[index]["icon"], size: 140, color: Color(0xFF1E3A8A)),
                        const SizedBox(height: 40),
                        Text(
                          pages[index]["title"],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          pages[index]["subtitle"],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  height: 10,
                  width: currentIndex == index ? 26 : 10,
                  decoration: BoxDecoration(
                    color:
                        currentIndex == index ? Colors.blue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (currentIndex == pages.length - 1) {
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut);
                  }
                },
                child: Text(
                  currentIndex == pages.length - 1 ? "Get Started" : "Next",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}




