# CoreBusiness Advanced Production Readiness Audit

Date: 2026-05-26

## Scope Implemented In This Slice

Phase 1 was prioritized because it protects every later feature:

1. Permission matrix foundation.
2. Role and permission based route guard.
3. Firestore Security Rules refinement.
4. Immutable audit log foundation.

## Deferred By Design

The following items are intentionally not implemented in this slice because each
requires a dedicated feature module, data model, and test plan:

- Offline-first sync queue.
- Approval workflow.
- Customer and supplier management.
- Invoice, receivable, and payable.
- Recurring transactions.
- Export reports.
- Backup and restore.
- Observability and Crashlytics.
- Cloud Functions migration.
- Wallet health check and balance repair.

## Production Risks Found

- Client-side wallet updates remain a consistency risk until approval and wallet
  finalization move to a trusted backend or stricter transaction service.
- Existing members may still carry legacy permissions such as `add_transaction`.
  Route guard now uses role templates, and rules include role fallback, but a
  future migration should backfill canonical permission keys.
- GoRouter redirect is synchronous, so permission checks use cached member
  access. The shell now listens to member snapshots, but backend rules remain
  the final enforcement layer.
- Team management still performs Firestore writes in a presentation page. It
  should become a layered feature with repository and usecases.
- Offline-first, approval workflow, recurring generation, and heavy export are
  risky if implemented purely client-side without idempotency and server-side
  support.

## Next Recommended Phase

Phase 2 should implement approval workflow before offline sync. Offline sync
without approval semantics can create wallet/report inconsistency when queued
transactions are replayed.
