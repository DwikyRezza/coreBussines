// ============================================================
// FEATURE: Settings - Team Management Page
// lib/features/settings/presentation/pages/team_management_page.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/security/permission_policy.dart';
import '../../../../core/services/business_context_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/widgets/security_verification_helper.dart';
import '../../../../core/utils/activity_logger.dart';

class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  final List<String> _availablePermissions = [
    'manage_members',
    'add_transaction',
    'delete_transaction',
    'manage_inventory',
    'view_analytics',
    'manage_wallets',
  ];

  String _getPermissionLabel(String key) {
    switch (key) {
      case 'manage_members':
        return 'Kelola Anggota';
      case 'add_transaction':
        return 'Mencatat Transaksi';
      case 'delete_transaction':
        return 'Menghapus Transaksi';
      case 'manage_inventory':
        return 'Mengatur Inventaris';
      case 'view_analytics':
        return 'Melihat Analitik';
      case 'manage_wallets':
        return 'Kelola Dompet';
      default:
        return key;
    }
  }

  List<String> _resolvePermissionKeys(
    String role,
    List<String> selectedPermissions,
  ) {
    final mapped = selectedPermissions.map((permission) {
      switch (permission) {
        case 'manage_members':
          return PermissionKeys.canManageEmployees;
        case 'add_transaction':
          return PermissionKeys.canCreateTransaction;
        case 'delete_transaction':
          return PermissionKeys.canDeleteTransaction;
        case 'manage_inventory':
          return PermissionKeys.canManageInventory;
        case 'view_analytics':
          return PermissionKeys.canViewAnalytics;
        case 'manage_wallets':
          return PermissionKeys.canManageWallet;
        default:
          return permission;
      }
    }).toList();

    return PermissionPolicy.resolvePermissions(
      role: role,
      explicitPermissions: mapped,
    );
  }

  void _showInviteDialog(BuildContext context, String businessId) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final divisionController = TextEditingController();
    final branchController = TextEditingController();
    final noteController = TextEditingController();

    String selectedRole = 'cashier';
    DateTime? selectedDate;
    List<String> selectedPermissions = ['add_transaction'];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final colors = Theme.of(context).colorScheme;

          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusXxl),
                topRight: Radius.circular(AppSpacing.radiusXxl),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Undang Karyawan Baru',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Fields
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Karyawan',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP (Opsional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: divisionController,
                    decoration: const InputDecoration(
                      labelText: 'Divisi (e.g. Operational, Finance)',
                      prefixIcon: Icon(Icons.business_center_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: branchController,
                    decoration: const InputDecoration(
                      labelText: 'Cabang (Opsional)',
                      prefixIcon: Icon(Icons.storefront_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role Karyawan',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'finance', child: Text('Finance')),
                      DropdownMenuItem(
                          value: 'secretary', child: Text('Secretary')),
                      DropdownMenuItem(
                          value: 'cashier', child: Text('Cashier')),
                      DropdownMenuItem(
                          value: 'inventory', child: Text('Inventory Staff')),
                      DropdownMenuItem(value: 'sales', child: Text('Sales')),
                      DropdownMenuItem(
                          value: 'manager', child: Text('Manager')),
                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                      DropdownMenuItem(
                          value: 'auditor', child: Text('Auditor')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedRole = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Start Work Date Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(
                      selectedDate == null
                          ? 'Mulai Bekerja (Opsional)'
                          : 'Mulai Bekerja: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Khusus (Opsional)',
                      prefixIcon: Icon(Icons.edit_note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Permissions Checkboxes
                  Text(
                    'Permission Tambahan',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._availablePermissions.map((perm) {
                    final active = selectedPermissions.contains(perm);
                    return CheckboxListTile(
                      value: active,
                      title: Text(_getPermissionLabel(perm)),
                      onChanged: (checked) {
                        setSheetState(() {
                          if (checked == true) {
                            selectedPermissions.add(perm);
                          } else {
                            selectedPermissions.remove(perm);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final phone = phoneController.text.trim();
                            final division = divisionController.text.trim();
                            final branch = branchController.text.trim();
                            final note = noteController.text.trim();

                            if (name.isEmpty || email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Nama Lengkap dan Email wajib diisi!')),
                              );
                              return;
                            }

                            // 1. Verifikasi PIN/Biometrik Owner
                            final verified =
                                await SecurityVerificationHelper.verifyAction(
                              context,
                              'Mengundang Karyawan Baru',
                            );
                            if (!verified) return;

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            try {
                              final memberDocRef = FirebaseFirestore.instance
                                  .collection('businesses')
                                  .doc(businessId)
                                  .collection('members')
                                  .doc(email.toLowerCase());

                              await memberDocRef.set({
                                'name': name,
                                'email': email.toLowerCase(),
                                'phone': phone.isEmpty ? null : phone,
                                'role': selectedRole,
                                'division':
                                    division.isEmpty ? 'Umum' : division,
                                'branch': branch.isEmpty ? null : branch,
                                'permissions': selectedPermissions,
                                'permission_keys': _resolvePermissionKeys(
                                  selectedRole,
                                  selectedPermissions,
                                ),
                                'status': 'active',
                                'start_work_date': selectedDate != null
                                    ? Timestamp.fromDate(selectedDate!)
                                    : null,
                                'note': note.isEmpty ? null : note,
                                'joined_at': FieldValue.serverTimestamp(),
                                'updated_at': FieldValue.serverTimestamp(),
                                'user_id': null, // Diisi saat staff login
                              });

                              ActivityLogger.log(
                                action: 'invite_employee',
                                targetType: 'employee',
                                targetId: email.toLowerCase(),
                                description:
                                    'Mengundang karyawan baru "$name" dengan email "$email" sebagai role "$selectedRole"',
                              );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Undangan berhasil dibuat & dikirim!'),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mengundang: $e'),
                                  backgroundColor: colors.error,
                                ),
                              );
                            }
                          },
                          child: const Text('Simpan & Undang'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, String businessId, String memberId,
      Map<String, dynamic> currentData) {
    final divisionController =
        TextEditingController(text: currentData['division'] ?? '');
    final branchController =
        TextEditingController(text: currentData['branch'] ?? '');
    final noteController =
        TextEditingController(text: currentData['note'] ?? '');

    String selectedRole = currentData['role'] ?? 'cashier';
    String selectedStatus = currentData['status'] ?? 'active';
    DateTime? selectedDate = currentData['start_work_date'] != null
        ? (currentData['start_work_date'] as Timestamp).toDate()
        : null;
    List<String> selectedPermissions =
        List<String>.from(currentData['permissions'] ?? []);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final colors = Theme.of(context).colorScheme;

          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusXxl),
                topRight: Radius.circular(AppSpacing.radiusXxl),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kelola Detail Karyawan',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currentData['name'] ?? currentData['email']}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fields
                  TextField(
                    controller: divisionController,
                    decoration: const InputDecoration(
                      labelText: 'Divisi',
                      prefixIcon: Icon(Icons.business_center_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: branchController,
                    decoration: const InputDecoration(
                      labelText: 'Cabang (Opsional)',
                      prefixIcon: Icon(Icons.storefront_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role Karyawan',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'finance', child: Text('Finance')),
                      DropdownMenuItem(
                          value: 'secretary', child: Text('Secretary')),
                      DropdownMenuItem(
                          value: 'cashier', child: Text('Cashier')),
                      DropdownMenuItem(
                          value: 'inventory', child: Text('Inventory Staff')),
                      DropdownMenuItem(value: 'sales', child: Text('Sales')),
                      DropdownMenuItem(
                          value: 'manager', child: Text('Manager')),
                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                      DropdownMenuItem(
                          value: 'auditor', child: Text('Auditor')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedRole = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status Keaktifan',
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'active', child: Text('Active (Aktif)')),
                      DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive (Tidak Aktif)')),
                      DropdownMenuItem(
                          value: 'suspended',
                          child: Text('Suspended (Ditangguhkan)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedStatus = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(
                      selectedDate == null
                          ? 'Mulai Bekerja (Opsional)'
                          : 'Mulai Bekerja: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Khusus (Opsional)',
                      prefixIcon: Icon(Icons.edit_note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Permissions Checkboxes
                  Text(
                    'Permission Tambahan',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._availablePermissions.map((perm) {
                    final active = selectedPermissions.contains(perm);
                    return CheckboxListTile(
                      value: active,
                      title: Text(_getPermissionLabel(perm)),
                      onChanged: (checked) {
                        setSheetState(() {
                          if (checked == true) {
                            selectedPermissions.add(perm);
                          } else {
                            selectedPermissions.remove(perm);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            // 1. Verifikasi PIN/Biometrik Owner
                            final verified =
                                await SecurityVerificationHelper.verifyAction(
                              context,
                              'Menghapus Karyawan dari Bisnis',
                            );
                            if (!verified) return;

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            try {
                              await FirebaseFirestore.instance
                                  .collection('businesses')
                                  .doc(businessId)
                                  .collection('members')
                                  .doc(memberId)
                                  .update({
                                'status': 'removed',
                                'updated_at': FieldValue.serverTimestamp(),
                              });

                              ActivityLogger.log(
                                action: 'remove_employee',
                                targetType: 'employee',
                                targetId: memberId,
                                description:
                                    'Menghapus akses karyawan "${currentData['name'] ?? memberId}"',
                              );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Akses karyawan berhasil dihapus.')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus: $e'),
                                  backgroundColor: colors.error,
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            side: BorderSide(color: colors.error),
                          ),
                          child: const Text('Hapus Akses'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            // 1. Verifikasi PIN/Biometrik Owner
                            final verified =
                                await SecurityVerificationHelper.verifyAction(
                              context,
                              'Mengubah Data Karyawan',
                            );
                            if (!verified) return;

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            try {
                              await FirebaseFirestore.instance
                                  .collection('businesses')
                                  .doc(businessId)
                                  .collection('members')
                                  .doc(memberId)
                                  .update({
                                'division':
                                    divisionController.text.trim().isEmpty
                                        ? 'Umum'
                                        : divisionController.text.trim(),
                                'branch': branchController.text.trim().isEmpty
                                    ? null
                                    : branchController.text.trim(),
                                'role': selectedRole,
                                'status': selectedStatus,
                                'permissions': selectedPermissions,
                                'permission_keys': _resolvePermissionKeys(
                                  selectedRole,
                                  selectedPermissions,
                                ),
                                'start_work_date': selectedDate != null
                                    ? Timestamp.fromDate(selectedDate!)
                                    : null,
                                'note': noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                                'updated_at': FieldValue.serverTimestamp(),
                              });

                              ActivityLogger.log(
                                action: 'edit_employee',
                                targetType: 'employee',
                                targetId: memberId,
                                description:
                                    'Mengubah data karyawan "${currentData['name'] ?? memberId}"',
                              );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Perubahan data disimpan!')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan: $e'),
                                  backgroundColor: colors.error,
                                ),
                              );
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BusinessContext>(
      future: sl<BusinessContextService>().getCurrentContext(),
      builder: (context, contextSnapshot) {
        final businessContext = contextSnapshot.data;
        final isOwner = businessContext?.isOwner ?? false;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const CoreAppBar(),
          body: businessContext == null
              ? (contextSnapshot.hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal mengakses manajemen tim: ${contextSnapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()))
              : _TeamList(
                  contextData: businessContext,
                  onManageMember: (memberId, memberData) {
                    _showEditSheet(
                      context,
                      businessContext.businessId,
                      memberId,
                      memberData,
                    );
                  },
                ),
          floatingActionButton: businessContext != null && isOwner
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      _showInviteDialog(context, businessContext.businessId),
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Undang Anggota'),
                )
              : null,
        );
      },
    );
  }
}

class _TeamList extends StatelessWidget {
  final BusinessContext contextData;
  final Function(String, Map<String, dynamic>) onManageMember;

  const _TeamList({
    required this.contextData,
    required this.onManageMember,
  });

  @override
  Widget build(BuildContext context) {
    final membersRef = FirebaseFirestore.instance
        .collection('businesses')
        .doc(contextData.businessId)
        .collection('members');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: membersRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Ambil data members & filter status removed di sisi klien
        final allDocs = snapshot.data!.docs;
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> activeMembers =
            [];

        for (final doc in allDocs) {
          final data = doc.data();
          final status = data['status'] as String? ?? 'active';
          if (status != 'removed' && status != 'used') {
            activeMembers.add(doc);
          }
        }

        // Urutkan berdasarkan joined_at
        activeMembers.sort((a, b) {
          final aTime = a.data()['joined_at'] as Timestamp?;
          final bTime = b.data()['joined_at'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime);
        });

        return ListView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Manajemen Anggota',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contextData.isOwner
                  ? 'Klik kartu anggota untuk mengedit atau menghapus akses.'
                  : 'Anda dapat melihat anggota bisnis ini.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (activeMembers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'Belum ada anggota tim terdaftar.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (final member in activeMembers) ...[
                _MemberCard(
                  memberId: member.id,
                  data: member.data(),
                  currentUserId: contextData.userId,
                  canManage: contextData.isOwner,
                  onTap: () {
                    if (contextData.isOwner &&
                        member.id != contextData.userId) {
                      onManageMember(member.id, member.data());
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String memberId;
  final Map<String, dynamic> data;
  final String currentUserId;
  final bool canManage;
  final VoidCallback onTap;

  const _MemberCard({
    required this.memberId,
    required this.data,
    required this.currentUserId,
    required this.canManage,
    required this.onTap,
  });

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      case 'finance':
        return 'Finance';
      case 'secretary':
        return 'Secretary';
      case 'cashier':
        return 'Cashier';
      case 'inventory':
        return 'Inventory Staff';
      case 'sales':
        return 'Sales';
      case 'manager':
        return 'Manager';
      case 'viewer':
        return 'Viewer';
      case 'auditor':
        return 'Auditor';
      default:
        return role;
    }
  }

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'suspended':
        return colors.error;
      default:
        return colors.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name =
        data['name'] as String? ?? data['email'] as String? ?? 'Anggota';
    final email = data['email'] as String? ?? '';
    final role = data['role'] as String? ?? 'cashier';
    final division = data['division'] as String? ?? 'Umum';
    final branch = data['branch'] as String?;
    final status = data['status'] as String? ?? 'active';
    final avatarUrl = data['photo_url'] as String?;
    final isSelf = data['user_id'] == currentUserId;
    final initials = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                backgroundImage:
                    avatarUrl == null ? null : NetworkImage(avatarUrl),
                child: avatarUrl == null
                    ? Text(
                        initials,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$name${isSelf ? ' (Anda)' : ''}',
                            style:
                                AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(status, colors),
                          ),
                        ),
                      ],
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.business_center_outlined,
                            size: 14, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          division,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (branch != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.storefront_outlined,
                              size: 14, color: colors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            branch,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: role.toLowerCase() == 'owner'
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _getRoleLabel(role),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: role.toLowerCase() == 'owner'
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
