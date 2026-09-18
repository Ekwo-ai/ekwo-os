# `@ekwo-ai/camt053`

Reads an **ISO 20022 bank-to-customer statement** — `camt.053`, the account
statement banks deliver as XML — into plain objects, in TypeScript, with no
dependencies.

Give it the file and it gives you the statements in it, their lines, and the
list of what does not add up.

```ts
import { readCamt053 } from '@ekwo-ai/camt053';

const { version, statements, violations } = readCamt053(bytesOrString);

for (const statement of statements) {
  statement.account.identifier; // { kind: 'iban', value } or { kind: 'other', value, scheme, issuer }
  statement.openingBalance;     // { type: 'OPBD', amount: '1000.00', currency: 'EUR', date: '2026-03-01' }
  statement.closingBalance;
  statement.balanced;           // true, false, or null when it could not be checked
  for (const line of statement.lines) {
    line.amount;                // '-450.50' — signed, a decimal string, never a float
    line.bookingDate;           // '2026-03-05'
    line.counterparty;          // { name, account, agentBic, ultimateName }
    line.remittance;            // { unstructured: ['Invoice 2026-0107'], structured: [{ reference, type, issuer }] }
    line.bankReference;         // the bank's own reference for the movement
  }
}
```

It knows no database, no ledger and no country. The shape it returns is
declared in [`src/types.ts`](./src/types.ts) and imported from nowhere.

Every other brick beside this one *writes* a file an administration takes. This
one *reads* a file a bank sent, and that changes what has to be proved: not
that the output is valid, but that the input was understood — and that a file
written to hurt the reader does not.

## What it does

- Reads **versions 02 to 14** of the message, and **says which one it read**
  (`version`, `namespace`). The version is the last part of the namespace of
  the document element, and nothing is assumed. The same invented statement is
  written in each of the thirteen versions, held against the schema ISO
  publishes for that version, and has to read to the same objects out of all
  thirteen. A later version is still read and reported as
  `version_not_verified`; version 01 is refused, because under the same name it
  is another message.
- Returns **every statement** of the file — a message may carry several
  accounts — and says on each violation which statement it is about.
- Identifies an account by **what the file gives**: an IBAN *or* `Othr/Id` with
  its scheme and issuer. ISO 20022 offers the choice because half the world has
  no IBAN; a reader that returned only IBANs would read half the statements.
- Signs every amount from the account holder's side — money in is positive, an
  overdrawn balance is negative — and returns it as a **decimal string with the
  digits the file wrote**. Sums are made on integers of hundred-thousandths
  (the schema allows five decimals); no figure passes through a `number`.
- Checks that **opening balance + booked entries = closing balance**, to the
  last decimal. When it is not, the statement comes back as the bank wrote it,
  `balanced` is `false`, and `balance_mismatch` says the difference. **Nothing
  is corrected**: a reader that adjusts a balance hides the one fact the check
  exists to show — a truncated export, a missing page, a line lost on the way.
- Counts only **booked** entries (`BOOK`). A pending or informational entry is
  returned, marked `booked: false`, and left out of the arithmetic, which is
  what the bank did when it computed the closing balance.
- Keeps the **structured communication and the free one apart**, and keeps both
  when a payment carries both. A creditor reference is something a payer copied
  from an invoice and a machine can match; free text is something a person
  typed. Folding one into the other throws away the difference reconciliation
  lives on.
- **Splits a batch into its transactions** — one line per `TxDtls` — when, and
  only when, every transaction carries an amount in the entry's currency and
  they add up to the entry exactly. Each line then keeps its own references,
  counterparty and communication, plus `entry`, `detail`, `detailCount` and
  `entryAmount` to put the batch back together. Otherwise the entry stays one
  line and `batch_not_split` says why. Either way the lines of a statement add
  up to what moved on the account, so the balance check does not depend on the
  choice. (Reconciliation wants the transaction; the balance wants the entry.
  The split is made only where both get what they want.)
- Names the **counterparty** as the debtor of money coming in and the creditor
  of money going out — and the other way round when `RvslInd` says the entry
  undoes an earlier one, where the parties keep the roles they had in the
  original: a transfer that bounced comes back *from* the party it was sent to.
