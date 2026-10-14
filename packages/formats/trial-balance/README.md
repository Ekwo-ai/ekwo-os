# `@ekwo-ai/trial-balance`

Reads a **trial balance written as CSV** — one row per account, a debit and a
credit, or one signed balance — into plain objects, in TypeScript, with no
dependencies.

It is the one thing every accounting package prints and every spreadsheet
saves, which makes it the way in for books that come from anywhere: the
balances of the day the new books open on.

```ts
import { readTrialBalance } from '@ekwo-ai/trial-balance';

const books = readTrialBalance(bytesOrString);

books.opening;    // [{ account: '512000', debit: '8400.00', credit: '0.00', contact: null, … }, …]
books.accounts;   // [{ code: '512000', name: 'Bank', type: null }, …]
books.contacts;   // the parties a receivable or a payable row names
books.violations; // [{ rule: 'unbalanced', message: '…', row: null }] when it does not balance
```

## The file

A header row, then one row per account. The columns are found by their name,
without regard to case, and without the `*` some exports put on a required
column:

| Column | Names accepted | |
|---|---|---|
| account | `account`, `account code`, `code` | required |
| name | `name`, `account name` | optional |
| debit, credit | `debit`, `credit` | both, or… |
| balance | `balance` | …one signed balance, positive in debit |
| contact | `contact`, `party` | optional: the customer or supplier of a receivable or payable row |
| contact name | `contact name`, `party name` | optional |
| label | `label`, `description` | optional |

- A row with a debit **and** a credit is **netted**: a trial balance prints the
  totals of each side, and 100 in debit with 30 in credit opens at 70 in
  debit. A row that nets to zero opens nothing and is left out.
- The **separator** is read from the header: the first of `,`, `;` and a tab it
  holds outside quotes. Fields may be quoted as RFC 4180 says.
- The **decimal mark** is a point. A comma is read as one only in a file
  separated by something else, where it cannot be a separator of thousands. No
  thousands separator, no currency sign, no exponent: each is refused rather
  than read one way or the other.
- The **encoding** is UTF-8, fatally. A file saved in Latin-1 is said to be so
  (`{ encoding: 'iso-8859-1' }`); it is never guessed, because every sequence
  of bytes is valid Latin-1.

## What it returns

The shape declared in [`src/types.ts`](./src/types.ts) — accounts, contacts,
entries, an opening balance, violations — which is, field for field, the shape
every reader of an accounting export in this repository declares for itself.
A trial balance fills `opening` and leaves `entries` empty. It says no
currency and no date: the file has neither, and whatever takes the balance is
told the day it opens on.

What does not balance comes back in `violations`, and the rows come back as
written. What is not a trial balance at all — no account column, a debit
column beside a balance column, an amount that is not one — is thrown as a
`BooksFileError` with a `code`.

## The open items beside it

The trial balance says what the receivable account holds; the aged balance
printed beside it says who owes it, under which number. `readOpenItems()`
reads that list, one row per invoice or credit note still open:

```ts
import { readOpenItems } from '@ekwo-ai/trial-balance';

const { items, contacts, violations } = readOpenItems(bytesOrString);

items; // [{ type: 'sale_invoice', number: 'F2025-0412', contact: 'C0001', amount: '1200.00',
       //    documentDate: '2025-12-12', dueDate: '2026-01-11', paymentReference: '+++090/9337/55493+++', … }]
```

| Column | Names accepted | |
|---|---|---|
| type | `type`, `document type` | required: `sale_invoice`, `sale_credit_note`, `purchase_invoice` or `purchase_credit_note` |
| number | `number`, `document number`, `invoice number` | required |
| contact | `contact`, `party` | required: the code the balance names the party by |
| contact name | `contact name`, `party name` | optional |
| amount | `amount`, `open amount`, `amount open` | required: what is still open, positive — the type says the side |
| document date | `document date`, `issue date`, `date` | required, `YYYY-MM-DD` |
| due date | `due date` | optional, `YYYY-MM-DD` |
| payment reference | `payment reference`, `structured reference` | optional |
| supplier reference | `supplier reference` | optional |
| label | `label`, `description` | optional |

A day is written `YYYY-MM-DD` and nothing else: one written in digits only is
read differently on each side of an ocean, and is refused rather than guessed.
A row that lacks a required value comes back in `violations` and is left out;
an unknown type, a signed amount or a day that is not one is thrown as a
`BooksFileError`. Separator, decimal mark and encoding are read as for the
balance.

## Where it goes

It knows no chart of accounts. The codes are the ones the file wrote; which
account of another chart each becomes is the importer's business. In
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os) that is `ekwo import
trial-balance <file> --opening-date <day> [--open-items <file>]`, where the day
is the first of a year or the day inside it the books were taken over, and
each open item becomes a posted document.

MIT.
