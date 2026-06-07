import 'package:flutter_test/flutter_test.dart';
import 'package:corebussiness/features/onboarding/domain/entities/smart_setup_policy.dart';

void main() {
  group('SmartSetupPolicy', () {
    test('routes initial usage choices to the correct setup flow', () {
      expect(
        SmartSetupPolicy.resolveInitialFlow('owner_solo'),
        SmartSetupFlow.owner,
      );
      expect(
        SmartSetupPolicy.resolveInitialFlow('owner_team'),
        SmartSetupFlow.ownerTeamPosition,
      );
      expect(
        SmartSetupPolicy.resolveInitialFlow('staff'),
        SmartSetupFlow.staff,
      );
      expect(
        SmartSetupPolicy.resolveInitialFlow('personal'),
        SmartSetupFlow.personal,
      );
    });

    test('recommends modules from business field and size without duplicates',
        () {
      final features = SmartSetupPolicy.recommendFeatures(
        businessField: 'f_and_b',
        businessSize: 'small',
        fnbNeedsRawInventory: true,
      );

      expect(
          features,
          containsAll(<String>[
            'dashboard',
            'transactions',
            'wallets',
            'analytics',
            'notifications',
            'settings',
            'employees',
            'approval',
            'reports',
            'catalog',
            'inventory',
            'scan_receipt_ai',
            'manual_receipt',
          ]));
      expect(features.length, features.toSet().length);
    });

    test('keeps solo business menu simple and hides team complexity', () {
      final menu = SmartSetupPolicy.menuForBusinessSize('solo');

      expect(
          menu,
          containsAll(<String>[
            'dashboard',
            'transactions',
            'wallets',
            'receipts',
            'analytics',
            'schedule',
            'settings',
          ]));
      expect(menu, isNot(contains('employees')));
      expect(menu, isNot(contains('divisions')));
      expect(menu, isNot(contains('approval')));
      expect(menu, isNot(contains('branches')));
    });

    test('returns role dashboard menu with cashier visibility limits', () {
      final menu = SmartSetupPolicy.menuForRole('cashier');

      expect(
          menu,
          containsAll(<String>[
            'add_transaction',
            'scan_receipt',
            'manual_receipt',
            'my_history',
            'notifications',
          ]));
      expect(menu, isNot(contains('profit_loss')));
      expect(menu, isNot(contains('employees')));
    });

    test('calculates setup score and next actions from completed checklist',
        () {
      final score = SmartSetupPolicy.calculateSetupScore(
        const SmartSetupChecklist(
          hasBusinessProfile: true,
          hasOwnerRole: true,
          hasInitialWallet: true,
          hasInitialCategories: true,
          hasSelectedFeatures: true,
          hasLogo: false,
          hasEmployees: false,
          hasSecurityPin: false,
        ),
      );

      expect(score.percent, 62);
      expect(score.completedItems, 5);
      expect(score.totalItems, 8);
      expect(
          score.ctas,
          containsAll(<String>[
            'Upload logo',
            'Tambah karyawan',
            'Aktifkan PIN',
          ]));
    });

    test('validates staff invite status and email ownership', () {
      expect(
        SmartSetupPolicy.validateInvite(
          inviteEmail: 'staff@core.test',
          currentUserEmail: 'staff@core.test',
          status: 'active',
          expiresAt: DateTime(2026, 5, 27),
          now: DateTime(2026, 5, 26),
        ),
        InviteValidationResult.valid,
      );

      expect(
        SmartSetupPolicy.validateInvite(
          inviteEmail: 'other@core.test',
          currentUserEmail: 'staff@core.test',
          status: 'active',
          expiresAt: DateTime(2026, 5, 27),
          now: DateTime(2026, 5, 26),
        ),
        InviteValidationResult.emailMismatch,
      );

      expect(
        SmartSetupPolicy.validateInvite(
          inviteEmail: 'staff@core.test',
          currentUserEmail: 'staff@core.test',
          status: 'used',
          expiresAt: DateTime(2026, 5, 27),
          now: DateTime(2026, 5, 26),
        ),
        InviteValidationResult.alreadyUsed,
      );
    });
  });
}
