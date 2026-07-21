# Implementation plan

- Status: Public source release complete; deployment and pilot pending
- Last updated: 2026-07-20

This is the durable project plan. Update it when a phase changes state so work can
resume across sessions without reconstructing decisions from chat history.

## Completed

1. Establish the free-product boundary and deliberately constrained feature set.
2. Install Ruby 3.4, Rails 8.1, and PostgreSQL locally and scaffold `gk-ruby`.
3. Record the Rails/PostgreSQL and single-database architecture decisions.
4. Implement tenant-scoped administrator authentication, invitations, sessions, and
   administrator deactivation.
5. Implement immutable form versions, one draft, one public version, explicit
   publishing, preview, conflict detection, field controls, and theme controls.
6. Implement the anonymous public form, validation, stable references, simulated
   attachment metadata, abuse controls, and the 10,000-per-30-day allowance.
7. Implement scoped submission review, workflow status, deletion, CSV export, audit
   history, and automatic retention deletion.
8. Add security headers, CSP, request-size enforcement, privacy-safe IP digests,
   production configuration, readiness checks, durable jobs/cache, and runbooks.
9. Add Minitest, executable Gherkin specifications, headless browser flows, automated
   Axe accessibility rules, security scans, dependency audits, and CI.
10. Publish the reviewed initial commit to the requested public GitHub repository.

## Next: required before a public pilot

11. Select a Rails host and transactional email provider; configure secrets and HTTPS.
12. Demonstrate a provider-specific encrypted backup and isolated restore.
13. Run manual keyboard and screen-reader smoke tests in supported browsers.
14. Verify real SMTP delivery, monitoring alerts, queue scheduling, and incident contacts.
15. Pilot with one or two organizations and measure support time, error rate, abuse,
    database growth, queue health, and submission volume without analyzing complaint
    contents.

## Deferred by design

- Real file retention, malware scanning, and retrieval
- Open self-service signup, billing, custom domains, and white-labeling
- Conditional logic, multi-page flows, analytics, APIs, and case-management features
- MFA until the pre-broad-launch review; it remains a documented residual risk

## Stop or redesign triggers

Pause expansion if free-user support becomes bespoke consulting, abuse controls create
material harm, privacy/legal review cannot be completed, operating cost is not bounded,
or organizations require case-management behavior outside the narrow complaint-form
promise.
