import 'package:weekend_gateway/models/trip_activity_model.dart';

class TripDayModel {
  final String id;
  final String tripId;
  final int dayNumber;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related data
  final List<TripActivityModel> activities;

  TripDayModel({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.activities = const [],
  });

  factory TripDayModel.fromJson(Map<String, dynamic> json, {
    List<TripActivityModel>? activities,
  }) {
    return TripDayModel(
      id: json['id'],
      tripId: json['trip_id'],
      dayNumber: json['day_number'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      activities: activities ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'day_number': dayNumber,
      'title': title,
    };
  }

  TripDayModel copyWith({
    String? title,
    List<TripActivityModel>? activities,
  }) {
    return TripDayModel(
      id: this.id,
      tripId: this.tripId,
      dayNumber: this.dayNumber,
      title: title ?? this.title,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      activities: activities ?? this.activities,
    );
  }
}
