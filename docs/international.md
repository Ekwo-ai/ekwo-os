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

A pack carries one of three statuses, which `ekwo init` and `ekwo status` print:

| Status | Meaning |
|---|---|
| `community` | Written from the official texts and checked by the tools and the golden year; no professional has signed it |
| `maintained` | As above, and kept current by the maintainers |
| `reviewed` | Read against the law by a named professional of the country, who signs it |

There is no status meaning "certified by Ekwo": writing a pack is not reviewing
it. How a professional reviews a pack is in
[`packs.md`](packs.md#certification-and-who-may-say-what).

## What an international core needs and does not have

| Capability | Where it stands |
|---|---|
| A country as a versioned pack, upgraded in place | **Done** — `ekwo pack status` and `ekwo pack upgrade` |
| The rules of an invoice: numbering, payment terms, tax point, legal mentions, e-invoicing profile | **Done**, as pack data |
| Opening balances and a year-end close | **Done** — `opening_balance()`, `close_fiscal_year()`, `reopen_fiscal_year()` |
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
