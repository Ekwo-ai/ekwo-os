# An analytic value is entered on the line, and read from the ledger

> Status: accepted

## Context

`analytic_axes`, `analytic_values` and `entry_line_analytics` have been in the
schema since the first release: axes of a company, values of an axis that may
nest, and the share of a ledger line that goes to each value, in percent.
Nothing filled them and nothing read them. A sales or a purchase invoice had
nowhere to say what its lines were for, posting copied nothing, and no report
gave the result of a project or a cost centre.

Products answer a neighbouring question. `document_lines.product_id` says
what was sold or bought, and `product_report()` reads the posted invoices to
give the margin of each offer. It sees invoice lines and nothing else: a
salary, a rent, a depreciation or an adjustment names no product and never
will.

The established ledgers settle the analytic question the same way. The value
is keyed where the person knows what a cost or a revenue is for — on the line
of the invoice, or on the line of a journal entry when no invoice exists — and
the posting carries it onto the ledger line, which every report reads. Only
lines of the income statement carry it: a receivable, a tax payable or a bank
balance is not "for" a project.

## Decision

**The value is entered on the document line and copied onto the ledger line
at posting.** `document_line_analytics` is the split of a document line: the
same shape and checks as `entry_line_analytics`, one row per value, a share in
percent. `post_document()` groups the lines of a document by account, tax and
split, so two lines that go to different values are two ledger lines, and
copies the split of each group onto the line it writes — the base and the
non-deductible share of a tax booked on the accounts of the lines alike. An
entry no document writes — payroll, depreciation, a year-end adjustment — is
split directly on its lines. After posting, the ledger line is the one truth:
every report reads `entry_line_analytics` and nothing reads the document split
again. `cancel_document()` gives the credit note the split of the invoice it
cancels; `reverse_entry()` already gave the mirror the split of the original.

**Only the income statement carries an analytic split.** A split on a line
whose account is not in the `income` or `expense` group is refused with
`analytic_not_on_result_account`, on a document line and on a ledger line,
when it is written and when the line moves to another account. The group is
`accounts.internal_group`, derived from the account type every account of
every chart carries in its country pack; no account code and no country's
numbering is read.

**A split is in percent, per axis, and the amounts are derived.** A line may
carry one split on each axis of its company: a project and a site, say. On one
axis the shares add up to at most 100; less leaves the rest of the line
unassigned, and more is refused with `analytic_split_over_100`. The `amount`
column is written by the database, never by the caller: the share of the line
— its untaxed amount on a document line, its balance in the company's currency
on a ledger line — with the shares of one axis rounded in the order of their
codes so that a whole split adds up to its line to the cent. A line that
changes amount or account takes its split with it.

**A product, and a contact, may carry a default value. It pre-fills the line
and never constrains it.** `products.analytic_value_id` and
`contacts.analytic_value_id`. When a line is written, or its product changes,
each default whose axis the line has no split on yet is added at 100 % — the
product's first, then the document contact's — and only where the line's
account is a result account; elsewhere the default does not apply and says
nothing. The person changes or removes what was pre-filled like any other
row, as long as the document is a draft. This is the rule products already
follow (decision 0044).

**The product says what; the axis says what for.** The product covers invoice
lines and answers "what did this offer bring in and cost" (`product_report()`).
The axis covers the whole income statement, salaries and rent included, and
answers "what did this activity make" (`analytic_report()`). The two are not
merged: a product is not an axis value, and an axis value is not a catalogue
entry.

**`analytic_report(company, axis, from, to)` reads the ledger.** For each value
of the axis that a posted ledger line of the period reaches, the income, the
expense and the result, in the company's currency; and one row with no value,
the part of the income statement that no split of this axis reaches. The rows
add up, to the cent, to the income statement of the period: the same posted
entries, the closing entry left out as the income statement leaves it out.

## Consequences

- A document with no analytic split posts exactly as before: the grouping key
  has one more member, which is empty for every line written so far.
- Two lines on the same account and tax with different splits give two ledger
  lines where they used to give one. The entry balances as before.
- The split of a posted document is frozen with its lines
  (`document_posted`). The split of a posted ledger line is not: it feeds no
  declaration and no statement, and a value keyed wrong is corrected on the
  ledger line, under `entries.write`, without crediting an invoice.
- An analytic split on a balance-sheet account written before this record is
  not touched; the guard reads what is written from now on, and an archive
  imported from such an installation is loaded as it is.
- An axis whose values nest reports each value on its own row with its
  `parent_id`; a total per parent is the caller's sum, not a second figure.

## See also

- `supabase/migrations/20261019130000_an_analytic_value_is_entered_on_the_line.sql`
- `supabase/migrations/20261019130500_analytic_report.sql`
- `supabase/migrations/20260911120800_analytics_attachments.sql`
- `tests/analytics.test.ts`
- [0008](0008-documents-and-entries-are-two-layers.md) — Documents and entries are two joined layers
- [0044](0044-a-product-is-a-catalogue-entry-in-the-core.md) — A product is a catalogue entry in the core, not stock
