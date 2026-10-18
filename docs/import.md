# Taking over books kept elsewhere

Somebody who wants to try Ekwo on their own books arrives with them. They
come from another package, or from nowhere in particular — a spreadsheet —
and what they hold is the same everywhere: a chart of accounts, parties,
entries, the balances of a day. This page is how those get in.

## The three parts

```
file(s) ──reader──▶ books ──correspondence──▶ import_books() ──post_entry()──▶ ledger
         packages/formats/     @ekwo-ai/core          the schema
```

1. **A reader per source**, in [`packages/formats/`](../packages/formats/README.md),
   MIT and on its own. It reads a file and returns **books**: accounts,
   contacts, entries, an opening balance, and `violations` for what does not add
   up. Each declares the shape in its own `types.ts`; the shape is the same in
   all of them, field for field, and it is not a shared abstraction — the same
   choice the three statement readers made.
2. **The correspondence**, in `@ekwo-ai/core` (`importBooks()`,
   `proposeMapping()`): which account of the company's chart each account of
   the old books becomes, and which journal each old journal goes to. It is
   proposed, saved by the caller and given back. It is the one part only the
   user can settle.
3. **`import_books()`**, in the schema: the books, already in the company's
   codes, written in one transaction through `post_entry()` and
   `opening_balance()`.

The command line (`ekwo import`) and the MCP server (`import_books`) call the
same `importBooks()`. Neither holds a rule.

## The readers

| Source | Brick | Reads |
|---|---|---|
| `trial-balance` | `@ekwo-ai/trial-balance` | A CSV of `account`, `debit`, `credit` or one signed `balance`. Becomes the opening entry of a year, or of the day inside it the books were taken over; with it, the list of the invoices still open (`readOpenItems()`). |
| `fec` | `@ekwo-ai/fec` (`readFec()`) | The *fichier des écritures comptables*, found by the names of its columns, in any of the variants of the text. |
| `journal-items` | `@ekwo-ai/journal-items` | The lines of every entry exported as CSV from the list view of an ERP whose ledger is a table of lines, under its labels or its field names; the chart and the partners beside it. |
| `journal-report` | `@ekwo-ai/journal-report` | A journal report or a general ledger detail, saved as CSV from a cloud service's spreadsheet export; the chart and the contacts beside it. |
| `transaction-journal` | `@ekwo-ai/transaction-journal` | A transaction journal saved as CSV from a spreadsheet export, each transaction a run of rows under one date, type and number; the list of accounts beside it. |
| `xaf` | `@ekwo-ai/xaf` (`readXaf()`) | An XML Audit File Financial, version 3.2 or 4.0: accounts, parties, the opening balance with the day it opens, and every transaction, in one XML file whose totals are checked against its lines. |

A reader is **named after the file**: the same kind of export can come from
several places. A user looks for the software the file came from, so
`ekwo import` and `import_books` also take the name of the software whose
export a reader was written against — [`compatibility.md`](compatibility.md)
lists them, with the official page of each export. Each README says which
columns are read, and which pages the format was checked against on the day it
was written.

What they share, and why:

- **The header decides.** Columns are found by their names, never by their
  position, and the separator is the one the header row uses. A column the
  reader needs and does not find is refused by name. An XML file is found by
  its namespace, and its elements by their names.
- **Nothing is guessed.** The encoding is UTF-8 unless the caller says
  otherwise — or, for an XML file, unless its declaration does, and bytes that are not UTF-8 are refused, because every sequence
  of bytes is valid Latin. A date written in digits in an order the file does
  not state is refused until the caller names the order. An amount that could
  be read two ways — a comma in a comma-separated file — is refused.
- **Nothing is corrected.** An entry that does not balance comes back as the
  file wrote it, with a violation. The import then refuses books with a
  violation; it does not repair them.
- **Amounts never pass through a float.** They are added as integers of
  millionths and returned as decimal strings, never negative: the side is the
  sign.

## The correspondence

```json
{
  "version": 1,
  "source": "fec",
  "accounts": { "411000": "411000", "401ACME": null },
  "journals": { "VE": "SAL", "AN": "@opening", "*": "MISC" },
  "suggested": {
    "401ACME": { "target": "401000", "reason": "…" }
  }
}
```

Each account of the old books is matched to an account of the company's chart,
and each old journal to a journal. Ekwo proposes a candidate from the codes and
then checks it against what the files say about the account — its type, its
name, the side of its balance — because two charts can give the same digits to
different things. Each proposal is marked:

- **`exact`** — taken without asking;
- **`suggested`** — written under `suggested`, with its reason, for the user to
  confirm;
- **`none`** — nothing to suggest, and why;
- **`given`** — the caller's own answer, flagged `doubtful` where the files
  contradict it.

**Nothing is posted while an account the books use is only suggested**
(`import_unconfirmed_accounts`). The user confirms a suggestion by writing it
under `accounts`, or accepts all of them after reading them
(`--accept-suggestions`). A dry run prints what to read first.

`@opening` turns the entries of a journal into the opening entry of the year —
what the *à-nouveaux* of a FEC are. `*` stands for the entries of a source with
no journal.

**Given back, it wins.** Save the correspondence (`--save-mapping`), answer the
nulls, correct what is wrong, and give it back (`--mapping`).

