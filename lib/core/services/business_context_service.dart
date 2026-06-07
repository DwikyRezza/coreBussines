import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../security/permission_policy.dart';
import '../storage/local_storage_service.dart';

class BusinessContext {
  final String businessId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final String role;
  final String memberStatus;
  final List<String> permissions;

  const BusinessContext({
    required this.businessId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    this.memberStatus = 'active',
    this.permissions = const <String>[],
    this.userPhotoUrl,
  });

  bool get isOwner => role == 'owner';
  bool get isStaff => role == 'staff' || role == 'karyawan';
  bool hasPermission(String permission) {
    return PermissionPolicy.hasPermission(permissions, permission);
  }
}

class BusinessContextService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  BusinessContextService({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalStorageService localStorage,
  })  : _auth = auth,
        _firestore = firestore,
        _localStorage = localStorage;

  Future<BusinessContext> getCurrentContext() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User belum login.');
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data() ?? const <String, dynamic>{};
    var businessId = _localStorage.activeBusinessId ??
        userData['active_business_id'] as String?;
    final onboardingCompleted =
        userData['onboarding_completed'] as bool? ?? false;

    if (businessId == null || businessId.isEmpty) {
      if (!onboardingCompleted) {
        throw StateError(
            'Workspace belum disiapkan. Selesaikan onboarding terlebih dahulu.');
      }
      businessId = 'business_${user.uid}';
    }

    if (_localStorage.activeBusinessId != businessId) {
      await _localStorage.setActiveBusinessId(businessId);
    }

    final memberRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('members')
        .doc(user.uid);
    var memberSnapshot = await memberRef.get();

    final name = (userData['full_name'] as String?) ??
        user.displayName ??
        user.email ??
        'Pengguna';
    final email = (userData['email'] as String?) ?? user.email ?? '';
    final photoUrl = (userData['avatar_url'] as String?) ?? user.photoURL;

    String role = 'owner';
    String memberStatus = 'active';
    List<String> permissions = PermissionPolicy.resolvePermissions(
      role: role,
      explicitPermissions: const <String>[],
    );
    if (!memberSnapshot.exists) {
      final businessSnapshot =
          await _firestore.collection('businesses').doc(businessId).get();
      final isBusinessOwner =
          (businessSnapshot.data()?['owner_id'] as String?) == user.uid;

      if (isBusinessOwner) {
        await memberRef.set({
          'user_id': user.uid,
          'name': name,
          'email': email,
          'photo_url': photoUrl,
          'role': 'owner',
          'permissions': permissions,
          'status': 'active',
          'joined_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        memberSnapshot = await memberRef.get();
      } else {
        // Cari undangan berdasarkan email. Undangan belum cukup untuk akses penuh;
        // staff harus menyelesaikan Smart Setup agar member doc berbasis UID dibuat.
        final emailQuery = await _firestore
            .collection('businesses')
            .doc(businessId)
            .collection('members')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (emailQuery.docs.isNotEmpty) {
          final invitedDoc = emailQuery.docs.first;
          final inviteData = invitedDoc.data();
          final status = inviteData['status'] as String? ?? 'active';

          if (status == 'removed' ||
              status == 'suspended' ||
              status == 'inactive') {
            await _auth.signOut();
            throw StateError(
                'Akses Anda ke workspace ini telah dicabut atau ditangguhkan.');
          }

          if (status == 'active' && inviteData['user_id'] == null) {
            throw StateError(
                'Undangan belum diselesaikan. Lanjutkan onboarding staff.');
          }
        }

        if (businessId == 'business_${user.uid}' ||
            businessId.startsWith('personal_')) {
          await memberRef.set({
            'user_id': user.uid,
            'name': name,
            'email': email,
            'photo_url': photoUrl,
            'role': 'owner',
            'permissions': permissions,
            'status': 'active',
            'joined_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          memberSnapshot = await memberRef.get();
        } else {
          await _auth.signOut();
          throw StateError('Anda tidak memiliki akses ke workspace ini.');
        }
      }
    } else {
      // Cek status keaktifan keanggotaan
      final status = memberSnapshot.data()?['status'] as String? ?? 'active';
      if (status == 'removed' ||
          status == 'suspended' ||
          status == 'inactive') {
        await _auth.signOut();
        throw StateError(
            'Akses Anda ke workspace ini telah dicabut atau ditangguhkan.');
      }

      role = memberSnapshot.data()?['role'] as String? ?? 'staff';
      memberStatus = status;
      permissions = PermissionPolicy.resolvePermissions(
        role: role,
        explicitPermissions:
            List<String>.from(memberSnapshot.data()?['permissions'] ?? []),
      );
      await memberRef.set({
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await _localStorage.setActiveMemberAccess(
      role: role,
      status: memberStatus,
      permissions: permissions,
    );

    return BusinessContext(
      businessId: businessId,
      userId: user.uid,
      userName: name,
      userEmail: email,
      userPhotoUrl: photoUrl,
      role: role,
      memberStatus: memberStatus,
      permissions: permissions,
    );
  }

  Stream<BusinessContext> watchCurrentContext() async* {
    final context = await getCurrentContext();
    final memberRef = _firestore
        .collection('businesses')
        .doc(context.businessId)
        .collection('members')
        .doc(context.userId);

    yield context;
    await for (final snapshot in memberRef.snapshots()) {
      final data = snapshot.data();
      if (data != null) {
        final status = data['status'] as String? ?? 'active';
        if (status == 'removed' ||
            status == 'suspended' ||
            status == 'inactive') {
          await _auth.signOut();
          throw StateError(
              'Akses Anda ke workspace ini telah dicabut atau ditangguhkan.');
        }
      }
      final role = snapshot.data()?['role'] as String? ?? context.role;
      final permissions = PermissionPolicy.resolvePermissions(
        role: role,
        explicitPermissions:
            List<String>.from(snapshot.data()?['permissions'] ?? []),
      );
      final memberStatus =
          snapshot.data()?['status'] as String? ?? context.memberStatus;
      await _localStorage.setActiveMemberAccess(
        role: role,
        status: memberStatus,
        permissions: permissions,
      );
      yield BusinessContext(
        businessId: context.businessId,
        userId: context.userId,
        userName: context.userName,
        userEmail: context.userEmail,
        userPhotoUrl: context.userPhotoUrl,
        role: role,
        memberStatus: memberStatus,
        permissions: permissions,
      );
    }
  }
}
