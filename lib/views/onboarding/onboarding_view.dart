import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../utils/app_theme.dart';
import '../home/main_tab_view.dart';
import '../paywall/paywall_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Smart Cleanup',
      subtitle: 'Free up storage by removing duplicate and similar photos automatically',
      color: AppTheme.primaryColor,
    ),
    _OnboardingPage(
      icon: Icons.photo_library,
      title: 'Photo Organizer',
      subtitle: 'Find screenshots, similar photos, and large files eating your space',
      color: AppTheme.warningColor,
    ),
    _OnboardingPage(
      icon: Icons.people,
      title: 'Contact Cleaner',
      subtitle: 'Merge duplicate contacts and remove incomplete entries',
      color: AppTheme.successColor,
    ),
    _OnboardingPage(
      icon: Icons.lock,
      title: 'Secret Space',
      subtitle: 'Keep your private photos safe with PIN & biometric protection',
      color: AppTheme.secondaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) => _pages[i],
              ),
            ),

            // Indicator
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: WormEffect(
                dotHeight: 8, dotWidth: 8,
                activeDotColor: AppTheme.primaryColor,
                dotColor: Colors.grey[300]!,
              ),
            ),
            const SizedBox(height: 32),

            // CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.appGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _onNext,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_currentPage == _pages.length - 1)
              TextButton(
                onPressed: _completeOnboarding,
                child: Text('Skip', style: TextStyle(color: Colors.grey[600])),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
      // Show paywall
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PaywallView()));
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainTabView()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;

  const _OnboardingPage({
    required this.icon, required this.title,
    required this.subtitle, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 32),
          Text(title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
