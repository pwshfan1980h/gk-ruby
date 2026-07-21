# Operations runbook

- Status: Required before deployment
- Last updated: 2026-07-20

This runbook is provider-neutral. A specific Rails host has deliberately not been
selected yet. Confirm provider-specific database, email, backup, and restore
procedures before launch.

## Production topology

- One immutable Rails container built from the repository Dockerfile
- One PostgreSQL database containing application, Solid Queue, and Solid Cache tables
- One HTTPS hostname
- One transactional SMTP provider
- Solid Queue scheduler and worker, initially supervised in the web container
- Platform log collection and error/availability alerting

The database contains organizations, identities, form versions, submissions, audit
events, queued work, and shared cache data. Database loss is the principal data-loss
risk. See ADR 0002 for the deliberate single-database tradeoff.

## Required configuration

Copy names—not values—from `.env.example` into the deployment secret/configuration
system. Never deploy an `.env` file or commit credential values.

Required before accepting traffic:

- `APP_HOST` names the HTTPS host used in password and invitation links.
- `RAILS_MASTER_KEY` is available only to the runtime and deployment system.
- `DATABASE_URL` uses TLS where the provider supports it.
- SMTP credentials can send password resets and administrator invitations.
- `FORCE_SSL` and `ASSUME_SSL` remain enabled behind the trusted TLS proxy.
- The host's request-body limit is at most 12 MB, matching the application limit.

## Deployment sequence

1. Build one container revision and run tests/scans against that commit.
2. Back up the primary database before a risky or destructive migration.
3. Run `bin/rails db:prepare` as a release task with only one concurrent executor.
4. Deploy the already-built container; do not rebuild separately per web process.
5. Check `/up` for process health and `/ready` for PostgreSQL readiness.
6. Sign in, open an organization dashboard, preview a draft, and open its public form.
7. Confirm the Solid Queue worker and recurring scheduler are running.
8. Record the commit SHA and migration version in the deployment log.

Migrations must remain backward-compatible with the preceding application revision
during rolling deployments. Use expand/migrate/contract changes when removing or
renaming stored data.

## Backup policy

Minimum policy for the database:

- encrypted daily backups;
- point-in-time recovery when offered by the provider;
- at least 14 days of backup history, reconciled with contractual/privacy needs;
- access restricted to designated operators;
- quarterly restore tests into an isolated, access-controlled environment.

Queue and cache records are included in the same backup. Before workers start after a
restore, the operator must determine whether restored jobs could repeat email or
retention work. Expired cache entries may be cleared after restoration.

### Restore test

1. Create an isolated PostgreSQL database with no public application access.
2. Restore a selected backup.
3. Run migrations using the matching application revision, then the candidate revision.
4. Verify row counts for organizations, memberships, forms, versions, submissions,
   and audit events.
5. Verify composite foreign keys and the one-draft/one-published constraints.
6. Sign in using a designated test account and open a known submission.
7. Destroy the isolated restore after recording the result; do not retain it as an
   undocumented extra copy of complaint data.

## Routine checks

Daily automated checks should cover:

- `/up` and `/ready` availability;
- HTTP error rate and request latency;
- PostgreSQL connections, storage, replication, and backup success;
- queue depth, job failures, and scheduler heartbeat;
- SMTP delivery failures;
- throttled submission and authentication rates;
- retention deletions and unexpected deletion failures.

Review dependency updates at least monthly and critical Ruby/Rails/PostgreSQL
security notices promptly. Apply supported patch releases after CI and smoke tests.

## Privacy operations

- Complaint contents must not appear in logs, analytics, error payloads, or audit metadata.
- A verified organization administrator may export or delete its own submissions.
- `SubmissionRetentionJob` deletes expired complaint records daily in bounded batches.
- The retention audit event retains only the reference number and organization context.
- Changes to retention apply to new submissions; changing existing deadlines requires
  an explicit, separately reviewed migration or operation.
- Never use complainant answers or contact details for sales or product analytics.

## Incident outline

1. Contain: revoke exposed credentials, disable affected endpoints or tenant access,
   and preserve relevant content-free security logs.
2. Assess: determine affected organizations, data classes, time window, and access path.
3. Recover: patch, rotate, restore if necessary, and verify tenant boundaries and jobs.
4. Notify: follow the product owner's contractual, privacy, and legal incident process.
5. Learn: document the timeline and controls, add regression coverage, and update the
   threat model and this runbook.

Do not copy complaint contents into tickets or chat while handling an incident.

## Rollback

- Roll back application containers only when the database remains compatible.
- Never reverse a destructive migration merely to make an old container boot.
- For a failed additive release, restore the prior container and leave additive schema
  in place until a reviewed cleanup release.
- For corrupt data, stop writes and follow the restore process; do not improvise direct
  production edits without a recorded query and peer review.
