// ============================================================
// FEATURE: Auth — Repository Implementation
// lib/features/auth/data/repositories/auth_repository_impl.dart
// ============================================================

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  // Broadcast so multiple listeners (Router, BLoC) can subscribe.
  final _authController = StreamController<UserEntity?>.broadcast();

  // Synchronous cache — lets the Router redirect without async.
  UserEntity? _cachedUser;

  AuthRepositoryImpl(this._remoteDataSource) {
    // On construction, check if a session is already active
    // (e.g. Google Sign-In silent sign-in restores previous session).
    _rehydrate();
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null && _cachedUser != null) {
        _cachedUser = null;
        _authController.add(null);
      } else if (user != null) {
        await _rehydrate();
      }
    });
  }

  /// Expose cached user for synchronous router redirect checks.
  UserEntity? get cachedUser => _cachedUser;

  /// Re-check auth state on cold start (silent sign-in).
  Future<void> _rehydrate() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      _cachedUser = user;
      _authController.add(user);
    } catch (_) {
      _cachedUser = null;
      _authController.add(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle(
      {bool isRegister = false}) async {
    try {
      final user =
          await _remoteDataSource.signInWithGoogle(isRegister: isRegister);
      _cachedUser = user;
      _authController.add(user); // ← notify router & BLoC
      return Right(user);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      _cachedUser = null;
      _authController.add(null); // ← notify router & BLoC
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      _cachedUser = user;
      _authController.add(user);
      return Right(user);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _authController.stream;

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      _cachedUser = null;
      _authController.add(null); // notify router & BLoC → redirect to login
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  /// Call this when the app is disposed to avoid stream leaks.
  void dispose() => _authController.close();
}
