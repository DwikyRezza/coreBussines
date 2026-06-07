// ============================================================
// FEATURE: Auth — Remote Data Source (Google Sign-In)
// lib/features/auth/data/datasources/auth_remote_datasource.dart
// ============================================================

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle({bool isRegister = false});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const _activeBusinessIdKey = 'active_business_id';

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;

  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    GoogleSignIn? googleSignIn,
    required SharedPreferences prefs,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: kIsWeb && AppConfig.googleWebClientId.isNotEmpty
                  ? AppConfig.googleWebClientId
                  : null,
              serverClientId: !kIsWeb && AppConfig.googleWebClientId.isNotEmpty
                  ? AppConfig.googleWebClientId
                  : null,
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

      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final credentialResult = await _auth.signInWithCredential(credential);
      final user = credentialResult.user;
      if (user == null) {
        throw const AuthException(message: 'Gagal masuk ke sistem.');
      }

      final profileRef = _firestore.collection('users').doc(user.uid);
      final profileSnapshot = await profileRef.get();
      final isRegistered = profileSnapshot.exists;

      if (!isRegister && !isRegistered) {
        try {
          await user.delete();
        } catch (_) {
          // If deletion is blocked for any reason, signing out still prevents access.
        }
        await _googleSignIn.signOut();
        await _auth.signOut();
        throw const AuthException(
          message:
              'Akun ini belum terdaftar. Silakan daftar dahulu dengan akun Google tersebut.',
        );
      }

      if (isRegister && isRegistered) {
        await _googleSignIn.signOut();
        await _auth.signOut();
        throw const AuthException(
          message:
              'Akun ini sudah pernah dibuat. Silakan masuk melalui menu Login dengan akun yang sama.',
        );
      }

      final userModel = UserModel.fromGoogleUser(
        id: user.uid,
        name: user.displayName ?? googleUser.displayName ?? 'Pengguna',
        email: user.email ?? googleUser.email,
        photoUrl: user.photoURL ?? googleUser.photoUrl,
      );

      await _ensureWorkspace(userModel);
      return userModel;
    } on AuthException {
      rethrow;
    } catch (e, stack) {
      print('DEBUG_AUTH_ERROR: $e');
      print('DEBUG_AUTH_STACK: $stack');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _prefs.remove(_activeBusinessIdKey);
      await _prefs.remove('active_member_role');
      await _prefs.remove('active_member_status');
      await _prefs.remove('active_member_permissions');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(message: 'Sesi tidak ditemukan.');

    // Re-authenticate via Google to get fresh credentials.
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException(message: 'Autentikasi Google dibatalkan.');
    }
    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await user.reauthenticateWithCredential(credential);

    // Delete all Firestore data for this user.
    final uid = user.uid;
    final batch = _firestore.batch();

    // Remove member records from all businesses the user belongs to.
    final memberSnap = await _firestore
        .collectionGroup('members')
        .where('user_id', isEqualTo: uid)
        .get();
    for (final doc in memberSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete the user document.
    batch.delete(_firestore.collection('users').doc(uid));
    await batch.commit();

    // Delete the Firebase Auth account.
    await user.delete();

    // Clear local prefs.
    await _googleSignIn.signOut();
    await _prefs.remove(_activeBusinessIdKey);
    await _prefs.remove('active_member_role');
    await _prefs.remove('active_member_status');
    await _prefs.remove('active_member_permissions');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final profile = await _firestore.collection('users').doc(user.uid).get();

    if (profile.exists && profile.data() != null) {
      final profileData = profile.data()!;
      final activeBusinessId = profileData['active_business_id'] as String?;
      if (activeBusinessId != null && activeBusinessId.isNotEmpty) {
        await _prefs.setString(_activeBusinessIdKey, activeBusinessId);
      }

      final userModel = UserModel.fromJson({
        'id': profile.id,
        ...profileData,
      });
      await _ensureWorkspace(userModel, activeBusinessId: activeBusinessId);
      return userModel;
    }

    return null;
  }

  Future<void> _ensureWorkspace(
    UserModel user, {
    String? activeBusinessId,
  }) async {
    // Only load active business ID if the user has completed onboarding.
    // If onboarding is false, any existing business ID in SharedPreferences is stale.
    final storedBusinessId = user.onboardingCompleted
        ? (activeBusinessId?.isNotEmpty == true
            ? activeBusinessId
            : _prefs.getString(_activeBusinessIdKey))
        : null;
    final shouldCreateLegacyWorkspace = user.onboardingCompleted &&
        (storedBusinessId == null || storedBusinessId.isEmpty);
    final businessId =
        shouldCreateLegacyWorkspace ? 'business_${user.id}' : storedBusinessId;
    final now = FieldValue.serverTimestamp();
    final userRef = _firestore.collection('users').doc(user.id);
    final businessRef = businessId == null
        ? null
        : _firestore.collection('businesses').doc(businessId);

    await _firestore.runTransaction((transaction) async {
      final businessSnapshot =
          businessRef == null ? null : await transaction.get(businessRef);

      transaction.set(
        userRef,
        {
          'full_name': user.fullName,
          'email': user.email,
          'avatar_url': user.avatarUrl,
          'onboarding_completed': user.onboardingCompleted,
          'updated_at': now,
          if (businessId != null) 'active_business_id': businessId,
        },
        SetOptions(merge: true),
      );

      if (!shouldCreateLegacyWorkspace || businessRef == null) return;

      transaction.set(
        businessRef,
        {
          'name': '${user.fullName ?? user.email} Workspace',
          'owner_id': user.id,
          'updated_at': now,
          if (businessSnapshot?.exists != true) 'created_at': now,
        },
        SetOptions(merge: true),
      );
    });

    if (!shouldCreateLegacyWorkspace || businessRef == null) {
      if (businessId != null) {
        await _prefs.setString(_activeBusinessIdKey, businessId);
      }
      return;
    }

    await businessRef.collection('members').doc(user.id).set(
      {
        'user_id': user.id,
        'name': user.fullName ?? user.email,
        'email': user.email,
        'photo_url': user.avatarUrl,
        'role': 'owner',
        'joined_at': now,
        'updated_at': now,
      },
      SetOptions(merge: true),
    );

    await businessRef.collection('wallets').doc('default_cash').set(
      {
        'name': 'Cash',
        'type': 'cash',
        'balance': 0.0,
        'updated_at': now,
      },
      SetOptions(merge: true),
    );

    await _prefs.setString(_activeBusinessIdKey, businessId!);
  }
}
