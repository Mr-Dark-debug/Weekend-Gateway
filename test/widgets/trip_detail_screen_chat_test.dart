import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weekend_gateway/models/trip_message_model.dart';
import 'package:weekend_gateway/models/trip_model.dart';
import 'package:weekend_gateway/models/user_model.dart';
import 'package:weekend_gateway/presentation/screens/trip/trip_detail_screen.dart';
import 'package:weekend_gateway/services/chat_service.dart';
import 'package:weekend_gateway/services/trip_service.dart';
import 'package:weekend_gateway/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weekend_gateway/config/app_routes.dart'; // For navigation checks
// import 'package:weekend_gateway/main.dart'; // Assuming MyApp is here for navigator
import 'package:weekend_gateway/presentation/common/neo_button.dart';
import 'package:weekend_gateway/presentation/common/neo_text_field.dart';


// Mocks
class MockTripService extends Mock implements TripService {}
class MockUserService extends Mock implements UserService {}
class MockChatService extends Mock implements ChatService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Mock Supabase and AuthState to simulate a logged-in user
class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  final GoTrueClient auth = MockGoTrueClient();
}
class MockGoTrueClient extends Mock implements GoTrueClient {
  @override
  User? get currentUser => MockUser(); // Simulate a logged-in user
  
  @override
  Stream<AuthState> get authState => Stream.value(AuthState(
    Session(accessToken: 'token', tokenType: 'bearer', user: MockUser()), 
    AuthChangeEvent.signedIn
  ));
}
class MockUser extends Mock implements User {
  @override
  String get id => 'current_user_test_id'; 
}


// Helper to create a valid JSON representation for a UserModel
Map<String, dynamic> mockUserJson(String id, String username) => {
  'id': id, 'username': username, 'full_name': '$username Full',
  'avatar_url': 'http://example.com/avatar/$username.png',
  'bio': 'Bio for $username', 'location': 'Location of $username',
  'created_at': DateTime.now().toIso8601String(),
  'updated_at': DateTime.now().toIso8601String(),
  'earned_badge_ids': [], 'tripCount': 0, 'followerCount': 0,
  'followingCount': 0, 'isFollowedByCurrentUser': false,
};

// A helper to create a valid JSON representation for a TripModel
Map<String, dynamic> mockTripJson(String id, String title, String ownerUserId) => {
  'id': id, 'user_id': ownerUserId, 'title': title,
  'description': 'Desc for $title', 'location': 'Location for $title', 'region': 'Region',
  'days': 2, 'price_level': 1, 'avg_rating': 0.0, 'is_public': true,
  'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String(),
  'cover_image_url': 'http://example.com/cover.png', 'thumbnail_url': 'http://example.com/thumb.png',
  'users': mockUserJson(ownerUserId, 'owner_username'), // Mocked author data for TripModel.fromJson
  'trip_ratings': [], 'trip_likes': [], 'trip_comments': [], 'trip_days': [],
};


