import 'dart:async';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weekend_gateway/models/trip_message_model.dart';
import 'package:weekend_gateway/models/user_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  Future<void> sendMessage(String tripId, String userId, String content) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('Message content cannot be empty.');
    }
    try {
      await _supabase.from('trip_messages').insert({
        'trip_id': tripId,
        'user_id': userId,
        'content': content.trim(),
      });
      _logger.i('Message sent to trip $tripId by user $userId');
    } catch (e, stackTrace) {
      _logger.e('Error sending message to trip $tripId by user $userId', e, stackTrace);
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<UserModel>> getMessageAuthors(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, avatar_url, created_at, updated_at') // Ensure all fields for UserModel.fromJson are selected
          .in_('id', userIds.toSet().toList()); // Use toSet().toList() to ensure unique IDs

      return response.map((userData) => UserModel.fromJson(userData)).toList();
    } catch (e, stackTrace) {
      _logger.e('Error fetching message authors for user IDs: $userIds', e, stackTrace);
      throw Exception('Failed to fetch message authors: $e');
    }
  }

  Stream<List<TripMessageModel>> getTripMessagesStream(String tripId) {
    final StreamController<List<TripMessageModel>> controller = StreamController.broadcast();
    Map<String, UserModel> userCache = {}; // Cache for author details
    List<TripMessageModel> currentMessages = []; // Local list to manage messages

    // Fetch initial historical messages and set up real-time subscription
    Future<void> fetchAndListen() async {
      try {
        final historicalData = await _supabase
            .from('trip_messages')
            .select()
            .eq('trip_id', tripId)
            .order('created_at', ascending: true);
        
        currentMessages.clear(); // Clear before adding historical messages

        if (historicalData.isNotEmpty) {
            final List<String> userIds = historicalData
                .map((msg) => msg['user_id'] as String)
                .toSet() 
                .toList();
            
            if (userIds.isNotEmpty) {
                final authors = await getMessageAuthors(userIds);
                for (var author in authors) {
                    userCache[author.id] = author;
                }
            }
            currentMessages.addAll(historicalData.map((msgData) {
                return TripMessageModel.fromJson(msgData, authorDetails: userCache[msgData['user_id']]);
            }));
        }
        controller.add(List.from(currentMessages)); // Emit initial list
      } catch (e, stackTrace) {
        _logger.e('Error fetching initial messages for trip $tripId', e, stackTrace);
        controller.addError(e);
      }
    }

    fetchAndListen(); // Fetch initial messages

    final subscription = _supabase
        .channel('public:trip_messages:trip_id=eq.$tripId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'trip_messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'trip_id', value: tripId),
          callback: (payload) async {
            _logger.i('Realtime: New message received for trip $tripId: ${payload.newRecord}');
            final newMessageData = payload.newRecord;
            if (newMessageData != null) {
              final String userId = newMessageData['user_id'] as String;
              if (!userCache.containsKey(userId)) {
                final authors = await getMessageAuthors([userId]);
                if (authors.isNotEmpty) {
                  userCache[userId] = authors.first;
                }
              }
              final newMessage = TripMessageModel.fromJson(newMessageData, authorDetails: userCache[userId]);
              currentMessages.add(newMessage); // Add to local list
              controller.add(List.from(currentMessages)); // Emit updated list
            }
          },
        )
        .subscribe(
          (String status, {Object? error}) {
            if (status == 'SUBSCRIBED') {
              _logger.i('Successfully subscribed to trip_messages channel for trip $tripId.');
              // Potentially trigger a re-fetch if messages might have been missed between initial load and subscription
              // fetchAndListen(); // Or a more targeted fetch for recent messages
            } else if (status == 'CHANNEL_ERROR' || status == 'TIMED_OUT' || status == 'CLOSED') {
              _logger.e('Subscription error for trip $tripId: $status, Error: $error');
              controller.addError('Subscription error: $status. Error: $error');
            }
          }
        );

    controller.onCancel = () {
      _logger.i('Stream for trip $tripId cancelled. Unsubscribing.');
      _supabase.removeChannel(subscription);
    };

    return controller.stream;
  }
}
