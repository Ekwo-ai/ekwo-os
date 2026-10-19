# Ekwo OS in every country

> How one core keeps the books of any country: what the core knows, what a
> country pack says, where the packs stand today and what comes next. The
> format of a pack is recorded in
> [decision 0025](decisions/0025-a-country-is-a-pack-of-data.md); the format
> itself, file by file, is in [`packs.md`](packs.md).

## The premise

A country is data, not code. A module of code per country breaks at every
major version, and one product per market splits the users. Ekwo OS ships
**one core and one versioned pack per country**, and a pack is something an
accountant can read, a contributor can propose in a pull request, and a test
can prove.

**No function of the core holds a country code, and a test enforces it.** A
company is attached to a pack when it is created — `ekwo company new "<name>"
--country <cc>` names it, and nothing assumes one — and everything that differs from one country to the next
is read from that pack at run time.

## What the core knows, and what a pack says

The core carries the mechanics every ledger shares:

- double entry enforced by the database, account types, journals, periods,
  opening balances and a year-end close whose style the pack chooses;
- taxes as rows — their kind (value added tax, GST, sales tax, withholding),
  whether they are recoverable, tax-inclusive prices, taxes due on collection,
  several taxes side by side on one line, and the rounding rule of the country;
- declarations as boxes and formulas, financial statements as lines and rules,
  computed by functions that know no country;
- the invoice as a document answering to EN 16931, with the legal mentions,
  the numbering and the e-invoicing profile a country prescribes;
- currencies and their decimals, realised exchange differences, territories
  and the zones a country belongs to;
- labels in every language a pack publishes ([`languages.md`](languages.md)).

A pack fills it in: the chart of accounts, or several where a country has
more than one; the taxes with their rate history; the declaration form; the
balance sheet and income statement schemes; the rules of an invoice; the
depreciation rules of fixed assets and, for some countries, the corporate
income tax; the translations. Every tax and every box cites the official text
it comes from, and every pack carries a year of books with the declaration,
the statements and the trial balance they must produce, to the cent.

File formats are separate MIT packages under
[`packages/formats/`](../packages/formats/), organised by format and never by
country: a format is used by whichever packs declare it.

## Where it stands today

