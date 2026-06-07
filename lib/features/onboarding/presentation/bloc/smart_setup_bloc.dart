// ============================================================
// FEATURE: Onboarding — Smart Setup BLoC (FUNCTIONAL & ADAPTIVE)
// lib/features/onboarding/presentation/bloc/smart_setup_bloc.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/security/permission_policy.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../settings/domain/repositories/app_lock_repository.dart';
import '../../../transactions/domain/entities/transaction_entities.dart';
import '../../domain/entities/smart_setup_policy.dart';

// ─── STATE ──────────────────────────────────────────────────
class SmartSetupState extends Equatable {
  final int currentStep;
  final String usageType; // 'owner_solo', 'owner_team', 'staff', 'personal', ''
  final bool
      isOwnerTeamSubStepChoice; // whether asking for owner vs member in team flow
  final String teamUserPosition; // 'owner', 'staff', ''

  // Owner Business Data
  final String businessName;
  final String
      businessField; // 'f_and_b', 'retail', 'jasa', 'online_shop', 'other'
  final String
      businessSize; // 'solo', 'micro', 'small', 'medium', 'growing', 'enterprise'
  final String businessDescription;
  final String businessAddress;
  final String businessWhatsApp;
  final String businessEmail;

  // Branching Questions Answers
  final bool fnbHasMenu;
  final bool fnbNeedsRawInventory;
  final List<String> fnbPayments;
  final bool fnbHasCashier;
  final bool fnbNeedsDailyReport;

  final bool retailHasPhysicalProducts;
  final bool retailNeedsInventory;
  final bool retailHasBarcode;

  final bool serviceNeedsBooking;
  final bool serviceNeedsInvoice;

  final String olsPlatform;
  final bool olsNeedsAdminFee;
  final bool olsNeedsShippingCost;

  // Recommendations & Wallet
  final List<String> enabledFeatures;
  final String walletName;
  final String walletType; // 'cash', 'bank', 'ewallet'
  final double walletBalance;
  final List<String> selectedCategories;

  // Staff Flow & Validation Details
  final String staffInviteOwnerEmail;
  final String staffNickname;
  final String staffPhone;
  final String staffInviteCode;
  final String ownerInviteStaffEmail;

  // Validated Invite Data Cached
  final String validatedBusinessId;
  final String validatedBusinessName;
  final String validatedRole;
  final String validatedDivision;
  final List<String> validatedPermissions;
  final String validatedInviteId;

  // Security
  final String securityPin;

