# A permission is a capability; a role is a preset

> Status: accepted

## Context

A permission model of three roles (`owner`, `accountant`, `viewer`) has three
positions. A bookkeeper who may post invoices and must never move a period
lock has no row to sit on, and the usual answer — a fourth role, then a fifth —
never ends. A firm keeping the books of many companies also needs to invite
the person who runs each company to read and hand over documents without
letting them write a line.

## Decision

**`capabilities` is a table of codes, and `has_capability()` is the only
authority.** `role_capabilities` says what each preset holds;
`company_members.capabilities_granted` / `capabilities_revoked` adjust one
member in both directions. A revoke wins over a grant and over a preset,
including on an owner: a company that wants its owner unable to close a year
is describing its own separation of duties. Every policy calls
`has_capability()`, and `can_write_company()` is rewritten on top of it as the
answer to `entries.write`.

**No capability without something that can refuse on it.** There is no
`reports.read` or `exports.run`: reports sum ledger lines that row level
security has already filtered, so a member without `entries.read` gets an
empty report. A second lock on the same door is a lock nobody turns.

**Posting and closing are acts, guarded by triggers.** `documents.post`,
`entries.post` and `year_end.close` concern a state transition on a row the
member may already write, which a table policy cannot express. A trigger on
the transition holds for every path into it.

**Presets.** `viewer` reads, `accountant` works, `owner` holds everything.
**`client`** holds what `viewer` holds plus `documents.deposit` and
`company.export`: the person whose company it is reads the books — the client
owns the books, the accountant is the guest — hands pieces over and may
leave with the ledger (see [0043](0043-a-company-leaves-with-its-books.md)).
`settings.read`, `contacts.read` and `products.read` are in it because a
ledger without its chart or a document without its contact is unreadable.

**`documents.deposit` is as narrow as the act.** Insert only, on
`attachments`, with `entity_type = 'company'` and `entity_id` equal to the
company — an in-tray, not a place to hang a file on a filing or an invoice —
and signed: `uploaded_by` defaults to `auth.uid()` and the policy refuses any
other value. A second select policy lets a holder read back their own
deposits, so a scanner key holding only the deposit capability can complete
`insert … returning`. `owner` and `accountant` hold it too, so an interface
asks one question and revoking `documents.write` does not silently remove the
in-tray.

**A module declares its own codes** (`assets.read`, `assets.write`,
`assets.post`, `budgets.read`, `budgets.write`) in its own migration;
`capabilities.area` is the module code. `assets.post` is asked as well as
`entries.post`, not instead of it. A code added after the socle's presets were
filled must name the owner preset itself.

## Consequences

- A firm that wants a client to see less revokes per member.
- The client preset can read the firm's name, the user ids of instance
  administrators and the audit trail of their own company — nothing of another
  company. `tests/client_preset.test.ts` sweeps every writable table and every
  callable volatile function from that seat.
- Some functions answer a caller without rights by doing nothing (an update
  that row level security empties) rather than raising; the list is frozen in
  that test so it cannot grow unnoticed.
- A deposit cannot be withdrawn by its author: the firm may already have
  booked from it.

## See also

- `tests/capabilities.test.ts`, `tests/client_preset.test.ts`
- [0005 A guard answers true or false](0005-a-guard-answers-true-or-false.md)
- [0006 A machine key is a narrow caller](0006-a-machine-key-is-a-narrow-caller.md)
- [`firms.md`](../firms.md)
