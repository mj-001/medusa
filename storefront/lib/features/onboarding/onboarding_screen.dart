import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_theme.dart';

const _pages = [
  _OnboardPage(
    icon: Icons.eco_rounded,
    title: 'Farm-Fresh Produce',
    body:
        'Get the freshest vegetables, fruits and groceries sourced directly from Kenyan farms, delivered to your door.',
    bgColor: Color(0xFF1B5E20),
  ),
  _OnboardPage(
    icon: Icons.delivery_dining_rounded,
    title: 'Same-Day Delivery',
    body:
        'Order by 10 AM and receive your groceries the same day across Nairobi and surrounding areas.',
    bgColor: Color(0xFFE65100),
  ),
  _OnboardPage(
    icon: Icons.phone_android_rounded,
    title: 'Pay with M-Pesa',
    body:
        'Seamless, secure checkout with M-Pesa. No cash, no hassle — just tap and confirm.',
    bgColor: Color(0xFF006064),
  ),
];

class _OnboardPage {
  final IconData icon;
  final String title;
  final String body;
  final Color bgColor;
  const _OnboardPage(
      {required this.icon,
      required this.title,
      required this.body,
      required this.bgColor});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_current];
    return Scaffold(
      backgroundColor: page.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _done,
                child: const Text('Skip',
                    style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: 14)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (ctx, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon, size: 72, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotColor: Colors.white38,
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: page.bgColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (_current == _pages.length - 1) {
                        _done();
                      } else {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    },
                    child: Text(
                      _current == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
