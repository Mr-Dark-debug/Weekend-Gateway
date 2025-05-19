import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  // Fetch all trips with optional filters
  Future<List<Map<String, dynamic>>> getTrips({
    String? searchQuery,
    int? days,
    String? region,
    double? minRating,
    String? priceRange,
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
            users:user_id (username, avatar_url),
            trip_ratings (rating),
            trip_likes (id)
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
        // This is a simplification - in a real app we'd join with the ratings table
        // and calculate the average, but for simplicity we'll use the stored rating
        query = query.gte('avg_rating', minRating);
      }

      if (priceRange != null && priceRange != 'Any') {
        query = query.eq('price_category', priceRange.toLowerCase());
      }

      // For location-based filtering we'd need to use PostGIS extensions
      // or calculate distances in the app
      if (nearbyOnly && userLat != null && userLng != null) {
        // Using Supabase's PostGIS extension - this requires the extension to be enabled
        // and your coordinates to be stored as geography or geometry types
        query = query.rpc('nearby_trips', params: {
          'user_lat': userLat,
          'user_lng': userLng,
          'distance_km': nearbyRadiusKm
        });
      }

      // Execute the query
      final List<dynamic> response = await query;
      
      // Transform the response
      return response.map((trip) => trip as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching trips', e, stackTrace);
      throw Exception('Failed to fetch trips: $e');
    }
  }

  // Get a single trip by ID
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select('''
            *,
            users:user_id (username, avatar_url),
            trip_comments (
              id, 
              content, 
              created_at, 
              users:user_id (username, avatar_url)
            ),
            trip_ratings (rating),
            trip_likes (id, user_id)
          ''')
          .eq('id', tripId)
          .single();
      
      return response;
    } catch (e, stackTrace) {
      _logger.e('Error fetching trip $tripId', e, stackTrace);
      throw Exception('Failed to fetch trip: $e');
    }
  }

  // Add a comment to a trip
  Future<void> addComment(String tripId, String userId, String content) async {
    try {
      await _supabase.from('trip_comments').insert({
        'trip_id': tripId,
        'user_id': userId,
        'content': content,
      });
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
  Future<String> createTrip(Map<String, dynamic> tripData) async {
    try {
      final response = await _supabase
          .from('trips')
          .insert(tripData)
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e, stackTrace) {
      _logger.e('Error creating trip', e, stackTrace);
      throw Exception('Failed to create trip: $e');
    }
  }

  // Update a trip
  Future<void> updateTrip(String tripId, Map<String, dynamic> tripData) async {
    try {
      await _supabase
          .from('trips')
          .update(tripData)
          .eq('id', tripId);
    } catch (e, stackTrace) {
      _logger.e('Error updating trip', e, stackTrace);
      throw Exception('Failed to update trip: $e');
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
} 