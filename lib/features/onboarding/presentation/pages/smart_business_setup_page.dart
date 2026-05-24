// ============================================================
// FEATURE: Onboarding — Smart Business Setup Page (FUNCTIONAL & PREMIUM)
// lib/features/onboarding/presentation/pages/smart_business_setup_page.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../settings/domain/repositories/app_lock_repository.dart';
import '../bloc/smart_setup_bloc.dart';

class SmartBusinessSetupPage extends StatelessWidget {
  const SmartBusinessSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmartSetupBloc(
        firestore: sl<FirebaseFirestore>(),
        auth: sl<firebase_auth.FirebaseAuth>(),
        prefs: sl<SharedPreferences>(),
        appLockRepository: sl<AppLockRepository>(),
        authBloc: sl<AuthBloc>(),
      ),
      child: const _SmartSetupView(),
    );
  }
}

class _SmartSetupView extends StatefulWidget {
  const _SmartSetupView();

  @override
  State<_SmartSetupView> createState() => _SmartSetupViewState();
}

class _SmartSetupViewState extends State<_SmartSetupView> {
  // Business fields map for labels & icons
  final Map<String, _FieldData> _fields = {
    'f_and_b': _FieldData(
        'F&B / Kuliner', Icons.restaurant_rounded, 'Makanan, Cafe, Kue, dll.'),
    'retail': _FieldData('Retail / Toko', Icons.storefront_rounded,
        'Kios, Minimarket, Grosir, dll.'),
    'online_shop': _FieldData('Online Shop', Icons.shopping_bag_rounded,
        'E-Commerce, Dropship, dll.'),
    'jasa': _FieldData('Jasa / Layanan', Icons.design_services_rounded,
        'Konsultan, Cuci Mobil, dll.'),
    'fashion': _FieldData('Fashion & Gaya', Icons.checkroom_rounded,
        'Butik, Pakaian, Aksesoris, dll.'),
    'kecantikan': _FieldData('Kecantikan / Salon', Icons.face_rounded,
        'Salon, Barbershop, Spa, dll.'),
    'bengkel': _FieldData('Bengkel / Otomotif', Icons.build_rounded,
        'Bengkel Motor, Mobil, Sparepart'),
    'pendidikan': _FieldData('Pendidikan / Kursus', Icons.school_rounded,
        'Les Privat, Bimbel, Pelatihan'),
    'kesehatan': _FieldData('Kesehatan / Klinik', Icons.local_hospital_rounded,
        'Klinik, Apotek, Praktek Dokter'),
    'pertanian': _FieldData('Pertanian', Icons.agriculture_rounded,
        'Tani, Pupuk, Bibit, Hasil Bumi'),
    'digital_product': _FieldData('Digital Product', Icons.devices_rounded,
        'Pulsa, Software, Agency, PPOB'),
    'other':
        _FieldData('Lainnya', Icons.more_horiz_rounded, 'Bidang usaha lainnya'),
  };

  // Business sizes map
  final Map<String, _SizeData> _sizes = {
    'solo':
        _SizeData('Solo Business', '1 orang (Tanpa tim)', Icons.person_rounded),
    'micro': _SizeData('Micro Business', '2-5 orang', Icons.group_rounded),
    'small': _SizeData('Small Business', '6-20 orang', Icons.groups_rounded),
    'medium':
        _SizeData('Medium Business', '21-100 orang', Icons.domain_rounded),
    'growing': _SizeData(
        'Growing Business', '101-300 orang', Icons.domain_add_rounded),
    'enterprise': _SizeData(
        'Enterprise', '300+ orang / Banyak cabang', Icons.business_rounded),
  };

  // Wallet Types map
  final Map<String, _WalletTypeData> _walletTypes = {
    'cash': _WalletTypeData('Cash / Tunai', Icons.payments_rounded),
    'bank': _WalletTypeData('Rekening Bank', Icons.account_balance_rounded),
    'ewallet': _WalletTypeData(
        'E-Wallet / Qris', Icons.account_balance_wallet_rounded),
  };

