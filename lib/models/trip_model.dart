import 'package:weekend_gateway/models/user_model.dart';
import 'package:weekend_gateway/models/trip_day_model.dart';
import 'package:weekend_gateway/models/trip_comment_model.dart';

class TripModel {
  final String id;
  final String title;
  final String? description;
  final String location;
  final String? region;
  final int days;
  final int priceLevel;
  final double avgRating;
  final String? coverImageUrl;
  final String? thumbnailUrl;
  final bool isPublic;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related data
  final UserModel? author;
  final List<TripDayModel> tripDays;
  final List<TripCommentModel> comments;
  final int likeCount;
  final int ratingCount;
  final bool isLikedByCurrentUser;
  final bool isSavedByCurrentUser;
  final double? userRating;

  TripModel({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    this.region,
    required this.days,
    required this.priceLevel,
    this.avgRating = 0.0,
    this.coverImageUrl,
    this.thumbnailUrl,
    this.isPublic = true,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.tripDays = const [],
    this.comments = const [],
    this.likeCount = 0,
    this.ratingCount = 0,
    this.isLikedByCurrentUser = false,
    this.isSavedByCurrentUser = false,
    this.userRating,
  });

  factory TripModel.fromJson(Map<String, dynamic> json, {
    UserModel? author,
    List<TripDayModel>? tripDays,
    List<TripCommentModel>? comments,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    double? userRating,
  }) {
    return TripModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      region: json['region'],
      days: json['days'],
      priceLevel: json['price_level'],
      avgRating: (json['avg_rating'] ?? 0.0).toDouble(),
      coverImageUrl: json['cover_image_url'],
      thumbnailUrl: json['thumbnail_url'],
      isPublic: json['is_public'] ?? true,
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      author: author,
      tripDays: tripDays ?? [],
      comments: comments ?? [],
      likeCount: json['like_count'] ?? 0,
      ratingCount: json['rating_count'] ?? 0,
      isLikedByCurrentUser: isLikedByCurrentUser ?? false,
      isSavedByCurrentUser: isSavedByCurrentUser ?? false,
      userRating: userRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'region': region,
      'days': days,
      'price_level': priceLevel,
      'cover_image_url': coverImageUrl,
      'thumbnail_url': thumbnailUrl,
      'is_public': isPublic,
      'user_id': userId,
    };
  }

  TripModel copyWith({
    String? title,
    String? description,
    String? location,
    String? region,
    int? days,
    int? priceLevel,
    double? avgRating,
    String? coverImageUrl,
    String? thumbnailUrl,
    bool? isPublic,
    UserModel? author,
    List<TripDayModel>? tripDays,
    List<TripCommentModel>? comments,
    int? likeCount,
    int? ratingCount,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    double? userRating,
  }) {
    return TripModel(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      region: region ?? this.region,
      days: days ?? this.days,
      priceLevel: priceLevel ?? this.priceLevel,
      avgRating: avgRating ?? this.avgRating,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPublic: isPublic ?? this.isPublic,
      userId: this.userId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      author: author ?? this.author,
      tripDays: tripDays ?? this.tripDays,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      ratingCount: ratingCount ?? this.ratingCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      userRating: userRating ?? this.userRating,
    );
  }
}
