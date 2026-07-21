# ADR 0002: Use one PostgreSQL database

- Status: Accepted
- Date: 2026-07-20

## Context

Rails 8 generates separate primary, cache, queue, and cable databases. That
isolation is useful at larger scale, but many managed hosts charge per database or
make creation of additional logical databases awkward. The product's early workload
is modest: complaint submissions, transactional administrator email, a daily
retention job, and cache-backed request throttles. It exposes no real-time features.

The operating goal is a reliable free product with a small maintenance and hosting
footprint. Backups and restores should cover the complete service without coordinating
four data stores.

## Decision

Use one PostgreSQL database for application records, Solid Queue, and Solid Cache.
Install the Solid Queue and Solid Cache tables through normal application migrations.
Do not configure a separate Solid Cable database while the product has no real-time
features.

This is an explicitly supported configuration for both Solid Queue and Solid Cache.
PostgreSQL remains the only stateful runtime dependency. The database, SMTP service,
and application container are therefore sufficient for a deployment.

## Consequences

- One database URL, backup, restore, connection pool, and bill are required.
- Queue jobs and shared throttling remain durable across web process restarts.
- A database outage affects every stateful function at once.
- Queue/cache traffic shares connections and I/O with complaint submissions.
- Restoring a database can restore queued work, so operators must check for duplicate
  emails or jobs before starting workers.
- Action Cable uses an in-process adapter only as dormant framework configuration;
  real-time product behavior must not depend on it.

## Revisit triggers

Move queue or cache data to a separate database when measurement shows connection or
I/O contention, job volume becomes operationally independent, failure isolation is
needed, or a real-time feature is approved. Such a move must preserve one public form
version and tenant boundaries and must add provider-specific backup procedures.
