// ============================================================
// FEATURE: Auth — Data Model
// lib/features/auth/data/models/user_model.dart
// ============================================================

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.fullName,
    required super.email,
    super.avatarUrl,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? json['name'] as String?,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
      updatedAt: DateTime.parse(
        (json['updated_at'] ?? json['created_at']) as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt.toIso8601String(),
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
      fullName: name,
      email: email,
      avatarUrl: photoUrl,
      updatedAt: DateTime.now(),
    );
  }
}