void main() {
  late MockTripService mockTripService;
  late MockUserService mockUserService;
  late MockChatService mockChatService;
  late MockNavigatorObserver mockNavigatorObserver;
  
  final testTripId = 'trip-chat-test-id';
  final currentUserId = 'current_user_test_id'; // Must match MockUser().id

  // Mock TripModel data
  final mockTripData = TripModel.fromJson(mockTripJson(testTripId, 'Chat Test Trip', currentUserId)); // Current user is owner
  final mockCollaboratorTripData = TripModel.fromJson(mockTripJson(testTripId, 'Collaborator Chat Trip', 'other_user_id'));


  setUp(() {
    mockTripService = MockTripService();
    mockUserService = MockUserService();
    mockChatService = MockChatService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Default stubs for services
    when(mockTripService.getTripById(any)).thenAnswer((_) async => mockTripData); // Default to owner
    when(mockTripService.getTripCollaborators(any)).thenAnswer((_) async => []);
    when(mockTripService.getUserRoleForTrip(any, any)).thenAnswer((_) async => null); // Default to no specific role
    when(mockChatService.getTripMessagesStream(any)).thenAnswer((_) => Stream.value([])); // Empty stream initially
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
      navigatorObservers: [mockNavigatorObserver],
       routes: { // Define routes used for navigation assertions
        AppRoutes.profile: (context) => Scaffold(body: Text('Mock Profile Screen: ${ModalRoute.of(context)?.settings.arguments}')),
      },
    );
  }

  group('TripDetailScreen Chat UI Tests', () {
    testWidgets('Chat section is visible for trip owner', (WidgetTester tester) async {
      // Arrange: Current user is the owner of _trip
      when(mockTripService.getTripById(testTripId)).thenAnswer((_) async => mockTripData); // Owner is currentUserId

      await tester.pumpWidget(createTestableWidget(TripDetailScreen(tripId: testTripId)));
      await tester.pumpAndSettle(); // Wait for async calls like _loadTripData

      expect(find.text('GROUP CHAT'), findsOneWidget);
      expect(find.byType(NeoTextField), findsNWidgets(2)); // 1 for comments, 1 for chat
      expect(find.widgetWithIcon(NeoButton, Icons.send), findsNWidgets(2));
    });

    testWidgets('Chat section is visible for collaborator with editor role', (WidgetTester tester) async {
      // Arrange: Current user is an editor
      when(mockTripService.getTripById(testTripId)).thenAnswer((_) async => mockCollaboratorTripData); // Not owned by current user
      when(mockTripService.getUserRoleForTrip(testTripId, currentUserId)).thenAnswer((_) async => 'editor');
      
      await tester.pumpWidget(createTestableWidget(TripDetailScreen(tripId: testTripId)));
      await tester.pumpAndSettle();

      expect(find.text('GROUP CHAT'), findsOneWidget);
    });

    testWidgets('Chat section is NOT visible for collaborator with viewer role', (WidgetTester tester) async {
      // Arrange: Current user is a viewer
      when(mockTripService.getTripById(testTripId)).thenAnswer((_) async => mockCollaboratorTripData);
      when(mockTripService.getUserRoleForTrip(testTripId, currentUserId)).thenAnswer((_) async => 'viewer');
      
      await tester.pumpWidget(createTestableWidget(TripDetailScreen(tripId: testTripId)));
      await tester.pumpAndSettle();

      expect(find.text('GROUP CHAT'), findsNothing);
    });

    testWidgets('Displays messages from ChatService stream', (WidgetTester tester) async {
      final messages = [
        TripMessageModel(id: 'm1', tripId: testTripId, userId: 'user1', content: 'Hello', createdAt: DateTime.now(), author: UserModel.fromJson(mockUserJson('user1', 'Alice'))),
        TripMessageModel(id: 'm2', tripId: testTripId, userId: currentUserId, content: 'Hi Alice!', createdAt: DateTime.now().add(Duration(seconds:1)), author: UserModel.fromJson(mockUserJson(currentUserId, 'CurrentUser'))),
      ];
      when(mockChatService.getTripMessagesStream(testTripId)).thenAnswer((_) => Stream.value(messages));
      when(mockTripService.getTripById(testTripId)).thenAnswer((_) async => mockTripData); // Owner

      await tester.pumpWidget(createTestableWidget(TripDetailScreen(tripId: testTripId)));
      await tester.pumpAndSettle(); // For _loadTripData & stream to emit

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Hi Alice!'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget); // Author username
      // Check for current user's message styling (e.g., alignment or color if distinct)
      // This requires more specific finders based on how NeoCard is styled for current user.
    });

    testWidgets('Typing in input and pressing send calls chatService.sendMessage', (WidgetTester tester) async {
      when(mockTripService.getTripById(testTripId)).thenAnswer((_) async => mockTripData); // Owner
      when(mockChatService.sendMessage(any, any, any)).thenAnswer((_) async {}); // Mock send message

      await tester.pumpWidget(createTestableWidget(TripDetailScreen(tripId: testTripId)));
      await tester.pumpAndSettle();

      // Find the chat input field (assuming it's the second NeoTextField)
      final chatInputField = find.byType(NeoTextField).at(1); // 0 is comments, 1 is chat
      await tester.enterText(chatInputField, 'Test chat message');
      await tester.pump(); 

      // Find the chat send button (assuming it's the second NeoButton with send icon)
      final sendButtons = find.widgetWithIcon(NeoButton, Icons.send);
      expect(sendButtons, findsNWidgets(2)); // 1 for comments, 1 for chat
      
      await tester.tap(sendButtons.at(1)); // Tap the chat send button
      await tester.pumpAndSettle();

      verify(mockChatService.sendMessage(testTripId, currentUserId, 'Test chat message')).called(1);
      // Check if the text field was cleared
      expect(find.widgetWithText(NeoTextField, 'Test chat message'), findsNothing);
    });
  });
}
