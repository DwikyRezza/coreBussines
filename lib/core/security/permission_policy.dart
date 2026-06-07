class PermissionKeys {
  const PermissionKeys._();

  static const canCreateTransaction = 'canCreateTransaction';
  static const canEditTransaction = 'canEditTransaction';
  static const canDeleteTransaction = 'canDeleteTransaction';
  static const canViewAllTransactions = 'canViewAllTransactions';
  static const canViewOwnTransactions = 'canViewOwnTransactions';
  static const canUploadReceipt = 'canUploadReceipt';
  static const canViewLimitedDashboard = 'canViewLimitedDashboard';
  static const canViewWalletBalance = 'canViewWalletBalance';
  static const canManageWallet = 'canManageWallet';
  static const canManageEmployees = 'canManageEmployees';
  static const canInviteEmployees = 'canInviteEmployees';
  static const canRemoveEmployees = 'canRemoveEmployees';
  static const canMoveEmployeeDivision = 'canMoveEmployeeDivision';
  static const canManageInventory = 'canManageInventory';
  static const canManageCatalog = 'canManageCatalog';
  static const canApproveTransaction = 'canApproveTransaction';
  static const canRejectTransaction = 'canRejectTransaction';
  static const canExportReport = 'canExportReport';
  static const canViewReports = 'canViewReports';
  static const canViewProfit = 'canViewProfit';
  static const canViewAnalytics = 'canViewAnalytics';
  static const canViewAuditLog = 'canViewAuditLog';
  static const canManageBusinessSettings = 'canManageBusinessSettings';
  static const canManageSecuritySettings = 'canManageSecuritySettings';
  static const canAccessBranchData = 'canAccessBranchData';
  static const canAccessDivisionData = 'canAccessDivisionData';
  static const canViewStaffPerformance = 'canViewStaffPerformance';

  static const all = <String>[
    canCreateTransaction,
    canEditTransaction,
    canDeleteTransaction,
    canViewAllTransactions,
    canViewOwnTransactions,
    canUploadReceipt,
    canViewLimitedDashboard,
    canViewWalletBalance,
    canManageWallet,
    canManageEmployees,
    canInviteEmployees,
    canRemoveEmployees,
    canMoveEmployeeDivision,
    canManageInventory,
    canManageCatalog,
    canApproveTransaction,
    canRejectTransaction,
    canExportReport,
    canViewReports,
    canViewProfit,
    canViewAnalytics,
    canViewAuditLog,
    canManageBusinessSettings,
    canManageSecuritySettings,
    canAccessBranchData,
    canAccessDivisionData,
    canViewStaffPerformance,
  ];
}

class PermissionPolicy {
  const PermissionPolicy._();

  static const _routePermissions = <String, List<String>>{
    '/transaction/add': <String>[PermissionKeys.canCreateTransaction],
    '/history': <String>[
      PermissionKeys.canViewAllTransactions,
      PermissionKeys.canViewOwnTransactions,
    ],
    '/analytics': <String>[PermissionKeys.canViewAnalytics],
    '/analytics/overview': <String>[PermissionKeys.canViewAnalytics],
    '/analytics/financial': <String>[PermissionKeys.canViewProfit],
    '/analytics/insights': <String>[PermissionKeys.canViewAnalytics],
    '/analytics/export': <String>[PermissionKeys.canExportReport],
    '/analytics/score': <String>[PermissionKeys.canViewAnalytics],
    '/settings/team': <String>[PermissionKeys.canManageEmployees],
    '/settings/activity-log': <String>[PermissionKeys.canViewAuditLog],
    '/settings/security': <String>[PermissionKeys.canManageSecuritySettings],
    '/settings/categories': <String>[PermissionKeys.canManageBusinessSettings],
    '/wallets': <String>[PermissionKeys.canViewWalletBalance],
    '/inventory/overview': <String>[PermissionKeys.canManageInventory],
    '/catalog': <String>[PermissionKeys.canManageCatalog],
  };

