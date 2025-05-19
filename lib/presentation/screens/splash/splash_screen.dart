import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_routes.dart';
import '../../../config/supabase_config.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Add a slight delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    // Determine the next route
    String nextRoute;
    if (!hasSeenOnboarding) {
      nextRoute = AppRoutes.onboarding;
    } else if (SupabaseConfig.isAuthenticated) {
      nextRoute = AppRoutes.home;
    } else {
      nextRoute = AppRoutes.login;
    }
    
    // Navigate to the next screen
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryBackground,
                border: Border.all(
                  color: AppTheme.primaryForeground,
                  width: 4,
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
                child: Text(
                  'WG',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .then(delay: 200.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Weekend Gateway',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppTheme.primaryForeground,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'Travel Together',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                color: AppTheme.primaryForeground,
              ),
            )
            .animate()
            .fadeIn(delay: 700.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
} 