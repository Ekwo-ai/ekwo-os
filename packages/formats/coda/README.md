# `@ekwo-ai/coda`

Reads a **CODA** file — the *coded statement of account* Belgian banks deliver,
records of 128 characters in fixed positions — into plain objects, in
TypeScript, with no dependencies.

Give it the file and it gives you the statements in it, their lines, and the
list of what does not add up.

```ts
import { readCoda } from '@ekwo-ai/coda';

const { statements, violations } = readCoda(bytesOrString);

for (const statement of statements) {
  statement.account.identifier; // { kind: 'iban', value } or { kind: 'other', value, scheme, issuer }
  statement.openingBalance;     // { type: 'OPBD', amount: '1000.00', currency: 'EUR', date: '2026-03-04' }
  statement.closingBalance;
  statement.balanced;           // true, false, or null when it could not be checked
  for (const line of statement.lines) {
    line.amount;                // '-450.50' — signed, a decimal string, never a float
    line.bookingDate;           // '2026-03-05'
    line.counterparty;          // { name, account, agentBic, ultimateName }
    line.remittance;            // { unstructured: [...], structured: [{ reference: '202600010704', type: 'SCOR', issuer: 'BBA' }] }
    line.bankReference;         // the bank's own reference for the movement
  }
}
```

It knows no database and no ledger. The shape it returns is declared in
[`src/types.ts`](./src/types.ts), imported from nowhere, and is **field for
field the shape [`@ekwo-ai/camt053`](../camt053/) declares for itself** — so
whatever takes a camt.053 that was read takes a CODA that was read, without an
adapter. What only CODA says comes after those fields, under its own names
(`sequenceNumber`, `detailNumber`, `transactionCode`, `globalisationCode`,
`structuredCommunication`, `information`, `freeCommunications`…).

A format is not a country. CODA happens to be Belgian the way Factur-X happens
to be French and German; nothing here assumes the euro, a Belgian account or a
language, and the tests read a pound and a dinar account.

## What it does

- Reads **version 2** of the standard — records 0, 1, 2.1/2.2/2.3, 3.1/3.2/3.3,
  8, 4 and 9 — and refuses version 1 by name: under the same name it is another
  lay-out.
- Returns **every statement** of the file. A physical file holds one CODA per
  account and per day, one after the other, and each violation says which.
- Identifies the account by **what record 1 says it is**: an IBAN (structures 2
  and 3) or a domestic number (0 and 1), with its currency. An IBAN is held
  against ISO 13616 and returned as written when it fails (`invalid_iban`).
- Signs every amount from the account holder's side and returns it as a
  **decimal string**. CODA writes twelve digits and **three decimals** whatever
  the currency; the reader adds on integers of thousandths and returns two
  decimals, and the third when the file wrote one that is not zero. Nothing is
  rounded.
- Checks that **old balance + movements = new balance**, to the last decimal.
  When it is not, the statement comes back as the bank wrote it, `balanced` is
  `false`, and `balance_mismatch` says the difference. **Nothing is corrected.**
- Holds the **trailer record** against the file: the number of records 1, 2, 3
  and 8, and the debit and credit totals, which the standard defines as the sum
  of the movement records *with detail number 0000*
  (`record_count_mismatch`, `debit_total_mismatch`, `credit_total_mismatch`). A
  file that lost a record on the way fails all three at once.
- **Never counts a total and its details twice.** A movement is the record with
  detail number `0000`; the records that follow under the same sequence number
  are its details (types 5, 6, 7, 8, and 9 beneath a 7). The movement is
  **split into its details when, and only when, they add up to it exactly** —
  each line then keeps its own counterparty, communication and references, plus
  `entry`, `detail`, `detailCount` and `entryAmount` to put it back together.
  Otherwise it stays one line and `batch_not_split` says why. Either way the
  lines add up to what moved on the account. It is the rule of the camt.053
  reader, for the same reason: reconciliation wants the transaction, the
  balance wants the movement.
- Returns the **Belgian structured communication** (types 101 and 102) as its
  twelve digits with `type: 'SCOR'`, `issuer: 'BBA'` — which is how a camt.053
  carries the same payment — **checks its modulo 97** (where a remainder of
  zero is written 97) and, when it fails, **reports it and returns it as
  written** (`invalid_structured_reference`). `formatBelgianReference()` gives
  the `+++123/4567/89002+++` of the invoice. An ISO 11649 reference (type 100)
  is treated the same way, with `issuer: 'ISO'`.
- Puts a **free communication back together** from the three records it is cut
  across, and keeps it apart from a structured one.
- Reads the SEPA direct debit out of structured communication **127**: the
  mandate, the communication, the reason.
- Keeps **every other structured communication as written**
  (`structuredCommunication: { type, text }`) rather than half decoding it.
- Attaches the **information records** (3) to their movement: the free ones
  make `additionalInformation`; type 001 names the counterparty when record 2.3
  does not; 008 and 009 name the party behind it.

## A statement is hostile input

It arrives by e-mail, from a download, from a third party's API.