  static List<String> resolvePermissions({
    required String role,
    required List<String> explicitPermissions,
  }) {
    if (role.toLowerCase() == 'owner') {
      return PermissionKeys.all;
    }

    final resolved = <String>{
      ..._templateForRole(role),
      ...explicitPermissions,
    };
    resolved
        .removeWhere((permission) => !PermissionKeys.all.contains(permission));
    return resolved.toList(growable: false);
  }

  static bool canAccessRoute({
    required String route,
    required String role,
    required List<String> permissions,
    required String memberStatus,
  }) {
    if (!_isActiveStatus(memberStatus)) return false;
    if (role.toLowerCase() == 'owner') return true;

    final requiredPermissions = _requiredPermissionsForRoute(route);
    if (requiredPermissions.isEmpty) return true;

    return requiredPermissions.any(permissions.contains);
  }

  static bool hasPermission(List<String> permissions, String permission) {
    return permissions.contains(permission);
  }

  static List<String> _requiredPermissionsForRoute(String route) {
    final normalized = route.split('?').first;
    if (normalized.startsWith('/transaction/detail/')) {
      return const <String>[
        PermissionKeys.canViewAllTransactions,
        PermissionKeys.canViewOwnTransactions,
      ];
    }
    if (normalized.startsWith('/transaction/') &&
        normalized.endsWith('/edit')) {
      return const <String>[PermissionKeys.canEditTransaction];
    }

    return _routePermissions[normalized] ?? const <String>[];
  }

  static List<String> _templateForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const <String>[
          PermissionKeys.canCreateTransaction,
          PermissionKeys.canEditTransaction,
          PermissionKeys.canViewAllTransactions,
          PermissionKeys.canViewWalletBalance,
          PermissionKeys.canManageEmployees,
          PermissionKeys.canInviteEmployees,
          PermissionKeys.canManageInventory,
          PermissionKeys.canManageCatalog,
          PermissionKeys.canViewAnalytics,
          PermissionKeys.canExportReport,
        ];
      case 'finance':
        return const <String>[
          PermissionKeys.canCreateTransaction,
          PermissionKeys.canEditTransaction,
          PermissionKeys.canViewAllTransactions,
          PermissionKeys.canViewWalletBalance,
          PermissionKeys.canViewAnalytics,
          PermissionKeys.canExportReport,
        ];
      case 'cashier':
        return const <String>[
          PermissionKeys.canCreateTransaction,
          PermissionKeys.canViewOwnTransactions,
          PermissionKeys.canUploadReceipt,
          PermissionKeys.canViewLimitedDashboard,
        ];
      case 'inventory':
      case 'inventory staff':
        return const <String>[
          PermissionKeys.canManageInventory,
          PermissionKeys.canViewReports,
        ];
      case 'sales':
        return const <String>[
          PermissionKeys.canCreateTransaction,
          PermissionKeys.canViewOwnTransactions,
          PermissionKeys.canUploadReceipt,
          PermissionKeys.canViewLimitedDashboard,
        ];
      case 'manager':
        return const <String>[
          PermissionKeys.canAccessDivisionData,
          PermissionKeys.canApproveTransaction,
          PermissionKeys.canRejectTransaction,
          PermissionKeys.canViewAnalytics,
          PermissionKeys.canViewStaffPerformance,
        ];
      case 'auditor':
      case 'viewer':
        return const <String>[
          PermissionKeys.canViewReports,
          PermissionKeys.canViewAuditLog,
        ];
      case 'secretary':
        return const <String>[
          PermissionKeys.canCreateTransaction,
          PermissionKeys.canViewOwnTransactions,
          PermissionKeys.canUploadReceipt,
        ];
      default:
        return const <String>[PermissionKeys.canViewLimitedDashboard];
    }
  }

  static bool _isActiveStatus(String status) {
    final cleanStatus = status.toLowerCase();
    return cleanStatus == 'active' || cleanStatus == 'used';
  }
}