- Takes the **day the bank wrote**. `2026-03-31T23:30:00+02:00` is 31 March; it
  is not moved to UTC, which would book it on another day for half the planet.
- Returns the bank's own reference (`AcctSvcrRef`, of the transaction, else of
  the entry), the entry reference, the end-to-end identifier **as written** —
  including the `NOTPROVIDED` placeholder, which is the bank's word and not an
  absence this reader should decide — the mandate, the bank transaction code
  (ISO domain/family/sub-family and the proprietary one), the return reason,
  and what was ordered in another currency with the rate, unconverted.

## A statement is hostile input

It arrives by e-mail, from a download, from a third party's API. The XML reader
is written in this package, some three hundred lines, and is strict on purpose:

- **Any `<!DOCTYPE` is refused**, unread. No statement needs one; the
  billion-laughs family and the external-entity family (XXE) both need one.
  There is no entity table to expand and nothing that opens a file or a socket.
- The five predefined entities and numeric character references are decoded;
  **any other entity is an error**, not an empty string. A character reference
  that is not an XML character is an error.
- **Size** is checked before a character is read (`maxBytes`, 32 MiB by
  default), **depth** and **element count** while reading (`maxDepth` 64,
  `maxElements` 2,000,000). The reader does not recurse: a hundred thousand
  nested elements are refused by the depth limit, and would not have touched
  the stack.
- **UTF-8 only, decoded fatally.** A byte that is not UTF-8 is an error and not
  a replacement character in somebody's name. A file that declares another
  encoding is refused: decode it and pass the string.
- Namespaces are resolved, so `<Document xmlns="…">` and
  `<ns2:Document xmlns:ns2="…">` are the same statement, and an element of
  another namespace is never read as the statement's.
- Not well-formed is not read: mismatched tags, a second root, a bare `&`, a
  repeated attribute, a control character.

It is not a general XML parser: element and attribute names are ASCII, which
every ISO 20022 name is, and nothing is validated against a schema at runtime.

## What is thrown, and what comes back as a violation

**Thrown** (`StatementFileError`, with a `code`), because there is no statement
to report on:

| code | when |
|---|---|
| `too_large`, `too_deep`, `too_many_elements` | a limit was passed |
| `unsupported_encoding` | not UTF-8 |
| `doctype_forbidden`, `undefined_entity` | see above |
| `malformed_xml` | not well-formed |
| `not_a_statement` | well-formed, and not a camt.053 — a camt.052, an HTML error page |
| `unsupported_version` | camt.053.001.01 |
| `incomplete_statement` | no `Stmt`, or a statement without an identifier or an account |

**Returned** in `violations`, with the statement and the line it is on, because
one bad line should not cost the other three hundred:

| code | when |
|---|---|
| `balance_mismatch` | opening + booked entries ≠ closing; the message says the difference |
| `opening_balance_missing`, `closing_balance_missing` | no `OPBD` (or `PRCD`), no `CLBD`; the balance is not checked |
| `balance_currency_mismatch` | a balance in another currency than the account |
| `foreign_currency_entry` | an entry in another currency than the account — reported, **not converted**; the balance is not checked |
| `invalid_amount`, `invalid_direction`, `invalid_date` | the line comes back with `null` there |
| `booking_date_missing` | a booked entry without `BookgDt` (the schema allows it) |
| `invalid_iban` | written as an IBAN and failing ISO 13616's own check digits — returned as written |
| `duplicate_bank_reference`, `duplicate_entry_reference` | two entries of one statement under one reference |
| `batch_not_split`, `batch_count_mismatch` | see above |
| `version_not_verified` | a version this package has no schema for |

`invalid_amount`, `invalid_direction` and `invalid_date` are each something the
schema refuses: the tests put each one in a file and watch validation fail.
`balance_mismatch` is the opposite, and the reason this package exists — the
tests show the schema **accepting** a statement that does not add up.

## What it does not do

