enum SmartSetupFlow {
  owner,
  ownerTeamPosition,
  staff,
  personal,
  unknown,
}

enum InviteValidationResult {
  valid,
  emailMismatch,
  expired,
  alreadyUsed,
  removed,
  suspended,
  inactive,
}

class SmartSetupChecklist {
  final bool hasBusinessProfile;
  final bool hasOwnerRole;
  final bool hasInitialWallet;
  final bool hasInitialCategories;
  final bool hasSelectedFeatures;
  final bool hasLogo;
  final bool hasEmployees;
  final bool hasSecurityPin;

  const SmartSetupChecklist({
    required this.hasBusinessProfile,
    required this.hasOwnerRole,
    required this.hasInitialWallet,
    required this.hasInitialCategories,
    required this.hasSelectedFeatures,
    required this.hasLogo,
    required this.hasEmployees,
    required this.hasSecurityPin,
  });
}

class SmartSetupScore {
  final int percent;
  final int completedItems;
  final int totalItems;
  final List<String> ctas;

  const SmartSetupScore({
    required this.percent,
    required this.completedItems,
    required this.totalItems,
    required this.ctas,
  });
}

class SmartSetupPolicy {
  const SmartSetupPolicy._();

  static SmartSetupFlow resolveInitialFlow(String usageType) {
    switch (usageType) {
      case 'owner_solo':
        return SmartSetupFlow.owner;
      case 'owner_team':
        return SmartSetupFlow.ownerTeamPosition;
      case 'staff':
      case 'staff_direct':
        return SmartSetupFlow.staff;
      case 'personal':
        return SmartSetupFlow.personal;
      default:
        return SmartSetupFlow.unknown;
    }
  }

  static List<String> recommendFeatures({
    required String businessField,
    required String businessSize,
    bool fnbNeedsRawInventory = false,
    bool fnbHasMenu = false,
    bool fnbHasCashier = false,
    bool fnbNeedsDailyReport = false,
    bool retailNeedsInventory = false,
    bool retailHasPhysicalProducts = false,
    bool retailHasBarcode = false,
    bool serviceNeedsBooking = false,
    bool serviceNeedsInvoice = false,
    bool olsNeedsAdminFee = false,
    bool olsNeedsShippingCost = false,
  }) {
    final features = <String>{
      'dashboard',
      'transactions',
      'wallets',
      'analytics',
      'notifications',
      'settings',
      'scan_receipt_ai',
      'manual_receipt',
    };

    if (businessSize != 'solo') {
      features.add('employees');
    }

    if (_isSmallOrLarger(businessSize)) {
      features.addAll(<String>{
        'approval',
        'reports',
        'audit_log',
      });
    }

    if (_isMediumOrLarger(businessSize)) {
      features.addAll(<String>{
        'divisions',
        'security_center',
      });
    }

    if (businessSize == 'growing' || businessSize == 'enterprise') {
      features.addAll(<String>{
        'branches',
        'advanced_permissions',
      });
    }

    switch (businessField) {
      case 'f_and_b':
        features.add('catalog');
        features.add('daily_sales_report');
        if (fnbNeedsRawInventory) {
          features.add('inventory');
        }
        if (fnbHasCashier || businessSize != 'solo') {
          features.add('cashier_role');
        }
        break;
      case 'retail':
        features.add('catalog');
        features.add('stock_warning');
        if (retailNeedsInventory || retailHasPhysicalProducts) {
          features.add('inventory');
        }
        if (retailHasBarcode) {
          features.add('barcode_sku');
        }
        break;
      case 'jasa':
        features.add('service_catalog');
        features.add('customers');
        if (serviceNeedsBooking) {
          features.add('schedule');
        }
        if (serviceNeedsInvoice) {
          features.add('invoice');
          features.add('reports');
        }
        break;
      case 'online_shop':
        features.addAll(<String>{
          'marketplace_sales',
          'catalog',
          'inventory',
          'profit_per_platform',
        });
        if (olsNeedsAdminFee) {
          features.add('admin_fee_tracking');
        }
        if (olsNeedsShippingCost) {
          features.add('shipping_cost');
        }
        break;
      default:
        features.add('reports');
        break;
    }

    return features.toList(growable: false);
  }

