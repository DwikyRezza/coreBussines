// ============================================================
// FEATURE: Auth — Remote Data Source (Mock / Google Sign-In)
// lib/features/auth/data/datasources/auth_remote_datasource.dart
// ============================================================

import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Login dibatalkan oleh pengguna.');
      }

      return UserModel.fromGoogleUser(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Pengguna',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Gagal masuk dengan Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException(message: 'Gagal keluar: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;

    return UserModel.fromGoogleUser(
      id: account.id,
      name: account.displayName ?? 'Pengguna',
      email: account.email,
      photoUrl: account.photoUrl,
    );
  }
}
