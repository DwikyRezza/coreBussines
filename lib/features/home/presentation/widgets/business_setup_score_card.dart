import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/business_context_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../settings/data/datasources/app_lock_local_datasource.dart';

class BusinessSetupScoreCard extends StatefulWidget {
  const BusinessSetupScoreCard({super.key});

  @override
  State<BusinessSetupScoreCard> createState() => _BusinessSetupScoreCardState();
}

class _BusinessSetupScoreCardState extends State<BusinessSetupScoreCard> {
  bool _isExpanded = false;

  Future<Map<String, dynamic>> _calculateScore(String businessId, BusinessContext context) async {
    final firestore = FirebaseFirestore.instance;

    final businessDocFuture = firestore.collection('businesses').doc(businessId).get();
    final walletsQueryFuture = firestore.collection('businesses').doc(businessId).collection('wallets').limit(1).get();
    final categoriesQueryFuture = firestore.collection('businesses').doc(businessId).collection('categories').limit(1).get();
    final membersQueryFuture = firestore.collection('businesses').doc(businessId).collection('members').where('role', isNotEqualTo: 'owner').limit(1).get();
    final pinSettingsFuture = sl<AppLockLocalDataSource>().getSettings();

    final results = await Future.wait([
      businessDocFuture,
      walletsQueryFuture,
      categoriesQueryFuture,
      membersQueryFuture,
      pinSettingsFuture,
    ]);

    final businessDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final walletsQuery = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final categoriesQuery = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final membersQuery = results[3] as QuerySnapshot<Map<String, dynamic>>;
    final pinSettings = results[4] as dynamic; // AppLockSettings

    final businessData = businessDoc.data() ?? {};

    // 8 Checklist items (each worth 12.5%)
    final checkList = <String, bool>{
      'businessProfile': businessData['name'] != null && (businessData['name'] as String).trim().isNotEmpty,
      'ownerActive': context.role == 'owner',
      'walletCreated': walletsQuery.docs.isNotEmpty,
      'categoryCreated': categoriesQuery.docs.isNotEmpty,
      'featureSelected': businessData['enabled_features'] != null && (businessData['enabled_features'] as List).isNotEmpty,
      'logoUploaded': businessData['logo_url'] != null || businessData['logoUrl'] != null,
      'staffAdded': membersQuery.docs.isNotEmpty,
      'pinEnabled': pinSettings.pinEnabled == true,
    };

    int completedCount = checkList.values.where((v) => v).length;
    double progress = completedCount / 8.0;

    return {
      'progress': progress,
      'score': (progress * 100).toInt(),
      'checklist': checkList,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<BusinessContext>(
      future: sl<BusinessContextService>().getCurrentContext(),
      builder: (context, contextSnapshot) {
        if (!contextSnapshot.hasData) return const SizedBox.shrink();
        final bizCtx = contextSnapshot.data!;

        // Score card is strictly for owner role
        if (bizCtx.role != 'owner') return const SizedBox.shrink();

        return FutureBuilder<Map<String, dynamic>>(
          future: _calculateScore(bizCtx.businessId, bizCtx),
          builder: (context, scoreSnapshot) {
            if (!scoreSnapshot.hasData) return const SizedBox.shrink();
            final data = scoreSnapshot.data!;
            final int score = data['score'] as int;
            final double progress = data['progress'] as double;
            final checklist = data['checklist'] as Map<String, bool>;

            // If setup is 100% complete, do not show card to keep home clean
            if (score >= 100) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withAlpha(20),
                    colors.secondary.withAlpha(10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.primary.withAlpha(38)),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withAlpha(10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.speed_rounded, color: colors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Setup Bisnis $score% Selesai',
                              style: AppTypography.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: colors.outlineVariant.withAlpha(100),
                                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Lengkapi setup untuk memaksimalkan fitur pencatatan, analitik keuangan, serta keamanan UMKM Anda.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Actionable incomplete items CTA
                  _buildCTASection(context, colors, checklist),

                  const SizedBox(height: AppSpacing.xs),
                  Divider(color: colors.outlineVariant.withAlpha(128)),
                  
                  // Collapse / Expand toggle
                  TextButton.icon(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    icon: Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                    label: Text(_isExpanded ? 'Sembunyikan Checklist' : 'Tampilkan Checklist Lengkap'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: colors.primary,
                    ),
                  ),

                  if (_isExpanded) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _buildChecklistItem('Profil bisnis dibuat', checklist['businessProfile']!),
                    _buildChecklistItem('Role Owner aktif', checklist['ownerActive']!),
                    _buildChecklistItem('Fitur utama dipilih', checklist['featureSelected']!),
                    _buildChecklistItem('Wallet awal dibuat', checklist['walletCreated']!),
                    _buildChecklistItem('Kategori transaksi dibuat', checklist['categoryCreated']!),
                    _buildChecklistItem('Logo bisnis diupload', checklist['logoUploaded']!),
                    _buildChecklistItem('Karyawan ditambahkan', checklist['staffAdded']!),
                    _buildChecklistItem('PIN keamanan aktif', checklist['pinEnabled']!),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCTASection(BuildContext context, ColorScheme colors, Map<String, bool> checklist) {
    // Collect incomplete items that have a clear CTA
    final ctas = <Widget>[];

    if (!checklist['logoUploaded']!) {
      ctas.add(_CTAButton(
        label: 'Upload Logo',
        icon: Icons.upload_file_rounded,
        onTap: () => context.push(AppRoutes.businessPortfolio),
      ));
    }
    if (!checklist['staffAdded']!) {
      ctas.add(_CTAButton(
        label: 'Tambah Karyawan',
        icon: Icons.person_add_rounded,
        onTap: () => context.push(AppRoutes.teamManagement),
      ));
    }
    if (!checklist['pinEnabled']!) {
      ctas.add(_CTAButton(
        label: 'Aktifkan PIN',
        icon: Icons.lock_outline_rounded,
        onTap: () => context.push(AppRoutes.securitySettings),
      ));
    }
    if (!checklist['walletCreated']!) {
      ctas.add(_CTAButton(
        label: 'Buat Dompet',
        icon: Icons.account_balance_wallet_rounded,
        onTap: () => context.push(AppRoutes.wallets),
      ));
    }

    if (ctas.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ctas,
    );
  }

  Widget _buildChecklistItem(String title, bool isDone) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? colors.primary : colors.outline,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: isDone ? colors.onSurface : colors.onSurfaceVariant,
                decoration: isDone ? TextDecoration.lineThrough : null,
                fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CTAButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
