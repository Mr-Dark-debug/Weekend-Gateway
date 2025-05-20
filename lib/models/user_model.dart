import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Stats
  int tripCount;
  int followerCount;
  int followingCount;
  bool isFollowedByCurrentUser;

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.tripCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowedByCurrentUser = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      username: user.userMetadata?['username'] ?? user.email?.split('@').first ?? 'User',
      fullName: user.userMetadata?['full_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt.toString()) : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location': location,
    };
  }

  UserModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? location,
    int? tripCount,
    int? followerCount,
    int? followingCount,
    bool? isFollowedByCurrentUser,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tripCount: tripCount ?? this.tripCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowedByCurrentUser: isFollowedByCurrentUser ?? this.isFollowedByCurrentUser,
    );
  }
}
