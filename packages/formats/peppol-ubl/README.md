# `@ekwo-ai/peppol-ubl`

A sales **invoice or credit note as the Peppol network carries it** — UBL 2.1
in the profile Peppol BIS Billing 3.0 of the European standard EN 16931 — in
TypeScript, with no dependencies.

Give it a posted document as the books hold it and it gives you the file, a
name for it, and every published rule the file breaks — named by the identifier
the rule is published under.

```ts
import { generatePeppolUbl } from '@ekwo-ai/peppol-ubl';

const { file, filename, violations } = generatePeppolUbl({ header, lines, taxes });
```

`header`, `lines` and `taxes` are one row of `document_header`, the rows of
`document_line_items` and the rows of `document_tax_summary` in
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os): a document, its lines, and its
VAT rounded once per tax. They are declared in this package's own types, so
any invoicing system that can produce the same three things can use it. It
reads no database and knows no accounting.

Writing the file is all it does. **Sending it takes a certified access point**,
a certificate and somebody on call, and this package has none of the three: you
get the same UBL anybody gets, and you send it through the access point you
chose.

## The figures are the books' figures

Nothing is recomputed. A total, a base and a tax are written as they were
posted, and where they do not add up the rule they break is named rather than
the figure corrected. An invoice is an accounting document before it is an XML
one: a file that disagrees with the ledger it came from by a cent is worse than
a file that is refused, because the first is found by whoever files the VAT
return.

For the same reason no figure passes through a `number`. Amounts arrive as the
text Postgres prints a `numeric` as, are compared as exact decimals on
`bigint`, and leave as the same digits. The rules of EN 16931 compare with `=`
and not with a tolerance; a sum a binary float gets wrong in its last bit is a
rule reported broken on an invoice that is right.

Two things are derived, because the standard has a place for them and the books
hold them in another shape:

- **The VAT breakdown.** The books keep one row per tax; the standard wants one
  group per category and rate (BG-23). Two taxes at one rate — goods and
  services at the standard rate — are one group: their bases added, their taxes
  added, nothing rounded again.
- **The net price of a discounted line.** The books hold the price as keyed and
  a discount in percent; the standard wants the net price (BT-146), and has room
  for the gross one and the discount beside it (BT-148, BT-147). All three are
  written, exact to the last digit — `27.7778` less 10 % is `25.00002` — so
  that the quantity times the net price is still the line the books rounded.

A line's category and rate are read from the line and from nowhere else. In
Ekwo OS a line keeps the category and the rate it was posted with, so that a
rate that changes later restates no invoice already sent; a line that says
neither has neither, and BR-CO-04 says so.

## Nothing is made up

There is no default currency, country, language, unit, payment means or
identifier scheme. An absent value is an absent element — never an empty one,
which is a rule broken in its own right (PEPPOL-EN16931-R008) — and the rule
that wanted it is reported. In particular:

- **The electronic addresses** (BT-34, BT-49) are read from the header —
  `seller_peppol_scheme` and `seller_peppol_identifier`, and the same two for
  the buyer — or given as `sellerEndpoint` and `buyerEndpoint`, which win. They
  are never derived: which identifier a participant is registered under is a
  fact of its registration, not of its VAT number.
- **The scheme of a registration number** (BT-30-1, BT-47-1) is given or left
  out. It is *not* what Ekwo OS calls `party_scheme`: that is the scheme a party
  is addressed by, and in more than one country it is not a scheme a
  registration number can be written in at all.
- **An IBAN without a payment means code** is not written. The format files the
  account under the code (UNTDID 4461) and there is no code that means "probably
  a transfer". It comes back as `payment-means-missing`.
- **A price keyed with its tax in it** has no net price here. That one is the
  line's base divided by its quantity — a rounding decision, and so the books'
  to make: pass it as `net_unit_price`, or read BR-26.
- **A `Date` object is refused.** A driver hands a `date` column back as an
  instant, at a midnight that is UTC for one driver and local for the next.
  Select it `::text`.

## What is refused, and what comes back as a violation

What would make the file absurd throws a `PeppolUblError`: a document that is
not a sales invoice or a sales credit note, that has no number, no date, no
currency or no line, an amount or a date that is not one. These are also what
the UBL schema requires, so **every file that comes back is a valid UBL 2.1
document** — the wrong ones too.