  final _businessNameController = TextEditingController();
  final _businessDescController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessWhatsAppController = TextEditingController();
  final _businessEmailController = TextEditingController();

  final _walletNameController = TextEditingController(text: 'Cash Utama');
  final _walletBalanceController = TextEditingController(text: '0');

  final _staffInviteEmailController = TextEditingController();
  final _staffNicknameController = TextEditingController();
  final _staffPhoneController = TextEditingController();

  final _securityPinController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessDescController.dispose();
    _businessAddressController.dispose();
    _businessWhatsAppController.dispose();
    _businessEmailController.dispose();
    _walletNameController.dispose();
    _walletBalanceController.dispose();
    _staffInviteEmailController.dispose();
    _staffNicknameController.dispose();
    _staffPhoneController.dispose();
    _securityPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<SmartSetupBloc, SmartSetupState>(
      listener: (context, state) {
        if (state.isSuccess) {
          context.go('/');
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: state.currentStep > 1
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context
                        .read<SmartSetupBloc>()
                        .add(const SetupPreviousStepRequested()),
                  )
                : null,
            title: const Text('Smart Business Setup',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ResponsiveHelper.constrainWidth(
            context: context,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Stepper Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.currentStep / 15.0,
                          minHeight: 6,
                          backgroundColor: colors.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        child: _buildCurrentStep(state),
                      ),
                    ),

                    // Bottom Navigation Bar
                    if (state.currentStep < 15)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _validateAndNext,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              state.currentStep == 14
                                  ? 'Konfirmasi & Selesai'
                                  : 'Lanjutkan',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Loading Overlay
                if (state.isSubmitting)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Menyiapkan Workspace Anda...',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Mohon tunggu beberapa saat.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _validateAndNext() {
    final bloc = context.read<SmartSetupBloc>();
    final state = bloc.state;

    if (state.currentStep == 1) {
      if (state.usageType.isEmpty) {
        _showNotice('Silakan pilih tipe penggunaan terlebih dahulu.');
        return;
      }
      if (state.isOwnerTeamSubStepChoice && state.teamUserPosition.isEmpty) {
        _showNotice('Silakan pilih posisi Anda di dalam tim.');
        return;
      }
      bloc.add(const SetupNextStepRequested());
      return;
    }

    if (state.usageType.startsWith('owner_')) {
      // Validations for Owner Setup Steps
      if (state.currentStep == 4) {
        final name = _businessNameController.text.trim();
        if (name.isEmpty) {
          _showNotice('Nama bisnis tidak boleh kosong.');
          return;
        }
        bloc.add(SetupUpdateField((current) => current.copyWith(
              businessName: name,
              businessDescription: _businessDescController.text.trim(),
              businessAddress: _businessAddressController.text.trim(),
              businessWhatsApp: _businessWhatsAppController.text.trim(),
              businessEmail: _businessEmailController.text.trim(),
            )));
        bloc.add(const SetupNextStepRequested());
        return;
      }

      if (state.currentStep == 10) {
        final name = _walletNameController.text.trim();
        final balanceText =
            _walletBalanceController.text.replaceAll('.', '').trim();
        final balance = double.tryParse(balanceText) ?? 0.0;
        if (name.isEmpty) {
          _showNotice('Nama dompet tidak boleh kosong.');
          return;
        }
        bloc.add(SetupUpdateField((current) => current.copyWith(
              walletName: name,
              walletBalance: balance,
            )));
        bloc.add(const SetupNextStepRequested());
        return;
      }

      if (state.currentStep == 13) {
        final pin = _securityPinController.text.trim();
        if (pin.length < 4) {
          _showNotice('PIN keamanan wajib 4 digit.');
          return;
        }
        bloc.add(
            SetupUpdateField((current) => current.copyWith(securityPin: pin)));
        bloc.add(const SetupNextStepRequested());
        return;
      }
    }

    // Validations for Staff Setup
    if (state.usageType == 'staff') {
      if (state.currentStep == 2) {
        final email = _staffInviteEmailController.text.trim();
        // Cek opsional email owner untuk mempersempit pencarian
        bloc.add(SetupUpdateField(
            (current) => current.copyWith(staffInviteOwnerEmail: email)));
        bloc.add(const SetupNextStepRequested());
        return;
      }
      if (state.currentStep == 3) {
        final nickname = _staffNicknameController.text.trim();
        final phone = _staffPhoneController.text.trim();
        if (nickname.isEmpty) {
          _showNotice('Nama Lengkap wajib diisi.');
          return;
        }
        bloc.add(SetupUpdateField((current) => current.copyWith(
              staffNickname: nickname,
              staffPhone: phone,
            )));
        bloc.add(const SetupNextStepRequested());
        return;
      }
      if (state.currentStep == 13) {
        final pin = _securityPinController.text.trim();
        if (pin.length < 4) {
          _showNotice('PIN wajib 4 digit.');
          return;
        }
        bloc.add(
            SetupUpdateField((current) => current.copyWith(securityPin: pin)));
        bloc.add(const SetupNextStepRequested());
        return;
      }
    }

    // Validations for Personal Finance
    if (state.usageType == 'personal') {
      if (state.currentStep == 3) {
        final name = _walletNameController.text.trim();
        final balanceText =
            _walletBalanceController.text.replaceAll('.', '').trim();
        final balance = double.tryParse(balanceText) ?? 0.0;
        if (name.isEmpty) {
          _showNotice('Nama dompet tidak boleh kosong.');
          return;
        }
        bloc.add(SetupUpdateField((current) => current.copyWith(
              walletName: name,
              walletBalance: balance,
            )));
        bloc.add(const SetupNextStepRequested());
        return;
      }
      if (state.currentStep == 13) {
        final pin = _securityPinController.text.trim();
        if (pin.length < 4) {
          _showNotice('PIN wajib 4 digit.');
          return;
        }
        bloc.add(
            SetupUpdateField((current) => current.copyWith(securityPin: pin)));
        bloc.add(const SetupNextStepRequested());
        return;
      }
    }

    bloc.add(const SetupNextStepRequested());
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildCurrentStep(SmartSetupState state) {
    final colors = Theme.of(context).colorScheme;

    // STEP 1: CHOOSE USAGE TYPE (Initial branching question)
    if (state.currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          LucideAnimatedIcon(
            icon: sparkles,
            size: 44,
            color: colors.primary,
            trigger: AnimationTrigger.loop,
            duration: const Duration(milliseconds: 2200),
          ),
          const SizedBox(height: 16),
          Text(
            'Selamat Datang!',
            style: AppTypography.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Kamu ingin menggunakan CoreBusiness untuk apa?',
            style: AppTypography.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildUsageTypeCard(
            context: context,
            type: 'owner_solo',
            title: 'Mengelola bisnis sendiri',
            subtitle: 'Sebagai Owner tunggal tanpa tim.',
            icon: Icons.person_rounded,
            isSelected: state.usageType == 'owner_solo',
          ),
          const SizedBox(height: 16),
          _buildUsageTypeCard(
            context: context,
            type: 'owner_team',
            title: 'Mengelola bisnis bersama tim',
            subtitle: 'Mengatur operasional bisnis bersama karyawan.',
            icon: Icons.group_rounded,
            isSelected:
                state.usageType == 'owner_team' || state.usageType == 'staff',
          ),

          // Sub-step inside Owner Team Choice
          if (state.isOwnerTeamSubStepChoice) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Apa posisi Anda di dalam tim?',
              style: AppTypography.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Pemilik (Owner)')),
                    selected: state.teamUserPosition == 'owner',
                    onSelected: (selected) {
                      if (selected) {
                        context
                            .read<SmartSetupBloc>()
                            .add(SetupUpdateField((c) => c.copyWith(
                                  teamUserPosition: 'owner',
                                  usageType: 'owner_team',
                                )));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Karyawan (Staff)')),
                    selected: state.teamUserPosition == 'staff',
                    onSelected: (selected) {
                      if (selected) {
                        context
                            .read<SmartSetupBloc>()
                            .add(SetupUpdateField((c) => c.copyWith(
                                  teamUserPosition: 'staff',
                                  usageType: 'staff',
                                )));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          _buildUsageTypeCard(
            context: context,
            type: 'staff_direct',
            title: 'Bergabung sebagai karyawan',
            subtitle: 'Bergabung ke workspace bisnis milik Owner.',
            icon: Icons.badge_rounded,
            isSelected:
                state.usageType == 'staff' && !state.isOwnerTeamSubStepChoice,
            onTapOverride: () {
              context
                  .read<SmartSetupBloc>()
                  .add(SetupUpdateField((c) => c.copyWith(
                        usageType: 'staff',
                        isOwnerTeamSubStepChoice: false,
                        teamUserPosition: 'staff',
                      )));
            },
          ),
          const SizedBox(height: 16),
          _buildUsageTypeCard(
            context: context,
            type: 'personal',
            title: 'Mencatat keuangan pribadi',
            subtitle: 'Catat pemasukan & pengeluaran personal harian.',
            icon: Icons.account_balance_wallet_rounded,
            isSelected: state.usageType == 'personal',
          ),
        ],
      );
    }

    // ─── BRANCH: OWNER BUSINESS SETUP FLOW ──────────────────────
    if (state.usageType.startsWith('owner_')) {
      // STEP 4: BUSINESS PROFILE DETAILS
      if (state.currentStep == 4) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil Bisnis Anda',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Masukkan detail informasi tentang bisnis yang Anda kelola.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            TextField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                  labelText: 'Nama Bisnis / Toko *',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _businessDescController,
              decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat (Opsional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _businessAddressController,
              decoration: const InputDecoration(
                  labelText: 'Alamat / Lokasi (Opsional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _businessWhatsAppController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp Bisnis (Opsional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _businessEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email Bisnis (Opsional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Card(
              color: colors.primaryContainer.withOpacity(0.2),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mata uang utama default adalah IDR (Rupiah) dengan zona waktu Asia/Jakarta.',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // STEP 5: CHOOSE BUSINESS FIELD
      if (state.currentStep == 5) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bidang Usaha',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pilih bidang usaha yang paling mendeskripsikan bisnis Anda.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                final key = _fields.keys.elementAt(index);
                final data = _fields[key]!;
                final isSelected = state.businessField == key;
                return InkWell(
                  onTap: () {
                    context.read<SmartSetupBloc>().add(SetupUpdateField(
                        (c) => c.copyWith(businessField: key)));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? colors.primaryContainer : colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(data.icon,
                            color:
                                isSelected ? colors.primary : colors.onSurface,
                            size: 32),
                        const SizedBox(height: 8),
                        Text(
                          data.label,
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? colors.primary : colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }

      // STEP 6: CHOOSE BUSINESS SIZE
      if (state.currentStep == 6) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ukuran / Skala Bisnis',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pilih skala tim operasional bisnis Anda saat ini.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            ..._sizes.keys.map((key) {
              final data = _sizes[key]!;
              final isSelected = state.businessSize == key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    context.read<SmartSetupBloc>().add(
                        SetupUpdateField((c) => c.copyWith(businessSize: key)));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? colors.primaryContainer : colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(data.icon,
                            color:
                                isSelected ? colors.primary : colors.onSurface,
                            size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.label,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurface)),
                              const SizedBox(height: 4),
                              Text(data.subtitle,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: colors.primary),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }

      // STEP 7: SPECIFIC BRANCHING QUESTIONS BASED ON FIELD
      if (state.currentStep == 7) {
        return _buildFieldBranchingQuestions(state);
      }

      // STEP 8: SPECIFIC SCALE QUESTIONS
      if (state.currentStep == 8) {
        return _buildScaleQuestions(state);
      }

      // STEP 9: RECOMMENDED FEATURES LIST
      if (state.currentStep == 9) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fitur yang Dibutuhkan',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Kami merekomendasikan fitur-fitur berikut berdasarkan bidang dan skala usaha Anda.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            _buildFeatureOptionCard(context, 'dashboard', 'Dashboard Utama',
                'Ringkasan visual bisnis', state.enabledFeatures),
            _buildFeatureOptionCard(
                context,
                'transactions',
                'Pencatatan Transaksi',
                'Catat pemasukan & pengeluaran',
                state.enabledFeatures),
            _buildFeatureOptionCard(context, 'wallets', 'Multi-Wallet',
                'Kelola banyak dompet keuangan', state.enabledFeatures),
            _buildFeatureOptionCard(context, 'catalog', 'Katalog Produk / Menu',
                'Kelola daftar item & layanan', state.enabledFeatures),
            _buildFeatureOptionCard(
                context,
                'inventory',
                'Inventory / Stok Barang',
                'Lacak persediaan bahan/produk',
                state.enabledFeatures),
            _buildFeatureOptionCard(context, 'employees', 'Manajemen Karyawan',
                'Atur hak akses staf', state.enabledFeatures),
            _buildFeatureOptionCard(context, 'approval', 'Approval Center',
                'Validasi transaksi oleh Owner', state.enabledFeatures),
            _buildFeatureOptionCard(
                context,
                'reports',
                'Laporan Keuangan Eksekutif',
                'Ekspor laporan bulanan',
                state.enabledFeatures),
            _buildFeatureOptionCard(
                context,
                'schedule',
                'Booking & Penjadwalan',
                'Jadwal kerja / janji temu',
                state.enabledFeatures),
          ],
        );
      }

      // STEP 10: INITIAL WALLET SETUP
      if (state.currentStep == 10) {
        return _buildWalletSetupWidget(state);
      }

      // STEP 11: INITIAL CATEGORIES Package
      if (state.currentStep == 11) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori Transaksi Awal',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Kami akan menyiapkan paket kategori transaksi default secara otomatis untuk Anda.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.amber, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Paket Kategori Cerdas',
                      style: AppTypography.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Secara default, bisnis Anda akan memiliki 13 kategori transaksi esensial (seperti Makanan, Transport, Belanja, Gaji, dll.). Anda dapat mengubah, menambah, atau menghapus kategori ini kapan saja di menu Pengaturan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, height: 1.4, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // STEP 12: EMPLOYEES ADD (Except solo business)
      if (state.currentStep == 12) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Karyawan Awal',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Undang tim/karyawan Anda untuk bergabung (opsional, bisa dilewati).',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            TextField(
              controller: _staffInviteEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email Karyawan',
                  hintText: 'Contoh: budi@gmail.com',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const Text(
              'Catatan: Karyawan yang Anda undang di sini akan mendapatkan hak akses sesuai skala bisnis Anda.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      }
    }

    // ─── BRANCH: STAFF INVITE FLOW ──────────────────────────────
    if (state.usageType == 'staff') {
      if (state.currentStep == 2) {
        final user = firebase_auth.FirebaseAuth.instance.currentUser;
        final loggedEmail = user?.email ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validasi Undangan Karyawan',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Sistem akan mencari undangan keanggotaan bisnis yang dikirimkan oleh Owner ke email Anda.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Email Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_outlined,
                      color: colors.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email Anda yang Terdaftar:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(loggedEmail,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _staffInviteEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Owner atau Kode Undangan (Opsional)',
                hintText: 'Membantu mempercepat pencarian...',
                prefixIcon: Icon(Icons.person_pin_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan pastikan Owner sudah mendaftarkan email Anda di menu Manajemen Karyawan milik mereka.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        );
      }

      if (state.currentStep == 3) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lengkapi Profil Pribadi',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Lengkapi biodata pribadi Anda untuk bergabung ke workspace tim.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Profile Picture Placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colors.primaryContainer.withOpacity(0.4),
                    child: Icon(Icons.person_rounded,
                        size: 50, color: colors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _staffNicknameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap Anda *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _staffPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor HP (Opsional)',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      }
    }

    // ─── BRANCH: PERSONAL FINANCE FLOW ──────────────────────────
    if (state.usageType == 'personal') {
      if (state.currentStep == 2) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tujuan Utama Keuangan',
                style: AppTypography.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pilih fokus utama Anda mencatat keuangan pribadi.',
                style: AppTypography.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 24),
            _buildPersonalGoalChip(
                context, 'Mengatur pengeluaran harian agar hemat'),
            _buildPersonalGoalChip(context, 'Menabung untuk target masa depan'),
            _buildPersonalGoalChip(
                context, 'Lacak hasil investasi & passive income'),
            _buildPersonalGoalChip(
                context, 'Membiasakan mencatat pengeluaran harian'),
          ],
        );
      }

      if (state.currentStep == 3) {
        return _buildWalletSetupWidget(state);
      }
    }

    // ─── COMMON STEP 13: PIN SECURITY ───────────────────────────
    if (state.currentStep == 13) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PIN Keamanan Akun',
              style: AppTypography.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
              'Setel PIN keamanan 4 digit untuk mengunci aplikasi dan mengamankan data sensitif.',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          TextField(
            controller: _securityPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Masukkan 4 Digit PIN Keamanan *',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
        ],
      );
    }

    // ─── COMMON STEP 14: REVIEW SETUP SUMMARY ───────────────────
    if (state.currentStep == 14) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tinjau Pengaturan Anda',
              style: AppTypography.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
              'Periksa kembali seluruh pengaturan setup adaptif Anda sebelum disimpan ke server.',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIPE OPERASI',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: colors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    state.usageType == 'personal'
                        ? 'Keuangan Pribadi (Personal Finance)'
                        : state.usageType == 'staff'
                            ? 'Karyawan / Anggota Tim'
                            : 'Owner Bisnis (${_sizes[state.businessSize]?.label})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(height: 24),
                  if (state.usageType.startsWith('owner_')) ...[
                    Text('NAMA BISNIS',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(state.businessName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('BIDANG USAHA',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_fields[state.businessField]?.label ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                  ],
                  if (state.usageType == 'staff') ...[
                    Text('BISNIS TUJUAN',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(state.validatedBusinessName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text('JABATAN / ROLE ANDA',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      state.validatedRole.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.secondary,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Text('DIVISI',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(state.validatedDivision,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('HAK AKSES / PERMISSIONS',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: state.validatedPermissions.map((perm) {
                        return Chip(
                          label: Text(
                            perm.replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: colors.surfaceContainerHighest,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                  ] else ...[
                    Text('DOMPET INVENTARIS',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        '${state.walletName} (${AppFormatter.currency(state.walletBalance)})',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // STEP 15: FINAL SAVE TRIGGER
    if (state.currentStep == 15) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.check_circle_outline_rounded,
              color: colors.primary, size: 84),
          const SizedBox(height: 24),
          Text(
            'Semua Setup Selesai!',
            style: AppTypography.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Klik tombol di bawah untuk mengaktifkan workspace adaptif Anda secara permanen dan masuk ke dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                context
                    .read<SmartSetupBloc>()
                    .add(const SetupSubmitRequested());
              },
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Aktifkan & Mulai',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // Branching Questions Layout based on Business Field
  Widget _buildFieldBranchingQuestions(SmartSetupState state) {
    final colors = Theme.of(context).colorScheme;

    if (state.businessField == 'f_and_b') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kuesioner F&B / Kuliner',
              style: AppTypography.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Bantu kami memahami operasional kuliner Anda.',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          _buildYesNoSwitchCard(
            'Apakah Anda memiliki menu makanan/minuman sendiri?',
            state.fnbHasMenu,
            (val) => context
                .read<SmartSetupBloc>()
                .add(SetupUpdateField((c) => c.copyWith(fnbHasMenu: val))),
          ),
          const SizedBox(height: 12),
          _buildYesNoSwitchCard(
            'Apakah bisnis Anda perlu melacak persediaan/stok bahan baku?',
            state.fnbNeedsRawInventory,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(fnbNeedsRawInventory: val))),
          ),
          const SizedBox(height: 12),
          _buildYesNoSwitchCard(
            'Apakah ada kasir khusus di tempat usaha Anda?',
            state.fnbHasCashier,
            (val) => context
                .read<SmartSetupBloc>()
                .add(SetupUpdateField((c) => c.copyWith(fnbHasCashier: val))),
          ),
        ],
      );
    }

    if (state.businessField == 'retail') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kuesioner Retail / Toko',
              style: AppTypography.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Sesuaikan kebutuhan stok barang toko retail Anda.',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          _buildYesNoSwitchCard(
            'Apakah Anda memiliki produk fisik untuk dijual?',
            state.retailHasPhysicalProducts,
            (val) => context.read<SmartSetupBloc>().add(SetupUpdateField(
                (c) => c.copyWith(retailHasPhysicalProducts: val))),
          ),
          const SizedBox(height: 12),
          _buildYesNoSwitchCard(
            'Apakah toko Anda memerlukan integrasi stok/inventory barang?',
            state.retailNeedsInventory,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(retailNeedsInventory: val))),
          ),
          const SizedBox(height: 12),
          _buildYesNoSwitchCard(
            'Apakah produk Anda memiliki barcode / SKU?',
            state.retailHasBarcode,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(retailHasBarcode: val))),
          ),
        ],
      );
    }

    if (state.businessField == 'jasa') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kuesioner Jasa / Layanan',
              style: AppTypography.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Sesuaikan kebutuhan layanan reservasi/booking Anda.',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          _buildYesNoSwitchCard(
            'Apakah klien memerlukan janji temu / booking terjadwal?',
            state.serviceNeedsBooking,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(serviceNeedsBooking: val))),
          ),
          const SizedBox(height: 12),
          _buildYesNoSwitchCard(
            'Apakah Anda memerlukan invoice / faktur penagihan formal?',
            state.serviceNeedsInvoice,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(serviceNeedsInvoice: val))),
          ),
        ],
      );
    }

    if (state.businessField == 'online_shop') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kuesioner Online Shop',
              style: AppTypography.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Optimalkan pencatatan biaya admin marketplace e-commerce Anda.',
              style: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          _buildYesNoSwitchCard(
            'Apakah Anda memerlukan pelacakan biaya admin marketplace?',
            state.olsNeedsAdminFee,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(olsNeedsAdminFee: val))),
          ),
          const SizedBox(height: 12),
          _buildYesNoSwitchCard(
            'Apakah Anda memerlukan pencatatan ongkir secara terpisah?',
            state.olsNeedsShippingCost,
            (val) => context.read<SmartSetupBloc>().add(
                SetupUpdateField((c) => c.copyWith(olsNeedsShippingCost: val))),
          ),
        ],
      );
    }

    // Default other branching questions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pertanyaan Usaha',
            style: AppTypography.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Tentukan kebutuhan laporan usaha lainnya.',
            style: AppTypography.textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 24),
        _buildYesNoSwitchCard(
          'Apakah usaha Anda menjual produk fisik?',
          state.retailHasPhysicalProducts,
          (val) => context.read<SmartSetupBloc>().add(SetupUpdateField(
              (c) => c.copyWith(retailHasPhysicalProducts: val))),
        ),
        const SizedBox(height: 12),
        _buildYesNoSwitchCard(
          'Apakah usaha Anda memerlukan laporan kinerja mingguan?',
          state.fnbNeedsDailyReport,
          (val) => context.read<SmartSetupBloc>().add(
              SetupUpdateField((c) => c.copyWith(fnbNeedsDailyReport: val))),
        ),
      ],
    );
  }

  // Branching Questions Layout based on Scale size
  Widget _buildScaleQuestions(SmartSetupState state) {
    final colors = Theme.of(context).colorScheme;

    String scaleText = '';
    String helperText = '';

    if (state.businessSize == 'solo') {
      scaleText = 'Skala Usaha Mandiri (Solo)';
      helperText =
          'Untuk skala usaha Solo, menu rumit seperti divisi, cabang, approval karyawan, dan log detail akan disembunyikan agar tampilan Anda super bersih dan efisien!';
    } else if (state.businessSize == 'micro') {
      scaleText = 'Skala Usaha Mikro';
      helperText =
          'Kami akan mengaktifkan menu pengelolaan karyawan sederhana untuk melacak aktivitas staf pencatat transaksi harian Anda.';
    } else {
      scaleText = 'Skala Usaha Profesional';
      helperText =
          'Kami akan mengaktifkan menu Divisi, Multi-level Approval Transaksi, Log Audit Keamanan, dan Laporan granular per cabang operasional.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Konfigurasi Skala Usaha',
            style: AppTypography.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Kami menyesuaikan dashboard berdasarkan ukuran tim.',
            style: AppTypography.textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 24),
        Card(
          color: colors.primaryContainer.withOpacity(0.12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: colors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      scaleText,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: colors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  helperText,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Wallet Setup helper widget
  Widget _buildWalletSetupWidget(SmartSetupState state) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inisialisasi Dompet Pertama',
            style: AppTypography.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Setel nama dompet dan masukkan nominal saldo awal Anda.',
            style: AppTypography.textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 24),
        Text('Pilih Tipe Dompet',
            style: AppTypography.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: _walletTypes.keys.map((key) {
            final data = _walletTypes[key]!;
            final isSelected = state.walletType == key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(data.icon,
                            size: 20,
                            color: isSelected ? Colors.white : colors.primary),
                        const SizedBox(height: 4),
                        Text(data.label, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context
                          .read<SmartSetupBloc>()
                          .add(SetupUpdateField((c) => c.copyWith(
                                walletType: key,
                                walletName: key == 'cash'
                                    ? 'Cash Utama'
                                    : key == 'bank'
                                        ? 'Rekening Bank'
                                        : 'E-Wallet Utama',
                              )));
                      _walletNameController.text = key == 'cash'
                          ? 'Cash Utama'
                          : key == 'bank'
                              ? 'Rekening Bank'
                              : 'E-Wallet Utama';
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _walletNameController,
          decoration: const InputDecoration(
              labelText: 'Nama Dompet / Rekening *',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _walletBalanceController,
          keyboardType: TextInputType.number,
          inputFormatters: [_ThousandsSeparatorInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Saldo Awal (Rp)',
            border: OutlineInputBorder(),
            prefixText: 'Rp ',
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoSwitchCard(
      String question, bool value, ValueChanged<bool> onChanged) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureOptionCard(BuildContext context, String key, String title,
      String subtitle, List<String> enabledList) {
    final isEnabled = enabledList.contains(key);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
        value: isEnabled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: colors.surface,
        selectedTileColor: colors.primaryContainer,
        checkColor: Colors.white,
        activeColor: colors.primary,
        onChanged: (val) {
          final list = List<String>.from(enabledList);
          if (val == true) {
            list.add(key);
          } else {
            list.remove(key);
          }
          context
              .read<SmartSetupBloc>()
              .add(SetupUpdateField((c) => c.copyWith(enabledFeatures: list)));
        },
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildPersonalGoalChip(BuildContext context, String goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // just auto advance to next step on personal goal select
          context.read<SmartSetupBloc>().add(const SetupNextStepRequested());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  goal,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageTypeCard({
    required BuildContext context,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTapOverride,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTapOverride ??
          () {
            context
                .read<SmartSetupBloc>()
                .add(SetupUpdateField((c) => c.copyWith(
                      usageType: type,
                      isOwnerTeamSubStepChoice: false,
                      teamUserPosition: '',
                    )));
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? colors.primary : colors.outlineVariant,
              width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.12)
                    : colors.surfaceContainerHighest.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                  size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              isSelected ? colors.primary : colors.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: colors.onSurfaceVariant)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────
class _FieldData {
  final String label;
  final IconData icon;
  final String subtitle;
  _FieldData(this.label, this.icon, this.subtitle);
}

class _SizeData {
  final String label;
  final String subtitle;
  final IconData icon;
  _SizeData(this.label, this.subtitle, this.icon);
}

class _WalletTypeData {
  final String label;
  final IconData icon;
  _WalletTypeData(this.label, this.icon);
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) return oldValue;
    final formatted = _format(number);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
