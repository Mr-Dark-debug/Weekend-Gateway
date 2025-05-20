import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weekend_gateway/models/user_model.dart';
import 'package:weekend_gateway/models/trip_model.dart';
import 'dart:io' as io;
import 'dart:typed_data';

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

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    return getUserProfile(userId: userId);
  }

  // Get user profile
  Future<UserModel?> getUserProfile({String? userId}) async {
    try {
      final String targetUserId = userId ?? _supabase.auth.currentUser?.id ?? '';

      if (targetUserId.isEmpty) {
        return null;
      }

      // Get basic user data
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', targetUserId)
          .single();

      // Get follower count
      final followerCount = await _supabase
          .from('user_follows')
          .select('id')
          .eq('following_id', targetUserId);

      // Get following count
      final followingCount = await _supabase
          .from('user_follows')
          .select('id')
          .eq('follower_id', targetUserId);

      // Get trip count
      final tripCount = await _supabase
          .from('trips')
          .select('id')
          .eq('user_id', targetUserId);

      // Check if current user is following this user
      bool isFollowedByCurrentUser = false;
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null && currentUserId != targetUserId) {
        final followData = await _supabase
            .from('user_follows')
            .select('id')
            .eq('follower_id', currentUserId)
            .eq('following_id', targetUserId);

        isFollowedByCurrentUser = followData.isNotEmpty;
      }

      // Create user model
      final user = UserModel.fromJson(userData);
      return user.copyWith(
        followerCount: followerCount.length,
        followingCount: followingCount.length,
        tripCount: tripCount.length,
        isFollowedByCurrentUser: isFollowedByCurrentUser,
      );
    } catch (e, stackTrace) {
      _logger.e('Error fetching user profile', e, stackTrace);
      return null;
    }
  }

  // Get user's created trips
  Future<List<TripModel>> getUserCreatedTrips(String userId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            users:user_id (id, username, avatar_url),
            trip_ratings (rating),
            trip_likes (id)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((trip) {
        final userData = trip['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return TripModel.fromJson(trip, author: author);
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching user created trips', e, stackTrace);
      return [];
    }
  }

  // Get user's saved trips
  Future<List<TripModel>> getUserSavedTrips(String userId) async {
    try {
      final response = await _supabase
          .from('saved_trips')
          .select('''
            trips (
              *,
              users:user_id (id, username, avatar_url),
              trip_ratings (rating),
              trip_likes (id)
            )
          ''')
          .eq('user_id', userId);

      // Transform the response to extract trip data
      return response.map((item) {
        final trip = item['trips'] as Map<String, dynamic>;
        final userData = trip['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return TripModel.fromJson(
          trip,
          author: author,
          isSavedByCurrentUser: true,
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching user saved trips', e, stackTrace);
      return [];
    }
  }

  // Get user's liked trips
  Future<List<TripModel>> getUserLikedTrips(String userId) async {
    try {
      final response = await _supabase
          .from('trip_likes')
          .select('''
            trips (
              *,
              users:user_id (id, username, avatar_url),
              trip_ratings (rating),
              trip_likes (id)
            )
          ''')
          .eq('user_id', userId);

      // Transform the response to extract trip data
      return response.map((item) {
        final trip = item['trips'] as Map<String, dynamic>;
        final userData = trip['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return TripModel.fromJson(
          trip,
          author: author,
          isLikedByCurrentUser: true,
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching user liked trips', e, stackTrace);
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
  Future<String> uploadAvatar(io.File file, String fileExt) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Read file as bytes
      final bytes = await file.readAsBytes();
      
      final String path = 'avatars/$userId/avatar.$fileExt';
      await _supabase.storage.from('user-content').uploadBinary(
        path,
        bytes,
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

  // Upload user avatar from bytes
  Future<String> uploadAvatarBytes(Uint8List bytes, String fileExt) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final String path = 'avatars/$userId/avatar.$fileExt';
      await _supabase.storage.from('user-content').uploadBinary(
        path,
        bytes,
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
  
  // Check if a user is following another user
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final response = await _supabase
          .from('user_follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      _logger.e('Error checking follow status', e, stackTrace);
      return false;
    }
  }
  
  // Follow a user
  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _supabase.from('user_follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
    } catch (e, stackTrace) {
      _logger.e('Error following user', e, stackTrace);
      throw Exception('Failed to follow user: $e');
    }
  }
  
  // Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _supabase
          .from('user_follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } catch (e, stackTrace) {
      _logger.e('Error unfollowing user', e, stackTrace);
      throw Exception('Failed to unfollow user: $e');
    }
  }
}