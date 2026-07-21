# gk-ruby Threat Model

- Status: Living document
- Last updated: 2026-07-20

## Protected assets

- Complaint contents and submitter-provided personal information
- Administrator identities, sessions, and password-reset capabilities
- Organization form configuration and unpublished drafts
- Tenant boundaries
- Submission exports and audit history
- Availability of public submission forms

## Trust boundaries

- Anonymous public browser to the public form endpoint
- Authenticated administrator browser to organization-scoped administration
- Rails application to PostgreSQL
- Rails application to transactional email and monitoring providers
- Deployment system to production runtime and secrets

Real file storage is outside the initial boundary. Simulated attachments retain
metadata only, but incoming multipart requests are still untrusted and size-limited.

## Principal threats and controls

### Cross-tenant access

Threat: an administrator reads or changes another organization's form, submission,
export, membership, or audit data by changing a URL or submitted identifier.

Controls:

- resolve private records through the current membership's organization scope;
- do not authorize using organization identifiers supplied by the browser;
- carry organization ownership on core records and enforce composite foreign keys;
- cover every private controller and export with a tenant-isolation test matrix;
- audit exports and security- or data-relevant mutations.

### Account takeover and session theft

Controls:

- strong password hashing and password-length rules;
- expiring, HTTP-only, secure, SameSite cookies;
- rotate sessions after authentication and password changes;
- throttle sign-in and password-reset endpoints;
- single-use, expiring reset tokens without account-enumeration responses;
- revoke all sessions after password reset or administrator deactivation;
- audit authentication and administrator-lifecycle events.

### Stored or reflected script injection

Controls:

- render administrator content as escaped text, not HTML;
- no arbitrary HTML, CSS, JavaScript, URLs, or executable templates;
- allow-list and normalize accent colors and field configuration;
- deploy a restrictive content security policy;
- add regression tests for labels, choices, answers, filenames, and exports.

### Forged or abusive submissions

Controls:

- CSRF protection where cookies affect behavior;
- per-IP-digest and per-organization throttling;
- honeypot and minimum-completion-time signals;
- strict limits on field count, strings, options, request size, and monthly volume;
- avoid raw-IP retention and rotate the digest secret;
- fail closed without logging complaint contents.

### Publishing races or unintended disclosure

Controls:

- edit a separate draft and make published/archived versions immutable;
- publish under a database lock and transaction;
- enforce one draft and one published version with partial unique indexes;
- use optimistic locking for administrator edits;
- bind every submission to the rendered immutable form version;
- audit preview and publication events.

### Sensitive-data leakage

Controls:

- filter dynamic answer parameters and reset tokens from logs;
- never include complaint contents in exception-report context;
- encrypt transport and backups;
- show a tenant-controlled privacy notice before submission;
- support export, explicit deletion, and automatic retention deletion;
- do not use complainant data for product analytics or sales leads.

### CSV formula injection

Controls:

- prefix cells beginning with `=`, `+`, `-`, `@`, tab, or carriage return;
- use the standard CSV encoder and test hostile values;
- authorize and audit every export.

### Denial of service and resource exhaustion

Controls:

- cap request bodies at the reverse proxy and application layers;
- cap queries through pagination and bounded exports;
- use database timeouts, indexes, connection limits, and health checks;
- throttle public submissions and authentication;
- monitor error, latency, saturation, and rejection rates.

### Supply-chain and deployment compromise

Controls:

- commit dependency locks and review automated updates;
- run dependency auditing, Brakeman, tests, and style checks in CI;
- use least-privilege deployment and database credentials;
- keep secrets outside source control and rotate them through a documented process;
- build one immutable container artifact and record deployed revisions.

## Residual risks and deferred controls

- MFA is desirable before a broad launch and must be reconsidered after the pilot.
- Open self-service organization signup would require stronger abuse, verification,
  support, and lifecycle controls and is not initially supported.
- Real attachments require separate storage, authorization, malware scanning,
  content verification, quarantine, retention, and abuse-reporting design.
- Legal basis, jurisdiction-specific notices, contractual terms, and incident
  response require review by the product owner's privacy and legal stakeholders.

## Review triggers

Review this model before enabling open signup, real attachments, new integrations,
custom domains, public APIs, longer retention, a new hosting provider, or a material
change to the tenant model.
