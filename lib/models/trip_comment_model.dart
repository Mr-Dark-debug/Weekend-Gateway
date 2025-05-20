import 'package:weekend_gateway/models/user_model.dart';

class TripCommentModel {
  final String id;
  final String tripId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related data
  final UserModel? user;

  TripCommentModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory TripCommentModel.fromJson(Map<String, dynamic> json, {
    UserModel? user,
  }) {
    return TripCommentModel(
      id: json['id'],
      tripId: json['trip_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'user_id': userId,
      'content': content,
    };
  }

  TripCommentModel copyWith({
    String? content,
    UserModel? user,
  }) {
    return TripCommentModel(
      id: this.id,
      tripId: this.tripId,
      userId: this.userId,
      content: content ?? this.content,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      user: user ?? this.user,
    );
  }
}