- **It converts nothing.** An entry in another currency is reported; what was
  ordered in dollars is returned in dollars beside what moved in the account's
  currency. Rates belong to whoever keeps the books.
- **It matches nothing.** It does not know an invoice from a salary. It hands
  over what reconciliation needs, separated.
- **It does not decide what a duplicate is.** Two lines with the same date,
  amount and counterparty are two lines; whether a file was already imported is
  a question for whoever holds the previous ones.
- **It does not read every element.** Charges, interest, tax, securities and
  card details, availability, and the postal address of a party are not
  returned. They are skipped, not misread.
- **It does not read camt.052 or camt.054.** The intraday report and the
  debit/credit notification share most of their types with the statement, and
  the reading would be close to the same — but a report has no closing booked
  balance to check and a notification has no balance at all, so they are other
  documents with other guarantees, and they are refused by name until someone
  needs them.
- **It reads no paginated statement as one.** `StmtPgntn` is returned (`page`);
  a statement delivered over several files opens and closes each page on
  interim balances (`ITBD`), which this package returns in `balances` and does
  not take for an opening or a closing. Such a page reports
  `opening_balance_missing` rather than guessing.

## Sources

- ISO 20022, *Bank-to-Customer Cash Management*, message
  `BankToCustomerStatement` (`camt.053.001.02` to `.14`): the schemas under
  [`test/xsd/`](./test/xsd/README.md), from the ISO 20022 message catalogue and
  archive, <https://www.iso20022.org/iso-20022-message-definitions>.
- ISO 13616 — the IBAN and its check digits (ISO 7064, MOD 97-10).
- ISO 11649 — the structured creditor reference (`RF…`), which this package
  returns and does not validate.
- Extensible Markup Language (XML) 1.0, Fifth Edition, and Namespaces in XML
  1.0 — <https://www.w3.org/TR/xml/>, <https://www.w3.org/TR/xml-names/>.

## What is verified, and what is not

**Verified**: every file this package is tested on is first held against the
schema ISO publishes for its version (`test/schema.test.ts`, thirteen schemas,
unmodified under `test/xsd/`, with no network and no system tool) — so the
reader is tested on camt.053, not on its author's idea of camt.053. One
statement is written in all thirteen versions and reads to the same objects.
The violations that are schema violations are shown to be refused by the
schema; the one that matters most, the balance, is shown **not** to be. The
hostile files are each refused by name, and the two that ask for time or
memory are refused within a bound the test measures.

Writing the fixtures against the schemas refuted the first draft once, the same
hour: `BIC` became `BICFI` in version 03, not in 04 as the draft had it. And
fetching the schemas found two versions the draft did not know: 14, published
in March 2026, and 01, which is served under the same name and is another
message.

**Not verified** — and this is the larger half:

- **No file from a bank.** Every statement here is invented, because a real one
  is somebody's account. The schema says what a bank *may* send; it does not
  say what any bank *does* send. Banks differ on exactly the things this
  package cares about: whether a batch is detailed, where the reference is
  (`AcctSvcrRef` on the entry, on the transaction, on both, on neither),
  whether the counterparty of a card payment is a party or a line of free text,
  what `PRCD` means on a Monday. *A reading that passes on invented files is an
  indication, not a proof*, and the first real statement from each bank is a
  test nobody has run.
- **No usage guideline.** EPC, CGI-MP, and the implementation guides of
  national banking federations restrict the message — which elements are
  filled, with which codes. None is tested.
- **The counterparty of a reversal.** That the parties keep their original
  roles when `RvslInd` is true is this package's reading of the message
  definition and of common practice; the schema cannot say, and banks may
  differ.
- **Versions 02 and 08 are the ones in use.** The eleven others are verified
  against their schemas and, as far as the authors know, against nothing else:
  nobody here has seen a camt.053.001.11 in the wild.
- **The external code sets** (bank transaction codes, return reasons, balance
  types) are returned as written and not checked against ISO's published
  lists.
- **Performance** is bounded, not measured: a statement at the default size
  limit is read in memory, as a whole.

## Licence

MIT. See [`LICENSE`](./LICENSE).
