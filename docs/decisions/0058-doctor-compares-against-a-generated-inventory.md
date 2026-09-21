# `ekwo doctor` compares against a generated inventory

> Status: accepted

## Context

An installation can drift: a migration not applied, an object dropped, a
policy removed or added by hand. A list of expected objects typed by a person
is wrong the first time somebody adds a table.

## Decision

**The inventory is generated, committed and shipped.**
`scripts/generate-expected-objects.mjs` applies the migrations under PGlite and
writes `packages/cli/assets/expected-objects.json`: per schema, tables and
columns, views, functions with identity arguments, policies, triggers, types
and grants. It travels with the CLI. The CI regenerates it and fails on any
difference, and diffs the shipped copy.

**Everything sorts on a key, and `oid` is never one.** Functions are keyed on
name and identity arguments, so overloads need no tiebreaker. `docs/schema.md`
orders overloads by `proname, oid` for the same reason.

**Missing, extra and changed are different answers.** Missing is a problem;
extra is information (an operator's own table is their business); a changed
column type is reported as changed. A **policy** is a problem either way —
row level security is the whole model, so a removed policy closes a table and
an added one is an unreviewed grant. Grants have their own check (see
[0003](0003-the-schema-grants-its-own-rights.md)).

**The exit code says one thing:** 0 unless something is a problem, so the
doctor can gate a deployment without an operator's extra table turning it red.

**A module is required only of a database that carries it**, per
`public.modules`; one whose migrations never ran is named and skipped.

**A database older than the CLI is compared anyway**, naming both versions.

**The audit trail is checked for what it claims:** guard trigger, row level
security, no write policy, `purge_audit_log` executable only by
`service_role`.

**Status and doctor compute the migration gap over the socle and the modules
together**, as `ekwo migrate` applies them.

## Consequences

- Constraints, indexes and function bodies are not compared: each is far more
  text for a diff that moves on every Postgres upgrade. `docs/schema.md`
  carries constraints for a human reader.

## See also

- `packages/cli/assets/expected-objects.json`, `tests/schema.test.ts`
- [0017 An append-only audit trail](0017-an-append-only-audit-trail.md)
