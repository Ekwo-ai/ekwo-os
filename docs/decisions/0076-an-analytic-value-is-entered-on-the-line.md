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
the posting carries it onto the ledger line, which every report reads. Lines
of the income statement carry it, and so do the fixed assets a project buys:
a receivable, a tax payable or a bank balance is not "for" a project.

The first version of this record left nine questions open. The founder
answered them on 19/10/2026; the answers are part of the decision below and
are listed under *The answers of 19/10/2026*.

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

**The income statement, and the fixed assets, carry an analytic split.** A
split on a line whose account is neither in the `income` or `expense` group
nor a fixed asset (account type `asset_fixed`) is refused with
`analytic_not_on_this_account`, on a document line and on a ledger line, when
it is written and when the line moves to another account; a receivable, a
payable, a tax and a bank account stay refused. The group is
`accounts.internal_group`, derived from the account type every account of
every chart carries in its country pack, and the fixed asset is that account
type itself; no account code and no country's numbering is read
(`account_carries_analytics()`).

**A split is in percent, per axis, and the amounts are derived.** A line may
carry one split on each axis of its company: a project and a site, say. On one
axis the shares add up to at most 100; less leaves the rest of the line
unassigned, and more is refused with `analytic_split_over_100`. The `amount`
column is written by the database, never by the caller: the share of the line
— its untaxed amount on a document line, its balance in the company's currency
on a ledger line — with the shares of one axis rounded in the order of their
codes so that a whole split adds up to its line to the cent. A line that
changes amount or account takes its split with it.

**A retired value takes no new share.** A value with `active = false` is
refused on a new share, or on a share moved onto it, with
`analytic_value_retired`. The shares that already name it stay, are posted
with their document, and are carried onto what undoes them: the credit note
`cancel_document()` writes, and the mirror `reverse_entry()` writes. A default
naming a retired value does not pre-fill.

**The split of a posted ledger line moves in an open period only.** Writing,
changing or removing a share of a posted line is refused on or before the
lock date (`period_locked`) and in a closed fiscal year
(`fiscal_year_closed`), through `assert_period_open()`, as every posted change
is. It feeds no declaration, but it moves the report of the period, and a
closed period is read as it was closed.

**A product, and a contact, may carry a default value. It pre-fills the line
and never constrains it.** `products.analytic_value_id` and
`contacts.analytic_value_id`. When a line is written, or its product changes,
each default whose axis the line has no split on yet is added at 100 % — the
product's first, then the document contact's, or, when that contact has none,
the default of the contact it belongs to (`parent_id`), one level up and no
further — and only where the line's account carries a split; elsewhere the
default does not apply and says nothing. One product default serves both
sides, sale and purchase. `merge_contacts()` gives the kept contact the
absorbed one's default when it has none, as it does every empty field. The person changes or removes what was pre-filled like any other
row, as long as the document is a draft. This is the rule products already
follow (decision 0044).

**The product says what; the axis says what for.** The product covers invoice
lines and answers "what did this offer bring in and cost" (`product_report()`).
The axis covers the whole income statement, salaries and rent included, and
answers "what did this activity make" (`analytic_report()`). The two are not
merged: a product is not an axis value, and an axis value is not a catalogue
entry.

**An axis may be required.** `analytic_axes.required_on` is `none` by default,
or `expense`, `income` or `result` (both). On a required axis, every line of
that group carries the axis whole — its shares on the axis add up to 100 —
or posting refuses it, with `analytic_axis_required`: a document in
`post_document()`, before anything reaches the ledger, and an entry keyed by a
person as it is posted. What the database writes on its own is not asked,
because nobody keyed it and nobody could split it: the mirror of an entry and
a credit note that names what it undoes, which carry what the original
carried; an opening, a closing, an appropriation; an entry of a module; a
difference or a fee booked while a matching or a bank line is settled. A
retired axis requires nothing, and a fixed-asset line is never required to
carry one.

**`analytic_report(company, axis, from, to)` reads the ledger.** One row per
value of the axis that a posted ledger line of the period reaches, itself or
through a value below it (`row_kind` `value`), in the order of the tree with
its depth (`level`): the income, the expense, the result, and `fixed_assets`,
the net movement of the fixed-asset accounts over the period from the ordinary
entries, beside the result and never in it. A parent value holds the subtotal
of every value below it plus its own amount; its own amount alone is in the
`direct_` columns. Then one row `unassigned`, the part no split of this axis
reaches, and one row `total`, the whole period. The `direct_` amounts of the
values and the unassigned row add up, to the cent, to the total, and so do the
values of level 0 and the unassigned row; the total is the income statement
of the period — the same posted entries, the closing entry left out as the
income statement leaves it out.

## Consequences

- A document with no analytic split posts exactly as before: the grouping key
  has one more member, which is empty for every line written so far.
- Two lines on the same account and tax with different splits give two ledger
  lines where they used to give one. The entry balances as before.
- The split of a posted document is frozen with its lines
  (`document_posted`). The split of a posted ledger line is not: in an open
  period, a value keyed wrong is corrected on the ledger line, under
  `entries.write`, without crediting an invoice.
- A required axis is asked at posting. A split changed afterwards on a posted
  line, in an open period, is the person's, and is not asked again.
- A takeover of books from elsewhere (`import_books()`) posts its entries as
  a person would; with an axis required, the imported lines carry no split
  and are refused. The axis is required once the history is in.
- An analytic split on a balance-sheet account written before this record is
  not touched; the guard reads what is written from now on, and an archive
  imported from such an installation is loaded as it is.
- A parent's row is a subtotal: adding a parent to its children counts them
  twice. The `direct_` columns are the ones that add up.
- The schema version is left to the release process.

## The answers of 19/10/2026

1. A split of a posted ledger line follows the lock date and the closed fiscal
   years: refused there, by name, like other posted changes.
2. A contact with no default falls back to its parent, one level up.
3. One product default for both sides; no separate purchase default.
4. A retired value is refused on a new split; existing splits stay.
5. `analytic_report()` gives each parent the subtotal of its children plus its
   own amount, and a total row; the unassigned row stays.
6. An axis may be required, by an option on the axis (`required_on`), off by
   default; posting a document or an entry with a result line missing it is
   refused by name.
7. Fixed-asset accounts carry a split too (capex by project), read from the
   account type of the pack; third-party, tax and bank accounts stay refused.
8. The non-deductible share of a tax booked on the expense (`tax_on_base`)
   carries the split of its lines, and a test says so with a tax it builds.
9. The schema version is left to the release process.

## See also

- `supabase/migrations/20261019130000_an_analytic_value_is_entered_on_the_line.sql`
- `supabase/migrations/20261019130500_analytic_report.sql`
- `supabase/migrations/20260911120800_analytics_attachments.sql`
- `tests/analytics.test.ts`, `tests/analytics-rules.test.ts`
- [0074](0074-two-contacts-of-one-company-are-merged.md) — Two contacts of one company are merged
- [0008](0008-documents-and-entries-are-two-layers.md) — Documents and entries are two joined layers
- [0044](0044-a-product-is-a-catalogue-entry-in-the-core.md) — A product is a catalogue entry in the core, not stock
