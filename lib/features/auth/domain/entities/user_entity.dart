// ============================================================
// FEATURE: Auth — Domain Entity
// lib/features/auth/domain/entities/user_entity.dart
// ============================================================

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? fullName;
  final String email;
  final String? avatarUrl;
  final bool onboardingCompleted;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    this.fullName,
    required this.email,
    this.avatarUrl,
    this.onboardingCompleted = false,
    required this.updatedAt,
  });

  String get name => fullName?.trim().isNotEmpty == true ? fullName! : email;

  String? get photoUrl => avatarUrl;

  @override
  List<Object?> get props =>
      [id, fullName, email, avatarUrl, onboardingCompleted, updatedAt];
}
