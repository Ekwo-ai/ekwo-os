# A release has a tag, a schema version and a schema floor

> Status: accepted

## Context

A package reads rows and calls functions of a particular version of the
database. The installation must know its version, and a client must refuse a
database too old for it rather than improvise.

## Decision

**Semantic versioning, from a first tagged minor.** While everything added is
additive, releases are minors; `1.0.0` is a promise of stability made only
when it can be kept. From the first tag, a published migration is never
edited, and the CI measures that rule against the latest tag.

**A release bumps `ekwo_schema_version()` in a migration of its own**, and
nothing else in that file. The column default and `init_instance()` call the
function, so a fresh installation records it; `ekwo migrate` writes it back
onto `instance.schema_version` for an existing one.

**Each package declares a `schema_min`**, in `package.json` under
`ekwo.schemaMin` and as a constant, the way a pack declares one. It is a floor,
not the version: a release that adds nothing a package reads leaves it. The MCP
server enforces it; the CLI, which carries the migrations, prints it.

**Tag first, publish after**, so a published version is always one whose
source can be read. `docs/releasing.md` is the procedure.

## Consequences

- An old database is refused by name instead of half-working.

## See also

- [`releasing.md`](../releasing.md), [`CHANGELOG.md`](../../CHANGELOG.md)
- `tests/release_publish.test.ts`
