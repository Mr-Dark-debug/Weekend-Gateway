import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weekend_gateway/config/app_routes.dart';
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Discover Weekend Trips',
      description: 'Explore a variety of weekend getaways curated by our community of travelers.',
      illustration: 'assets/images/onboarding_discover.png',
    ),
    OnboardingPage(
      title: 'Create & Share',
      description: 'Create your own travel plans, share your experiences, and help others discover new places.',
      illustration: 'assets/images/onboarding_create.png',
    ),
    OnboardingPage(
      title: 'Join the Community',
      description: 'Connect with fellow travelers, vote for your favorite trips, and build your travel profile.',
      illustration: 'assets/images/onboarding_community.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    // Set onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    
    // Navigate to login page
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only show on the first two pages)
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: _completeOnboarding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryForeground,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Pagination indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryAccent
                          : Colors.grey,
                      border: Border.all(
                        color: AppTheme.primaryForeground,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage < _pages.length - 1
                  ? NeoButton(
                      onPressed: () {
                        if (_pageController.page! < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text('NEXT'),
                    )
                  : NeoButton(
                      onPressed: () {
                        // Navigate to Login Screen
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('GET STARTED'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppTheme.primaryBackground,
              border: Border.all(
                color: AppTheme.primaryForeground,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryForeground,
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                page.illustration,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ).animate().slideY(
            begin: 0.2, 
            end: 0, 
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ).fadeIn(duration: 500.ms),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(
            begin: 0.2, 
            end: 0, 
            delay: 200.ms,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ).fadeIn(delay: 200.ms, duration: 500.ms),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(
            begin: 0.2, 
            end: 0, 
            delay: 400.ms,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          ).fadeIn(delay: 400.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String illustration;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.illustration,
  });
} 