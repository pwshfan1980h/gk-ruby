# Living documentation

This directory records why gk-ruby exists, what it promises, its important risks,
and how it should be operated. Documentation changes are part of feature work rather
than an end-of-project cleanup task.

## Product and behavior

- [Product specification](product-specification.md) defines scope, limits,
  non-goals, and release gates.
- [Implementation plan](implementation-plan.md) records completed, active, pilot,
  and deferred work across sessions.
- [Free-product strategy](product-strategy.md) records why a bounded free utility may
  be worthwhile and the signals that should stop or reshape it.
- [`features/`](../features) contains executable Gherkin examples of user-visible
  behavior. Cucumber runs these examples in CI so they cannot silently drift from
  the application.

## Architecture and security

- [ADR 0001](architecture/0001-use-ruby-on-rails.md) records why Rails 8 and
  PostgreSQL were selected and when that choice should be reconsidered.
- [ADR 0002](architecture/0002-use-one-postgresql-database.md) records why the
  initial production topology uses one PostgreSQL database.
- [Threat model](threat-model.md) records protected assets, trust boundaries,
  threats, controls, deferred controls, and review triggers.

## Operations

- [Operations runbook](operations.md) covers the provider-neutral production
  topology, configuration, deployment, backup/restore, monitoring, privacy
  operations, incidents, and rollback.

## Documentation rule

When behavior, limits, data lifecycle, architecture, or operational responsibility
changes, update the corresponding document and executable feature in the same
change. Gherkin scenarios should describe observable business behavior and normally
contain three to five steps; low-level edge cases remain in Minitest.
