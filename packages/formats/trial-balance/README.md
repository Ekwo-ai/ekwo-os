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

It knows no chart of accounts. The codes are the ones the file wrote; which
account of another chart each becomes is the importer's business. In
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os) that is `ekwo import
trial-balance <file> --opening-date <first day of the year>`.

MIT.
