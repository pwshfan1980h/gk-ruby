# gk-ruby Product Specification

- Status: Draft for implementation
- Last updated: 2026-07-20

## Product promise

gk-ruby gives a small organization a dependable, accessible complaint form without
requiring a bespoke software engagement. Administrators configure and publish one
form, then review and export the resulting submissions.

The product may be offered free. It must therefore remain intentionally bounded,
cheap to operate, and safe to maintain. It should solve its supported use case well
rather than imitate a general-purpose form or case-management platform.

## Initial operating model

- Centrally hosted, multi-tenant application
- Controlled organization provisioning for the pilot; no open self-service signup
- One complaint form per organization
- One editable draft and exactly one public version after initial publication
- Up to two active administrators per organization
- Up to 30 fields per form
- Up to 10,000 accepted submissions per organization per rolling 30 days by
  default, with an operator-configurable ceiling of 100,000
- Default 90-day submission retention, configurable downward by an administrator
- Web review and CSV export
- Documentation-based, best-effort support with no service-level agreement

A portable container deployment remains a requirement so a future single-tenant or
self-hosted distribution does not require a rewrite.

## Supported field types

- Short text
- Long text
- Email address
- Telephone number
- Date
- Select list
- Radio group
- Required acknowledgment checkbox
- Simulated attachment

Limits:

- Field label: 120 characters
- Help text: 500 characters
- Placeholder: 150 characters
- Short-text response: at most 255 characters
- Long-text response: at most 5,000 characters
- Choice fields: at most 20 unique choices of at most 80 characters each
- Simulated attachment: at most 10 MB according to request metadata
- Supported simulated extensions: PDF, JPG, JPEG, PNG, DOCX, and TXT

The simulated attachment flow records a sanitized filename, reported media type,
and byte size. It does not persist file contents. Both public and administrative
interfaces must disclose this behavior clearly.

## Form lifecycle

- Administrators always edit a draft.
- Draft edits never change the public form.
- Administrators can preview the draft.
- Publishing is one explicit, atomic action.
- The previous published version becomes archived and immutable.
- A new editable draft is cloned from the newly published version.
- Every submission belongs to the immutable version that rendered it.
- Publishing conflicts are detected rather than silently overwriting another edit.

## Customization

- Organization display name
- Form title, introduction, confirmation message, and privacy-notice link/content
- Curated accessible color presets
- Optional custom accent color accepted only when generated foreground/background
  combinations meet the supported contrast rules
- Field labels, help text, placeholders, requirements, choices, and ordering

Arbitrary CSS, JavaScript, HTML, fonts, layout templates, and custom domains are not
part of the initial product.

## Administrator capabilities

- Sign in, sign out, and reset a password
- Invite or deactivate an administrator within the two-seat limit
- Edit, preview, and publish the form
- See draft-versus-published state and conflicting edits
- Review paginated submissions
- Search by reference number and filter by date or workflow status
- Set status to New, In review, or Resolved
- Export the filtered result set to CSV
- Delete a submission and see the applicable retention date
- Review security- and data-relevant audit events

## Public capabilities

- Open an organization's stable public form URL without an account
- Complete the form using keyboard, pointer, touch, or assistive technology
- See clear field-level and form-level validation errors without losing valid answers
- Submit once and receive a non-sequential public reference number
- See the organization's confirmation and privacy information

## Security, privacy, and abuse controls

- Every private query is scoped to an authorized organization membership.
- Administrator actions never accept an organization identifier as authorization.
- Passwords use Rails' password hashing; sessions use secure, HTTP-only cookies.
- Authentication, publishing, export, deletion, and administrator changes are audited.
- CSRF protection, content security policy, security headers, parameter filtering,
  login throttling, public submission throttling, and a honeypot are enabled.
- Public submission attempts are limited to 30 per organization and privacy-safe IP
  digest in 10 minutes, independently of the 10,000 accepted-submission allowance.
- IP addresses are not stored directly for submissions. A rotating keyed digest may
  be retained briefly for abuse controls.
- Complaint contents are excluded from application logs and error-report payloads.
- Privacy information and retention behavior are visible before submission.
- Expired submissions are deleted automatically and deletion is auditable without
  retaining the deleted complaint contents.
- Backups are encrypted and follow a documented retention and restore-test policy.

## Accessibility and resilience

- Target WCAG 2.2 AA for supported flows.
- Use semantic server-rendered HTML as the baseline.
- JavaScript enhances administrative editing but is not required to submit the
  public form.
- Validate color contrast, focus order, error association, labels, instructions,
  touch targets, and reduced-motion behavior.
- Publishing and submission creation use database transactions and constraints.
- Health/readiness checks distinguish an alive process from a usable application.

## Explicit non-goals for the initial release

- General surveys or unlimited forms
- Conditional branching or multi-page forms
- Calculations, scoring, or dynamic scripts
- Real attachment persistence or retrieval
- Complainant accounts or a complainant case portal
- Anonymous administrator signup
- Billing
- Webhooks, public APIs, or third-party integrations
- Custom domains, custom CSS, or white-labeling
- Advanced case management, assignments, internal notes, or analytics
- Guaranteed uptime or bespoke free support

## Release gates

- All model, request, authorization, publishing-concurrency, and system tests pass.
- Tenant-isolation tests cover every administrator resource and export.
- Static analysis, dependency audit, style checks, and CI pass without unexplained
  exceptions.
- Supported public flows pass automated accessibility checks and manual keyboard and
  screen-reader smoke tests.
- Production-like backup and restore are demonstrated.
- Rate limits, retention jobs, failed email, database outage, stale edits, duplicate
  publish attempts, and malformed submissions have tested outcomes.
- Production secrets, HTTPS, logging redaction, monitoring, and alert routing are
  documented and verified.
- No known critical/high security issue or release-blocking defect remains.