- **Every record is 128 characters or the file is refused**
  (`invalid_record_length`, with the record's number). Nothing is padded and
  nothing is trimmed: a format of positions that is off by one is off for every
  field after it. A file with no line break at all is read as consecutive
  records, if its length is a whole number of them.
- **An unknown record is refused by name** (`unknown_record`), and so is a
  known one out of place (`unexpected_record`): a 2.3 whose 2.1 is another
  movement, a movement before the old balance, a second header before a
  trailer. A file that stops before its trailer is `incomplete_statement`.
- **UTF-8, decoded fatally**, which reads the ASCII the standard writes.
  `{ encoding: 'iso-8859-1' }` is said by the caller and **never guessed** —
  every sequence of bytes is valid ISO-8859-1, so a guess could not fail. A
  control character or a replacement character is `unsupported_encoding`: the
  file was decoded wrongly by somebody already.
- **Size** is checked before a record is read (`maxBytes`, 32 MiB by default).

## What is thrown, and what comes back as a violation

**Thrown** (`StatementFileError`, with a `code` and the `record` it stopped on):
`too_large`, `unsupported_encoding`, `empty_file`, `invalid_record_length`,
`unknown_record`, `unexpected_record`, `unsupported_version`,
`inconsistent_record` (the new balance is of another account than the old one),
`incomplete_statement`.

**Returned** in `violations`, with the statement and the line it is on:

| code | when |
|---|---|
| `balance_mismatch` | old balance + movements ≠ new balance; the message says the difference |
| `record_count_mismatch`, `debit_total_mismatch`, `credit_total_mismatch` | the trailer disagrees with the file |
| `closing_balance_missing` | no record 8 — which is how the standard writes a day without movement; nothing is invented |
| `separate_application` | the header says the file is an extract; its balances are zeroed by the standard and prove nothing |
| `currency_missing` | the account zone carries no currency; none is assumed |
| `invalid_amount`, `invalid_direction`, `invalid_date`, `booking_date_missing` | the line comes back with `null` there |
| `invalid_iban` | the account is announced as an IBAN and fails its check digits |
| `invalid_structured_reference` | a structured communication fails its own modulo 97 — returned as written |
| `batch_not_split` | see above |

## What it does not do

- **It converts nothing, matches nothing, and does not decide what a duplicate
  is.**
- **It does not explain the transaction code.** The eight digits are returned,
  apart (`transactionCode`) and whole (`bankTransactionCode.proprietary`); the
  sixty pages of annex II that say what each means are not in this package.
- **It decodes four structured communications** (100, 101, 102, 127) out of
  some twenty-five. The others are returned as written.
- **It does not check the link and next codes** (positions 126 and 128): the
  records that follow are what is read, not what was announced.
- **It does not read version 1**, and it does not read a year before the pivot
  as this century: `YY` is 20YY under `pivotYear` (80 by default) and 19YY from
  it.
- **It does not read Windows-1252.** A euro sign at byte 0x80 is a control
  character of ISO-8859-1 and is refused; decode the file and pass the string.

## The bank reference, and the same month in two formats

`bankReference` is the "reference number of the bank" of record 2.1. The
standard says of it (§ 7.4): *"purely informative … The bank may change this
reference without prior notice. Consequently, it is not recommendable to apply
any kind of programming in this field."* It is returned because it is what the
file says, blank or all zeros as `null`.

A reader does not decide what a duplicate is, but it should say what it gives
the one who does: **nothing in the standard promises that this reference is the
`AcctSvcrRef` the same bank writes in a camt.053 of the same day.** Where it
is, a core that keys a line on its bank reference will recognise it across the
two formats; where it is not, it will not.

## Sources

- Febelfin, *Coded statement of account (CODA)*, **version 2.6** (February
  2018),
  <https://febelfin.be/media/pages/publicaties/2021/gecodeerde-berichtgeving-coda/c580ddf2b4-1694763197/standard-coda-2.6-en.pdf>,
  and **version 2.8** (November 2025),
  <https://febelfin.be/media/pages/publicaties/2023/febelfin-standaarden-voor-online-bankieren/d7168c5c37-1764229602/standard-coda-en_-2025.pdf>
  — both downloaded on 18 September 2026. The lay-out of the records (annex I)
  is the same in both; 2.7 and 2.8 add card schemes and a tax category.
- ISO 13616 (IBAN), ISO 11649 (creditor reference), ISO 7064 (MOD 97-10).

## What is verified, and what is not

**Verified**: every position this reader takes was written from annex I of the
standard, and the test builder (`test/build.ts`) was written from the same
annex, separately from the reader — so a fixture is a second reading of the
lay-out, and the two have to agree. The fixtures under `test/fixtures/` are
what the builder writes, compared on every run.

**Not verified** — and this is the larger half:

- **No file from a bank has been read.** Every statement here is invented,
  because a real one is somebody's account. Reader and builder share an author
  and a reading of the standard: where that reading is wrong, both are, and the
  tests pass. *The first real file from each bank is a test nobody has run.*
- **How banks number details.** The standard has the detail number go up for
  each record 2.1 *and* each record 3.1 of a movement; this reader relies on
  the sequence number and on `0000` only, and on the type digit of the
  transaction code for what is a detail of what.
- **The globalisation code** (position 125) is returned and not used. The
  hierarchy is read from the transaction type, which the trailer's own
  definition of its totals supports; a bank that globalises otherwise would
  show as `batch_not_split`, not as a wrong balance.
- **Whether details always add up.** Where they do not — a detail given for
  information, a tax shown and not charged — the movement stays one line and
  says so. That is safe, and it is not the same as understood.
- **The counterparty's account** "comes in the structure of the initial
  payment": it is an IBAN when it passes ISO 13616, else what was written.

## Licence

MIT. See [`LICENSE`](./LICENSE).