  static List<String> menuForBusinessSize(String businessSize) {
    switch (businessSize) {
      case 'solo':
        return const <String>[
          'dashboard',
          'transactions',
          'wallets',
          'receipts',
          'analytics',
          'schedule',
          'settings',
        ];
      case 'micro':
        return const <String>[
          'dashboard',
          'transactions',
          'wallets',
          'receipts',
          'catalog',
          'inventory',
          'employees',
          'notifications',
          'analytics',
          'settings',
        ];
      case 'small':
        return const <String>[
          'dashboard',
          'transactions',
          'wallets',
          'catalog',
          'inventory',
          'employees',
          'divisions',
          'approval',
          'analytics',
          'reports',
          'notifications',
          'schedule',
          'settings',
        ];
      case 'medium':
        return const <String>[
          'executive_dashboard',
          'finance',
          'transactions',
          'wallets',
          'products',
          'inventory',
          'employees',
          'divisions',
          'approval_center',
          'reports',
          'audit_logs',
          'notifications',
          'schedule',
          'security_center',
          'settings',
        ];
      case 'growing':
        return const <String>[
          'business_overview',
          'branch_management',
          'division_management',
          'finance_center',
          'transaction_center',
          'approval_center',
          'inventory_center',
          'product_center',
          'employee_center',
          'reports_center',
          'audit_compliance',
          'notifications',
          'security_center',
          'settings',
        ];
      case 'enterprise':
        return const <String>[
          'executive_overview',
          'branches',
          'departments',
          'employees',
          'finance',
          'transactions',
          'inventory',
          'products',
          'approvals',
          'reports',
          'audit_logs',
          'security',
          'system_settings',
        ];
      default:
        return menuForBusinessSize('solo');
    }
  }

  static List<String> menuForRole(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return const <String>[
          'dashboard',
          'transactions',
          'wallets',
          'scan_receipt',
          'manual_receipt',
          'analytics',
          'reports',
          'employees',
          'divisions',
          'inventory',
          'catalog',
          'approval',
          'activity_log',
          'notifications',
          'settings',
          'security',
        ];
      case 'admin':
        return const <String>[
          'dashboard',
          'transactions',
          'wallets',
          'analytics',
          'employees',
          'notifications',
          'settings',
        ];
      case 'finance':
        return const <String>[
          'finance_dashboard',
          'transactions',
          'wallets',
          'categories',
          'reports',
          'finance_approval',
          'notifications',
        ];
      case 'secretary':
        return const <String>[
          'dashboard',
          'add_transaction',
          'manual_receipt',
          'schedule',
          'documents',
          'notifications',
          'activity_history',
        ];
      case 'cashier':
        return const <String>[
          'add_transaction',
          'scan_receipt',
          'manual_receipt',
          'my_history',
          'notifications',
        ];
      case 'inventory':
      case 'inventory staff':
        return const <String>[
          'inventory',
          'products',
          'stock_in',
          'stock_out',
          'low_stock',
          'notifications',
        ];
      case 'sales':
        return const <String>[
          'sales',
          'add_transaction',
          'customers',
          'my_history',
          'notifications',
        ];
      case 'manager':
        return const <String>[
          'division_dashboard',
          'division_transactions',
          'division_staff',
          'division_approval',
          'division_reports',
          'notifications',
        ];
      case 'viewer':
      case 'auditor':
        return const <String>[
          'dashboard',
          'reports',
          'activity_log',
          'notifications',
        ];
      default:
        return menuForRole('viewer');
    }
  }

  static SmartSetupScore calculateSetupScore(SmartSetupChecklist checklist) {
    final checks = <bool>[
      checklist.hasBusinessProfile,
      checklist.hasOwnerRole,
      checklist.hasInitialWallet,
      checklist.hasInitialCategories,
      checklist.hasSelectedFeatures,
      checklist.hasLogo,
      checklist.hasEmployees,
      checklist.hasSecurityPin,
    ];
    final completed = checks.where((item) => item).length;
    final ctas = <String>[
      if (!checklist.hasLogo) 'Upload logo',
      if (!checklist.hasEmployees) 'Tambah karyawan',
      if (!checklist.hasSecurityPin) 'Aktifkan PIN',
      if (!checklist.hasBusinessProfile) 'Lengkapi profil bisnis',
    ];

    return SmartSetupScore(
      percent: ((completed / checks.length) * 100).floor(),
      completedItems: completed,
      totalItems: checks.length,
      ctas: ctas,
    );
  }

  static InviteValidationResult validateInvite({
    required String inviteEmail,
    required String currentUserEmail,
    required String status,
    required DateTime? expiresAt,
    required DateTime now,
  }) {
    if (inviteEmail.trim().toLowerCase() !=
        currentUserEmail.trim().toLowerCase()) {
      return InviteValidationResult.emailMismatch;
    }

    switch (status.toLowerCase()) {
      case 'used':
        return InviteValidationResult.alreadyUsed;
      case 'removed':
        return InviteValidationResult.removed;
      case 'suspended':
        return InviteValidationResult.suspended;
      case 'inactive':
        return InviteValidationResult.inactive;
    }

    if (expiresAt != null && now.isAfter(expiresAt)) {
      return InviteValidationResult.expired;
    }

    return InviteValidationResult.valid;
  }

  static bool _isSmallOrLarger(String businessSize) {
    return const <String>{
      'small',
      'medium',
      'growing',
      'enterprise',
    }.contains(businessSize);
  }

  static bool _isMediumOrLarger(String businessSize) {
    return const <String>{
      'medium',
      'growing',
      'enterprise',
    }.contains(businessSize);
  }
}
