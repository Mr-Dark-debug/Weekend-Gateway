import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

class SupabaseConfig {
  static final Logger _logger = Logger();
  static late final SupabaseClient _client;
  static bool _isInitialized = false;
  
  // Getter for the Supabase client
  static SupabaseClient get client {
    if (!_isInitialized) {
      _logger.w('Supabase client accessed before initialization.');
      // Optionally, throw an error or handle as per app's requirement
      // For now, this will lead to an error if _client methods are called.
      // However, currentUser and isAuthenticated will handle this.
    }
    return _client;
  }

  // Initialize Supabase client
  static Future<void> initialize() async {
    try {
      final String supabaseUrl = dotenv.get('SUPABASE_URL');
      final String supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY');
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
      );
      
      _client = Supabase.instance.client;
      _isInitialized = true;
      _logger.i('Supabase initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Supabase: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // Get current user
  static User? get currentUser => _isInitialized ? _client.auth.currentUser : null;
  
  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  // Sign up a new user
  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }
  
  // Sign in a user
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }
  
  // Sign out the current user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      _logger.e('Reset password error: $e');
      rethrow;
    }
  }
  
  // Upload a file to Supabase storage
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(contentType: contentType),
      );
      
      final String fileUrl = _client.storage.from(bucket).getPublicUrl(path);
      return fileUrl;
    } catch (e) {
      _logger.e('File upload error: $e');
      rethrow;
    }
  }
} 