Everything else comes back in `violations`, beside a file that says what it was
given:

```ts
{ code: 'BR-CO-15', message: '1450.00 without VAT and 267.00 of VAT are not the 1717.01 the document totals.' }
{ code: 'PEPPOL-EN16931-R120', message: '…', line: '10' }
```

`code` is the identifier of the published rule — what a validator on the
network will say of the same file, and the only name worth branching on.
`message` is this package's sentence, not the rule's text. Two codes are
lower-case because they are this package's own — things it could not write, and
which no validator reports because it never sees them: `payment-means-missing`,
and `exemption-reason-ambiguous` for a VAT group whose lines carry several
exemption codes where the group has room for one.

An empty `violations` is the only state to send a file in.

The rules re-read here, 112 of them:

| | |
|---|---|
| the parties | BR-06 to BR-11, BR-57, BR-62, BR-63, BR-CO-09, BR-CO-26, PEPPOL-EN16931-R010, R020 |
| the reference Peppol requires | PEPPOL-EN16931-R003 |
| payment | BR-61, BR-CO-25 |
| the lines | BR-22, BR-23, BR-25 to BR-28, BR-CO-04, UBL-SR-48, PEPPOL-EN16931-R120 |
| the VAT breakdown | BR-47, BR-48, BR-CO-17, BR-CO-18, PEPPOL-EN16931-R053, R054 |
| the categories S, Z, E, AE, K, G and O | BR-*-01, -02, -05, -08, -09, -10 for each, BR-IC-11, BR-IC-12, BR-O-11, BR-O-12, PEPPOL-EN16931-P0104 to P0111 |
| the totals | BR-CO-10, BR-CO-14, BR-CO-15, BR-CO-16 |
| decimals | BR-DEC-09, -12, -14, -16, -18, -19, -20, -23, UBL-DT-01 |
| check digits | PEPPOL-COMMON-R040 (GLN), R043 (Belgian enterprise number) |
| code lists | BR-CL-03, -04, -11, -14, -16, -17, -18, -22, -23, -25, PEPPOL-EN16931-CL007, CL008 |

## What is verified, and what is not

**Against the UBL 2.1 schema: verified, in the test suite.** Every file the
tests produce — 100 cases, invoices and credit notes, right and wrong — is
validated against the schemas OASIS publishes, unmodified under `test/xsd/`
(`xmllint-wasm`, a development dependency: no network, no system tool). The
test also mutates a file three ways and watches validation fail, so a validator
that resolved no import would not pass for one that checks.

**The code lists: generated, and compared code for code.** `src/codelists.ts`
is written by `scripts/build-codelists.mjs` from the `BR-CL-*` assertions of the
EN 16931 Schematron as Peppol BIS Billing 3.0 ships it (`test/codelist/`), and
the tests parse that file again, with other code, and compare every list with
it in order.

**Against the Schematron of EN 16931 and of Peppol: played, but not by the test
suite.** Both rule sets are Schematron with an XSLT 2.0 query binding. Nothing
in a JavaScript runtime executes XSLT 2.0 except SaxonJS, which this repository
does not depend on for a test and whose licence is not an open-source one. So:

- the Schematron was **played by hand**, from outside the repository, on
  18 September 2026: release **3.0.20** of Peppol BIS Billing (which ships the
  EN 16931 rules at version 1.3.15), compiled with SchXslt 1.10.1, run with
  SaxonJS. `scripts/play-schematron.mjs` is the whole procedure and checks the
  SHA-256 of everything it downloads;
- it was played against the 100 files under `test/fixtures/`, and what it said
  is committed as `test/fixtures/verdicts.json`;
- the test suite holds the package to that record on every run: the generator
  must still write those files **byte for byte**, and for every one of them the
  rules this package reports must be **exactly** the fatal rules the Schematron
  reported — no more, no fewer. The 16 files meant to be right are right for
  both, without a warning;
- every one of the 112 rules named above was reported by the published
  Schematron on at least one of those files, and the Schematron reported
  nothing on them that this package does not name. A rule added to
  `src/rules.ts` and never played fails the tests.

What that proves: on those 100 documents, this package and the network agree.
What it does not: that they agree on a document that is not one of them. The
re-reading is code written from the rules, not the rules themselves. **Before
relying on an empty `violations` for a kind of invoice these cases do not
cover, validate one through your access point** — most offer a test endpoint —
or play the script.

