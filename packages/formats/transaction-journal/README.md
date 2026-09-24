# `@ekwo-ai/transaction-journal`

Reads a **transaction journal** saved as CSV — the report a ledger prints of
every transaction it posted, one after the other, each line of a transaction
on a row of its own — into plain objects, in TypeScript, with no
dependencies. Beside it, the list of accounts, exported the same way.

```ts
import { readTransactionJournal } from '@ekwo-ai/transaction-journal';

const books = readTransactionJournal([journal, accountList], { dateOrder: 'mdy' });

books.entries;    // [{ journal: 'Invoice', number: '1001', date: '2025-01-15', lines: […] }, …]
books.accounts;   // [{ code: '1200', name: 'Accounts Receivable (A/R)', type: 'Accounts receivable (A/R)' }, …]
books.violations; // a transaction that does not balance, a line that belongs to none
```

## The files

**The journal** (required). Such a ledger exports its reports as a
spreadsheet, not as CSV: open it and save it as CSV. A report is laid out for a
person, and nothing on a line names the transaction it belongs to, so it is
read in order:

- the **header** is the first row that names a `Date`, an `Account` (or an
  `Account #`), a `Debit` and a `Credit` — the title rows above it are passed
  over, and so is an empty first column;
- a row with an account and a **date starts** a transaction — unless it
  repeats the date, the `Transaction Type` and the `Num` of the transaction
  just before it, which a layout that prints them on every line does;
- a row with an account and **no date continues** the transaction above;
- a row with **no account ends** it: the total of a transaction, a blank row,
  the total of the report, the footer.

Optional columns: `Transaction Type` (kept as the journal of the entry), `Num`
(its number and reference), `Name` — or `Customer full name`, `Vendor`,
`Supplier`, `Employee` where the report shows those instead — and
`Memo/Description`.

- An **account** is identified by its number, `Account #`, where the report
  has the column — tick it among the report's columns before exporting — and
  otherwise by the name the list of accounts gives a number to, or by its
  name alone.
- A **date written in digits** — `03/04/2026` — is read in the order the
  caller names (`dateOrder: 'dmy' | 'mdy' | 'ymd'`) and refused without one:
  the order follows the region of the company, and the file does not say it.
  A date in ISO or with its month in letters (`Jan 15, 2025`) needs none.
- An **amount** is read as a spreadsheet displays it. In a comma-separated file
  the decimal mark is a point and a comma only groups thousands, three digits at
  a time (`1,234.50`). In a file separated by a semicolon or a tab the decimal
  mark is the one mark the number carries, and thousands are grouped by a space
  only. A negative is a minus or brackets. A currency symbol, or anything else,
  is refused.

**The list of accounts** (optional): `Account` (or `Full name`), `Type`, and
`Account #` where it has one; the rest is ignored. The type is kept in the
list's words.

## What it returns

The shape declared in [`src/types.ts`](./src/types.ts), which is, field for
field, the shape every reader of an accounting export in this repository
declares for itself. A report says no currency: it prints the company's and
does not name it, and no amount in another currency is read. Amounts are decimal strings, never negative. What does not add up comes back in
`violations`; what is not a journal is thrown as a `BooksFileError` with a
`code`.

It knows no chart of accounts: in [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os)
the correspondence is made by
`ekwo import transaction-journal <files…> --date-order mdy`.

## Sources

This reader was written against the **Journal** report of **QuickBooks
Online**, read on 24 September 2026 from its help centre:

- [Print a journal entry report](https://quickbooks.intuit.com/learn-support/en-us/help-article/journal-entries/print-journal-entry-report/L1IhAG8PT_US_en_US):
  the Journal report, its filter by transaction type, and its columns — `Name`,
  or `Customer full name`, `Employee`, `Vendor` in its place;
- [Customize reports](https://quickbooks.intuit.com/learn-support/en-us/help-article/customize-reports/customize-reports-quickbooks-online/L0gKmSawG_US_en_US)
  and [Export reports to Excel](https://quickbooks.intuit.com/learn-support/en-us/help-article/report-management/export-reports-excel-quickbooks-online/L7iAoP97n_US_en_US):
  the columns a report shows, its number format, and its export — to Excel or
  PDF, not to CSV;
- [Export your QuickBooks Online data](https://quickbooks.intuit.com/learn-support/en-us/help-article/list-management/export-reports-lists-data-quickbooks-online/L1xleDrLp_US_en_US):
  the Account List, the chart of accounts, exported to Excel the same way.

`ekwo import quickbooks-online <files…>` is the same as
`ekwo import transaction-journal`.

What those pages do not state — the exact text of the title and total rows,
whether a line repeats the date of its transaction — is why the reader finds
the header by its columns, and a transaction by the order of its rows under
either layout, rather than by position. The fixtures under `test/fixtures/`
are written by hand from those pages and hold no real data.

MIT.
