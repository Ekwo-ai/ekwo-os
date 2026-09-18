# `docs/firms.md` — an accounting firm and its clients

An accounting firm, a fiduciary, a bookkeeper with thirty customers, a group
that keeps the books of its three subsidiaries: somebody who keeps **several
companies that are not all theirs**. This page is what Ekwo gives them, where
each piece lives, and what is still missing.

It is the normal case of this schema and not an edition of it. There is no
"firm plan", no `tenant_id`, and no table called `firms`.

---

## The model in four sentences

1. **One installation belongs to one customer** — here, the firm. `instance` is
   that fact, in one row.
2. **Every client of the firm is a `companies` row** inside it, with its own
   chart, its own journals, its own locks and its own country pack. Forty
   clients in six countries is forty rows and six packs.
3. **A person has a role per company**, in `company_members`. A collaborator of
   the firm is `accountant` on the companies they keep; the person who runs a
   client company is `client` on that one, and does not know the others exist —
   row level security answers them as if the installation held one company.
4. **The firm is therefore nothing but the people who hold rights on several
   companies.** Which is why the word needs a definition below.

## What "portfolio" means here

> **Portfolio** — the set of companies a caller may read, worked out at the
> moment of the call. For a collaborator of an accounting firm it is the
> clients they keep: the firm's *client portfolio*, in the sense the profession
> uses the word (*portefeuille de clients*, *klantenportefeuille*,
> *Mandantenstamm*). It has nothing to do with investments.

The word appears in two functions, and means the same thing in both:

| Function | The question a firm asks on Monday morning |
|---|---|
| `portfolio_upcoming_filings(from, to)` | Across all my clients, which returns fall due between these two dates — and which have I not started? |
| `portfolio_filings_touched_since(from, to)` | Across all my clients, which returns that already went have had their period written to since? |

Each is the per-company reading (`upcoming_filings()`,
`filings_touched_since()`) asked of every company of the portfolio, with the
company named on each row. See [`filing.md`](filing.md#several-companies-at-once)
for the columns.

**Nobody maintains a portfolio.** It is not a list, a table or a setting: it is
"the companies on which the caller holds `filings.read`", computed each time.
So it follows the rights, and cannot drift from them:

| Who calls | Their portfolio |
|---|---|
| A collaborator who is `accountant` on forty companies | those forty |
| A collaborator who joined last week and was given two | those two |
| The person who runs a client company (`client`) | that one company — the same function serves them |
| Somebody whose `filings.read` was revoked on a company | every company but that one |
| The administrator of the instance, member of no company | none: creating companies is not keeping their books |

The functions run as the caller (`security invoker`) and name the capability
they filter on, because a company's *row* is visible to people its
*declarations* are closed to.

**Every company of the portfolio is in every answer**, at least once. A company
with nothing due is a row that says `nothing_due`; one whose pack names no
deadline is listed without a date and says `no_deadline_rule`. A client missing
from the list a firm plans its fortnight on is worse than a client listed
without a date.

## The client is a guest with narrow rights

The `client` preset is the person who runs a company whose books the firm
keeps. They **read** everything that is theirs — documents, the ledger, the
frozen declarations and the proofs of deposit — they **hand pieces over**
(`documents.deposit`: an attachment on their own company, signed by them,
insert only), and they write nothing else. Inviting one is one call:

```sql
select * from invite_member(:company, 'owner@client.example', 'client');
```

The ledger is included on purpose: the books are the client's, and the firm is
the guest who keeps them. A firm that wants to show less revokes a capability
on that member; see *Who may do what* in the [README](../README.md).

A client is never counted, licensed or charged for in the open core.

## The firm files in its own name, for all of them at once

Where the format of a country allows it, a representative deposits the returns
of all its clients in one file. The Belgian periodic VAT return does: the brick
[`@ekwo-ai/vat-consignment`](../packages/formats/vat-consignment/README.md)
writes one `VATConsignment` holding as many declarations as it is given, under
the `Representative` who files them — each taken from the figures that company
froze, never recomputed.

Sending the file is the operated side (`ee/`). What comes back — the deposit
number, the acknowledgement, the administration's words — is recorded in each
client's own `tax_filing_deposits`, in the open core: a client who leaves keeps
every proof that their returns were filed.

## Two ways to arrange a firm and a client

| | A. The firm's installation | B. The client's installation |
|---|---|---|
| Who owns the installation | the firm | the client |
| The client is | a guest (`client`) | the owner; the firm's collaborator is invited as `accountant` |
| Suits | small businesses and the self-employed: the firm does everything | a company that keeps part of its own books |
| The portfolio | one call, in the firm's installation | crosses installations, so it is a control plane: `ee/` |
| The client leaves | `export_company()`: their company, whole, as an archive another installation takes in | `pg_dump`, and nothing else |

Both are meant to exist. **A** is what this schema serves today.

## The client leaves with the books

Arrangement A is only honest if the way out exists, and it does. A company
leaves an installation as an archive — entries, documents, pieces, the bank,
the declarations with the figures they were frozen with and the proof each one
went, the trail — and arrives in another installation as a living company, with
its numbers, its locks and its identifiers. `ekwo company export` and
`ekwo company import` from a shell; `export_company()` and `import_company()`
underneath. The format and every check are in
[`company-archive.md`](company-archive.md).

**The client can do it themselves.** Leaving needs `company.export`, and the
`client` preset holds it as the `owner` preset does: a right to leave that only
the firm could exercise would be a courtesy of the firm. The firm's
collaborators (`accountant`) do not hold it. A firm with a reason to withhold
it revokes it for that member, and the revocation is on the audit trail of the
company.

What stays in the firm's installation: who was a member, the invitations, the
machine keys, the shared links — and the company itself, since nothing deletes
one yet. What the archive does not carry: the files the attachments point at,
which the manifest lists for somebody to copy.

## What is missing, in the order it matters

- **Carrying the files of the attachments**, and **removing a company** once it
  has left. A company can now be extracted and imported elsewhere
  ([`company-archive.md`](company-archive.md)); the bytes of its pieces are
  listed and not moved, and the original stays where it was.
- **The mandate as an object**: who may file for whom, with which
  administration, from when to when. `tax_filing_deposits.sent_by` says who
  sent; nothing says in what capacity. The brick that writes the representative
  does not check that one exists.
- **Groups of collaborators.** Giving somebody forty companies is forty rows of
  `company_members` today.
- **Separation of duties** between whoever prepares a return and whoever files
  it: the `ready` state exists for it, the rule that forbids one person both
  gestures does not.
- **An API key has no portfolio.** The `companies` row is closed to a key, and
  that row is where the functions start from.
- **The portfolio across installations** (arrangement B), which is `ee/`.

What is deliberately not here: billing a firm's clients and tracking its time
(the firm's trade, not its accounting), and a `tenant_id` that would let several
firms share a database.
