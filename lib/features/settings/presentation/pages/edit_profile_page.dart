// ============================================================
// FEATURE: Settings — Edit Profile Page
// lib/features/settings/presentation/pages/edit_profile_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF0D47A1),
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            
            // Avatar Profile
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Builder(
                          builder: (context) {
                            final user = sl<AuthRepositoryImpl>().cachedUser;
                            final avatarUrl = user?.photoUrl;
                            final initial = (user?.name ?? 'U')[0].toUpperCase();
                            return CircleAvatar(
                              radius: 56,
                              backgroundColor: AppColors.primaryContainer,
                              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl == null
                                  ? Text(initial, style: AppTypography.textTheme.displaySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))
                                  : null,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2962FF), // Bright Blue
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ketuk untuk mengubah foto',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Form Fields
            _FormField(
              label: 'Nama Lengkap',
              initialValue: sl<AuthRepositoryImpl>().cachedUser?.name ?? '',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            _FormField(
              label: 'Alamat Email',
              initialValue: sl<AuthRepositoryImpl>().cachedUser?.email ?? '',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _FormField(
              label: 'Nomor Telepon',
              initialValue: '+62 812 3456 7890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: AppSpacing.xl),

            // Account Security Link Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF), // Very light blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFF0D47A1), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Keamanan Akun', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF1A202C), fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'Ubah kata sandi atau atur autentikasi dua faktor.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Kelola Keamanan', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF0D47A1), size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48), // Padding before bottom nav
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: const Color(0xFF2962FF), // Bright Blue
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Simpan Perubahan',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String initialValue;
  final IconData icon;
  final TextInputType? keyboardType;

  const _FormField({
    required this.label,
    required this.initialValue,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4A5568),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          style: AppTypography.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1A202C)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFA0AEC0)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2962FF)), // Focus blue
            ),
          ),
        ),
      ],
    );
  }
}
