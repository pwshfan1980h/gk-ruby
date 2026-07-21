# Free-product strategy

- Status: Working hypothesis
- Last updated: 2026-07-20

The idea is reasonable if gk-ruby remains a narrow utility rather than a free bespoke
services channel. It can help organizations whose requirements do not justify a paid
engagement, demonstrate the company's execution quality, and preserve goodwill. Its
value as an introduction to paid work is a possible secondary outcome, not permission
to use complaint data for sales.

## Conditions that make the strategy work

- Controlled provisioning prevents anonymous abuse and sets expectations before use.
- One form, two administrators, curated field types, bounded customization, and no
  integrations keep support and regression cost predictable.
- A portable Rails container and one PostgreSQL database keep hosting understandable.
- Best-effort support and no SLA are stated clearly before a pilot.
- Product telemetry measures service health and aggregate usage, never complaint text,
  identities, attachment metadata, or individual administrator behavior for sales.
- A path to the company's paid products can be visible outside the complaint workflow,
  but access to the free utility is not conditioned on a sales conversation.

## Measures for a pilot

- Monthly infrastructure cost and database growth per organization
- Operator minutes spent provisioning, updating, and supporting each organization
- Availability, request latency, error rate, queue failures, and restore-test outcome
- Form publication success, aggregate accepted/throttled counts, and administrator
  retention, without inspecting complaint contents
- Requests that fall outside the supported scope and whether they indicate a paid need

## Failure signals

- Frequent requests for custom workflows, integrations, or case management
- Recurring manual data repair or tenant-specific deployments
- Abuse or legal obligations disproportionate to the public benefit
- A support burden that cannot be handled through documentation and standard fixes
- Using sensitive complaint information as lead-generation data

If those signals appear, narrow enrollment, move organizations to a self-hosted option,
or stop the free service rather than allowing an unpriced custom product to emerge.
