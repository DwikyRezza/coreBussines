// ============================================================
// FEATURE: Auth — Repository Interface (Domain Layer)
// lib/features/auth/domain/repositories/auth_repository.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract contract for auth operations.
/// The domain layer depends on this interface, NOT the implementation.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle({bool isRegister = false});
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
