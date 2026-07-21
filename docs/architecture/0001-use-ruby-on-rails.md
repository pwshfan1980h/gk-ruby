# ADR 0001: Use Ruby on Rails 8 and PostgreSQL

- Status: Accepted
- Date: 2026-07-20
- Owners: gk-ruby maintainers

## Context

gk-ruby is a production-oriented complaint-form product. An organization configures
one public form, edits a private draft, publishes it atomically, and reviews
submissions made against the exact version that was public at submission time.

The product is deliberately constrained so that it can be inexpensive to operate
and dependable for organizations with modest requirements. Its difficult problems
are authorization, tenant isolation, dynamic validation, relational data integrity,
publishing transactions, retention, auditability, and secure administration. It is
not primarily a content site or a highly interactive client-side application.

The principal alternative considered was a TypeScript application using Next.js on
Vercel with separately selected database, authentication, job, email, and storage
services.

## Decision

Use Ruby on Rails 8.1 with PostgreSQL as a modular monolith.

Prefer Rails 8 facilities and conventions when they fit the requirement:

- Active Record migrations, validations, associations, transactions, and locking
- the Rails authentication generator as the identity foundation
- Action Controller protections, signed/encrypted cookies, and rate limiting
- Hotwire (Turbo and Stimulus) for focused browser interactivity
- Active Job with Solid Queue for asynchronous work when needed
- Solid Cache and Solid Cable unless scale or operating evidence justifies replacing them
- Action Mailer for transactional administrator email
- the generated Dockerfile, Thruster, health endpoint, and Kamal-compatible deployment
- Minitest, system tests, RuboCop, Brakeman, and dependency auditing in CI

PostgreSQL is the system of record. Database constraints must enforce important
invariants in addition to Rails validations, particularly organization ownership,
unique slugs, and the single-draft/single-published-version rules.

## Why Rails fits

1. **The application is workflow- and data-centric.** Rails provides one coherent
   model for forms, versions, fields, submissions, administrators, audit events, and
   retention jobs.
2. **Publishing needs strong consistency.** Active Record and PostgreSQL make the
   transition from one published form version to another a testable database
   transaction rather than a distributed sequence of service calls.
3. **A small team can own the whole system.** Authentication, HTML rendering,
   validation, mail, jobs, database migrations, and security defaults live in one
   application with fewer integration boundaries.
4. **Server-rendered HTML is a feature here.** Public forms and administrative CRUD
   benefit from resilient, accessible HTML. Hotwire adds reorder, preview, and
   inline-edit interactions without requiring a separate frontend application.
5. **Deployment remains portable.** The application is a conventional container
   backed by PostgreSQL. It can run on a managed container platform or be
   self-hosted without depending on one frontend cloud vendor.
6. **Costs are predictable at modest scale.** A continuously running application
   and PostgreSQL database are easy to size, observe, back up, and cap for a free
   product.
7. **Rails 8 reduces infrastructure sprawl.** Its authentication foundation,
   database-backed job/cache/cable options, Dockerfile, and deployment tooling cover
   much of this product's initial operational footprint.

## Why not Next.js on Vercel

Next.js and Vercel are capable of building this product and would be preferred if
the owning team were already deeply standardized on React/TypeScript or if the
product required a highly interactive frontend. For this product they would not
remove the need for PostgreSQL, tenancy, authorization, retention, auditing, email,
or background processing. Those concerns would generally span more providers and
application boundaries.

Vercel's deployment and preview experience is excellent, but deployment convenience
alone does not outweigh Rails' cohesion for this application's dominant risks.

## Consequences

### Positive

- Business rules have a clear home in models and service objects.
- Public and admin interfaces share validation, authorization, and rendering.
- Fewer external services are required for the initial release.
- Production and self-hosted installations can use the same container artifact.
- The application can add a React island later without replacing Rails.

### Costs and risks

- The team must maintain current Ruby and Rails expertise.
- Rails needs a long-running application host; Vercel is not the intended runtime.
- Rich drag-and-drop behavior may require more Stimulus work than a React-first UI.
- A centrally hosted free service is not literally maintenance-free for its owner;
  monitoring, backups, patching, privacy operations, and support boundaries remain.

## Guardrails

- Do not introduce React or a separate JSON API merely for fashion or familiarity.
- Do not place significant business rules only in controllers or browser code.
- Keep tenant scoping explicit and covered by authorization tests.
- Use database transactions and constraints for cross-record invariants.
- Prefer framework defaults, but document every security-sensitive deviation.
- Simulated attachments may retain sanitized metadata only. The interface must state
  that file contents are not retained.

## Revisit this decision if

- the owning engineering team standardizes on another supported stack and cannot
  sustainably operate Ruby;
- measured usage requires a frontend interaction model that Hotwire cannot serve
  cleanly;
- platform or compliance requirements prohibit the chosen Rails hosting model; or
- operational evidence shows that another architecture materially lowers total cost
  without weakening security, privacy, or maintainability.

Any change requires a new ADR; this document should not be silently rewritten to
make a later decision appear inevitable.

## References

- [Ruby on Rails 8.0 release notes](https://guides.rubyonrails.org/8_0_release_notes.html)
- [Rails security guide](https://guides.rubyonrails.org/security.html)
- [Active Record and PostgreSQL](https://guides.rubyonrails.org/active_record_postgresql.html)
- [Rails getting started and deployment](https://guides.rubyonrails.org/getting_started.html)
- [Next.js on Vercel](https://vercel.com/frameworks/nextjs)
