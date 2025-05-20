import 'package:weekend_gateway/models/user_model.dart';

class TripMessageModel {
  final String id;
  final String tripId;
  final String userId;
  final String content;
  final DateTime createdAt;
  UserModel? author; // Populated after fetching or during stream processing

  TripMessageModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory TripMessageModel.fromJson(Map<String, dynamic> json, {UserModel? authorDetails}) {
    return TripMessageModel(
      id: json['id'],
      tripId: json['trip_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      author: authorDetails, // Allow pre-populating if author details are joined
    );
  }

  TripMessageModel copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? content,
    DateTime? createdAt,
    UserModel? author,
  }) {
    return TripMessageModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }
}
