class TripActivityModel {
  final String id;
  final String tripDayId;
  final String title;
  final String? description;
  final String? location;
  final String? time;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripActivityModel({
    required this.id,
    required this.tripDayId,
    required this.title,
    this.description,
    this.location,
    this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripActivityModel.fromJson(Map<String, dynamic> json) {
    return TripActivityModel(
      id: json['id'],
      tripDayId: json['trip_day_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      time: json['time'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_day_id': tripDayId,
      'title': title,
      'description': description,
      'location': location,
      'time': time,
    };
  }

  TripActivityModel copyWith({
    String? title,
    String? description,
    String? location,
    String? time,
  }) {
    return TripActivityModel(
      id: this.id,
      tripDayId: this.tripDayId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      time: time ?? this.time,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
