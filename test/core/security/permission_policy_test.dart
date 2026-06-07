import 'package:flutter_test/flutter_test.dart';
import 'package:corebussiness/core/security/permission_policy.dart';

void main() {
  group('PermissionPolicy', () {
    test('owner receives all permissions', () {
      final permissions = PermissionPolicy.resolvePermissions(
        role: 'owner',
        explicitPermissions: const <String>[],
      );

      expect(permissions, contains(PermissionKeys.canManageEmployees));
      expect(permissions, contains(PermissionKeys.canApproveTransaction));
      expect(permissions, contains(PermissionKeys.canManageSecuritySettings));
      expect(permissions.length, PermissionKeys.all.length);
    });

    test('cashier can create transactions but cannot view profit', () {
      final permissions = PermissionPolicy.resolvePermissions(
        role: 'cashier',
        explicitPermissions: const <String>[],
      );

      expect(permissions, contains(PermissionKeys.canCreateTransaction));
      expect(permissions, contains(PermissionKeys.canViewOwnTransactions));
      expect(permissions, isNot(contains(PermissionKeys.canViewProfit)));
      expect(permissions, isNot(contains(PermissionKeys.canManageEmployees)));
    });

    test('explicit permissions extend role template without duplicates', () {
      final permissions = PermissionPolicy.resolvePermissions(
        role: 'finance',
        explicitPermissions: const <String>[
          PermissionKeys.canApproveTransaction,
          PermissionKeys.canApproveTransaction,
        ],
      );

      expect(permissions, contains(PermissionKeys.canCreateTransaction));
      expect(permissions, contains(PermissionKeys.canApproveTransaction));
      expect(permissions.length, permissions.toSet().length);
    });

    test('removed members cannot access workspace routes', () {
      final result = PermissionPolicy.canAccessRoute(
        route: '/settings/team',
        role: 'owner',
        permissions: PermissionKeys.all,
        memberStatus: 'removed',
      );

      expect(result, isFalse);
    });

    test('route access requires matching permission', () {
      expect(
        PermissionPolicy.canAccessRoute(
          route: '/settings/team',
          role: 'cashier',
          permissions: PermissionPolicy.resolvePermissions(
            role: 'cashier',
            explicitPermissions: const <String>[],
          ),
          memberStatus: 'active',
        ),
        isFalse,
      );
      expect(
        PermissionPolicy.canAccessRoute(
          route: '/transaction/add',
          role: 'cashier',
          permissions: PermissionPolicy.resolvePermissions(
            role: 'cashier',
            explicitPermissions: const <String>[],
          ),
          memberStatus: 'active',
        ),
        isTrue,
      );
    });
  });
}