## `import_books()`

```sql
import_books(p_company_id uuid, p_books jsonb,
             p_dry_run boolean default false,
             p_open_years boolean default false,
             p_allow_result_accounts boolean default false) returns jsonb
```

It runs as the caller and needs `entries.write` and `entries.post`. In one
transaction it opens the fiscal years the books need (with `p_open_years`),
finds or creates the parties, checks every account code before writing
anything, posts each entry through `post_entry()`, writes the opening balance
through `opening_balance()` — on the day the books give, with the open items of
`opening.items` — and records the import in `book_imports`. The same
files imported twice are refused (`import_already_done`), with what the first
import wrote.

**The rehearsal** is the same function with `p_dry_run`: everything runs and is
rolled back, so a rehearsal is refused exactly as the import would be and shows
the numbers the entries would take.

## An opening on the day of the takeover

Books are rarely taken over on the first day of a year. The trial balance of
the day before the takeover is the opening; the invoices and credit notes
still open that day come beside it, as a second CSV:

```
type,number,contact,contact name,amount,document date,due date,payment reference
sale_invoice,F2026-0412,C0001,Atelier Sirocco,1200.00,2026-05-12,2026-07-11,+++090/9337/55493+++
purchase_invoice,A-2026-118,F0001,Verger du Moulin,900.00,2026-06-20,2026-07-19,VM-5521
```

```sh
ekwo import trial-balance balance.csv --open-items open-items.csv \
  --opening-date 2026-07-01 --allow-result-accounts --dry-run
```

`type` is `sale_invoice`, `sale_credit_note`, `purchase_invoice` or
`purchase_credit_note`; `contact` is the code the balance names the party by;
`amount` is what is still open, positive, the type saying the side; the days
are written `YYYY-MM-DD`. `supplier reference` and `label` are optional
columns.

- **The opening entry is dated on the day of the takeover**, on the opening
  journal. With `--allow-result-accounts` it carries the income and expense of
  the months before at their figure of the day.
- **Each open item becomes a posted document** on the opening journal, booked
  on that day and dated on the day it was issued, with its number, its payment
  reference and its due date. Its one line names the suspense account of the
  company and carries no tax, so its entry puts the amount on the receivable
  or payable of its party against the suspense account: nothing is booked to
  revenue, expense or tax a second time. A statement line that quotes the
  reference finds it (`suggest_matches()`), and `settle_from_statement()` and
  `reconcile()` settle it, as they would an invoice issued here.
- **The items of an account are its whole balance.** The lines of the balance
  on a receivable or payable account the items fall on are written on the
  suspense account instead, which the items bring back to nothing; an account
  whose items do not add up to its line is refused
  (`opening_items_unbalanced`), with both figures.

Read on either side of the day: a trial balance or a statement that ends the
day before the takeover reads nothing of these books; one that covers the
whole year reads what the previous system held plus what was booked since; one
that starts on the day reads the year-to-date figures as a movement of its
period. A tax return reads none of it — the opening carries no tax and no box,
and the returns of the months before were filed from the previous system.

The same is `opening_balance(…, p_opening_date, p_items)` in the schema, where
each item names its contact by id, and the MCP tool `opening_balance`
(`opening_date`, `items`). See
[decision 0067](decisions/0067-an-opening-on-the-day-of-the-takeover.md).

## Invoices and their pieces

The ledger is the minimum an import brings. When the former system also holds
the invoices — a purchase with its supplier, lines and taxes, and the PDF
behind it — bring them in as documents: the purchase or sale becomes a
`documents` row, its entry is the one the document posts, and the PDF goes on
the document (`attachments.entity_type = 'document'`). Never hang the PDF on a
ledger entry that stands in for an invoice: a document is what a reader opens
to find the receipt, and an entry posted by a document refuses a file
(decision 0069). The documents of an open year replace the imported entries:
each document is posted, and the entry imported for the same invoice is
reversed on its own date, so the trial balance ends unchanged account by
account. A closed year is reopened first with `reopen_fiscal_year()`, which
refuses (`next_fiscal_year_in_use`) as soon as the following year holds a
posted entry: the history of such a year stays in the ledger as imported.

## What an import does not do

- **No tax.** A line arrives with an account and an amount, not with the tax
  that produced it. The history feeds the ledger, the trial balance and the
  financial statements, and no box of a VAT return: a period kept elsewhere
  was declared from where it was kept.
- **No matching yet.** The readers keep the reconciliation mark of each line
  (`matching`), and the import does not re-apply it: an open receivable is
  matched against its payment in Ekwo, with `reconcile`.
- **No chart.** An account the company's chart does not have is not created.
  The correspondence points it at one that exists, or the user adds it first.
- **No bank statement.** A statement is not books: it books nothing, and its
  lines wait for a payment. `ekwo import camt.053 | coda | cfonb120` hands it
  to `import_bank_statement()`, the MCP server's tool of the same name.

## Adding a source

A reader in `packages/formats/`, returning the shape above from fixtures that
hold no real data; one line in `BOOK_SOURCES` and in `readBooks()` of
`packages/core/src/books/imports.ts`; its README, with the pages the format was
read from. No second command, no second function in the schema.
