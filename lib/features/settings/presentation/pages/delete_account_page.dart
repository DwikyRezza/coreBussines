// ============================================================
// FEATURE: Settings — Delete Account Page
// lib/features/settings/presentation/pages/delete_account_page.dart
//
// 4-step hard deletion flow:
//   Step 1 – verify email
//   Step 2 – Google re-authentication (confirms identity + password)
//   Step 3 – type agreement phrase
//   Step 4 – biometric confirmation
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/app_lock_repository.dart';

// The exact phrase the user must type to confirm deletion.
const _kAgreementPhrase = 'saya setuju untuk menghapus akun saya';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage>
    with SingleTickerProviderStateMixin {
  // Current step index (0-based).
  int _step = 0;

  // Step 1 – Email verification.
  final _emailController = TextEditingController();
  String? _emailError;

  // Step 2 – Google re-auth: advanced to step 3 once done.

  // Step 3 – Agreement phrase.
  final _phraseController = TextEditingController();
  String? _phraseError;

  bool _loading = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _phraseController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phraseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String get _currentUserEmail {
    final impl = sl<AuthRepositoryImpl>();
    return impl.cachedUser?.email ?? '';
  }

  void _animateToStep(int step) {
    _fadeController.reset();
    setState(() => _step = step);
    _fadeController.forward();
  }

  // ─── Step 1: Verify email ────────────────────────────────────────────────────

  void _validateEmail() {
    final entered = _emailController.text.trim().toLowerCase();
    final expected = _currentUserEmail.toLowerCase();
    if (entered.isEmpty) {
      setState(() => _emailError = 'Masukkan email akun Anda.');
      return;
    }
    if (entered != expected) {
      setState(() => _emailError = 'Email tidak sesuai dengan akun yang login.');
      return;
    }
    setState(() => _emailError = null);
    _animateToStep(1);
  }

  // ─── Step 2: Google re-authentication ───────────────────────────────────────

  Future<void> _proceedStep2() async {
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _loading = false);
      _animateToStep(2);
    } catch (_) {
      setState(() => _loading = false);
      if (!mounted) return;
      _showError('Autentikasi Google gagal. Coba lagi.');
    }
  }

  // ─── Step 3: Agreement phrase ────────────────────────────────────────────────

  bool get _phraseValid =>
      _phraseController.text.trim().toLowerCase() == _kAgreementPhrase;

  void _validatePhrase() {
    if (!_phraseValid) {
      setState(() => _phraseError = 'Kalimat tidak sesuai. Ketik persis seperti di atas.');
      return;
    }
    setState(() => _phraseError = null);
    _animateToStep(3);
  }

  // ─── Step 4: Biometric + final deletion ─────────────────────────────────────

  Future<void> _proceedBiometric() async {
    setState(() => _loading = true);
    try {
      final repo = sl<AppLockRepository>();
      final settings = await repo.getSettings();

      bool passed = false;
      if (settings.biometricSupported && settings.biometricEnabled) {
        passed = await repo.authenticateWithBiometric();
      } else {
        // Biometric not set up — ask user to proceed anyway with a warning.
        passed = await _showBiometricFallbackDialog() ?? false;
      }

      if (!passed) {
        setState(() => _loading = false);
        _showError('Autentikasi biometrik gagal atau dibatalkan.');
        return;
      }

      setState(() => _loading = false);

      await _performDeletion();
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      _showError('Terjadi kesalahan: $e');
    }
  }

  Future<bool?> _showBiometricFallbackDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Biometrik Tidak Aktif'),
          ],
        ),
        content: const Text(
          'Biometrik belum diatur di perangkat ini.\n\n'
          'Anda tetap dapat melanjutkan penghapusan akun, '
          'namun kami sangat menyarankan untuk mengaktifkan biometrik demi keamanan.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lanjutkan Tanpa Biometrik'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeletion() async {
    setState(() => _loading = true);
    try {
      final result = await sl<AuthRepository>().deleteAccount();
      result.fold(
        (failure) {
          setState(() => _loading = false);
          String msg = 'Gagal menghapus akun.';
          if (failure is AuthFailure) msg = failure.message;
          if (failure is ServerFailure) msg = failure.message;
          _showError(msg);
        },
        (_) {
          // Auth stream will fire → router redirects to /login automatically.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun berhasil dihapus.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } catch (e) {
      setState(() => _loading = false);
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hapus Akun',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.xl,
                  AppSpacing.pagePadding,
                  AppSpacing.xl,
                ),
                child: [
                  _buildStep1(colors),
                  _buildStep2(colors),
                  _buildStep3(colors),
                  _buildStep4(colors),
                ][_step],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1 Widget ───────────────────────────────────────────────────────────
  Widget _buildStep1(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DangerHeader(
          icon: Icons.email_outlined,
          title: 'Verifikasi Email',
          subtitle: 'Masukkan email akun Anda untuk melanjutkan.',
        ),
        const SizedBox(height: AppSpacing.xl),
        _WarningBanner(
          message:
              'Penghapusan akun bersifat permanen dan tidak dapat dibatalkan. '
              'Seluruh data bisnis, transaksi, dan riwayat akan ikut terhapus.',
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Email Akun',
            hintText: 'contoh@email.com',
            prefixIcon: const Icon(Icons.alternate_email_rounded),
            errorText: _emailError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (_) => _validateEmail(),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _validateEmail,
            child: const Text(
              'Lanjutkan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2 Widget ───────────────────────────────────────────────────────────
  Widget _buildStep2(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DangerHeader(
          icon: Icons.password_rounded,
          title: 'Konfirmasi Identitas',
          subtitle:
              'Masuk ulang dengan Google untuk membuktikan bahwa ini adalah akun milik Anda.',
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('G',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4),
                      )),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masuk Ulang dengan Google',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sistem akan meminta password Google Anda\nuntuk memverifikasi identitas.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _loading ? null : _proceedStep2,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(
              _loading ? 'Memverifikasi...' : 'Masuk Ulang dengan Google',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 3 Widget ───────────────────────────────────────────────────────────
  Widget _buildStep3(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DangerHeader(
          icon: Icons.edit_note_rounded,
          title: 'Ketik Persetujuan',
          subtitle: 'Ketik kalimat berikut persis seperti ditampilkan untuk melanjutkan.',
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.error.withValues(alpha: 0.4)),
          ),
          child: Text(
            '"$_kAgreementPhrase"',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.error,
              letterSpacing: 0.3,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _phraseController,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Ketik kalimat di atas',
            errorText: _phraseError,
            suffixIcon: _phraseValid
                ? Icon(Icons.check_circle_rounded, color: colors.primary)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _phraseValid ? colors.error : colors.outline,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _phraseValid ? _validatePhrase : null,
            child: const Text(
              'Lanjutkan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 4 Widget ───────────────────────────────────────────────────────────
  Widget _buildStep4(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DangerHeader(
          icon: Icons.fingerprint_rounded,
          title: 'Konfirmasi Biometrik',
          subtitle:
              'Langkah terakhir: gunakan sidik jari atau wajah Anda untuk mengonfirmasi penghapusan akun.',
        ),
        const SizedBox(height: AppSpacing.xl),
        _WarningBanner(
          icon: Icons.warning_amber_rounded,
          message:
              'Setelah ini, akun Anda akan DIHAPUS PERMANEN. '
              'Semua data tidak dapat dipulihkan kembali.',
          color: colors.error,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: GestureDetector(
            onTap: _loading ? null : _proceedBiometric,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _loading
                    ? colors.errorContainer
                    : colors.error.withValues(alpha: 0.12),
                border: Border.all(
                  color: colors.error,
                  width: 2.5,
                ),
              ),
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colors.error,
                        strokeWidth: 3,
                      ),
                    )
                  : Icon(
                      Icons.fingerprint_rounded,
                      size: 64,
                      color: colors.error,
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            _loading ? 'Menghapus akun...' : 'Tekan untuk autentikasi',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: colors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: const Text(
              'Batalkan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Email', 'Sandi', 'Persetujuan', 'Biometrik'];
  static const _icons = [
    Icons.email_outlined,
    Icons.password_rounded,
    Icons.edit_note_rounded,
    Icons.fingerprint_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          final color = isDone
              ? colors.primary
              : isActive
                  ? colors.error
                  : colors.outlineVariant;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? colors.primary : colors.outlineVariant,
                        ),
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone || isActive
                            ? color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(Icons.check_rounded, size: 16, color: color)
                            : Icon(_icons[i], size: 15, color: color),
                      ),
                    ),
                    if (i < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < currentStep
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? colors.error
                        : isDone
                            ? colors.primary
                            : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DangerHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DangerHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colors.error, size: 32),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          title,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const _WarningBanner({
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bannerColor = color ?? colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: bannerColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: bannerColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
