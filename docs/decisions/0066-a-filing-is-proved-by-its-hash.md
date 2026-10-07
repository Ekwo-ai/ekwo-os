# A filing is proved by its hash, on a public ledger

> Status: accepted

## Context

The schema keeps what a company filed: the figures as frozen
([0037](0037-a-filed-declaration-is-frozen.md)), every send and what came back
([0039](0039-a-deposit-is-an-event.md)). All of it lives in the company's own
database, which the company can rewrite. A third party (an auditor, a buyer of
the company, a court, a bank) has no reason to believe that the file shown
today is the file that went, or that it existed on the day it says.

## Decision

**A proof is the sha256 of the exact bytes, committed to a public ledger.**
`filing_proofs` holds one row per hash and per method, about a declaration,
the annual accounts of a financial year, or a document. The file never leaves:
only its hash does, with a random nonce appended before submission.

**OpenTimestamps is the first method.** It costs nothing, needs no account and
no key, and its proof is verified against Bitcoin block headers without any
Ekwo installation. The protocol is implemented in `@ekwo-ai/core` rather than
through the published client library, which brings a Bitcoin library and a
dozen transitive dependencies to do what a few hundred lines do.

**The network is the client's, the record is the database's.** Calendars and
block explorers are reached by the command line or a scheduled job, never by
a database function: a transaction does not wait on somebody else's server.
The database records the bytes it is handed, refuses what does not fit, and
freezes a proof once it is anchored.

**The method is a column.** `eas`, the Ethereum Attestation Service, is
reserved for a second layer that proves *who* attests, where OpenTimestamps
proves *when*. [`filing-proofs.md`](../filing-proofs.md) evaluates it; nothing
writes it yet.

**Proving is its own capability.** `filings.prove`, on `owner` and
`accountant`: publishing in the company's name is an outward act, as sharing a
document is ([0042](0042-a-document-is-shared-by-a-link.md)).

**`anon` reaches one function.** `filing_proof(sha256)` returns the proofs of
one hash and nothing about who proved it or what it is about. A malformed hash
and an unknown hash get the same empty answer. Whoever presents a hash already
holds the file.

**The figures have a canonical hash too.** For a declaration,
`tax_filing_values_sha256()` hashes the frozen boxes in the canonical form an
archive already uses (`canonical_json()`), derived and never taken from the
caller. A reader with the figures and no file can still match them.

**Nothing is national.** No pack is read. The feature applies to any
declaration, any annual accounts and any document of any country.

## Consequences

- Anybody holding a filed file can check, without an account and without
  trusting the installation, that it existed no later than a Bitcoin block.
- A proof travels with the company's archive and means the same thing in any
  installation.
- A proof says nothing about who made the file or whether its content is
  right. EAS, or a qualified timestamp under RFC 3161, would each be a further
  method in the same table.

## See also

- `supabase/migrations/20261007192418_a_filing_is_proved_by_its_hash.sql`
- `tests/filing_proofs.test.ts`, `tests/opentimestamps.test.ts`
- [`filing-proofs.md`](../filing-proofs.md)
- [0002 The surface is closed, not merely empty](0002-the-surface-is-closed-not-merely-empty.md)