  // Operations state
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const SmartSetupState({
    this.currentStep = 1,
    this.usageType = '',
    this.isOwnerTeamSubStepChoice = false,
    this.teamUserPosition = '',
    this.businessName = '',
    this.businessField = 'f_and_b',
    this.businessSize = 'solo',
    this.businessDescription = '',
    this.businessAddress = '',
    this.businessWhatsApp = '',
    this.businessEmail = '',
    this.fnbHasMenu = false,
    this.fnbNeedsRawInventory = false,
    this.fnbPayments = const ['Cash'],
    this.fnbHasCashier = false,
    this.fnbNeedsDailyReport = false,
    this.retailHasPhysicalProducts = false,
    this.retailNeedsInventory = false,
    this.retailHasBarcode = false,
    this.serviceNeedsBooking = false,
    this.serviceNeedsInvoice = false,
    this.olsPlatform = 'Shopee',
    this.olsNeedsAdminFee = false,
    this.olsNeedsShippingCost = false,
    this.enabledFeatures = const [],
    this.walletName = 'Cash Utama',
    this.walletType = 'cash',
    this.walletBalance = 0.0,
    this.selectedCategories = const [],
    this.staffInviteOwnerEmail = '',
    this.staffNickname = '',
    this.staffPhone = '',
    this.staffInviteCode = '',
    this.ownerInviteStaffEmail = '',
    this.validatedBusinessId = '',
    this.validatedBusinessName = '',
    this.validatedRole = '',
    this.validatedDivision = '',
    this.validatedPermissions = const [],
    this.validatedInviteId = '',
    this.securityPin = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  SmartSetupState copyWith({
    int? currentStep,
    String? usageType,
    bool? isOwnerTeamSubStepChoice,
    String? teamUserPosition,
    String? businessName,
    String? businessField,
    String? businessSize,
    String? businessDescription,
    String? businessAddress,
    String? businessWhatsApp,
    String? businessEmail,
    bool? fnbHasMenu,
    bool? fnbNeedsRawInventory,
    List<String>? fnbPayments,
    bool? fnbHasCashier,
    bool? fnbNeedsDailyReport,
    bool? retailHasPhysicalProducts,
    bool? retailNeedsInventory,
    bool? retailHasBarcode,
    bool? serviceNeedsBooking,
    bool? serviceNeedsInvoice,
    String? olsPlatform,
    bool? olsNeedsAdminFee,
    bool? olsNeedsShippingCost,
    List<String>? enabledFeatures,
    String? walletName,
    String? walletType,
    double? walletBalance,
    List<String>? selectedCategories,
    String? staffInviteOwnerEmail,
    String? staffNickname,
    String? staffPhone,
    String? staffInviteCode,
    String? ownerInviteStaffEmail,
    String? validatedBusinessId,
    String? validatedBusinessName,
    String? validatedRole,
    String? validatedDivision,
    List<String>? validatedPermissions,
    String? validatedInviteId,
    String? securityPin,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SmartSetupState(
      currentStep: currentStep ?? this.currentStep,
      usageType: usageType ?? this.usageType,
      isOwnerTeamSubStepChoice:
          isOwnerTeamSubStepChoice ?? this.isOwnerTeamSubStepChoice,
      teamUserPosition: teamUserPosition ?? this.teamUserPosition,
      businessName: businessName ?? this.businessName,
      businessField: businessField ?? this.businessField,
      businessSize: businessSize ?? this.businessSize,
      businessDescription: businessDescription ?? this.businessDescription,
      businessAddress: businessAddress ?? this.businessAddress,
      businessWhatsApp: businessWhatsApp ?? this.businessWhatsApp,
      businessEmail: businessEmail ?? this.businessEmail,
      fnbHasMenu: fnbHasMenu ?? this.fnbHasMenu,
      fnbNeedsRawInventory: fnbNeedsRawInventory ?? this.fnbNeedsRawInventory,
      fnbPayments: fnbPayments ?? this.fnbPayments,
      fnbHasCashier: fnbHasCashier ?? this.fnbHasCashier,
      fnbNeedsDailyReport: fnbNeedsDailyReport ?? this.fnbNeedsDailyReport,
      retailHasPhysicalProducts:
          retailHasPhysicalProducts ?? this.retailHasPhysicalProducts,
      retailNeedsInventory: retailNeedsInventory ?? this.retailNeedsInventory,
      retailHasBarcode: retailHasBarcode ?? this.retailHasBarcode,
      serviceNeedsBooking: serviceNeedsBooking ?? this.serviceNeedsBooking,
      serviceNeedsInvoice: serviceNeedsInvoice ?? this.serviceNeedsInvoice,
      olsPlatform: olsPlatform ?? this.olsPlatform,
      olsNeedsAdminFee: olsNeedsAdminFee ?? this.olsNeedsAdminFee,
      olsNeedsShippingCost: olsNeedsShippingCost ?? this.olsNeedsShippingCost,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      walletName: walletName ?? this.walletName,
      walletType: walletType ?? this.walletType,
      walletBalance: walletBalance ?? this.walletBalance,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      staffInviteOwnerEmail:
          staffInviteOwnerEmail ?? this.staffInviteOwnerEmail,
      staffNickname: staffNickname ?? this.staffNickname,
      staffPhone: staffPhone ?? this.staffPhone,
      staffInviteCode: staffInviteCode ?? this.staffInviteCode,
      ownerInviteStaffEmail:
          ownerInviteStaffEmail ?? this.ownerInviteStaffEmail,
      validatedBusinessId: validatedBusinessId ?? this.validatedBusinessId,
      validatedBusinessName:
          validatedBusinessName ?? this.validatedBusinessName,
      validatedRole: validatedRole ?? this.validatedRole,
      validatedDivision: validatedDivision ?? this.validatedDivision,
      validatedPermissions: validatedPermissions ?? this.validatedPermissions,
      validatedInviteId: validatedInviteId ?? this.validatedInviteId,
      securityPin: securityPin ?? this.securityPin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        usageType,
        isOwnerTeamSubStepChoice,
        teamUserPosition,
        businessName,
        businessField,
        businessSize,
        businessDescription,
        businessAddress,
        businessWhatsApp,
        businessEmail,
        fnbHasMenu,
        fnbNeedsRawInventory,
        fnbPayments,
        fnbHasCashier,
        fnbNeedsDailyReport,
        retailHasPhysicalProducts,
        retailNeedsInventory,
        retailHasBarcode,
        serviceNeedsBooking,
        serviceNeedsInvoice,
        olsPlatform,
        olsNeedsAdminFee,
        olsNeedsShippingCost,
        enabledFeatures,
        walletName,
        walletType,
        walletBalance,
        selectedCategories,
        staffInviteOwnerEmail,
        staffNickname,
        staffPhone,
        staffInviteCode,
        ownerInviteStaffEmail,
        validatedBusinessId,
        validatedBusinessName,
        validatedRole,
        validatedDivision,
        validatedPermissions,
        validatedInviteId,
        securityPin,
        isSubmitting,
        errorMessage,
        isSuccess,
      ];
}

// ─── EVENTS ──────────────────────────────────────────────────
abstract class SmartSetupEvent extends Equatable {
  const SmartSetupEvent();
  @override
  List<Object?> get props => [];
}

class SetupUpdateField extends SmartSetupEvent {
  final SmartSetupState Function(SmartSetupState current) updater;
  const SetupUpdateField(this.updater);
  @override
  List<Object?> get props => [updater];
}

class SetupNextStepRequested extends SmartSetupEvent {
  const SetupNextStepRequested();
}

class SetupPreviousStepRequested extends SmartSetupEvent {
  const SetupPreviousStepRequested();
}

class SetupSubmitRequested extends SmartSetupEvent {
  const SetupSubmitRequested();
}

// ─── BLOC ────────────────────────────────────────────────────
class SmartSetupBloc extends Bloc<SmartSetupEvent, SmartSetupState> {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final SharedPreferences _prefs;
  final AppLockRepository _appLockRepository;
  final AuthBloc _authBloc;

  SmartSetupBloc({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth auth,
    required SharedPreferences prefs,
    required AppLockRepository appLockRepository,
    required AuthBloc authBloc,
  })  : _firestore = firestore,
        _auth = auth,
        _prefs = prefs,
        _appLockRepository = appLockRepository,
        _authBloc = authBloc,
        super(const SmartSetupState()) {
    on<SetupUpdateField>(_onUpdateField);
    on<SetupNextStepRequested>(_onNextStep);
    on<SetupPreviousStepRequested>(_onPreviousStep);
    on<SetupSubmitRequested>(_onSubmit);
  }

  void _onUpdateField(SetupUpdateField event, Emitter<SmartSetupState> emit) {
    emit(event.updater(state));
  }

  Future<void> _onNextStep(
      SetupNextStepRequested event, Emitter<SmartSetupState> emit) async {
    if (state.currentStep == 1) {
      if (state.usageType == 'owner_solo') {
        emit(state.copyWith(
            currentStep: 4,
            isOwnerTeamSubStepChoice: false)); // Go direct to Owner step 4
      } else if (state.usageType == 'owner_team') {
        emit(state.copyWith(
            isOwnerTeamSubStepChoice:
                true)); // stay in step 1 but show owner/member subchoice
      } else if (state.usageType == 'staff') {
        emit(state.copyWith(
            currentStep: 2,
            isOwnerTeamSubStepChoice: false)); // Go direct to Staff step 2
      } else if (state.usageType == 'personal') {
        emit(state.copyWith(
            currentStep: 2,
            isOwnerTeamSubStepChoice: false)); // Go direct to Personal step 2
      }
      return;
    }

    // Stepping for Owner Business
    if (state.usageType.startsWith('owner_')) {
      if (state.currentStep == 4) {
        emit(state.copyWith(currentStep: 5));
      } else if (state.currentStep == 5) {
        emit(state.copyWith(currentStep: 6));
      } else if (state.currentStep == 6) {
        emit(state.copyWith(currentStep: 7)); // specific fields questions
      } else if (state.currentStep == 7) {
        emit(state.copyWith(currentStep: 8)); // scale questions
      } else if (state.currentStep == 8) {
        // Auto-recommend features based on size and field
        final recs = _recommendFeatures();
        emit(state.copyWith(currentStep: 9, enabledFeatures: recs));
      } else if (state.currentStep == 9) {
        emit(state.copyWith(currentStep: 10)); // wallets
      } else if (state.currentStep == 10) {
        emit(state.copyWith(currentStep: 11)); // categories selection
      } else if (state.currentStep == 11) {
        // Skip employee step if solo business
        if (state.businessSize == 'solo') {
          emit(state.copyWith(
              currentStep: 13)); // skip employee list to security PIN
        } else {
          emit(state.copyWith(currentStep: 12)); // employees add
        }
      } else if (state.currentStep == 12) {
        emit(state.copyWith(currentStep: 13)); // security setup
      } else if (state.currentStep == 13) {
        emit(state.copyWith(currentStep: 14)); // review setup
      } else if (state.currentStep == 14) {
        emit(state.copyWith(currentStep: 15)); // final save screen
      }
      return;
    }

    // Stepping for Staff (Validation & Setup)
    if (state.usageType == 'staff') {
      if (state.currentStep == 2) {
        // ── STAFF STEP 2: VALIDASI UNDANGAN DARI FIRESTORE ────────────────────
        emit(state.copyWith(isSubmitting: true, errorMessage: null));

        final user = _auth.currentUser;
        if (user == null) {
          emit(state.copyWith(
              isSubmitting: false,
              errorMessage: 'Sesi habis. Silakan masuk kembali.'));
          return;
        }

        final staffEmail = user.email?.trim().toLowerCase() ?? '';

        try {
          final inviteSnap = await _firestore
              .collectionGroup('invites')
              .where('email', isEqualTo: staffEmail)
              .get();

          if (inviteSnap.docs.isNotEmpty) {
            final targetInvite = inviteSnap.docs.first;
            final inviteData = targetInvite.data();
            final expiresAtValue = inviteData['expires_at'];
            final expiresAt =
                expiresAtValue is Timestamp ? expiresAtValue.toDate() : null;
            final validation = SmartSetupPolicy.validateInvite(
              inviteEmail: inviteData['email'] as String? ?? '',
              currentUserEmail: staffEmail,
              status: inviteData['status'] as String? ?? 'active',
              expiresAt: expiresAt,
              now: DateTime.now(),
            );

            if (validation != InviteValidationResult.valid) {
              emit(state.copyWith(
                isSubmitting: false,
                errorMessage: _inviteErrorMessage(validation, staffEmail),
              ));
              return;
            }

            final businessRef = targetInvite.reference.parent.parent;
            if (businessRef == null) {
              emit(state.copyWith(
                  isSubmitting: false,
                  errorMessage: 'Data bisnis tidak valid.'));
              return;
            }

            final businessDoc = await businessRef.get();
            if (!businessDoc.exists) {
              emit(state.copyWith(
                  isSubmitting: false,
                  errorMessage: 'Data bisnis tidak ditemukan.'));
              return;
            }

            final businessName =
                businessDoc.data()?['name'] as String? ?? 'Bisnis Tanpa Nama';

            emit(state.copyWith(
              isSubmitting: false,
              validatedBusinessId: businessRef.id,
              validatedBusinessName: businessName,
              validatedRole: inviteData['role'] as String? ?? 'cashier',
              validatedDivision: inviteData['division'] as String? ?? 'Umum',
              validatedPermissions: List<String>.from(
                inviteData['permission_keys'] ??
                    inviteData['permissions'] ??
                    [],
              ),
              validatedInviteId: targetInvite.id,
              currentStep: 3,
            ));
            return;
          }

          // Cari dokumen members dengan email karyawan di semua subkoleksi businesses
          final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
              .collectionGroup('members')
              .where('email', isEqualTo: staffEmail)
              .get();

          if (snap.docs.isEmpty) {
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage:
                  'Email Anda ($staffEmail) belum terdaftar dalam undangan bisnis mana pun. Silakan hubungi Owner bisnis Anda.',
            ));
            return;
          }

          // Cari dokumen undangan yang tepat (filter di sisi client agar aman)
          QueryDocumentSnapshot<Map<String, dynamic>>? targetDoc;

          for (final doc in snap.docs) {
            final data = doc.data();
            final status = data['status'] as String? ?? 'active';

            // Ambil undangan aktif untuk email akun yang sedang login.
            if (status != 'removed') {
              targetDoc = doc;
              break;
            }
          }

          if (targetDoc == null) {
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage:
                  'Undangan untuk email Anda sudah dihapus atau tidak aktif.',
            ));
            return;
          }

          final inviteData = targetDoc.data();
          final status = inviteData['status'] as String? ?? 'active';

          DateTime? expiresAt;
          final createdAt = inviteData['created_at'] as Timestamp?;
          if (createdAt != null) {
            final date = createdAt.toDate();
            expiresAt = date.add(const Duration(days: 7));
          }

          final validation = SmartSetupPolicy.validateInvite(
            inviteEmail: inviteData['email'] as String? ?? '',
            currentUserEmail: staffEmail,
            status: status,
            expiresAt: expiresAt,
            now: DateTime.now(),
          );
          if (validation != InviteValidationResult.valid) {
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage: _inviteErrorMessage(validation, staffEmail),
            ));
            return;
          }

          // Cek apakah undangan sudah terpakai oleh user lain
          final existingUserId = inviteData['user_id'] as String?;
          if (existingUserId != null && existingUserId != user.uid) {
            emit(state.copyWith(
                isSubmitting: false,
                errorMessage: 'Undangan ini sudah digunakan oleh akun lain.'));
            return;
          }

          // Dapatkan data bisnis induk
          final businessRef = targetDoc.reference.parent.parent;
          if (businessRef == null) {
            emit(state.copyWith(
                isSubmitting: false, errorMessage: 'Data bisnis tidak valid.'));
            return;
          }

          final businessDoc = await businessRef.get();
          if (!businessDoc.exists) {
            emit(state.copyWith(
                isSubmitting: false,
                errorMessage: 'Data bisnis tidak ditemukan.'));
            return;
          }

          final businessName =
              businessDoc.data()?['name'] as String? ?? 'Bisnis Tanpa Nama';

          // Simpan data undangan yang terverifikasi ke state
          emit(state.copyWith(
            isSubmitting: false,
            validatedBusinessId: businessRef.id,
            validatedBusinessName: businessName,
            validatedRole: inviteData['role'] ?? 'cashier',
            validatedDivision: inviteData['division'] ?? 'Umum',
            validatedPermissions: List<String>.from(
              inviteData['permission_keys'] ?? inviteData['permissions'] ?? [],
            ),
            currentStep: 3, // Pindah ke Step 3 (Lengkapi Profil Karyawan)
          ));
        } catch (e) {
          emit(state.copyWith(
              isSubmitting: false,
              errorMessage: 'Gagal memvalidasi undangan: ${e.toString()}'));
        }
      } else if (state.currentStep == 3) {
        emit(state.copyWith(currentStep: 13)); // Pindah ke Setup PIN
      } else if (state.currentStep == 13) {
        emit(state.copyWith(currentStep: 14)); // Pindah ke Ringkasan
      } else if (state.currentStep == 14) {
        emit(state.copyWith(currentStep: 15)); // Pindah ke Final
      }
      return;
    }

    // Stepping for Personal Finance
    if (state.usageType == 'personal') {
      if (state.currentStep == 2) {
        emit(state.copyWith(currentStep: 3)); // initial wallet setup
      } else if (state.currentStep == 3) {
        emit(state.copyWith(currentStep: 13)); // PIN setup
      } else if (state.currentStep == 13) {
        emit(state.copyWith(currentStep: 14)); // Review
      } else if (state.currentStep == 14) {
        emit(state.copyWith(currentStep: 15)); // final save
      }
      return;
    }
  }

  void _onPreviousStep(
      SetupPreviousStepRequested event, Emitter<SmartSetupState> emit) {
    if (state.currentStep == 15) {
      emit(state.copyWith(currentStep: 14));
      return;
    }
    if (state.currentStep == 14) {
      emit(state.copyWith(currentStep: 13));
      return;
    }
    if (state.currentStep == 13) {
      if (state.usageType.startsWith('owner_')) {
        if (state.businessSize == 'solo') {
          emit(state.copyWith(
              currentStep: 11)); // go back to step 11 skipping employee step 12
        } else {
          emit(state.copyWith(currentStep: 12));
        }
      } else if (state.usageType == 'staff') {
        emit(state.copyWith(currentStep: 3));
      } else if (state.usageType == 'personal') {
        emit(state.copyWith(currentStep: 3));
      }
      return;
    }
    if (state.currentStep == 12) {
      emit(state.copyWith(currentStep: 11));
      return;
    }
    if (state.currentStep == 11) {
      emit(state.copyWith(currentStep: 10));
      return;
    }
    if (state.currentStep == 10) {
      emit(state.copyWith(currentStep: 9));
      return;
    }
    if (state.currentStep == 9) {
      emit(state.copyWith(currentStep: 8));
      return;
    }
    if (state.currentStep == 8) {
      emit(state.copyWith(currentStep: 7));
      return;
    }
    if (state.currentStep == 7) {
      emit(state.copyWith(currentStep: 6));
      return;
    }
    if (state.currentStep == 6) {
      emit(state.copyWith(currentStep: 5));
      return;
    }
    if (state.currentStep == 5) {
      emit(state.copyWith(currentStep: 4));
      return;
    }
    if (state.currentStep == 4) {
      emit(state.copyWith(currentStep: 1, isOwnerTeamSubStepChoice: false));
      return;
    }
    if (state.currentStep == 3) {
      emit(state.copyWith(currentStep: 2));
      return;
    }
    if (state.currentStep == 2) {
      emit(state.copyWith(currentStep: 1, isOwnerTeamSubStepChoice: false));
      return;
    }
  }

  Future<void> _onSubmit(
      SetupSubmitRequested event, Emitter<SmartSetupState> emit) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));

    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(
          isSubmitting: false,
          errorMessage:
              'Pengguna belum terautentikasi. Silakan masuk kembali.'));
      return;
    }

    final userEmail = user.email ?? '';
    final now = FieldValue.serverTimestamp();
    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      if (state.usageType.startsWith('owner_') ||
          state.usageType == 'personal') {
        // ── OWNER / PERSONAL SETUP FLOW ───────────────────────────
        final isPersonal = state.usageType == 'personal';
        final newBusinessId = isPersonal
            ? 'personal_${user.uid}'
            : _firestore.collection('businesses').doc().id;
        final businessRef =
            _firestore.collection('businesses').doc(newBusinessId);

        // Fetch current user name
        final userDoc = await userRef.get();
        final userName = userDoc.data()?['full_name'] as String? ??
            user.displayName ??
            user.email ??
            'Pemilik Bisnis';
        final userPhoto =
            userDoc.data()?['avatar_url'] as String? ?? user.photoURL;
        final enabledFeatures = isPersonal
            ? [
                'dashboard',
                'transactions',
                'wallets',
                'analytics',
                'schedule',
              ]
            : state.enabledFeatures;
        final setupScore = SmartSetupPolicy.calculateSetupScore(
          SmartSetupChecklist(
            hasBusinessProfile: isPersonal || state.businessName.isNotEmpty,
            hasOwnerRole: true,
            hasInitialWallet: state.walletName.isNotEmpty,
            hasInitialCategories: true,
            hasSelectedFeatures: enabledFeatures.isNotEmpty,
            hasLogo: false,
            hasEmployees: isPersonal ||
                state.businessSize == 'solo' ||
                state.ownerInviteStaffEmail.isNotEmpty,
            hasSecurityPin: state.securityPin.isNotEmpty,
          ),
        );
        final ownerPermissions = PermissionPolicy.resolvePermissions(
          role: 'owner',
          explicitPermissions: const <String>[],
        );
        final cashierPermissions = PermissionPolicy.resolvePermissions(
          role: 'cashier',
          explicitPermissions: const <String>[],
        );

        await _firestore.runTransaction((transaction) async {
          // 1. Write business configuration
          transaction.set(businessRef, {
            'name':
                isPersonal ? 'Keuangan Pribadi $userName' : state.businessName,
            'owner_id': user.uid,
            'business_type': isPersonal ? 'personal' : state.businessField,
            'field': isPersonal ? 'personal' : state.businessField,
            'business_size': isPersonal ? 'solo' : state.businessSize,
            'businessSize': isPersonal ? 'solo' : state.businessSize,
            'currency': 'IDR',
            'timezone': 'Asia/Jakarta',
            'details': {
              'description': state.businessDescription,
              'address': state.businessAddress,
              'whatsapp': state.businessWhatsApp,
              'email': state.businessEmail,
            },
            'enabled_features': enabledFeatures,
            'enabledModules': enabledFeatures,
            'menu_config': {
              'by_size': SmartSetupPolicy.menuForBusinessSize(
                isPersonal ? 'solo' : state.businessSize,
              ),
              'owner': SmartSetupPolicy.menuForRole('owner'),
            },
            'setup_score': setupScore.percent,
            'setupScore': setupScore.percent,
            'setup_checklist': {
              'completed_items': setupScore.completedItems,
              'total_items': setupScore.totalItems,
              'ctas': setupScore.ctas,
            },
            'created_at': now,
            'updated_at': now,
          });

          // 2. Set user as Owner in members list
          final memberRef = businessRef.collection('members').doc(user.uid);
          transaction.set(memberRef, {
            'user_id': user.uid,
            'name': userName,
            'email': userEmail,
            'photo_url': userPhoto,
            'role': 'owner',
            'permissions': ownerPermissions,
            'joined_at': now,
            'updated_at': now,
            'status': 'active',
          });

          // 3. Write initial wallet
          final walletRef = businessRef.collection('wallets').doc();
          transaction.set(walletRef, {
            'name': state.walletName,
            'type': state.walletType,
            'balance': state.walletBalance,
            'updated_at': now,
          });

          // 4. Update user profile to setup finished
          transaction.set(
              userRef,
              {
                'onboarding_completed': true,
                'active_business_id': newBusinessId,
                'updated_at': now,
              },
              SetOptions(merge: true));
        });

        // 5. Seed default categories if selected
        final categoriesCollection = businessRef.collection('categories');
        final batch = _firestore.batch();

        // Seed default categories
        final defaults = [
          const TransactionCategory(
              id: 'food', name: 'Makanan', iconKey: 'food', isIncome: false),
          const TransactionCategory(
              id: 'transport',
              name: 'Transportasi',
              iconKey: 'transport',
              isIncome: false),
          const TransactionCategory(
              id: 'shopping',
              name: 'Belanja',
              iconKey: 'shopping',
              isIncome: false),
          const TransactionCategory(
              id: 'entertainment',
              name: 'Hiburan',
              iconKey: 'entertainment',
              isIncome: false),
          const TransactionCategory(
              id: 'bill', name: 'Tagihan', iconKey: 'bill', isIncome: false),
          const TransactionCategory(
              id: 'health',
              name: 'Kesehatan',
              iconKey: 'health',
              isIncome: false),
          const TransactionCategory(
              id: 'education',
              name: 'Pendidikan',
              iconKey: 'education',
              isIncome: false),
          const TransactionCategory(
              id: 'other', name: 'Lainnya', iconKey: 'other', isIncome: false),
          const TransactionCategory(
              id: 'salary', name: 'Gaji', iconKey: 'income', isIncome: true),
          const TransactionCategory(
              id: 'freelance',
              name: 'Freelance',
              iconKey: 'freelance',
              isIncome: true),
          const TransactionCategory(
              id: 'investment',
              name: 'Investasi',
              iconKey: 'investment',
              isIncome: true),
          const TransactionCategory(
              id: 'bonus', name: 'Bonus', iconKey: 'bonus', isIncome: true),
          const TransactionCategory(
              id: 'other_income',
              name: 'Lainnya',
              iconKey: 'other',
              isIncome: true),
        ];

        for (final cat in defaults) {
          batch.set(categoriesCollection.doc(), cat.toFirestore());
        }

        if (state.ownerInviteStaffEmail.isNotEmpty && !isPersonal) {
          final staffEmail = state.ownerInviteStaffEmail.trim().toLowerCase();
          final staffInviteDocRef = businessRef.collection('invites').doc();
          batch.set(staffInviteDocRef, {
            'name': 'Staf Baru',
            'email': staffEmail,
            'role': 'cashier',
            'division': 'Umum',
            'permissions': ['add_transaction'],
            'permission_keys': cashierPermissions,
            'status': 'active',
            'invite_code': staffInviteDocRef.id,
            'expires_at': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 7)),
            ),
            'created_by_user_id': user.uid,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
            'user_id': null,
          });

          batch.set(businessRef.collection('members').doc(staffEmail), {
            'name': 'Staf Baru',
            'email': staffEmail,
            'role': 'cashier',
            'division': 'Umum',
            'permissions': ['add_transaction'],
            'permission_keys': cashierPermissions,
            'status': 'active',
            'joined_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
            'user_id': null,
          });
        }
        await batch.commit();

        // 6. Save locally in SharedPrefs
        await _prefs.setString('active_business_id', newBusinessId);
        await _prefs.setString('active_member_role', 'owner');
        await _prefs.setString('active_member_status', 'active');
        await _prefs.setStringList('active_member_permissions', ownerPermissions);
      } else if (state.usageType == 'staff') {
        // ── STAFF JOIN FLOW SUBMISSION ────────────────────────────────────
        final businessId = state.validatedBusinessId;
        if (businessId.isEmpty) {
          emit(state.copyWith(
              isSubmitting: false,
              errorMessage:
                  'Data undangan bisnis tidak valid atau belum terverifikasi.'));
          return;
        }

        final userDoc = await userRef.get();
        final userPhoto =
            userDoc.data()?['avatar_url'] as String? ?? user.photoURL;

        final inviteRef = state.validatedInviteId.isEmpty
            ? _firestore
                .collection('businesses')
                .doc(businessId)
                .collection('members')
                .doc(userEmail.toLowerCase())
            : _firestore
                .collection('businesses')
                .doc(businessId)
                .collection('invites')
                .doc(state.validatedInviteId);
        final memberRef = _firestore
            .collection('businesses')
            .doc(businessId)
            .collection('members')
            .doc(user.uid);

        String resolvedRole = state.validatedRole;
        List<String> resolvedPermissions = state.validatedPermissions;

        await _firestore.runTransaction((transaction) async {
          final inviteSnapshot = await transaction.get(inviteRef);
          if (!inviteSnapshot.exists) {
            throw StateError('Undangan tidak ditemukan.');
          }
          final inviteData = inviteSnapshot.data() ?? const <String, dynamic>{};
          final inviteStatus = inviteData['status'] as String? ?? 'active';
          if (inviteStatus != 'active') {
            throw StateError('Undangan tidak aktif.');
          }
          final invitedUserId = inviteData['user_id'] as String?;
          if (invitedUserId != null && invitedUserId != user.uid) {
            throw StateError('Undangan ini sudah digunakan oleh akun lain.');
          }

          resolvedRole = inviteData['role'] as String? ?? state.validatedRole;
          resolvedPermissions = List<String>.from(
            inviteData['permission_keys'] ??
                inviteData['permissions'] ??
                state.validatedPermissions,
          );

          transaction.update(inviteRef, {
            'user_id': user.uid,
            'status': 'used',
            'used_at': now,
            'updated_at': now,
          });

          transaction.set(memberRef, {
            'user_id': user.uid,
            'name': state.staffNickname,
            'email': userEmail.toLowerCase(),
            if (state.validatedInviteId.isNotEmpty)
              'invite_id': state.validatedInviteId,
            'phone': state.staffPhone.isEmpty ? null : state.staffPhone,
            'photo_url': userPhoto,
            'role': resolvedRole,
            'division': inviteData['division'] ?? state.validatedDivision,
            'permissions': resolvedPermissions,
            'status': 'active',
            'joined_at': now,
            'updated_at': now,
          });

          // Tandai onboarding selesai untuk user
          transaction.set(
              userRef,
              {
                'onboarding_completed': true,
                'active_business_id': businessId,
                'updated_at': now,
              },
              SetOptions(merge: true));
        });

        // Save locally in SharedPrefs
        await _prefs.setString('active_business_id', businessId);
        await _prefs.setString('active_member_role', resolvedRole);
        await _prefs.setString('active_member_status', 'active');
        final resolvedPermKeys = PermissionPolicy.resolvePermissions(
          role: resolvedRole,
          explicitPermissions: resolvedPermissions,
        );
        await _prefs.setStringList('active_member_permissions', resolvedPermKeys);
      }

      // If user sets up PIN, save PIN locally using injected AppLockRepository
      if (state.securityPin.isNotEmpty) {
        await _appLockRepository.setPin(state.securityPin);
      }

      // Success
      emit(state.copyWith(isSubmitting: false, isSuccess: true));

      // Notify authentication BLoC to reload and refresh redirect guard
      _authBloc.add(const AuthCheckCurrentUserRequested());
    } catch (e) {
      emit(state.copyWith(
          isSubmitting: false, errorMessage: 'Terjadi kesalahan sistem: $e'));
    }
  }

  List<String> _recommendFeatures() {
    return SmartSetupPolicy.recommendFeatures(
      businessField: state.businessField,
      businessSize: state.businessSize,
      fnbNeedsRawInventory: state.fnbNeedsRawInventory,
      fnbHasMenu: state.fnbHasMenu,
      fnbHasCashier: state.fnbHasCashier,
      fnbNeedsDailyReport: state.fnbNeedsDailyReport,
      retailNeedsInventory: state.retailNeedsInventory,
      retailHasPhysicalProducts: state.retailHasPhysicalProducts,
      retailHasBarcode: state.retailHasBarcode,
      serviceNeedsBooking: state.serviceNeedsBooking,
      serviceNeedsInvoice: state.serviceNeedsInvoice,
      olsNeedsAdminFee: state.olsNeedsAdminFee,
      olsNeedsShippingCost: state.olsNeedsShippingCost,
    );
  }

  String _inviteErrorMessage(
    InviteValidationResult result,
    String currentUserEmail,
  ) {
    switch (result) {
      case InviteValidationResult.emailMismatch:
        return 'Email undangan tidak cocok dengan akun Anda ($currentUserEmail).';
      case InviteValidationResult.expired:
        return 'Masa berlaku undangan Anda telah kedaluwarsa.';
      case InviteValidationResult.alreadyUsed:
        return 'Undangan ini sudah digunakan.';
      case InviteValidationResult.removed:
        return 'Undangan untuk email Anda sudah dihapus.';
      case InviteValidationResult.suspended:
        return 'Akses undangan Anda ditangguhkan.';
      case InviteValidationResult.inactive:
        return 'Akses undangan Anda tidak aktif.';
      case InviteValidationResult.valid:
        return '';
    }
  }
}