**Not re-read at all**, so never reported here, and a validator may:

- the **national rules** Peppol adds for a seller in Denmark, Germany, Greece,
  Iceland, Italy, the Netherlands, Norway and Sweden (`DK-R-*`, `DE-R-*`,
  `GR-R-*`, `IS-R-*`, `IT-R-*`, `NL-R-*`, `NO-R-*`, `SE-R-*`);
- the check digits of identifier schemes other than `0088` and `0208`
  (PEPPOL-COMMON-R041, R042, R044 to R050);
- every rule about something this package does not write — see below;
- the **warnings**. Only fatal rules are named.

## What it does not write

Document-level allowances and charges (BG-20, BG-21), line-level ones (BG-27,
BG-28), the invoicing period (BG-14, BG-26), a VAT accounting currency (BT-6,
BT-111), a payee other than the seller (BG-10), a tax representative (BG-11),
attachments (BG-24), item attributes and classifications, card and direct-debit
payments, prepayment and self-billed invoices — the type is `380` or `381`.
Ekwo OS has no column for any of them today. A document that needs one is a
document this package cannot write yet, and it does not pretend to.

Neighbouring profiles — XRechnung, a PINT, Factur-X in UBL — are other formats
and would be other packages. Reading an incoming invoice is another job
altogether.

## What the source refuted

The first draft was written from the specification. Playing the Schematron
against it found what reading had not:

- **`0999999999` is not a Belgian enterprise number.** The number every test in
  the surrounding repository uses fails the check digits Peppol verifies
  (PEPPOL-COMMON-R043). The fixtures use `0999999922`, in a range no number was
  issued in.
- **The two rule sets do not share a list of electronic address schemes.**
  EN 16931 lists seven that Peppol refuses — e-mail and telephone among them. A
  scheme can break one rule and not the other (`SCHEMES_NOT_ON_PEPPOL`).
- **BR-DEC-13 never fires.** The rule that the total VAT has two decimals looks
  for the currency code underneath the amount, where it is not. UBL-DT-01
  catches the same digits and is what is reported.
- **BR-CO-16 rounds in one branch and not the other**, which shows on an amount
  with a third decimal; **an absent price fails the rule against a negative
  one** (BR-27); **a group without a rate fails the rule on its tax** (BR-S-09);
  **a total VAT with no breakdown under it** breaks two Peppol rules and not
  one (R053, R054); and **the UBL binding has rules of its own** beside the
  standard's, so three decimals are UBL-DT-01 as well as BR-DEC-*, and a line
  without a category UBL-SR-48 as well as BR-CO-04.
- **A line of the books did not say its VAT category.** The end-to-end test
  found `document_line_items.vat_category` empty on every line of every pack,
  and the first version joined a silent line to its tax by `tax_id`. The books
  now write the line when it is posted, and the join is gone: it read the tax
  of today into an invoice of last year.
- **A reason is a code *or a text*.** The same test reported BR-E-10, BR-G-10
  and BR-AE-10 on a pack that codes no exemption, and called the code missing.
  The rules accept a sentence, the pack had one, and the breakdown did not
  carry it. It does now, as `exemption_reason`.
- **`party_scheme` is not the scheme of a registration number.** The same test
  found it to be an address scheme, which for two of the four countries that
  declare this profile is not an ISO 6523 identifier scheme at all (BR-CL-11).

## Sources

- OASIS, *Universal Business Language 2.1*, schemas of 4 November 2013:
  <https://docs.oasis-open.org/ubl/os-UBL-2.1/>.
- OpenPeppol, *Peppol BIS Billing 3.0*: <https://docs.peppol.eu/poacc/billing/3.0/>
  — the syntax bindings of the invoice and the credit note, the rules, the code
  lists. Rules as released: <https://github.com/OpenPEPPOL/peppol-bis-invoice-3>,
  tag `v3.0.20`.
- CEN/TC 434, the validation artefacts of EN 16931:
  <https://github.com/ConnectingEurope/eInvoicing-EN16931>.

## Licence

MIT. The files under `test/` that come from OASIS and from the European
Commission keep their own notices and licences, are fixtures of the tests, and
are not part of the published package.
