# `@ekwo-ai/journal-report`

Reads a **journal report**, or a **general ledger detail**, saved as CSV — the
report a cloud ledger prints of every journal it posted, one row
per line with the number of its journal — into plain objects, in TypeScript,
with no dependencies. Beside it, the chart of accounts and the contacts, which
the same ledger exports as CSV directly.

```ts
import { readJournalReport } from '@ekwo-ai/journal-report';

const books = readJournalReport([report, chart, contacts], { dateOrder: 'dmy' });

books.entries;    // [{ number: '102', journal: 'Receivable Invoice', date: '2025-01-15', lines: […] }, …]
books.accounts;   // [{ code: '090', name: 'Business Bank Account', type: 'Bank' }, …]
books.violations; // a journal that does not balance
```

## The files

**The report** (required). Such a service exports its reports as a
spreadsheet, not as CSV: open it and save it as CSV. A report is laid out for a
person, so:

- the **header** is the first row that names a `Date`, an `Account Code`, a
  `Debit` and a `Credit` — the title rows above it are passed over;
- a **line** is a row whose date cell holds a date; the rows that head a group,
  total it, or give an opening or closing balance are passed over;
- lines are gathered into entries by their **journal number** (`Journal ID`,
  `Journal Number`, `Journal #`), which the report has to carry: add the column
  in the report's column picker before exporting it, with the account code. A
  report without it is refused by name — there would be no way to put its lines
  back into entries.

Optional columns: `Source` (kept as the journal of the entry), `Account`,
`Description`, `Narration`, `Reference`, `Contact`.

- A **date written in digits** — `03/04/2026` — is read in the order the
  caller names (`dateOrder: 'dmy' | 'mdy' | 'ymd'`) and refused without one:
  the order follows the region of the organisation, and the file does not say
  it. A date in ISO or with its month in letters (`3 Apr 2026`) needs none.
- An **amount** is read as a spreadsheet displays it. In a comma-separated file
  the decimal mark is a point and a comma only groups thousands, three digits at
  a time (`1,234.50`). In a file separated by a semicolon or a tab the decimal
  mark is the one mark the number carries, and thousands are grouped by a space
  only. A negative is a minus or brackets. Anything else is refused.

**The chart of accounts** (optional): `*Code`, `*Name`, `*Type`, the rest
ignored. Codes are kept as text: `090` stays `090`.

**The contacts** (optional): `*ContactName`, `AccountNumber`, `EmailAddress`,
`TaxNumber`, `CompanyNumber`; the country only when it is written as a
two-letter code.

## What it returns

The shape declared in [`src/types.ts`](./src/types.ts), which is, field for
field, the shape every reader of an accounting export in this repository
declares for itself. A report says no currency: it prints the organisation's
and does not name it. Amounts are decimal strings, never negative. What does
not add up comes back in `violations`; what is not a report is thrown as a
`BooksFileError` with a `code`.

It knows no chart of accounts: in [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os)
the correspondence is made by `ekwo import journal-report <files…> --date-order dmy`.

## Sources

This reader was written against the reports of **Xero**, read on 22 September
2026 from its help centre:

- [General Ledger Detail report](https://central.xero.com/0/article/General-Ledger-Detail-report)
  and [Journal report](https://central.xero.com/0/article/Journal-report): the
  columns each offers, the Journal ID and Account Code columns of the column
  picker, the grouping by account or none;
- [Export or print a report](https://central.xero.com/0/article/Export-or-print-a-report):
  reports export to PDF, a spreadsheet or Google Sheets, not to CSV;
- [Export or print your chart of accounts](https://central.xero.com/0/article/Export-or-print-your-chart-of-accounts)
  and [Import a chart of accounts](https://central.xero.com/s/article/Import-a-chart-of-accounts):
  the columns of the chart and the account types;
- [Export contacts out of Xero](https://central.xero.com/0/article/Export-contacts-out-of-Xero)
  and [Import contacts into Xero](https://central.xero.com/0/article/Import-contacts-into-Xero):
  the columns of the contacts file.

`ekwo import xero <files…>` is the same as `ekwo import journal-report`.

What those pages do not state — the exact text of the title and total rows —
is why the reader finds the header by its columns and a line by its date,
rather than by position. The fixtures under `test/fixtures/` are written by
hand from those pages and hold no real data.

MIT.
