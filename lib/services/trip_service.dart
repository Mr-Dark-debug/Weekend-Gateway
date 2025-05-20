import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weekend_gateway/models/trip_model.dart';
import 'package:weekend_gateway/models/user_model.dart';
import 'package:weekend_gateway/models/trip_day_model.dart';
import 'package:weekend_gateway/models/trip_activity_model.dart';
import 'package:weekend_gateway/models/trip_comment_model.dart';
import 'dart:io' as io;
import 'dart:typed_data';

class TripService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  // Get trips created by a specific user
  Future<List<TripModel>> getTripsCreatedByUser(String userId) async {
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

      final List<dynamic> tripsList = response;
      return tripsList.map((trip) {
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

  // Get trips saved by a specific user
  Future<List<TripModel>> getTripsSavedByUser(String userId) async {
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
      final List<dynamic> savedTripsList = response;
      return savedTripsList.map((item) {
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

  // Fetch all trips with optional filters
  Future<List<TripModel>> getTrips({
    String? searchQuery,
    int? days,
    String? region,
    double? minRating,
    int? priceLevel,
    bool nearbyOnly = false,
    double? userLat,
    double? userLng,
    double nearbyRadiusKm = 100.0,
  }) async {
    try {
      // Start with the base query
      var query = _supabase
          .from('trips')
          .select('''
            *,
            users:user_id (id, username, avatar_url),
            trip_ratings (rating),
            trip_likes (id, user_id)
          ''');

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,location.ilike.%$searchQuery%');
      }

      if (days != null && days > 0) {
        query = query.eq('days', days);
      }

      if (region != null && region != 'Any') {
        query = query.eq('region', region);
      }

      if (minRating != null && minRating > 0) {
        query = query.gte('avg_rating', minRating);
      }

      if (priceLevel != null) {
        query = query.eq('price_level', priceLevel);
      }

      // Execute the query
      final List<dynamic> response = await query;

      // Get current user ID for checking likes and saves
      final currentUserId = _supabase.auth.currentUser?.id;

      // Transform the response to TripModel objects
      return Future.wait(response.map((trip) async {
        // Extract user data
        final userData = trip['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Check if current user liked this trip
        bool isLikedByCurrentUser = false;
        if (currentUserId != null) {
          final likes = trip['trip_likes'] as List<dynamic>;
          isLikedByCurrentUser = likes.any((like) => like['user_id'] == currentUserId);
        }

        // Check if current user saved this trip
        bool isSavedByCurrentUser = false;
        if (currentUserId != null) {
          final savedTrips = await _supabase
              .from('saved_trips')
              .select()
              .eq('trip_id', trip['id'])
              .eq('user_id', currentUserId);

          isSavedByCurrentUser = savedTrips.isNotEmpty;
        }

        return TripModel.fromJson(
          trip,
          author: author,
          isLikedByCurrentUser: isLikedByCurrentUser,
          isSavedByCurrentUser: isSavedByCurrentUser,
        );
      }).toList());
    } catch (e, stackTrace) {
      _logger.e('Error fetching trips', e, stackTrace);
      throw Exception('Failed to fetch trips: $e');
    }
  }

  // Get a single trip by ID
  Future<TripModel> getTripById(String tripId) async {
    try {
      // Validate if the ID is in UUID format
      bool isValidUuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(tripId);

      if (!isValidUuid) {
        _logger.w('Invalid UUID format for trip ID: $tripId');
        // For demo purposes, return a mock trip if ID is not a valid UUID
        if (tripId == 'paris123' || tripId == 'barca456' || tripId == 'tokyo789') {
          return _getMockTrip(tripId);
        }
      }

      // Get the trip data
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            users:user_id (id, username, avatar_url),
            trip_comments (
              id,
              content,
              created_at,
              updated_at,
              user_id,
              users:user_id (id, username, avatar_url)
            ),
            trip_ratings (id, rating, user_id),
            trip_likes (id, user_id)
          ''')
          .eq('id', tripId);

      // Check if we got any results
      if (response.isEmpty) {
        _logger.w('No trip found with ID: $tripId');
        // For demo purposes, return a mock trip
        if (tripId == 'paris123' || tripId == 'barca456' || tripId == 'tokyo789') {
          return _getMockTrip(tripId);
        }
        throw Exception('Trip not found');
      }

      // Use the first result
      final tripData = response.first;

      // Get trip days and activities
      final tripDays = await _supabase
          .from('trip_days')
          .select('''
            *,
            trip_activities (*)
          ''')
          .eq('trip_id', tripId)
          .order('day_number', ascending: true);

      // Get current user ID for checking likes and saves
      final currentUserId = _supabase.auth.currentUser?.id;

      // Check if current user liked this trip
      bool isLikedByCurrentUser = false;
      if (currentUserId != null) {
        final likes = tripData['trip_likes'] as List<dynamic>;
        isLikedByCurrentUser = likes.any((like) => like['user_id'] == currentUserId);
      }

      // Check if current user saved this trip
      bool isSavedByCurrentUser = false;
      if (currentUserId != null) {
        final savedTrips = await _supabase
            .from('saved_trips')
            .select()
            .eq('trip_id', tripId)
            .eq('user_id', currentUserId);

        isSavedByCurrentUser = savedTrips.isNotEmpty;
      }

      // Check if current user rated this trip
      double? userRating;
      if (currentUserId != null) {
        final ratings = tripData['trip_ratings'] as List<dynamic>;
        final userRatingData = ratings.firstWhere(
          (rating) => rating['user_id'] == currentUserId,
          orElse: () => null,
        );

        if (userRatingData != null) {
          userRating = (userRatingData['rating'] as num).toDouble();
        }
      }

      // Create author model
      final userData = tripData['users'] as Map<String, dynamic>;
      final author = UserModel.fromJson({
        ...userData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create trip days models
      final List<TripDayModel> dayModels = tripDays.map((day) {
        final activities = (day['trip_activities'] as List<dynamic>)
            .map((activity) => TripActivityModel.fromJson(activity))
            .toList();

        return TripDayModel.fromJson(day, activities: activities);
      }).toList();

      // Create comment models
      final comments = (tripData['trip_comments'] as List<dynamic>).map((comment) {
        final commentUserData = comment['users'] as Map<String, dynamic>;
        final commentUser = UserModel.fromJson({
          ...commentUserData,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return TripCommentModel.fromJson(comment, user: commentUser);
      }).toList();

      // Create and return the trip model
      return TripModel.fromJson(
        tripData,
        author: author,
        tripDays: dayModels,
        comments: comments,
        isLikedByCurrentUser: isLikedByCurrentUser,
        isSavedByCurrentUser: isSavedByCurrentUser,
        userRating: userRating,
      );
    } catch (e, stackTrace) {
      _logger.e('Error fetching trip $tripId', e, stackTrace);
      throw Exception('Failed to fetch trip: $e');
    }
  }

  // Add a comment to a trip
  Future<TripCommentModel> addComment(String tripId, String userId, String content) async {
    try {
      // Insert the comment
      final response = await _supabase
          .from('trip_comments')
          .insert({
            'trip_id': tripId,
            'user_id': userId,
            'content': content,
          })
          .select('*, users:user_id(*)')
          .single();

      // Get the user data
      final userData = response['users'] as Map<String, dynamic>;
      final user = UserModel.fromJson({
        ...userData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create and return the comment model
      return TripCommentModel.fromJson(response, user: user);
    } catch (e, stackTrace) {
      _logger.e('Error adding comment', e, stackTrace);
      throw Exception('Failed to add comment: $e');
    }
  }

  // Toggle like on a trip
  Future<bool> toggleLike(String tripId, String userId) async {
    try {
      // Check if the user already liked this trip
      final existingLikes = await _supabase
          .from('trip_likes')
          .select()
          .eq('trip_id', tripId)
          .eq('user_id', userId);

      if (existingLikes.isEmpty) {
        // Add like
        await _supabase.from('trip_likes').insert({
          'trip_id': tripId,
          'user_id': userId,
        });
        return true; // Liked
      } else {
        // Remove like
        await _supabase
            .from('trip_likes')
            .delete()
            .eq('trip_id', tripId)
            .eq('user_id', userId);
        return false; // Unliked
      }
    } catch (e, stackTrace) {
      _logger.e('Error toggling like', e, stackTrace);
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Rate a trip
  Future<void> rateTrip(String tripId, String userId, double rating) async {
    try {
      // Check if the user already rated this trip
      final existingRatings = await _supabase
          .from('trip_ratings')
          .select()
          .eq('trip_id', tripId)
          .eq('user_id', userId);

      if (existingRatings.isEmpty) {
        // Add new rating
        await _supabase.from('trip_ratings').insert({
          'trip_id': tripId,
          'user_id': userId,
          'rating': rating,
        });
      } else {
        // Update existing rating
        await _supabase
            .from('trip_ratings')
            .update({'rating': rating})
            .eq('trip_id', tripId)
            .eq('user_id', userId);
      }

      // Update the average rating in the trips table
      await _updateAverageRating(tripId);
    } catch (e, stackTrace) {
      _logger.e('Error rating trip', e, stackTrace);
      throw Exception('Failed to rate trip: $e');
    }
  }

  // Update the average rating for a trip
  Future<void> _updateAverageRating(String tripId) async {
    try {
      // Calculate the average rating from all ratings for this trip
      final response = await _supabase
          .from('trip_ratings')
          .select('rating')
          .eq('trip_id', tripId);

      if (response.isNotEmpty) {
        final List<dynamic> ratings = response;
        final double averageRating = ratings.fold(0.0, (sum, item) => sum + (item['rating'] as num)) / ratings.length;

        // Update the trip with the new average rating
        await _supabase
            .from('trips')
            .update({'avg_rating': averageRating})
            .eq('id', tripId);
      }
    } catch (e, stackTrace) {
      _logger.e('Error updating average rating', e, stackTrace);
      // Don't throw here, just log the error since this is a background operation
    }
  }

  // Create a new trip
  Future<String> createTrip(TripModel trip, List<TripDayModel> days) async {
    try {
      // Start a transaction
      final tripId = await _supabase.rpc('create_trip_with_days', params: {
        'trip_data': trip.toJson(),
        'days_data': days.map((day) => day.toJson()).toList(),
      });

      return tripId;
    } catch (e, stackTrace) {
      _logger.e('Error creating trip', e, stackTrace);
      throw Exception('Failed to create trip: $e');
    }
  }

  // Create a new trip with manual transaction
  Future<String> createTripManual(TripModel trip, List<Map<String, dynamic>> days) async {
    try {
      // Insert the trip
      final tripResponse = await _supabase
          .from('trips')
          .insert(trip.toJson())
          .select('id')
          .single();

      final tripId = tripResponse['id'] as String;

      // Insert the days
      for (int i = 0; i < days.length; i++) {
        final day = days[i];
        final activities = day['activities'] as List<Map<String, dynamic>>;

        // Insert the day
        final dayResponse = await _supabase
            .from('trip_days')
            .insert({
              'trip_id': tripId,
              'day_number': i + 1,
              'title': day['title'],
            })
            .select('id')
            .single();

        final dayId = dayResponse['id'] as String;

        // Insert the activities
        for (final activity in activities) {
          await _supabase
              .from('trip_activities')
              .insert({
                'trip_day_id': dayId,
                'title': activity['title'],
                'description': activity['description'],
                'location': activity['location'],
                'time': activity['time'],
              });
        }
      }

      return tripId;
    } catch (e, stackTrace) {
      _logger.e('Error creating trip', e, stackTrace);
      throw Exception('Failed to create trip: $e');
    }
  }

  // Upload trip image
  Future<String> uploadTripImage(io.File file, String fileExt) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Read file as bytes
      final bytes = await file.readAsBytes();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String path = 'trips/$userId/$timestamp.$fileExt';
      await _supabase.storage.from('trip-content').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      return _supabase.storage.from('trip-content').getPublicUrl(path);
    } catch (e, stackTrace) {
      _logger.e('Error uploading trip image', e, stackTrace);
      throw Exception('Failed to upload trip image: $e');
    }
  }

  // Upload trip image from bytes
  Future<String> uploadTripImageBytes(Uint8List bytes, String fileExt) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String path = 'trips/$userId/$timestamp.$fileExt';
      await _supabase.storage.from('trip-content').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      return _supabase.storage.from('trip-content').getPublicUrl(path);
    } catch (e, stackTrace) {
      _logger.e('Error uploading trip image', e, stackTrace);
      throw Exception('Failed to upload trip image: $e');
    }
  }

  // Update a trip
  Future<void> updateTrip(TripModel trip) async {
    try {
      await _supabase
          .from('trips')
          .update(trip.toJson())
          .eq('id', trip.id);
    } catch (e, stackTrace) {
      _logger.e('Error updating trip', e, stackTrace);
      throw Exception('Failed to update trip: $e');
    }
  }

  // Toggle save trip
  Future<bool> toggleSaveTrip(String tripId, String userId) async {
    try {
      // Check if the user already saved this trip
      final existingSaves = await _supabase
          .from('saved_trips')
          .select()
          .eq('trip_id', tripId)
          .eq('user_id', userId);

      if (existingSaves.isEmpty) {
        // Add save
        await _supabase.from('saved_trips').insert({
          'trip_id': tripId,
          'user_id': userId,
        });
        return true; // Saved
      } else {
        // Remove save
        await _supabase
            .from('saved_trips')
            .delete()
            .eq('trip_id', tripId)
            .eq('user_id', userId);
        return false; // Unsaved
      }
    } catch (e, stackTrace) {
      _logger.e('Error toggling save', e, stackTrace);
      throw Exception('Failed to toggle save: $e');
    }
  }

  // Follow a user
  Future<bool> toggleFollowUser(String followerId, String followingId) async {
    try {
      // Check if already following
      final existingFollows = await _supabase
          .from('user_follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);

      if (existingFollows.isEmpty) {
        // Add follow
        await _supabase.from('user_follows').insert({
          'follower_id': followerId,
          'following_id': followingId,
        });
        return true; // Followed
      } else {
        // Remove follow
        await _supabase
            .from('user_follows')
            .delete()
            .eq('follower_id', followerId)
            .eq('following_id', followingId);
        return false; // Unfollowed
      }
    } catch (e, stackTrace) {
      _logger.e('Error toggling follow', e, stackTrace);
      throw Exception('Failed to toggle follow: $e');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .limit(20);

      return response.map((userData) => UserModel.fromJson(userData)).toList();
    } catch (e, stackTrace) {
      _logger.e('Error searching users', e, stackTrace);
      return [];
    }
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _supabase
          .from('trips')
          .delete()
          .eq('id', tripId);
    } catch (e, stackTrace) {
      _logger.e('Error deleting trip', e, stackTrace);
      throw Exception('Failed to delete trip: $e');
    }
  }

  // Create a mock trip for demo purposes when a trip with a non-UUID ID is requested
  TripModel _getMockTrip(String tripId) {
    // Create a mock author
    final author = UserModel(
      id: '123e4567-e89b-12d3-a456-426614174099',
      username: tripId == 'paris123' ? 'Maria C.' : (tripId == 'barca456' ? 'Carlos M.' : 'Kenji T.'),
      fullName: tripId == 'paris123' ? 'Maria Cortez' : (tripId == 'barca456' ? 'Carlos Martinez' : 'Kenji Tanaka'),
      avatarUrl: 'https://i.pravatar.cc/150?u=${tripId}',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );

    // Create mock trip days
    final List<TripDayModel> tripDays = [];
    final int dayCount = tripId == 'paris123' ? 3 : (tripId == 'barca456' ? 2 : 4);

    for (int i = 1; i <= dayCount; i++) {
      final activities = <TripActivityModel>[
        TripActivityModel(
          id: 'activity-${tripId}-${i}-1',
          tripDayId: 'day-${tripId}-$i',
          title: 'Morning Activity',
          description: 'Explore the local area and enjoy the sights.',
          location: tripId == 'paris123' ? 'Eiffel Tower' : (tripId == 'barca456' ? 'La Rambla' : 'Shibuya Crossing'),
          time: '09:00 AM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TripActivityModel(
          id: 'activity-${tripId}-${i}-2',
          tripDayId: 'day-${tripId}-$i',
          title: 'Lunch',
          description: 'Enjoy local cuisine at a popular restaurant.',
          location: tripId == 'paris123' ? 'Le Bistro' : (tripId == 'barca456' ? 'Mercado de La Boqueria' : 'Tsukiji Market'),
          time: '01:00 PM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TripActivityModel(
          id: 'activity-${tripId}-${i}-3',
          tripDayId: 'day-${tripId}-$i',
          title: 'Evening Activity',
          description: 'Relax and enjoy the evening atmosphere.',
          location: tripId == 'paris123' ? 'Seine River Cruise' : (tripId == 'barca456' ? 'Tapas Tour' : 'Tokyo Tower'),
          time: '07:00 PM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      tripDays.add(TripDayModel(
        id: 'day-${tripId}-$i',
        tripId: tripId,
        dayNumber: i,
        title: 'Day $i',
        activities: activities,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Create and return the mock trip
    return TripModel(
      id: tripId,
      title: tripId == 'paris123' ? 'Weekend in Paris' : (tripId == 'barca456' ? 'Barcelona Food Tour' : 'Tokyo Adventure'),
      description: tripId == 'paris123'
          ? 'Experience the magic of Paris in a weekend getaway. Visit iconic landmarks, enjoy delicious cuisine, and immerse yourself in French culture.'
          : (tripId == 'barca456'
              ? 'Explore Barcelona\'s vibrant food scene with this culinary adventure. From tapas to paella, discover the best of Spanish cuisine.'
              : 'Discover the wonders of Tokyo with this 4-day adventure. Experience Japanese culture, visit historic temples, and enjoy the bustling city life.'),
      location: tripId == 'paris123' ? 'Paris, France' : (tripId == 'barca456' ? 'Barcelona, Spain' : 'Tokyo, Japan'),
      region: tripId == 'paris123' ? 'Europe' : (tripId == 'barca456' ? 'Europe' : 'Asia'),
      days: dayCount,
      priceLevel: tripId == 'paris123' ? 2 : (tripId == 'barca456' ? 1 : 3),
      avgRating: tripId == 'paris123' ? 4.8 : (tripId == 'barca456' ? 4.6 : 4.9),
      coverImageUrl: tripId == 'paris123'
          ? 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073'
          : (tripId == 'barca456'
              ? 'https://images.unsplash.com/photo-1583422409516-2895a77efded?q=80&w=2070'
              : 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=2187'),
      thumbnailUrl: tripId == 'paris123'
          ? 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073'
          : (tripId == 'barca456'
              ? 'https://images.unsplash.com/photo-1583422409516-2895a77efded?q=80&w=2070'
              : 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=2187'),
      isPublic: true,
      userId: author.id,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      author: author,
      tripDays: tripDays,
      comments: [],
      likeCount: tripId == 'paris123' ? 120 : (tripId == 'barca456' ? 85 : 150),
      ratingCount: tripId == 'paris123' ? 45 : (tripId == 'barca456' ? 32 : 60),
      isLikedByCurrentUser: false,
      isSavedByCurrentUser: false,
    );
  }

  // Get trips where the user is a collaborator (not the primary owner)
  Future<List<TripModel>> getCollaborativeTrips(String userId) async {
    try {
      final response = await _supabase
          .from('trip_collaborators')
          .select('''
            role,
            trips (
              *,
              users:user_id (id, username, avatar_url),
              trip_ratings (rating),
              trip_likes (id)
            )
          ''')
          .eq('user_id', userId)
          .neq('role', 'owner'); // Exclude trips where the user's role is 'owner' in collaborators table
                                 // This might need adjustment if 'owner' in collaborators means something different than trips.user_id

      final List<dynamic> collaborativeLinks = response;
      
      List<TripModel> trips = [];
      for (var item in collaborativeLinks) {
        final tripData = item['trips'];
        if (tripData == null) continue;

        // Ensure the current user is not also the primary owner of the trip
        if (tripData['user_id'] == userId) continue;

        final userData = tripData['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(), // Mocked, ideally from DB
          'updated_at': DateTime.now().toIso8601String(), // Mocked
        });

        // Additional checks for isLikedByCurrentUser and isSavedByCurrentUser could be added here if necessary
        // For simplicity, they are defaulted to false for collaborative trips unless explicitly fetched.
        trips.add(TripModel.fromJson(
          tripData,
          author: author,
          isLikedByCurrentUser: false, // Default or fetch if needed
          isSavedByCurrentUser: false, // Default or fetch if needed
        ));
      }
      return trips;
    } catch (e, stackTrace) {
      _logger.e('Error fetching collaborative trips for user $userId', e, stackTrace);
      return [];
    }
  }

  // Get trips forked by the user
  Future<List<TripModel>> getForkedTrips(String userId) async {
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
          .ilike('title', 'Fork of %') // Filter for titles starting with "Fork of "
          .order('created_at', ascending: false);

      final List<dynamic> tripsList = response;
      return tripsList.map((trip) {
        final userData = trip['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(), 
          'updated_at': DateTime.now().toIso8601String(), 
        });
        // For forked trips, isLikedByCurrentUser and isSavedByCurrentUser would typically be false by default
        // or would need separate checks if a user can like/save their own forked trips.
        return TripModel.fromJson(
          trip, 
          author: author,
          isLikedByCurrentUser: false, // Defaulting, adjust if needed
          isSavedByCurrentUser: false, // Defaulting, adjust if needed
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching forked trips for user $userId', e, stackTrace);
      return [];
    }
  }

  // Get recent public trips (can be used for "Featured")
  Future<List<TripModel>> getPublicTrips({int limit = 10, String sortBy = 'created_at'}) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            users:user_id (id, username, avatar_url),
            trip_ratings (rating),
            trip_likes (id)
          ''')
          .eq('is_public', true)
          .order(sortBy, ascending: false)
          .limit(limit);

      final List<dynamic> tripsList = response;
      // Similar processing to getTrips, but without specific user context for likes/saves initially
      return tripsList.map((trip) {
        final userData = trip['users'] as Map<String, dynamic>;
        final author = UserModel.fromJson({
          ...userData,
          'created_at': DateTime.now().toIso8601String(), 
          'updated_at': DateTime.now().toIso8601String(), 
        });
        // For generic public trips, isLiked/isSaved would depend on whether a user is logged in
        // and if we want to make those checks here or on the TripDetailScreen.
        // For now, defaulting them to false.
        return TripModel.fromJson(
          trip, 
          author: author,
          isLikedByCurrentUser: false, 
          isSavedByCurrentUser: false, 
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching public trips', e, stackTrace);
      return [];
    }
  }
}