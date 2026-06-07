# Smart Business Setup Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden CoreBusiness Smart Business Setup so branching, role/menu policy, setup scoring, and security rules are explicit, testable, and production-ready.

**Architecture:** Move onboarding decisions into pure domain policy files, keep BLoC focused on state orchestration, and keep Firestore access behind data-layer boundaries over time. This slice avoids a risky full rewrite and gives the existing UI a stable domain contract.

**Tech Stack:** Flutter, Dart, BLoC, Firebase Auth, Cloud Firestore, Firebase Storage, flutter_test.

---

### Task 1: Smart Setup Domain Policy

**Files:**
- Create: `lib/features/onboarding/domain/entities/smart_setup_policy.dart`
- Test: `test/features/onboarding/domain/smart_setup_policy_test.dart`
- Modify: `lib/features/onboarding/presentation/bloc/smart_setup_bloc.dart`

- [ ] Write tests for usage branching, owner/staff/personal role policy, size menus, feature recommendations, and setup score.
- [ ] Run `flutter test test/features/onboarding/domain/smart_setup_policy_test.dart` and verify the missing file failure.
- [ ] Implement the pure Dart policy and keep Firebase out of domain.
- [ ] Run the targeted test and verify it passes.
- [ ] Replace duplicated recommendation logic in `SmartSetupBloc` with the policy.

### Task 2: Invite And Rules Hardening

**Files:**
- Modify: `firestore.rules`
- Modify: `lib/features/onboarding/presentation/bloc/smart_setup_bloc.dart`

- [ ] Add Firestore rules for `businesses/{businessId}/invites/{inviteId}`.
- [ ] Keep backwards-compatible `members/{email}` invite behavior during migration.
- [ ] Tighten transaction create rules to validate both snake_case and camelCase creator/business fields.
- [ ] Prevent non-owner member role escalation and owner deletion by non-owner.

### Task 3: Verification

**Files:**
- No production file ownership beyond touched files.

- [ ] Run `flutter test`.
- [ ] Run `flutter analyze`.
- [ ] Report remaining pre-existing analyzer warnings separately from new issues.
