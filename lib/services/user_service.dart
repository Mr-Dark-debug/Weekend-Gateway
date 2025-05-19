import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile({String? userId}) async {
    try {
      final String targetUserId = userId ?? _supabase.auth.currentUser?.id ?? '';
      
      if (targetUserId.isEmpty) {
        return null;
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', targetUserId)
          .single();
          
      return response;
    } catch (e, stackTrace) {
      _logger.e('Error fetching user profile', e, stackTrace);
      return null;
    }
  }

  // Get user's created trips
  Future<List<Map<String, dynamic>>> getUserCreatedTrips(String userId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            trip_ratings (rating),
            trip_likes (id)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((trip) => trip as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching user created trips', e, stackTrace);
      return [];
    }
  }

  // Get user's saved/liked trips
  Future<List<Map<String, dynamic>>> getUserSavedTrips(String userId) async {
    try {
      final response = await _supabase
          .from('trip_likes')
          .select('''
            trips (
              *,
              users:user_id (username, avatar_url),
              trip_ratings (rating)
            )
          ''')
          .eq('user_id', userId);
      
      // Transform the response to extract trip data
      return response
          .map((item) => item['trips'] as Map<String, dynamic>)
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching user saved trips', e, stackTrace);
      return [];
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('users')
          .update(profileData)
          .eq('id', userId);
    } catch (e, stackTrace) {
      _logger.e('Error updating user profile', e, stackTrace);
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload user avatar
  Future<String> uploadAvatar(String filePath, String fileExt) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final String path = 'avatars/$userId/avatar.$fileExt';
      await _supabase.storage.from('user-content').upload(
        path,
        filePath,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final imageUrl = _supabase.storage.from('user-content').getPublicUrl(path);

      // Update user profile with new avatar URL
      await _supabase.from('users').update({
        'avatar_url': imageUrl,
      }).eq('id', userId);

      return imageUrl;
    } catch (e, stackTrace) {
      _logger.e('Error uploading avatar', e, stackTrace);
      throw Exception('Failed to upload avatar: $e');
    }
  }

  // Register user
  Future<User> registerUser(String email, String password, String username) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      // Create user profile in 'users' table
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'username': username,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });

      return response.user!;
    } catch (e, stackTrace) {
      _logger.e('Error registering user', e, stackTrace);
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<User> loginUser(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      return response.user!;
    } catch (e, stackTrace) {
      _logger.e('Error logging in', e, stackTrace);
      throw Exception('Login failed: $e');
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
    } catch (e, stackTrace) {
      _logger.e('Error logging out', e, stackTrace);
      throw Exception('Logout failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e, stackTrace) {
      _logger.e('Error resetting password', e, stackTrace);
      throw Exception('Password reset failed: $e');
    }
  }
} 