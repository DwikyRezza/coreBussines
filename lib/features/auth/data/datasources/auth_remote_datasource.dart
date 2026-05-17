// ============================================================
// FEATURE: Auth — Remote Data Source (Mock / Google Sign-In)
// lib/features/auth/data/datasources/auth_remote_datasource.dart
// ============================================================

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle({bool isRegister = false});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const _activeBusinessIdKey = 'active_business_id';

  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;

  AuthRemoteDataSourceImpl({
    SupabaseClient? supabase,
    GoogleSignIn? googleSignIn,
    required SharedPreferences prefs,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: AppConfig.googleAndroidClientId,
              serverClientId: AppConfig.googleWebClientId,
              scopes: ['email', 'profile'],
            ),
        _prefs = prefs;

  @override
  Future<UserModel> signInWithGoogle({bool isRegister = false}) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Login dibatalkan oleh pengguna.');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw const AuthException(message: 'Gagal mendapatkan token Google.');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(message: 'Gagal masuk ke sistem.');
      }

      final userModel = UserModel.fromGoogleUser(
        id: user.id,
        name: googleUser.displayName ?? 'Pengguna',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      await _ensureWorkspace(userModel);
      return userModel;
    } on AuthException {
      rethrow;
    } catch (e, stack) {
      print('DEBUG_AUTH_ERROR: $e');
      print('DEBUG_AUTH_STACK: $stack');
      throw AuthException(message: 'Detail Error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      await _prefs.remove(_activeBusinessIdKey);
    } catch (e) {
      throw AuthException(message: 'Gagal keluar: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile != null) {
      final userModel = UserModel.fromJson(profile);
      await _ensureWorkspace(userModel);
      return userModel;
    }

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final userModel = UserModel(
      id: user.id,
      fullName:
          metadata['full_name'] as String? ?? metadata['name'] as String?,
      email: user.email ?? metadata['email'] as String? ?? '',
      avatarUrl:
          metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
      updatedAt: DateTime.now(),
    );

    await _ensureWorkspace(userModel);
    return userModel;
  }

  Future<void> _ensureWorkspace(UserModel user) async {
    final businessId = await _supabase.rpc<String>(
      'ensure_current_user_workspace',
      params: {
        'p_full_name': user.fullName,
        'p_email': user.email,
        'p_avatar_url': user.avatarUrl,
      },
    );

    if (businessId.isNotEmpty) {
      await _prefs.setString(_activeBusinessIdKey, businessId);
    }
  }
}
