# A document is shared by a link that is the whole secret

> Status: accepted

## Context

A customer who receives an invoice wants to look at it, and is not a member of
the company. An account for somebody who reads one invoice is a login nobody
maintains; a PDF attachment stops being true the day the invoice is paid.

## Decision

**A share is a row and a function.** `document_shares` says one document may
be read by whoever presents one secret; `shared_document(token)` returns the
document as sent, with what is still owed today. The application draws the
page.

**The token is hashed and wide.** Only `sha256(token)` is stored, as for
invitations and keys. The bytes are two `gen_random_uuid()` — 244 random bits
in 43 base64url characters — because `pgcrypto` is unavailable under PGlite
where the tests run, and `gen_random_uuid()` is core Postgres.

**`anon` gets one function, not one table.** `shared_document` is `security
definer`; the visitor has no rights of their own; the output is one document
in one `jsonb`. No view to select from, no filter to widen.

**Unknown, withdrawn, expired and no-longer-shareable are the same null.**
Distinct refusals would be an oracle for guessed tokens.

**No IP address and no user agent.** `view_count` and `last_viewed_at` answer
"did they open it". A log of where customers were when they read an invoice is
personal data the core is not prepared to answer for; an application that is
keeps its own.

**No access code, and room for one.** A second factor is a useful option and
a bad floor; the day it is wanted it is a column and a second argument.

**Sales only** (`share_not_a_sale`). A purchase invoice is a third party's
document.

**A share is not edited.** No update policy: an expiry that can move is a
lifetime nobody can rely on. Revoke it and make another.

**`subject_kind` exists with one value**, so the next kind of shared subject
adds a column and a branch of the same check without changing old rows.

**The list of links is row level security**, not a function.

**`instance.public_base_url` is nullable, with no default.** No URL of Ekwo's
is written anywhere; where it is empty, `share_document` returns the token and
a null `url`.

## Consequences

- A customer reads a live invoice without an account.
- The anonymous surface grows by one audited function, not by a table.

## See also

- `tests/document_shares.test.ts`
- [`sharing.md`](../sharing.md)
- [0002 The surface is closed, not merely empty](0002-the-surface-is-closed-not-merely-empty.md)
