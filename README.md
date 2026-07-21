# gk-ruby

Internal Rails 8 implementation of a constrained, versioned complaint form. This
repository is under active development and is not a hosted service or a promise of
support.

The simulated attachment field stores sanitized filename, reported media type, and
byte-size metadata only. It does not retain file contents.

## Local requirements

- Ruby 3.4.10 through `rbenv`
- Rails 8.1.3 (installed through Bundler)
- PostgreSQL 17 or another Rails-supported PostgreSQL release

On this Mac, `rbenv`, Ruby, Rails, and PostgreSQL were installed during project
setup. New terminal sessions load `rbenv` from `~/.zshrc`.

## Setup

```sh
cd /Users/willm/Projects/gk-ruby
bin/setup
bin/dev
```

The development seed creates:

- administrator: `admin@example.test`
- password: `Development-Only-Password-1`
- public form: `/forms/example-community-services`

These credentials are development-only and are never created in production.

## Verification

```sh
bin/rails test
bin/cucumber
bin/rails test:system
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
```

`bin/ci` runs the local release checks, including the executable Gherkin
specifications.

## Provisioning

Production organization provisioning is controlled rather than publicly available:

```sh
ORGANIZATION_NAME="Example Organization" \
ORGANIZATION_SLUG="example-organization" \
ADMIN_NAME="Initial Owner" \
ADMIN_EMAIL="owner@example.org" \
ADMIN_PASSWORD="use-a-secret-password-manager-value" \
bin/rails gk_ruby:provision
```

The task atomically creates an organization, owner, initial public version, and
editable draft. It rolls everything back if any part is invalid.

Production uses one PostgreSQL database for application data, durable jobs, and the
shared cache. See ADR 0002 and the operations runbook before selecting a host.

## Documentation

Start with [docs/README.md](docs/README.md). The Rails decision, product limits,
threat model, executable behavior specifications, and operating runbook live there.

No software license has been selected. Public visibility does not imply permission
to redistribute or operate this code.
