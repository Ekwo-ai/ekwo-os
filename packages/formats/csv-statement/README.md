# `@ekwo-ai/csv-statement`

Reads a statement exported as **CSV** — by a bank, a payment service, a card
issuer — into plain objects, in TypeScript, with no dependencies.

A CSV is a table, not a format: every bank lays its own out, and the file
does not say which column is the date or how a number is written. So this
reader takes, beside the file, a **profile of its columns** — data the caller
gives and keeps, one per lay-out. There is one reader and no bank in it: a
new bank is a new profile, never new code.

```ts
import { readCsvStatement, type CsvStatementProfile } from '@ekwo-ai/csv-statement';

const profile: CsvStatementProfile = {
  delimiter: ';',
  dateFormat: 'DD/MM/YYYY',
  decimalSeparator: ',',
  columns: { date: 'Date', amount: 'Amount', counterparty: 'Name', description: 'Details', balance: 'Balance' },
};

const { statements, violations } = readCsvStatement(bytesOrString, profile, {
  account: 'GB82 WEST 1234 5698 7654 32', // the file names no account: the caller does
  currency: 'GBP',
});

const statement = statements[0];
statement.openingBalance; // { type: 'OPBD', amount: '100.00', currency: 'GBP', date: null } — from the running balance
statement.closingBalance; // { type: 'CLBD', amount: '547.50', currency: 'GBP', date: '2026-03-09' }
statement.balanced;       // true, false, or null when there is nothing to check
for (const line of statement.lines) {
  line.amount;      // '-800.00' — signed, a decimal string, never a float
  line.bookingDate; // '2026-03-05'
  line.row;         // the row of the file it was read from
}
```

It knows no database and no ledger. The shape it returns is declared in
[`src/types.ts`](./src/types.ts), imported from nowhere, and is **field for
field the shape [`@ekwo-ai/camt053`](../camt053/) declares for itself** — so
whatever takes a camt.053 that was read takes a CSV that was read, without an
adapter. What only a CSV says comes after those fields (`row`, `rowBalance`).

A format is not a country, and neither is a profile: nothing here assumes a
currency, two decimals, a language or the order of a day and a month.

## The profile, field by field

| Field | Required | What it says |
|---|---|---|
| `delimiter` | yes | The character between two fields: `,`, `;`, a tab, `\|`. Fields between double quotes may hold it, a line break and a doubled quote (RFC 4180). |
| `encoding` | no | `utf-8` (default, refused if the bytes are not), `iso-8859-1` or `windows-1252`. Never guessed: every sequence of bytes is valid Latin-1. |
| `skipRows` | no | Lines above the header — a title, an account line. Default 0. |
| `header` | no | Whether the first row read is a header. Default `true`. Without one, columns are named by their position. |
| `skipFooterRows` | no | Rows at the end that are not movements — a total. Default 0. |
| `dateFormat` | yes | `DD`, `MM`, `YYYY` (or `YY`) and what stands between them: `DD/MM/YYYY`, `MM/DD/YYYY`, `YYYY-MM-DD`, `DD.MM.YY`, `YYYYMMDD`. Where the parts are separated, a day or month of one digit is read too; a time after the date is left aside. `YY` at or above 80 is 19YY. |
| `decimalSeparator` | yes | `.` or `,`. |
| `thousandsSeparator` | no | The mark between groups of three digits, when the file writes one: a blank, `.`, `,`, `'`. Default none — and then `1,234.00` is refused, not read as 1.234. |
| `sign` | no | `as-written` (default): positive is money in. `inverted`: positive is money out, as a card statement writes a purchase. Applies to `amount`, `fee` and `balance`. |
| `newestFirst` | no | The file lists the newest row first. Lines come back oldest first either way. |
| `columns` | yes | Which column says what — below. |

A column is named by its **header**, as written (compared without the blanks
around it, and without regard to case), or by its **position, counted from 1**.

| Column | What it holds | Becomes |
|---|---|---|
| `date` | **Required.** The day the movement was booked. | `bookingDate` |
| `valueDate` | The value date, or the day of a card purchase. | `valueDate` |
| `amount` | One signed amount. | `amount` |
| `debit`, `credit` | **Or** money out and money in, in two columns. Each is taken in its direction whatever sign it is written with. One may be left out. | `amount` |
| `fee` | A fee taken on the movement, beside a gross amount (see below). | a second line |
| `currency` | The ISO 4217 code of each row. | `currency` |
| `counterparty` | The name of the other party. | `counterparty.name` |
| `counterpartyAccount` | Its account: an IBAN when it passes ISO 13616, else as written. | `counterparty.account` |
| `description` | The text of the movement. One column, or a list of them, kept in order. | `remittance.unstructured` |
| `reference` | The transaction id the bank or service gives the movement. | `bankReference` |
| `balance` | The balance of the account after the row. | `rowBalance`, and the two balances |

`amount` and `debit`/`credit` are one or the other; a profile with both, or
neither, is refused.

## What the caller says, and the file does not

`readCsvStatement(input, profile, options)`:

