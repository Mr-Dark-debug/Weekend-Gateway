import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:weekend_gateway/config/app_routes.dart';
import 'package:weekend_gateway/config/supabase_config.dart';
import 'package:weekend_gateway/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    // Continue execution, Supabase init will fail gracefully if keys are missing
  }
  
  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    // Continue anyway, allowing the app to show login screen
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.primaryBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekend Gateway',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeData(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
