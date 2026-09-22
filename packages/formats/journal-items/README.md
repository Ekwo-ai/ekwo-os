# `@ekwo-ai/journal-items`

Reads an **export of journal items** — the lines of every entry, one row per
line, saved as CSV from the list view of an ERP whose ledger is a table of
lines — into plain objects, in TypeScript, with no dependencies. Beside it, the
chart of accounts and the partners exported from the same screen.

```ts
import { readJournalItems } from '@ekwo-ai/journal-items';

const books = readJournalItems([items, accounts, partners]); // any order; the last two are optional

books.entries;    // [{ number: 'INV/2025/00001', journal: 'Customer Invoices', date: '2025-01-15', lines: […] }, …]
books.accounts;   // [{ code: '400000', name: 'Receivable', type: 'Receivable' }, …]
books.contacts;   // the partners, with their tax ID and e-mail when the partners file has them
books.currency;   // the company currency the export states, or null
books.violations; // an entry that does not balance, a line of a draft entry
```

## The files

Each file is recognised by its header, so they may be given in any order.

**The journal items** (required). The columns are found by name, under either
spelling the export uses — the label a person reads, or the technical name of
the field an export for re-import writes:

| Column | Labels | Field names |
|---|---|---|
| the entry | `Number`, or `Journal Entry` | `move_name`, or `move_id` |
| journal | `Journal` | `journal_id` |
| date | `Date` | `date` |
| account | `Account` | `account_id` |
| partner | `Partner` | `partner_id` |
| label | `Label` | `name` |
| reference | `Reference` | `ref` |
| debit, credit | `Debit`, `Credit` | `debit`, `credit` |
| currency, amount | `Currency`, `Amount in Currency` | `currency_id`, `amount_currency` |
| company currency | `Company Currency` | `company_currency_id` |
| due date | `Due Date` | `date_maturity` |
| matching | `Matching #` | `matching_number` |
| status | `Status` | `parent_state` |

- Lines belong to one entry when they share its **number**; without that
  column, its display name.
- An **account** arrives as it is displayed, its code and then its name
  (`400000 Receivable`). With the chart beside it the display is matched whole;
  without, the code is what comes before the first space.
- A **partner** arrives as its name, and is identified by it.
- A line whose entry is **not posted** is refused in `violations`: filter the
  export on posted entries, which is what books are made of.
- **Dates** are ISO, `YYYY-MM-DD`; **amounts** have a point for decimal mark,
  a minus for a negative. A negative debit is a credit, and the other way
  round.
- An export with a **group-by** active cannot be saved as CSV; remove the
  grouping first. A spreadsheet export is saved as CSV before it is read.

**The chart of accounts** (optional): `Code`, `Account Name` or `Name`, `Type`
(or `code`, `name`, `account_type`). The type is kept in the source's words.

**The partners** (optional): `Name`, `Tax ID`, `Email`, `Company ID`, and the
country as a two-letter code (`Country/Country Code`) — a country written as
its name is not turned into a code.

## What it returns

The shape declared in [`src/types.ts`](./src/types.ts), which is, field for
field, the shape every reader of an accounting export in this repository
declares for itself. Amounts are decimal strings, never negative; the side is
the sign. What does not add up comes back in `violations` and the entry comes
back as written; what is not an export of journal items is thrown as a
`BooksFileError` with a `code`.

It knows no chart of accounts. Which account of another chart each code
becomes is the importer's business: in [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os),
`ekwo import journal-items <files…>`.

## Sources

This reader was written against the export of the **Journal Items** of Odoo
(Accounting), versions 17 and 18, read on 22 September 2026 from:

- [Export and import data — Odoo 17.0 documentation](https://www.odoo.com/documentation/17.0/applications/essentials/export_import_data.html)
  and [18.0](https://www.odoo.com/documentation/18.0/applications/essentials/export_import_data.html):
  the two modes of an export, the ISO dates, the field names of an export for
  re-import;
- the source of the accounting module, branch 17.0:
  [`account_move_line.py`](https://github.com/odoo/odoo/blob/17.0/addons/account/models/account_move_line.py),
  [`account_account.py`](https://github.com/odoo/odoo/blob/17.0/addons/account/models/account_account.py),
  [`res_partner.py`](https://github.com/odoo/odoo/blob/17.0/odoo/addons/base/models/res_partner.py) and
  [`export.py`](https://github.com/odoo/odoo/blob/17.0/addons/web/controllers/export.py):
  the label of every field above, the display name of an account, and the way a
  CSV is written — comma, double quotes, UTF-8, a point for decimals.

`ekwo import odoo <files…>` is the same as `ekwo import journal-items`.

The fixtures under `test/fixtures/` are written by hand from those pages and
hold no real data.

MIT.