**More than a hundred countries ship as packs**, each seeded by `ekwo init` and listed with
its version and status in the [table of packs](packs.md#the-packs-of-this-checkout),
which is generated from the repository and is never a country behind. Among
them, the States of the OHADA treaty share one chart of accounts, written once
in [`packs/ohada/`](../packs/ohada/), and a country-less
[`packs/generic/`](../packs/generic/) gives any chart a balance sheet that ties
out. [ekwo.ai](https://ekwo.ai/countries/) publishes a page per pack, generated
from it, with what it covers and every source it cites.

What a zone of countries shares is described once, in [`zones/`](zones/): the
[European Union](zones/european-union.md) with its intra-Community rules and
recapitulative statements, and how a country that stands alone is written, as
the [United Kingdom](zones/united-kingdom.md) and the
[United States](zones/united-states.md) show it.

A pack carries one of four statuses, which `ekwo init` and `ekwo status` print:

| Status | Meaning |
|---|---|
| `community` | Written from the official texts and checked by the tools and the golden year; no professional has signed it |
| `maintained` | As above, and kept current by the maintainers |
| `proven` | As above, and it reproduced the statements a real company filed and the administration accepted, after its books were imported; the pack lists the scopes reproduced and the ones not tested |
| `reviewed` | Read against the law by a named professional of the country, who signs it |

There is no status meaning "certified by Ekwo": writing a pack is not reviewing
it. How a professional reviews a pack is in
[`packs.md`](packs.md#certification-and-who-may-say-what).

## What an international core needs and does not have

| Capability | Where it stands |
|---|---|
| A country as a versioned pack, upgraded in place | **Done** — `ekwo pack status` and `ekwo pack upgrade` |
| The rules of an invoice: numbering, payment terms, tax point, legal mentions, e-invoicing profile | **Done**, as pack data |
| The fiscalisation of invoices: a record chained by a hash, a clearance by the authority before issue, the data reported | **Done**, as pack data and the `einvoicing` module; the call to an authority is the host's |
| Opening balances and a year-end close | **Done** — `opening_balance()`, `close_fiscal_year()`, `reopen_fiscal_year()`, and the final close `close_fiscal_year_finally()`, required where the pack says so |
| A tax engine beyond the European value added tax | **Done** — GST, sales and use taxes, withholding, non-recoverable and tax-inclusive taxes, several taxes on one line |
| Taxes due on collection | **Done**; cash accounting as a ledger is not |
| Exchange differences | **Realised differences done**; revaluation of open items not yet |
| A cash-flow statement | **Not yet** — the format accepts one, and no pack prescribes it yet |
| Consolidation across companies | **Not yet** |
| A pack proved against figures | **Done** — a golden year per pack, and a legal source on every tax and box |

## How a country is added

A country is added the same way whoever adds it: from the official texts, in a
pull request, checked by `ekwo pack check` and proved by its own year of books.
The walkthrough is
[Adding a country in a day](packs.md#adding-a-country-in-a-day), and
[`CONTRIBUTING.md`](../CONTRIBUTING.md) lists the invariants a pack may not
break. A correction to an existing pack follows the same path; the professional
who knows a country is the person whose review turns a `community` pack into a
`reviewed` one.

## What comes next

In no promised order, and without dates:

- **Reviewed packs** — named professionals reading the packs of their country.
- **Deeper coverage per country** — more declarations as files, corporate
  income tax for more countries, the electronic invoice sent and received
  where a country requires it.
- **The European One-Stop Shop**, read from the same two facts the
  recapitulative statements use: the treatment of the tax and the country of
  the customer.
- **Revaluation of open items, the cash-flow statement and consolidation**,
  for groups and companies trading in several currencies.

The criteria of the 1.0 release are in [`road-to-1.0.md`](road-to-1.0.md).

## Deliberately out of scope

Inventory, payroll, point of sale and its certifications. A products table
exists so that inventory can come later as its own schema, as
[decision 0044](decisions/0044-a-product-is-a-catalogue-entry-in-the-core.md)
describes. Rates that depend on a delivery address — American district sales
taxes, for instance — belong to a rate provider: the core models the shape of
the tax, and a pack carries the statewide rates.

## What the packs do not say yet

Each pack's own README says what it leaves out, and its page on
[ekwo.ai](https://ekwo.ai/countries/) prints it. Two things hold for every pack
today: **no pack is `reviewed` yet**, and some packs declare bank statement
formats no reader in this repository parses yet — `ekwo pack check` warns about
each one. A silence a pack cannot fill from an official text is stated as such
rather than guessed.

## From Zimbabwe

**Fiscalisation is a device, not a network.** Since 1 January 2026 a tax
invoice under the Value Added Tax Act [Chapter 23:12] is a fiscal tax invoice:
printed by a fiscal device approved by ZIMRA, transmitted to and signed by the
Fiscalisation Data Management System (FDMS), and shown valid on its portal
(s. 2(1), as substituted by the Finance Act, 2025, s. 35). The device registers
with a certificate, opens and closes fiscal days, signs every receipt (SHA-256,
device key), submits it to the Fiscal Device Gateway API, keeps a daily counter
and a global number, and prints a QR code built from ZIMRA's verification URL,
the device ID, the date, the global number and a hash of the signature (API
specification v7.2). Input tax is claimed only on such invoices, which TaRMS
now pulls from the FDMS. The socle has no device certificate, no fiscal day,
no signature and no QR code; the pack declares `einvoicing.obligation: none`,
since nothing obliges an exchange between businesses, and every document
carries a mention saying it is not a fiscal tax invoice. What would close the
gap: a virtual fiscal device module that signs and submits each posted sale and
credit note and stores the FDMS signature and QR code. Same family as Zambia
(Smart Invoice), Kenya (eTIMS), Uganda (EFRIS) and Tanzania.

**The buyer's telephone.** Section 20(4) and ZIMRA Public Notice No. 30 of 2025
ask for the buyer's contact details on a fiscal tax invoice; the contact has a
phone, the document view does not carry it.

**Two currencies, one ledger.** The US dollar circulates beside the Zimbabwe
Gold (ZWG). VAT received in foreign currency is paid in that currency, import
VAT and the tax on imported services in foreign currency (s. 38(4), (4a),
s. 13(6)), and Part V of the VAT 7 splits sales, purchases and the amount
payable between foreign and local currency. A box adds up postings and cannot
be filtered on the currency of the document, so Part V is not computed. The
pack's default currency is ZWG and the company chooses its own at `init`. The
golden format has no document currency either, so a scenario cannot show an
invoice in USD beside one in ZWG.

**Category A periods.** Section 27 assigns two-month periods ending in odd
months (Category A) or even months (Category B). `bimonth` is anchored on
January–February, which is Category B; Category A's December–January cannot be
expressed.

**Two deadlines.** The return is due on the 10th and the payment on the 15th
(Statutory Instrument 81 of 2025); a form holds one deadline.

**Credit notes on their own line.** The VAT 7 declares debit and credit notes
as adjustments (lines 18 and 29) at the VAT-inclusive consideration. The pack
routes credit-note postings there with the value net of tax; the form's
consideration is value plus tax.

**A time of supply of five clauses.** Section 8(1) takes the earliest of
invoice, payment, removal, possession and performance; the format's nearest
value is `earliest_of_delivery_or_payment`.

**No TIN field.** Zimbabwe has a TIN (ten digits) and a VAT number (nine); the
pack maps the TIN onto the registration number.

## From Malaysia

**An invoice the authority validates before it is issued.** Under the Income
Tax Act 1967, s. 82C, and the Income Tax (Issuance of Electronic Invoice) Rules
2024, an e-Invoice is submitted to LHDNM's MyInvois system — through its
portal, its API or a Peppol service provider — and is the taxpayer's only once
MyInvois has validated it: LHDNM returns a Unique Identifier Number, the moment
of validation and the link to its validation page, which the e-Invoice carries
as a QR code when it is shared with the buyer. Within 72 hours of the
validation the supplier may cancel it and the buyer reject it, each with a
reason; afterwards it is corrected by a credit note. The core holds this shape
as a **clearance** regime of `einvoicing.fiscalisation`, beside the chained
record and the report, written after comparing MyInvois with Poland's KSeF and
Italy's SdI: the pack says where the verification link comes from (here,
`returned`) and the two windows (`PT72H`), and the `einvoicing` module keeps
each submission in `einvoicing.clearances` — `submitted`, `validated` with the
identifier, the moment and the link, `rejected` by the authority or the buyer,
`cancelled` — refusing every transition that cannot have happened and every
cancellation or rejection after its window. The status names each posted sale
without a validation. The document submitted is written by
`@ekwo-ai/myinvois` through the ordinary path of issue: the tax type of each
tax and the classification of each line are attributes the pack gives
(`tax_attributes`, `line_attributes`), and the identifiers LHDNM asks of both
parties — a TIN, an SST registration — are `identifiers` of the company and
of the contact, by the scheme the format names them. What would close the
rest is a host that calls MyInvois — its authentication, and the signature
version 1.1 asks — and reports back through `record_clearance_submission()`
and `record_clearance_answer()`. Same family as
Poland (KSeF), Italy (SdI), Saudi Arabia (ZATCA, phase 2), India (IRN), Mexico
(CFDI) and Turkey, each a pack that can declare the same block.

**An obligation by size, and a threshold that moves by guideline.** LHDNM
phased the duty by annual turnover or revenue — above RM100 million from
1 August 2024, RM25 million from 1 January 2025, RM5 million from 1 July 2025,
RM1 million from 1 January 2026 — and its guideline sets the threshold below
which a taxpayer is exempted, raised to RM1,000,000 in December 2025 and to
RM3,000,000 by version 4.8 of 30 August 2026, § 1.6.1(e). The pack carries
both as dated data: each step of `mandatory_from` with its `turnover_above`,
and `exemption` as a history that gains an entry when the threshold moves.
Two gaps stay. The books do not hold a company's turnover, so the status
cannot tell which step binds a company, or whether it is exempted: it counts
from the earliest step and says the threshold in force, and the answer is the
company's. And the RM1,000,000 threshold is not an entry, because no text the
pack cites gives the day it took effect; the RM3,000,000 one is dated from the
guideline that states it.

**Cancelled at the authority, undone in the books.** A cancellation in
MyInvois voids the e-Invoice; the ledger still holds the posted sale until
`cancel_document()` undoes it, with a credit note in the books. The status
lists a sale cancelled at the authority and still posted, and does not count
the credit note that undoes it as missing a validation of its own. A buyer's
rejection leaves the e-Invoice valid until the supplier cancels it; the status
lists it apart.

**No VAT number, and a TIN with no scheme.** Malaysia levies Sales Tax and
Service Tax, not a value added tax, so `vat_scheme` is empty; the Tax
Identification Number is a LHDNM identifier with no ISO 6523 scheme found, and
the party scheme is the SSM registration number, `0230`.

## From Botswana

**Tax periods that start in December.** Under s. 54 of the Value Added Tax Act,
2026, a Category A registered person files for two months ending in January,
March, May…; `bimonth` is anchored on January and fits Category B only. The
pack declares `month` and `bimonth` and no default cadence.

**An electronic billing system that reports to the administration.** Section 15
of the Tax Administration Act, 2026 obliges every taxpayer to issue invoices
through a billing system approved by the Botswana Unified Revenue Service. It
is a reporting system, with no Peppol profile and no party scheme, so
`einvoicing.obligation` is `none`; the date it becomes binding is set by
regulations the pack could not open.

**A suspension by notice.** The charging of VAT on private medical services was
suspended by a public notice of 30 July 2026; the Act itself still makes them
taxable. The pack carries no code for them rather than invent a treatment.

## From Namibia

Namibia levies a value-added tax at 15 % (Value-Added Tax Act, 2000, s. 6(1)),
filed on the Namibia Revenue Agency's ITAS portal on a two-month tax period by
the 25th of the month after it. The pack (`packs/na`) fits the format without a
change to the core; what it could not carry is written in its README:

- **The registration threshold** is data the format has no field for. The
  Amendment Act, 2024 raises it from N$500 000 to N$1 000 000 on a date the
  Minister fixes by notice in the Gazette, which the pack did not find.
- **Category A periods.** `bimonth` is anchored on January–February, the
  Category B of the Act; Category A (ending January, March…) is not
  expressible.
- **Imported services** are declared on an import declaration and the form does
  not say on which row; the pack assumes row 15 and says so.
- **E-invoicing** has no official date or platform yet, so the obligation is
  `none`.
