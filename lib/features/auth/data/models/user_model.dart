// ============================================================
// FEATURE: Auth — Data Model
// lib/features/auth/data/models/user_model.dart
// ============================================================

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert from Google Sign-In data
  factory UserModel.fromGoogleUser({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );
  }
}
