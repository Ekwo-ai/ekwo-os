# An invitation names an address, not a user id

> Status: accepted

## Context

`company_members.user_id` has no foreign key to `auth.users` precisely so a
membership can exist before the person signs up. Without an act that produces
one, somebody has to read an id out of the Auth dashboard.

## Decision

**`invite_member()` returns a token once and stores its sha256.**
`accept_invitation()` requires that `auth.email()` match the invited address,
case-insensitively; an invitation is single-use and expires. `sha256()` is core
Postgres, so no extension is needed — `pgcrypto` is unavailable under PGlite,
where the tests run, and the schema does without it.

**Accepting is the invitee's own act.** It is not an MCP tool; it is done from
the application or any client holding the invitee's session.

**A user preference has no default.** Every preference column of
`user_preferences` (`preferred_company_id`, `language`, `timezone`,
`date_display_format`, `number_display_format`, `theme`) is nullable, and null
means "take the company's answer, then the pack's". Display formats are named
`*_display_format` so they are never confused with
`country_defaults.number_format`, the pattern a document number is built
from.

## Consequences

- An invitation token and a key hash are never copied into the audit trail
  (see [0017](0017-an-append-only-audit-trail.md)).
- Orphan memberships left by deleted users are reported by `ekwo doctor`,
  never deleted automatically: that would silently undo an invitation not yet
  taken up.

## See also

- `tests/invitations.test.ts`, `tests/preferences.test.ts`
- [0034 A label is data](0034-a-label-is-data.md)
