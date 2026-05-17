# CoreBusiness Tasks

## P0 - Must Fix Before Production

- [x] Remove hard-coded Supabase key from `main.dart`.
- [x] Add API-key setup comments via `AppConfig`.
- [x] Align user entity/model with Supabase `profiles` schema.
- [x] Provide `AuthBloc` to `LoginPage`.
- [x] Fix DI registration for `AuthRepositoryImpl`.
- [x] Fix HomeBloc typed result folding.
- [x] Replace template counter widget test.
- [x] Guard workspace bootstrap RPC against cross-user calls.
- [ ] Run `flutter analyze` successfully after local Dart toolchain is healthy.
- [ ] Run `flutter test` successfully after local Dart toolchain is healthy.

## P1 - Make Core Features Fully Data-Backed

- [ ] Create `BusinessContextRepository` for active business.
- [ ] Replace transaction local storage with Supabase transaction data source.
- [ ] Replace home local summary with `get_dashboard_summary`.
- [ ] Connect wallet page to `wallets`.
- [ ] Connect catalog page to `products`.
- [ ] Connect inventory page to `inventory_items`.
- [ ] Connect team page to `business_members`.

## P2 - Runtime Resilience

- [ ] Add network timeout mapping and retry policy.
- [ ] Add optimistic write only where rollback is safe.
- [ ] Add refresh behavior after transaction submit.
- [ ] Add empty states for every data-backed page.
- [ ] Add destructive action confirmation dialogs.

## P3 - Maintainability

- [x] Replace legacy brand text with `CoreBusiness`.
- [ ] Create shared branded app bar.
- [ ] Consolidate duplicate transaction BLoC event/state files.
- [ ] Split large pages into focused widgets.
- [ ] Replace deprecated `withOpacity` calls with `withValues`.
- [ ] Remove unused imports.

## P4 - Test Coverage

- [ ] Auth repository tests.
- [ ] HomeBloc failure and refresh tests.
- [ ] TransactionBloc double-submit tests.
- [ ] Supabase mapping tests for transaction models.
- [ ] Golden/smoke tests for core navigation.
