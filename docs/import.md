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
| `trial-balance` | `@ekwo-ai/trial-balance` | A CSV of `account`, `debit`, `credit` or one signed `balance`. Becomes the opening entry of a year. |
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
  "accounts": { "411000": "411000", "401ACME": null, "471200": null },
  "journals": { "VE": "SAL", "AN": "@opening", "*": "MISC" },
  "suggested": {
    "401ACME": { "target": "401000", "reason": "the longest beginning of the code the chart has; its name, \"Acme, supplier\", says a payable account, and 401000 Suppliers is a payable account" }
  }
}
```

**How an account is proposed.** The codes give a candidate — never the
country:

1. the same code, where the chart has it;
2. the same digits once the zeros a chart pads with on the right are set
   aside: `411` and `411000`;
3. the account of the chart whose digits are the longest beginning of the old
   code, three digits at least: `401ACME` and `401000`.

A tie is no answer, two digits are no answer, a deprecated account is never
proposed.

**Then the files are held against it**, because two charts give the same
digits to different things: `610` is the receivable of one chart and `6100`
an expense of another, and a correspondence made from the digits alone would
post customers to carriage costs without a word. What the files say of the
old account, strongest first:

1. the type the export gives it (`Accounts Receivable`, `Expenses`,
   `asset_receivable`…), where it gives one;
2. a name that is the candidate's own name in the chart;
3. a receivable, a payable or a bank named in its name, in whatever language
   the books were kept — `Clients`, `Debiteuren`, `Suppliers`, `Banque` — and
   not when the name turns it (`advances from customers`, `bank charges`);
4. the side its balance is on in the files. The weakest: it confirms, and
   where it disagrees — an accumulated depreciation, an overdrawn bank — it
   leaves the candidate to the user rather than dropping it.

Each is compared with the type of the candidate in the chart. Each proposal
carries its `basis`, its `match` — `same-code`, `same-digits`, `prefix`,
`kind` — and its `reason`:

- **`exact`**: the same code, and the files say the same kind of account, or
  its own name. Only this is taken without asking.
- **`suggested`**: any other candidate, and the same code where the files say
  nothing. It stays out of `accounts` and is written under `suggested`, with
  its reason. A candidate the files contradict is dropped, and the one account
  of the chart of the kind they say — the only receivable, the only payable,
  the only bank — is suggested in its place (`kind`).
- **`none`**: nothing to suggest, and the reason why.
- **`given`**: the caller's answer. It is used as it is; where the files
  contradict it, it is still marked `doubtful`, with the reason, so a
  correspondence saved from an earlier proposal is not trusted blind.

**Nothing is posted while a line the books use is only suggested**
(`import_unconfirmed_accounts`). The user confirms a suggestion by writing its
code under `accounts`, or accepts all of them at once after reading them
(`--accept-suggestions`, `accept_suggestions`). A dry run prints the lines to
read first, each with its reason.

**How a journal is proposed**: the company's journal of the same code; the
opening, `@opening`, for the journal whose code is the one the pack opens its
years on; otherwise the company's general journal. `*` stands for the entries
of a source that has no journal — a trial balance, a report without a Source
column.

**`@opening`** turns the entries of that journal into the opening entry of the
year they are dated on: their lines go to `opening_balance()`, not to entries of
their own. That is what the *à-nouveaux* of a FEC are. The entries mapped to it
have to share one date, the first day of a fiscal year.

**Given back, it wins.** The caller saves the correspondence
(`--save-mapping`), answers the nulls, corrects what is wrong, and gives it back
(`--mapping`). What it answers is used as it is; what it does not answer is
proposed again; `suggested` is never read back. Nothing is posted while a used
account or journal is null.

## `import_books()`

```sql
import_books(p_company_id uuid, p_books jsonb,
             p_dry_run boolean default false,
             p_open_years boolean default false,
             p_allow_result_accounts boolean default false) returns jsonb
```

Invoker, so everything the caller may not do is refused to them — it needs
`entries.write` and `entries.post`, and says so by name. In one transaction:

1. **The years.** A date that falls in no fiscal year is refused
   (`import_outside_fiscal_year`), or, with `p_open_years`, opened by
   `import_fiscal_year_for()` as a year of the same length and on the same first
   day as the company's earliest — the one thing the books say about how the
   company counts its years.
2. **The parties**, by the code the source gave them (`contacts.auxiliary_code`),
   then by their name, or created. The core says what each is from where its
   lines are booked: on a receivable a customer, on a payable a supplier, on
   both, both.
3. **The accounts**: every code the lines name is looked up before anything is
   written, and the missing ones are refused together (`unknown_account`).
4. **The entries**, each inserted as a draft and posted by `post_entry()`, which
   numbers it on its journal — or keeps the old number, with `keep_numbers`,
   where the country allows a number chosen by hand or the caller holds
   `entries.import`. The old number is otherwise kept as the reference.
5. **The opening**, through `opening_balance()`, which refuses an income or
   expense account unless `p_allow_result_accounts` — books taken over in the
   middle of a year — and refuses a second opening in the same year.
6. **The record**, one row of `book_imports`: the source, the checksum of the
   files, the counts, the first and last number. The checksum is unique per
   company, so the same files a second time are refused
   (`import_already_done`) rather than counted twice. The refusal says what
   the first import was: the files, the source, the minute (UTC), and what it
   wrote — its entries and their numbers, its opening entry, its lines.

**The rehearsal** is the same function with `p_dry_run`: it runs all six steps
inside a block that it then leaves by an exception, which rolls every one of
them back — the way `rehearse_post_document()` does. The answer is a variable,
not part of the transaction, and survives. So a rehearsal is refused exactly as
the import would be, and the numbers it shows are the ones the entries would
take now.

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
