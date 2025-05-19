import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/trip/trip_detail_screen.dart';
import '../presentation/screens/trip/create_trip_screen.dart';
import '../presentation/screens/search/search_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String tripDetail = '/trip-detail';
  static const String createTrip = '/create-trip';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return _buildPageRoute(const OnboardingScreen(), settings);
      case login:
        return _buildPageRoute(const LoginScreen(), settings);
      case signup:
        return _buildPageRoute(const SignupScreen(), settings);
      case forgotPassword:
        return _buildPageRoute(const ForgotPasswordScreen(), settings);
      case home:
        return _buildPageRoute(const HomeScreen(), settings);
      case profile:
        final String? userId = settings.arguments as String?;
        return _buildPageRoute(ProfileScreen(userId: userId), settings);
      case tripDetail:
        final String tripId = settings.arguments as String;
        return _buildPageRoute(TripDetailScreen(tripId: tripId), settings);
      case createTrip:
        return _buildPageRoute(const CreateTripScreen(), settings);
      case search:
        return _buildPageRoute(const SearchScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(fontFamily: 'RobotoMono'),
              ),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder<dynamic> _buildPageRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
} 