# `@ekwo-ai/cfonb120`

Reads a **CFONB 120** file — the *relevé de compte sur support informatique*
French banks deliver, records of 120 characters in fixed positions — into plain
objects, in TypeScript, with no dependencies.

Give it the file and it gives you the statements in it, their lines, and the
list of what does not add up.

```ts
import { readCfonb120 } from '@ekwo-ai/cfonb120';

const { statements, violations } = readCfonb120(bytesOrString, { ibanCountry: 'FR' });

for (const statement of statements) {
  statement.account.identifier; // { kind: 'iban', value } — or { kind: 'other', value } when no country was named
  statement.openingBalance;     // { type: 'OPBD', amount: '1000.00', currency: 'EUR', date: '2026-02-28' }
  statement.closingBalance;
  statement.balanced;           // true, false, or null when it could not be checked
  for (const line of statement.lines) {
    line.amount;                // '-450.50' — signed, a decimal string, never a float
    line.bookingDate;           // '2026-03-06'
    line.counterparty;          // { name, account, agentBic, ultimateName }
    line.remittance;            // { unstructured: [...], structured: [{ reference, type, issuer }] }
    line.additionalInformation; // the label the bank gave the movement
  }
}
```

It knows no database and no ledger. The shape it returns is declared in
[`src/types.ts`](./src/types.ts), imported from nowhere, and is **field for
field the shape [`@ekwo-ai/camt053`](../camt053/) declares for itself** — so
whatever takes a camt.053 that was read takes a CFONB 120 that was read, without
an adapter. What only this format says comes after those fields, under its own
names (`interbankOperationCode`, `entryNumber`, `referenceZone`, `unavailable`,
`complements`…).

A format is not a country. Nothing here assumes the euro, two decimals or a
language — and the format itself **carries no country**, which is why this
reader does not supply one (see *The account* below).

## What it does

- Reads records **01** (old balance), **04** (movement), **05** (complement)
  and **07** (new balance), and returns **every statement** of the file.
- Reads the **sign written over the last digit** of an amount — `{` and `A` to
  `I` for 0 to 9 of a credit, `}` and `J` to `R` for 0 to 9 of a debit — and
  the **number of decimals from the record** (position 20). Amounts come back
  as decimal strings with exactly that many decimals: `150000` for a yen
  account, `1.001` for a dinar one. Sums are made on integers; nothing is
  rounded and nothing knows that a euro has cents.
- Checks that **old balance + movements = new balance**. When it is not, the
  statement comes back as the bank wrote it, `balanced` is `false`, and
  `balance_mismatch` says the difference. **Nothing is corrected.**
- Reads the **complements** the 2010 addendum standardised for SEPA: payer and
  beneficiary (`NPY`, `NBE`), their identifiers (`IPY`, `IBE`), the parties
  behind them (`NPO`, `NBU`), their accounts (`CPY`, `CBE`), the remittance
  (`LCC` + `LC2`, put back into the one text they were cut from; `LCS`,
  structured, kept apart), the end-to-end reference and purpose (`RCN`), the
  payment information and instruction identifiers (`REF`), the mandate and its
  sequence (`RUM`), the amount of origin and the rate (`MMO`, returned beside
  what moved, **never converted**), and free lines (`LIB`). Every complement,
  a bank's own qualifiers included, is also returned as written
  (`complements`).
- Names the **counterparty** as the payer of money coming in and the
  beneficiary of money going out — and the other way round when the movement
  carries a reject code, where the parties keep the roles they had in the
  original.
- Reports a movement **booked outside its statement**
  (`booking_date_outside_statement`): the brochure defines a statement as the
  movements booked strictly after the date of the old balance and up to the
  date of the new one.

## The account, and the country nobody wrote

A CFONB 120 identifies an account by a **bank code, a branch code and an
account number**. It carries no IBAN and **no country**: the same lay-out is
used wherever that way of numbering accounts is. So:

- by default the identifier is `{ kind: 'other', value }`, the three joined, as
  written — and `statement.account` gives them apart;
- with `{ ibanCountry: 'FR' }` — or any other two letters — it is the IBAN
  those three make **in the country the caller named**: the key of the relevé
  d'identité bancaire is computed (`ribKey()`), then the check digits of
  ISO 13616 (`ibanOf()`). Parts that cannot make one are `invalid_iban`, and
  the account comes back as written.

The reader never picks the country. Whoever imports the file knows where the
account is held; the file does not say.

## A statement is hostile input

