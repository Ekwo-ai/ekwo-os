# A module has its own schema and posts through a function

> Status: accepted

## Context

Fixed assets, budgets, a carbon ledger are not the accounting core. Each is
tables, a calculation and a report a company wants or not — and each ends with
an entry. The question is where they live and what they may touch.

## Decision

**One Postgres schema per module; the socle stays in `public`.** A prefix on
socle tables becomes unreadable after the fourth module. A schema is exposed to
the API by one line of configuration, closed by one `revoke`, documented by
one section, and absent entirely when not installed.

**The registry is a table.** `public.modules` holds one row per installed
module, written by the module's first migration; `company_modules` records who
enabled what. There is no plugin registry in code to keep in step.

**A module never writes the ledger by hand: `post_module_entry()` does.**
Postgres has no privilege that forbids a schema from writing a table (privileges
belong to roles), so the rule is structural: a module hands over a company, a
date, a tag and lines as data, and the socle builds the draft and calls
`post_entry()`. A test proves that no write statement under `modules/` names
`entries` or `entry_lines`.

**The tag makes a module idempotent, enforced by the database.**
`entries.module_code` and `module_ref`, unique per company: the second booking
of a period fails on insert. That is also why `entry_kind` gains no value per
module.

**A module is enabled per company by definer functions** that check
`company.write`; `company_modules` has no write policy. `module_enabled()` is
the call every module policy makes, and one of the helpers `anon` may execute.

**Disabling asks the module, by convention.** `disable_module()` runs
`<schema>.can_disable(uuid)` if it exists: null allows, a sentence refuses.
Nothing a module wrote is deleted by a disable. The same convention answers
`accounts_in_use()` and `archive_tables()`.

**A country is data inside a module too.** `packs/<cc>/<module>.json` compiles
into the module's seed, applied only by the module runner. Accounts a module
posts to are roles of the country model, so `ekwo pack check` already verifies
them in every chart. Mechanisms are named, not countries (e.g. a disposal is
`net_result` or `gross`), and roles carry no defaults.

**Module migrations share the socle's history.** Same table, plain timestamp
as version, module in the name. Every migration of a module sorts after the
socle migration its manifest declares it requires; `ekwo migrate` applies the
socle first, then modules. `--no-modules` is for use before `supabase db
push`, which knows only the socle's files.

**Exposing a schema is an API setting no migration can make**, so
`ekwo module enable` prints the line to add and the MCP server translates the
PostgREST error into the same sentence.

**A module refuses rather than guesses** where guessing would untie the register
from the ledger (a method it does not implement, rewriting a booked schedule, a
disposal while an earlier period is unbooked). Conventions that are a reading
of the rules are listed for an accountant in the module's README.

## Consequences

- A module that is not installed leaves no trace in the schema.
- The core never names a module; modules answer the core's conventions.

## See also

- [`modules.md`](../modules.md), [`modules/README.md`](../../modules/README.md)
- `tests/modules.test.ts`
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