| Option | What it is |
|---|---|
| `account` | The account the file is of: an IBAN (returned as `kind: 'iban'` when it passes ISO 13616) or the identifier the bank gives it. A CSV names none; without it the account's identifier is empty, and an import has nothing to match the statement to. |
| `currency` | The ISO 4217 currency of the account. With a `currency` column, rows in another currency are left out as another balance and reported `other_currency`. |
| `openingBalance`, `closingBalance` | The balances the bank declares for the period, read from its own statement or app, as decimal strings (`1250.00`, `-40.10`). |
| `maxBytes` | Refuse a larger file unread. Default 32 MiB. |

## Balances

A statement is proved by its balances: opening plus every movement is the
closing, or a line is missing. A CSV may carry them in two ways, and may carry
neither:

- **A running balance column** (`columns.balance`). The opening balance is the
  first row's balance less its movement; the closing balance is the last row's.
  Every row's balance is checked against the one before it plus its movement,
  and a row that does not follow is `balance_mismatch`, with its row.
- **Declared by the caller** (`openingBalance`, `closingBalance`). They win
  over the running balance, and a disagreement between the two is reported.
- **Neither.** The statement comes back with `openingBalance` and
  `closingBalance` `null`, and `balanced` `null`: the reader proves nothing it
  was not given. An importer that requires a proof — `import_bank_statement()`
  of Ekwo OS refuses a statement with lines and no balances,
  `statement_without_balances` — gets it from the caller: the closing balance
  of the previous statement and the one the bank shows today.

Nothing is ever corrected: a statement that does not add up comes back as the
file wrote it, `balanced: false`, and the difference is in the message.

## A fee in its own column: two lines

A payment service writes a sale as a gross amount, the fee it kept, and the
net. With `columns.fee`, a row whose fee is not zero becomes **two lines** of
one entry (`entry` the same, `detail` 1 and 2, `detailCount` 2): the gross
amount, then the fee, both with the row's reference, date and counterparty.
The fee line's `additionalInformation` is the fee column's header, as the
file writes it.

Two lines, and not one net line, because they are matched to two different
things: the gross amount to the invoice the customer paid, in full, and the
fee to a charge. A net line would match neither. A caller who wants the net
names the net column as `amount` and leaves `fee` out.

## An example per kind of export

The profiles below are examples of **data**, as a caller would keep them. They
are tested in [`test/read.test.ts`](./test/read.test.ts).

A bank with a day before the month, a decimal comma and a running balance:

```ts
{
  delimiter: ';',
  dateFormat: 'DD/MM/YYYY',
  decimalSeparator: ',',
  thousandsSeparator: ' ',
  columns: { date: 'Date', valueDate: 'Value date', description: ['Label', 'Details'], amount: 'Amount', balance: 'Balance' },
}
```

A payment service's activity download — gross, fee, a transaction id, one
balance per currency (read with `{ currency: 'EUR' }`):

```ts
{
  delimiter: ',',
  dateFormat: 'DD/MM/YYYY',
  decimalSeparator: '.',
  thousandsSeparator: ',',
  columns: {
    date: 'Date', counterparty: 'Name', description: 'Type', currency: 'Currency',
    amount: 'Gross', fee: 'Fee', reference: 'Transaction ID', balance: 'Balance',
  },
}
```

A card statement — purchases written positive, newest first, a posting date
and a transaction date:

```ts
{
  delimiter: ',',
  dateFormat: 'MM/DD/YYYY',
  decimalSeparator: '.',
  sign: 'inverted',
  newestFirst: true,
  columns: { date: 'Post Date', valueDate: 'Transaction Date', description: 'Description', amount: 'Amount' },
}
```

## What is thrown, and what comes back as a violation

**Thrown** (`StatementFileError`, with a `code`, and the `row` it stopped on
where there is one): `too_large`, `unsupported_encoding` (bytes that are not
the encoding named, a replacement character, a NUL — a spreadsheet's own
format, UTF-16), `empty_file`, `malformed_csv` (a quote never closed),
`invalid_profile`, `missing_column` (a header without a column the profile
names, or with it twice; the message lists the columns the header has).

**Returned** in `violations`, with the row and, where there is one, the line:

| code | when |
|---|---|
| `balance_mismatch` | a running balance that does not follow, balances that do not add up, a declared balance the running one contradicts |
| `invalid_amount`, `invalid_date`, `booking_date_missing` | the line comes back with `null` there |
| `other_currency` | a row in another currency than the account's, left out |
| `mixed_currencies` | rows in several currencies and no `currency` named |

## What it does not do

- **It does not guess a profile.** Which column is the date is said; a reader
  that guessed would read a day as a month on the twelve first days of every
  month and nobody would see it. A caller may propose a profile from a preview
  of the file (`parseCsv()` is exported for that) and have a person confirm it.
- **It reads no status column.** An export that lists pending or refused
  movements beside completed ones is exported with the completed ones only.
- **It gives a statement no number**: its `id` is made of the days of its first
  and last line.
- **It converts nothing, matches nothing, and does not decide what a duplicate
  is.** A transaction id in `reference` is what lets an importer recognise the
  same movement in two overlapping exports.
- **It does not read a spreadsheet** (`.xlsx`, `.ods`): save it as CSV.

## Licence

MIT. See [`LICENSE`](./LICENSE).