- **Every record is 120 characters or the file is refused**
  (`invalid_record_length`, with the record's number). Nothing is padded:
  a file whose trailing blanks were trimmed on the way is refused, because a
  reader that pads cannot tell a trimmed record from a truncated one. A file
  with no line break at all — common for this format — is read as consecutive
  records, if its length is a whole number of them.
- **An unknown record code is refused by name** (`unknown_record`), and so is a
  known one out of place (`unexpected_record`). A file that stops before a new
  balance is `incomplete_statement`.
- **A record of another account in the middle of a statement is refused**
  (`inconsistent_record`): the brochure says bank, branch, currency, decimals
  and account are identical in every record of one statement. That is also
  what refuses a movement in another currency, or on another scale.
- **UTF-8, decoded fatally**, which reads the ASCII the brochure allows.
  `{ encoding: 'iso-8859-1' }` is said by the caller and never guessed.
  **EBCDIC**, which the brochure also describes, is `unsupported_encoding`.
- **Size** is checked before a record is read (`maxBytes`, 32 MiB by default).

## What is thrown, and what comes back as a violation

**Thrown** (`StatementFileError`, with a `code` and the `record` it stopped on):
`too_large`, `unsupported_encoding`, `empty_file`, `invalid_record_length`,
`unknown_record`, `unexpected_record`, `inconsistent_record`,
`incomplete_statement`.

**Returned** in `violations`, with the statement and the line it is on:

| code | when |
|---|---|
| `balance_mismatch` | old balance + movements ≠ new balance; the message says the difference |
| `invalid_amount`, `invalid_date`, `booking_date_missing` | the line comes back with `null` there |
| `booking_date_outside_statement` | see above |
| `invalid_iban` | `ibanCountry` was given and the account's parts do not make an IBAN |

## What it does not do

- **It gives a movement no bank reference, because the format has none.**
  `bankReference` is always `null`. The "numéro d'écriture" is a cheque or
  remittance number, or zeros; the `REF` complement carries the payer's
  references, not the bank's; the reference zone is the ordering party's. A
  core that recognises a line by the reference of the bank will recognise no
  line of a CFONB 120 in a camt.053 of the same month — it will import both.
  That is a property of the format, said here rather than papered over.
- **It gives a statement no number**, for the same reason: its `id` is made of
  the dates of its two balances.
- **It converts nothing, matches nothing, and does not decide what a duplicate
  is.**
- **It does not explain the operation codes** (interbank or internal), nor the
  reject codes: they are returned as written.
- **It does not parse the label** (zone 2-M), whose recommended structure
  (chapter 5 of the brochure) differs by payment instrument and is a
  recommendation.
- **It does not read EBCDIC, the 240-character format, or Windows-1252.**

## Sources

- CFONB, *Relevé de compte sur support informatique* (brochure, July 2004),
  <https://www.cfonb.org/fichiers/20130612113947_7_4_Releve_de_Compte_sur_support_informatique_2004_07.pdf>.
- CFONB, *Évolutions du relevé de compte 120 caractères pour les opérations de
  virements et de prélèvements SEPA*, version 2.0 (March 2010),
  <https://www.cfonb.org/files/fichiers/20130612114053_7_8_Evol_Releve_Cpt_120_caract._ope._SCT_et_SDD_sepa_V2_0_2010_03.pdf>.
  Both downloaded on 18 September 2026.
- ISO 13616 (IBAN), ISO 7064 (MOD 97-10), ISO 4217 (currency codes).

## What is verified, and what is not

**Verified**: every position this reader takes was written from the tables of
the two documents above, and the test builder (`test/build.ts`) was written
from the same tables, separately from the reader. The fixtures under
`test/fixtures/` are what the builder writes, compared on every run. The twenty
characters that carry a digit and a sign are each read.

**Not verified** — and this is the larger half:

- **No file from a bank has been read.** Every statement here is invented.
  Reader and builder share an author and a reading of the brochure: where that
  reading is wrong, both are, and the tests pass. *The first real file from
  each bank is a test nobody has run.*
- **How strictly banks keep to 120.** Files whose trailing blanks were trimmed
  exist; this reader refuses them by name rather than guess what was there.
- **The counterparty of a rejected operation** — that the parties keep their
  original roles when a reject code is present — is this package's reading,
  taken from how the camt.053 reader treats a reversal. Banks may differ.
- **The key of the relevé d'identité bancaire** is computed from its published
  rule and held against ISO 13616 in the tests; it is not held against a real
  account, because none is in this repository.
- **Which qualifiers banks really send.** The 2010 addendum lists them; banks
  add their own, which are returned as written and otherwise ignored.

## Licence

MIT. See [`LICENSE`](./LICENSE).
