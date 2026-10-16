# An opening on the day of the takeover, with its open items

> Status: accepted

## Context

Books are rarely taken over on the first day of a year. A company changes
software when its contract ends, and arrives with the trial balance of the day
before and the list of invoices still open — each with its number, the
structured reference its customer will quote, its due date. An opening that
only knows the first day of a year refuses the first, and an opening made of
lines keeps the second only as one amount per party: when the customer pays,
statement matching has no number and no reference to find.

## Decision

**The opening takes a day.** `opening_balance()` takes `p_opening_date`, any
day of the fiscal year, its first day when left out. The opening entry is
dated there. What the previous system booked from the first day of the year to
the day before arrives in the opening entry itself — the income and expense
accounts at their figure of that day, under `p_allow_result_accounts` — and
nothing of these books is dated before it. A year still holds one opening.

**An open item is a document.** `p_items` lists the sale and purchase invoices
and credit notes still open: type, number, contact, amount still open, date of
issue, due date, payment reference, supplier reference. Each is written as a
draft and posted by `post_document()`, the one way a document is posted, on
the opening journal and on the opening day, while its `document_date` keeps
the day it was issued. Its one line carries no tax and names the suspense
account the pack names under `defaults.roles.suspense`. Its entry therefore
puts the amount on the receivable or payable of its contact, with the due date
as maturity, against that account. Nothing is booked to revenue, expense or
tax again: the sale is in the opening already, and its tax was declared by
whoever kept the books then. `open_items()`, `suggest_matches()`,
`settle_from_statement()` and `reconcile()` read these documents the way they
read one issued here, because they are the same kind of row.

**An account the items fall on is carried by its items.** The balance says
what the receivable account holds; the items say who owes it. The lines of the
balance on such an account are written on the suspense account instead, and
the items, each booked against the suspense account, put the amount back on
the receivable or payable, by contact. The suspense account comes out at
nothing. An account whose items do not add up to its line of the balance is
refused, `opening_items_unbalanced`: the open items of an account are its whole
balance, and an aged balance that disagrees with the trial balance is the first
thing to settle at a takeover, not something to book. The account an item
falls on is the one `post_document()` will book it on,
`resolve_counterpart_account()` of its contact, so the check and the entry
cannot disagree.

**One function, not a second one.** The items are new arguments of
`opening_balance()` rather than an `opening_items()` beside it. They are
checked against the lines of the balance and written in the transaction that
writes the opening entry. A separate function would have to find an opening
already posted and check against it in a second call over the API — a second
transaction, and an opening that stands for a moment without its items, or
for ever if the second call fails. The arguments come last and default to
null, so a call written for the first four reads the same.

**Refused by name, before anything is written:** a type that is not an
invoice or a credit note, a missing number, a number already a document of its
type in the company or twice in the list, a contact of another company, an
amount that is not positive, an item issued after the opening day or due
before it was issued, an opening day outside the year, a company with no
suspense account.

**The import takes the same.** `import_books()` dates the opening on the day
the files give and passes `opening.items` on, each naming its contact by the
key of the files. `@ekwo-ai/trial-balance` reads the list as CSV
(`readOpenItems()`), and `ekwo import trial-balance … --open-items` and the
`import_books` tool carry it.

## Consequences

- A trial balance or a statement of the whole year reads what the previous
  system held plus what was booked since. One that ends the day before the
  takeover reads nothing. One that starts on or after it reads the
  year-to-date figures as a movement of the period the takeover falls in.
- A tax return reads none of it: the opening and its items carry no tax and
  no box. The returns of the months before the takeover were filed from the
  previous system.
- The audit file of the year of a takeover carries the opening entry among
  the movements of the year, on the opening journal, and the open items as the
  entries of their documents.
- An open item is in the currency of the company. An item in another currency
  is not taken yet.
- Where a chart keeps its suspense account reconcilable, the lines the
  opening and its items write on it are matched against each other by
  `reconcile()` in the same transaction, so none is left among the open items.
  The opening then needs `reconcile.write` besides `entries.post`,
  `documents.write` and `documents.post`.

## See also

- `supabase/migrations/20261014081038_an_opening_on_the_day_of_the_takeover.sql`
- `tests/opening_at_takeover.test.ts`, `tests/import_books.test.ts`
- [0031 Opening and closing are parameters](0031-opening-and-closing-are-parameters.md)
- [0008 Documents and entries are two joined layers](0008-documents-and-entries-are-two-layers.md)
- [0046 Settling applies identification, offers resemblance](0046-settling-applies-identification-and-offers-resemblance.md)
- [`docs/import.md`](../import.md)
