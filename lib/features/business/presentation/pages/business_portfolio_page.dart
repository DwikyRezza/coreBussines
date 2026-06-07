// ============================================================
// FEATURE: Business — Business Portfolio Page (Dinamis & Switcher)
// lib/features/business/presentation/pages/business_portfolio_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class BusinessPortfolioPage extends StatefulWidget {
  const BusinessPortfolioPage({super.key});

  @override
  State<BusinessPortfolioPage> createState() => _BusinessPortfolioPageState();
}

class _BusinessPortfolioPageState extends State<BusinessPortfolioPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = firebase_auth.FirebaseAuth.instance;
  final _localStorage = sl<LocalStorageService>();

  String? _activeBusinessId;

  @override
  void initState() {
    super.initState();
    _activeBusinessId = _localStorage.activeBusinessId;
  }

  Future<void> _switchBusiness(String businessId, String businessName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _activeBusinessId = businessId;
    });

    await _localStorage.setActiveBusinessId(businessId);
    await _firestore.collection('users').doc(user.uid).set({
      'active_business_id': businessId,
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil beralih ke bisnis "$businessName"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateBusinessDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Buat Bisnis Baru',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Bisnis / Workspace',
            hintText: 'Contoh: Zen Cafe, Totapo...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final businessName = nameController.text.trim();
              if (businessName.isEmpty) return;

              Navigator.pop(context);
              final user = _auth.currentUser;
              if (user == null) return;

              try {
                // 1. Buat dokumen bisnis baru
                final businessDoc = _firestore.collection('businesses').doc();
                final now = FieldValue.serverTimestamp();

                await businessDoc.set({
                  'name': businessName,
                  'owner_id': user.uid,
                  'created_at': now,
                  'updated_at': now,
                });

                // 2. Tambahkan owner ke subkoleksi members
                final userDoc =
                    await _firestore.collection('users').doc(user.uid).get();
                final userData = userDoc.data();
                final userName = userData?['full_name'] as String? ??
                    user.displayName ??
                    user.email ??
                    'Owner';

                await businessDoc.collection('members').doc(user.uid).set({
                  'user_id': user.uid,
                  'name': userName,
                  'email': user.email,
                  'photo_url': userData?['avatar_url'] ?? user.photoURL,
                  'role': 'owner',
                  'joined_at': now,
                  'updated_at': now,
                });

                // 3. Tambahkan default cash wallet
                await businessDoc
                    .collection('wallets')
                    .doc('default_cash')
                    .set({
                  'name': 'Cash',
                  'type': 'cash',
                  'balance': 0.0,
                  'updated_at': now,
                });

                // Set sebagai bisnis aktif secara instan
                await _switchBusiness(businessDoc.id, businessName);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Gagal membuat bisnis: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error),
                );
              }
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _watchUserBusinesses() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return Stream.value([]);
    }

    return _firestore
        .collectionGroup('members')
        .where('email', isEqualTo: user.email)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> list = [];
      for (final doc in snapshot.docs) {
        final businessRef = doc.reference.parent.parent;
        if (businessRef == null) continue;

        try {
          final businessSnap = await businessRef.get();
          if (!businessSnap.exists) continue;

          final data = businessSnap.data()!;
          final memberData = doc.data();

          list.add({
            'id': businessRef.id,
            'name': data['name'] ?? 'Workspace',
            'owner_id': data['owner_id'],
            'role': memberData['role'] ?? 'owner',
          });
        } catch (_) {
          // Abaikan jika tidak memiliki izin membaca dokumen bisnis tertentu
        }
      }
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _watchUserBusinesses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final businesses = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Portofolio Bisnis',
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showCreateBusinessDialog(context),
                        icon: Icon(Icons.add_business_rounded,
                            color: colors.primary, size: 28),
                        tooltip: 'Tambah Bisnis Baru',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Horizontal Portfolio Cards
                if (businesses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding, vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.storefront_outlined,
                              size: 64, color: colors.outline),
                          const SizedBox(height: 12),
                          const Text('Belum bergabung dengan bisnis apa pun.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding),
                      itemCount: businesses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final biz = businesses[index];
                        final isCurrentActive = biz['id'] == _activeBusinessId;
                        return InkWell(
                          onTap: () => _switchBusiness(biz['id'], biz['name']),
                          borderRadius: BorderRadius.circular(16),
                          child: _PortfolioCard(
                            title: biz['name'],
                            subtitle: biz['role'] == 'owner'
                                ? 'Owner / Pemilik'
                                : 'Staff / Karyawan',
                            icon: biz['role'] == 'owner'
                                ? Icons.storefront_rounded
                                : Icons.badge_rounded,
                            isActive: isCurrentActive,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Dynamic Overview Section based on current selected workspace
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding),
                  child: Text(
                    'Pintasan Portofolio',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Overview card showing brief usage info
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: colors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Workspace Aktif',
                              style:
                                  AppTypography.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Anda sedang masuk ke workspace aktif. Semua pencatatan transaksi, dompet, analitik, dan manajemen tim akan disinkronkan ke bisnis terpilih di atas.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Klik salah satu kartu bisnis di atas untuk beralih workspace dengan cepat secara instan.',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;

  const _PortfolioCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: colors.primary, width: 2.5)
            : Border.all(color: colors.outlineVariant, width: 1.5),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: colors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: colors.shadow.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? colors.primaryContainer.withOpacity(0.4)
                      : colors.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isActive ? colors.primary : colors.onSurfaceVariant,
                  size: 24,
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Aktif',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
