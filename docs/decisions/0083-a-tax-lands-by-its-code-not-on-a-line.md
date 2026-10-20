# A tax lands by its code, not on a line

> Status: accepted

## Context

A document line carries its base and names its tax (`document_lines.tax_id`).
When the document is posted, the tax is computed per rate over the document
and written on the account the tax points to (`tax_postings`, decision 0019).
Nothing else is meant to reach that account from a document.

Nothing refused it, though. A purchase keyed with its VAT as a second line at
0 % on the VAT account, or a history brought in by an import that took the
VAT line of the former ledger for an expense, gave a document whose tax was
zero while its ledger was right account by account: the trial balance matched,
the return read nothing from the document, and a reader who opened it saw a
tax that was not there. Eighty-six purchase invoices of one company arrived
that way on 18 October 2026, and were found by eye two days later.

## Decision

**A line on an account a tax lands on is refused.** The trigger
`document_lines_guard_tax_account` reads `tax_postings` of the company
(`posting_type = 'tax'`) and refuses a document line whose account is one of
theirs, with `tax_account_on_a_line` naming the account and the taxes that
land there, and a hint to put the line on an expense or revenue account with
its `tax_id` set. The guard reads what is written from now on: rows already
there are left as they are.

**The credit note of a cancelled document copies its lines.** `cancel_document()`
writes the credit note from the lines of the invoice as they were; a line the
invoice carries on a tax account is carried by its credit note too. The guard
lets that one copy through, by `documents.reversed_document_id`, so a document
posted before the guard is still undone — the only way left to undo it in a
country whose `posted_edit_policy` is `reversal_only`.

**An import maps the VAT line to the tax of the base lines.** A reader that
brings invoices in as documents does not carry the VAT line of the former
ledger as a line: it reads it as the tax of the base lines, and chooses the
tax code that gives the same amount. `docs/import.md` says so.

## Consequences

- A document shows the tax it carries, and the return reads it. The ledger
  side of a tax is written by the posting only.
- A caller that meant to key a tax gets the taxes that land on that account
  by name, and sets `tax_id` on the base line instead.
- An older document with such a line is cancelled and issued again; its credit
  note is not refused.
- An account that a tax lands on takes no line of a document. A supplier's
  invoice that re-charges a tax is a base with its own tax, not that account.

## See also

- `supabase/migrations/20261020210000_a_tax_lands_by_its_code_not_on_a_line.sql`
- `tests/tax_account_on_a_line.test.ts`
- [0019](0019-tax-postings-carry-the-account-and-the-box.md) — A tax posting carries the account and the box
- [0069](0069-a-piece-goes-on-its-document.md) — A piece goes on its document
- `docs/import.md` — Invoices and their pieces
