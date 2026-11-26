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
| A tax engine beyond the European value added tax | **Done** — GST, sales and use taxes, withholding, non-recoverable and tax-inclusive taxes, taxes computed inside their own base, several taxes on one document |
| Taxes due on collection | **Done**; cash accounting as a ledger is not |
| Exchange differences | **Realised differences done**; revaluation of open items not yet |
| A cash-flow statement | **Not yet** — the format accepts one, and no pack prescribes it yet |
| Consolidation across companies | **Not yet** |
| A pack proved against figures | **Done** — a golden year per pack, and a legal source on every tax and box |
| A bank account in the scheme of its country, on every row that names one | **Done** — a scheme and a value, see [below](#from-recognising-who-paid-an-account-is-a-scheme-and-a-value) |

## From recognising who paid: an account is a scheme and a value

An IBAN is the European answer to "which account?". The United States names
an account by an ABA routing number and an account number, Canada by a transit
number, an institution number and an account number, Australia by a BSB, India
by an IFSC, the United Kingdom by a sort code. A statement line from a customer
in one of those countries carries their account in that scheme, and the books
recognise who paid by comparing it with the account recorded against the
contact.

So every account the books record is a **scheme and a value**, the shape the
schema already gives an electronic address (`peppol_scheme`,
`peppol_identifier`):

| Fact | Scheme | Value | Deprecated name, kept in step |
|---|---|---|---|
| The company's own account | `bank_accounts.account_scheme` | `account_identifier` | `iban` |
| Its bank | `bank_accounts.bank_scheme` | `bank_identifier` | `bic` |
| A contact's account | `contacts.account_scheme` | `account_identifier` | `iban` |
| A contact's bank | `contacts.bank_scheme` | `bank_identifier` | `bic` |
| The other side of a statement line | `bank_transactions.counterpart_account_scheme` | `counterpart_account_identifier` | `counterpart_iban` |
| The account a document asks to be paid into (EN 16931 BT-84) | `documents.payee_account_scheme` | `payee_account_identifier` | `payee_iban` |

The schemes are a closed list held by the database, `bank_identifier_schemes`:
the account schemes the packs declare (`iban`, `aba-routing-account`,
`sort-code-account`, `bsb-account`, `ifsc-account`, `clabe`, `zengin`,
`transit-institution-account`, and `account-number` for a number as the bank
gives it) and the schemes that name a bank (`bic`, `aba`, `sort-code`, `bsb`,
`ifsc`, `transit-institution`, `zengin-bank-branch`). The check follows the
scheme: `bank_identifier_problem()` reads the scheme first, then ISO 7064
mod 97-10 for an IBAN, the 3-7-1 weighted sum for an ABA routing number; a
scheme with no check digit is stored as written, and nothing is refused for not
being an IBAN.

The old columns stay readable and writable, held in step by a trigger the way
`companies.vat_period` is held to `company_filing_periods`: a write to `iban`
writes the pair in the scheme `iban`, a write to the pair writes `iban` when its
scheme is `iban` and clears it otherwise. A client that knows only the old
names keeps working; a newer client reading a database without the pair reads
the old columns (`SCHEMA_FEATURES.account_identifier_pairs`). The old names are
removed by a later major version, never by a minor one.

Recognising who paid (`contact_candidates()`, `suggest_contacts()`,
`confirm_contact()`) compares the pair, and a statement imported by
`import_bank_statement()` keeps the scheme its reader recognised. The electronic
invoice writes BT-84 in its own scheme: UBL `PayeeFinancialAccount/ID` for any
account, Factur-X `IBANID` for an IBAN and `ProprietaryID` for any other.

## An amount is written at the decimals of its currency

A currency has the decimals `currencies.decimal_places` gives it — two for the
euro, none for the yen or the Icelandic krona, three for the Kuwaiti or the
Tunisian dinar — and a country rounds by the method its pack declares. One
function, `round_amount()`, applies the pair, and every amount the engine
computes passes through it. A money column is a bare `numeric`: it holds what
the currency has, and cuts nothing.

An amount a person or a program writes as it is — a line keyed on a draft
entry, a statement line, a payment, the amount to match, the tax a supplier's
invoice states, the share capital, and in the modules the cost of an asset, a
budget line, the value of a contract or the amount of a deal — is held to its
currency by `assert_amount_of_currency()`: one finer than the currency is
refused, `amount_finer_than_currency`, with the amount, the currency and the
decimals it has. It is never rounded behind the writer's back, because two
lines of a balanced entry rounded each on its own can end a unit apart. An
amount in another currency than the company's is held to its own; `12.30` is a
euro amount and `1200.00` a yen amount, since trailing zeros are not decimals.
A unit price, a quantity or a rate is not an amount and may be finer. A bank
statement file is read at the decimals of the account's currency, so a dinar
statement imports its thousandths.

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

Where a country asks for something the core cannot express — a fiscal device,
a clearance before issue, a deadline the format has no field for — the pack
says so in its README, under the heading `## What the core could not say`,
each point opening on a sentence in bold. The index below is generated from
those sections by `ekwo pack build`, and `ekwo pack check` refuses it stale:
a country writes its gaps in its own folder, never in this page.

<!-- generated:core-gaps -->
- **[Argentina](../packs/ar/README.md#what-the-core-could-not-say)** (`ar`) — Clearance; No inflation adjustment; Withholdings and perceptions; A restricted credit balance; A credit the law makes computable only in the period after its event
- **[Burundi](../packs/bi/README.md#what-the-core-could-not-say)** (`bi`) — Three rates in one law; A chart the law cites and no open source gives; An electronic billing machine that is not an exchange format; Zero decimals
- **[Bolivia](../packs/bo/README.md#what-the-core-could-not-say)** (`bo`) — Clearance-adjacent e-invoicing; The Impuesto a las Transacciones; The Impuesto sobre las Utilidades de las Empresas (IUE); A deadline that runs off the last digit of the NIT; Compras no discriminables and their proportional crédito fiscal; Ekwo does not issue a Factura, Nota Fiscal o Documento Equivalente
- **[Bhutan](../packs/bt/README.md#what-the-core-could-not-say)** (`bt`) — A five per cent GST in force from 1 January 2026; A deadline counted in days; A reverse charge that is also a credit
- **[Botswana](../packs/bw/README.md#what-the-core-could-not-say)** (`bw`) — Tax periods that start in December; An electronic billing system that reports to the administration; A suspension by notice
- **[Colombia](../packs/co/README.md#what-the-core-could-not-say)** (`co`) — Clearance; A retention paid on a different form; A municipal tax the core has no place for; Two forms this pack does not carry
- **[Costa Rica](../packs/cr/README.md#what-the-core-could-not-say)** (`cr`) — Clearance; Proportional credit; Forms not carried
- **[Cabo Verde](../packs/cv/README.md#what-the-core-could-not-say)** (`cv`) — A text read in the Boletim Oficial, up to 2015; An official chart; A form that cannot be fully filled; A clearance platform
- **[Djibouti](../packs/dj/README.md#what-the-core-could-not-say)** (`dj`) — A rate that moved and a guide that did not; A form of 22 lines; A chart nobody publishes; Zero decimals
- **[Ecuador](../packs/ec/README.md#what-the-core-could-not-say)** (`ec`) — Clearance; A tax point that differs by document, at the taxpayer's election; Two withholding regimes on a separate return; A proportionality factor for input tax; A deferred tax point for sales on credit
- **[Guatemala](../packs/gt/README.md#what-the-core-could-not-say)** (`gt`) — Clearance; Regional or sectoral rates this pack does not carry; A deadline that Guatemalan law does not stagger by taxpayer
- **[Honduras](../packs/hn/README.md#what-the-core-could-not-say)** (`hn`)
- **[កម្ពុជា](../packs/kh/README.md#what-the-core-could-not-say)** (`kh`) — A ten per cent VAT, a monthly return, and texts that are scans; Two due dates for one return; Time of supply with seven days of grace; Credit excluded or prorated; A currency with no minor unit, used alongside the dollar
- **[Lao PDR](../packs/la/README.md#what-the-core-could-not-say)** (`la`) — A law read through summaries; A currency with no minor unit in use; No readable chart, form or portal
- **[Lesotho](../packs/ls/README.md#what-the-core-could-not-say)** (`ls`) — Rates in regulations, not in the Act; Clearance e-invoicing; A return form with no published numbering
- **[Madagascar](../packs/mg/README.md#what-the-core-could-not-say)** (`mg`) — A Code that is readable and a Plan that is not; A tax paid by the beneficiary; A threshold the pack cannot enforce
- **[Монгол Улс](../packs/mn/README.md#what-the-core-could-not-say)** (`mn`) — A ten per cent VAT with a return on the 10th; Chart and return form not readable; State receipt system
- **[Mauritanie](../packs/mr/README.md#what-the-core-could-not-say)** (`mr`) — A plan older than the Code; One rate and a long list of exemptions; Services taxed when paid; Tax paid at customs
- **[Malawi](../packs/mw/README.md#what-the-core-could-not-say)** (`mw`) — A law read in its 2014 consolidation; No readable VAT return form; Real-time clearance
- **[México](../packs/mx/README.md#what-the-core-could-not-say)** (`mx`) — Clearance; Withholding; Zero and exempt on collection; A region that is a list of municipalities; Two more forms; The CFDI data of a party; A deadline shifted in working days
- **[Malaysia](../packs/my/README.md#what-the-core-could-not-say)** (`my`) — An invoice the authority validates before it is issued; An obligation by size, and a threshold that moves by guideline; Cancelled at the authority, undone in the books; No VAT number, and a TIN with no scheme
- **[Namibia](../packs/na/README.md#what-the-core-could-not-say)** (`na`) — The registration threshold; Category A periods; Imported services; E-invoicing
- **[Nicaragua](../packs/ni/README.md#what-the-core-could-not-say)** (`ni`) — Taxes on turnover that are not invoice taxes; Withholdings; Proportional credit; A credit one period after its document; The refund procedure; Tax point; Two payment dates for one return; No fiscal e-invoice and no clearance
- **[Nepal](../packs/np/README.md#what-the-core-could-not-say)** (`np`) — A flat thirteen percent; A month that is not a Gregorian month; A year that begins in the middle of July; A reverse charge that is also a deduction
- **[Panamá](../packs/pa/README.md#what-the-core-could-not-say)** (`pa`) — Clearance; A service tax point with a third anchor; A ratio the declaration itself computes; Withholding, on its own annex
- **[Perú](../packs/pe/README.md#what-the-core-could-not-say)** (`pe`) — Clearance; Regional and sectoral regimes not carried; A deadline shifted by a digit of the RUC; The saldo a favor of a prior period; Export services under Apéndice V
- **[Paraguay](../packs/py/README.md#what-the-core-could-not-say)** (`py`)
- **[Seychelles](../packs/sc/README.md#what-the-core-could-not-say)** (`sc`) — One signed figure for lines 10 and 11; Two dates for the same return; A threshold that moved; No reverse charge, no adjustments
- **[Ҷумҳурии Тоҷикистон (Республика Таджикистан)](../packs/tj/README.md#what-the-core-could-not-say)** (`tj`) — A rate that changes on a date written in the transitional provisions; A chart read only in part; Reduced rates without credit; Reverse charge without credit; A return form with no readable text
- **[Туркменистан](../packs/tm/README.md#what-the-core-could-not-say)** (`tm`) — A fifteen per cent VAT with a return on the 20th; Input tax follows payment; Chart and return form not readable
- **[Ўзбекистон Республикаси](../packs/uz/README.md#what-the-core-could-not-say)** (`uz`) — A chart replaced on 1 January 2025; Tax kept "by type" in a single account; A tax point that takes the earlier of two dates; Exempt supplies with a proration of the credit; A return form with no readable text
- **[Zimbabwe](../packs/zw/README.md#what-the-core-could-not-say)** (`zw`) — Fiscalisation is a device, not a network; The buyer's telephone; Two currencies, one ledger; Category A periods; Two deadlines; Credit notes on their own line; A time of supply of five clauses; No TIN field
<!-- /generated -->
