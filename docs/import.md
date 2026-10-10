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
through `opening_balance()`, and records the import in `book_imports`. The same
files imported twice are refused (`import_already_done`), with what the first
import wrote.

**The rehearsal** is the same function with `p_dry_run`: everything runs and is
rolled back, so a rehearsal is refused exactly as the import would be and shows
the numbers the entries would take.

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
