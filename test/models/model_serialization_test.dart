import 'package:flutter_test/flutter_test.dart';
import 'package:weekend_gateway/models/trip_activity_model.dart';
import 'package:weekend_gateway/models/badge_model.dart';
import 'package:weekend_gateway/models/user_badge_model.dart';
import 'package:weekend_gateway/models/trip_message_model.dart';
import 'package:weekend_gateway/models/user_model.dart'; // For TripMessageModel.author

void main() {
  group('Model Serialization/Deserialization Tests', () {
    group('TripActivityModel Tests', () {
      test('TripActivityModel fromJson and toJson', () {
        final now = DateTime.now();
        final jsonData = {
          'id': 'activity1',
          'trip_day_id': 'day1',
          'title': 'Visit Museum',
          'description': 'Explore local history.',
          'location': 'City Museum',
          'time': '10:00',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'latitude': 48.8584,
          'longitude': 2.2945,
          'photo_urls': ['http://example.com/photo1.jpg', 'http://example.com/photo2.jpg'],
        };

        final model = TripActivityModel.fromJson(jsonData);

        expect(model.id, 'activity1');
        expect(model.title, 'Visit Museum');
        expect(model.photoUrls, isA<List<String>>());
        expect(model.photoUrls.length, 2);
        expect(model.photoUrls.first, 'http://example.com/photo1.jpg');
        expect(model.latitude, 48.8584);

        final backToJson = model.toJson();
        // Check a few key fields to ensure toJson is working.
        // Note: toJson for TripActivityModel doesn't include id, createdAt, updatedAt by design.
        expect(backToJson['title'], 'Visit Museum');
        expect(backToJson['photo_urls'], jsonData['photo_urls']);
        expect(backToJson['latitude'], jsonData['latitude']);
      });

      test('TripActivityModel fromJson handles null or malformed photo_urls', () {
        final now = DateTime.now();
        final jsonDataNull = {
          'id': 'activity2', 'trip_day_id': 'day1', 'title': 'Sightseeing',
          'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(), 'photo_urls': null,
        };
        final modelNull = TripActivityModel.fromJson(jsonDataNull);
        expect(modelNull.photoUrls, isEmpty);

        final jsonDataString = {
          'id': 'activity3', 'trip_day_id': 'day1', 'title': 'Walk',
          'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(), 'photo_urls': 'http://single.jpg',
        };
        final modelString = TripActivityModel.fromJson(jsonDataString);
        expect(modelString.photoUrls, isNotEmpty);
        expect(modelString.photoUrls.first, 'http://single.jpg');
        
        final jsonDataInvalidList = {
          'id': 'activity4', 'trip_day_id': 'day1', 'title': 'Hike',
          'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(), 'photo_urls': [1, "http://valid.jpg", true],
        };
        final modelInvalidList = TripActivityModel.fromJson(jsonDataInvalidList);
        expect(modelInvalidList.photoUrls.length, 1); // Only the valid string URL
        expect(modelInvalidList.photoUrls.first, "http://valid.jpg");
      });
    });

    group('BadgeModel Tests', () {
      test('BadgeModel fromJson', () {
         final now = DateTime.now();
         final jsonData = {
          'id': 'badge1',
          'name': 'Super Explorer',
          'description': 'Awarded for exploring 5 countries.',
          'icon_url': 'assets/badges/explorer.png',
          'criteria_type': 'COUNTRIES_VISITED',
          'criteria_value_numeric': 5,
          'criteria_value_text': null,
          'created_at': now.toIso8601String(),
         };
         final model = BadgeModel.fromJson(jsonData);
         expect(model.id, 'badge1');
         expect(model.name, 'Super Explorer');
         expect(model.criteriaType, 'COUNTRIES_VISITED');
         expect(model.criteriaValueNumeric, 5);
         expect(model.createdAt.toIso8601String(), now.toIso8601String());
      });
    });

    group('UserBadgeModel Tests', () {
      test('UserBadgeModel fromJson with nested BadgeModel', () {
        final now = DateTime.now();
        final badgeData = {
          'id': 'badge_alpha', 'name': 'Alpha User', 'description': 'Early user', 
          'icon_url': null, 'criteria_type': 'REGISTRATION_DATE', 'criteria_value_numeric': null,
          'criteria_value_text': '2023-01-01', 'created_at': now.toIso8601String(),
        };
        final userBadgeData = {
          'id': 'userbadge1', 'user_id': 'user123', 'badge_id': 'badge_alpha',
          'earned_at': now.toIso8601String(), 'badges': badgeData, // Supabase nested select
        };
        final model = UserBadgeModel.fromJson(userBadgeData);
        expect(model.id, 'userbadge1');
        expect(model.badgeId, 'badge_alpha');
        expect(model.badge, isNotNull);
        expect(model.badge!.name, 'Alpha User');
      });

      test('UserBadgeModel fromJson with pre-populated BadgeModel', () {
        final now = DateTime.now();
         final badge = BadgeModel(id: 'b1', name: 'Test', description: 'Desc', criteriaType: 'TEST', createdAt: now);
        final userBadgeData = {
          'id': 'userbadge2', 'user_id': 'user456', 'badge_id': 'b1',
          'earned_at': now.toIso8601String(),
        };
        final model = UserBadgeModel.fromJson(userBadgeData, badgeDetails: badge);
        expect(model.badge, isNotNull);
        expect(model.badge!.id, 'b1');
      });
    });
    
    group('TripMessageModel Tests', () {
      test('TripMessageModel fromJson with author', () {
        final now = DateTime.now();
        final authorData = {
          'id': 'author1', 'username': 'chatty_cathy', 'full_name': 'Cathy Chatter', 
          'avatar_url': null, 'bio': null, 'location': null, 
          'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(),
          'earned_badge_ids': [],
        };
        final messageData = {
          'id': 'msg1', 'trip_id': 'trip1', 'user_id': 'author1', 
          'content': 'Hello from the chat!', 'created_at': now.toIso8601String(),
        };
        final authorModel = UserModel.fromJson(authorData);
        final model = TripMessageModel.fromJson(messageData, authorDetails: authorModel);

        expect(model.id, 'msg1');
        expect(model.content, 'Hello from the chat!');
        expect(model.author, isNotNull);
        expect(model.author!.username, 'chatty_cathy');
      });
    });

  });
}
