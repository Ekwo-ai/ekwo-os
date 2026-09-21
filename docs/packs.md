# Country packs

A country is data. Everything Belgium or France adds to Ekwo — a chart of
accounts, journals, VAT codes, the accounts each of them posts to, the boxes
of the periodic return — is a set of files under `packs/<cc>/`, compiled into
one SQL seed that is committed. There is no module per country, no Python
hook, and no field in the format through which a pack could run anything.

The decision behind this, with the alternatives that were weighed, is in
[`decisions.md`](decisions.md).

## What a pack is

```
packs/be/
├── pack.json          manifest: version, certification, defaults, roles, journals, charts
├── accounts.csv       the default chart: code, parent, type, reconcilable, name, sequence
├── accounts.asbl.csv  a second chart, named by charts[] in the manifest
├── taxes.json         taxes and their postings, per kind of document
├── tax_report.json    the boxes of the periodic return and their totals
├── statements.json    the balance sheet, the income statement and their rules
├── assets.json        the section of the fixed assets module, where the country has one
├── golden/
│   ├── scenario.json  one year of books: documents, payments, the periods filed
│   ├── vat_return.json    what the declaration comes to, period by period
│   ├── statements.json    what every line of every statement comes to
│   └── trial_balance.json every account that moved, to the cent
└── i18n/
    ├── README.md      where each language's wording comes from
    ├── nl.json        every label of the pack, in one more language
    ├── de.json
    └── en.json

packs/generic/         a pack with no country: statements by account type
├── pack.json
└── statements.json
```

## A country has charts, not a chart

`pack.json` declares them, exactly one of them the default:

```json
"charts": [
  { "code": "default", "name": "PCMN — plan comptable minimum normalisé",
    "accounts": "accounts.csv", "default": true, "audience": "companies",
    "statements": ["BE-BNB-ABBR-BS", "BE-BNB-ABBR-IS", "BE-BNB-ABBR-AF"] },
  { "code": "asbl", "name": "PCMN — associations et fondations",
    "accounts": "accounts.asbl.csv", "audience": "nonprofits", "statements": [],
    "certification": { "status": "community" } }
]
```

A pack that declares no `charts` has one chart called `default` whose accounts
are in `accounts.csv`, which is what every pack written before this said.

**The journals, the taxes and the declaration form are common to the charts of
a country.** An association buys, sells and banks through the same journals as
a company and files the same VAT return; only the accounts differ, and the
statements that present them. So do the roles — receivable, payable, suspense
— which stay in `defaults.roles`, and `ekwo pack check` refuses a pack whose
role codes and tax posting accounts are not in *every* chart it ships.

`ekwo init --chart <code>` picks one; without the flag, an interactive install
asks only when the pack offers several, and a non-interactive one refuses and
lists them. `ekwo status` prints the chart each company keeps its books on.

## Financial statements

`statements.json` holds one entry per scheme: a `code`, a `kind`
(`balance_sheet`, `income_statement`, `allocation`), a `framework`, and its
lines. A line is either summed from the ledger, through `rules`, or computed
from other lines, through `plus` and `minus` — there is no expression
language, as there is none for a declaration form.

```json
{ "code": "40/41", "parent": "29/58", "name": "Créances à un an au plus",
  "sequence": 150, "xbrl": "met:am1|bas:m9|rst:m2",
  "rules": [ { "kind": "code_range", "code_from": "40", "code_to": "41" },
             { "kind": "code_range", "code_from": "499", "code_to": "499", "side": "debit" } ] }
```

Four kinds of rule: `account_code` names one code, `code_range` and
`code_prefix` compare the head of the code (`40`..`41` takes 400000 and 411000
and stops at 42), `account_type` is what the generic framework is made of.
`side` splits one account between two lines — a suspense account is a
receivable while it is in debit and a payable while it is in credit — and is
the only way two lines may share an account.

`sign` multiplies the debit-minus-credit balance so the line reads the way the
scheme prints it: `1` on an asset or an expense, `-1` on a liability, equity or
income line.

`xbrl` is the **fact key** of the line in the taxonomy the country files in,
and it is optional: null where nothing could be verified. The three Belgian
schemes name all fifty-three of theirs. A taxonomy such as
the Belgian CBSO has no element per reporting code — it is dimensional, so a
line is a metric plus a set of domain members, written metric first and
separated by `|`. One key, one fact, therefore **one line**: `ekwo pack check`
refuses two lines of a statement carrying the same key, which is how a key
missing a member shows up. The two sides of a balance sheet are the case to
watch — `met:am1|bas:m25` is the total of the assets *and* the total of the
liabilities until `part:m1` or `part:m3` says which.

The totals of a scheme and the totals of a declaration form are worked out by
the same function, `evaluate_totals()`, in the order they depend on each other.
A statement prints its whole frame and a return omits a box that comes to
nothing, which is one argument to it and not a second evaluator.

A `balance_sheet` reads balances cumulative to the end of the period; an
`income_statement` reads the movements inside it, **less the entries
`close_fiscal_year()` marks `kind = 'closing'`**, so a closed year still
reports what it earned. A balance sheet keeps those entries: they are what
carries the result onto the line it shows.

**A chart names the statements it reports on.** A statement named by exactly
one chart belongs to that chart; one named by several, or by none, fits every
chart of the country. A chart that names none falls back to `packs/generic/`,
the country-less pack whose rules are all `account_type` — which is what the
eighteen account types buy, and what gives a British or American chart with no
legal codes a balance sheet that ties out.

**A sign belongs to a line summed from the ledger, and to no other.** `sign:
-1` is how a scheme prints a credit balance as a positive figure, and
`financial_statement()` applies it when it sums the line. A total is then
worked out from lines that already read that way, so a sign on the total would
be applied to them a second time: flip a credit line and flip the subtotal
above it, and the figure comes back the way it started, silently. It cost the
Luxembourg pack a wrong set of golden figures. `ekwo pack check` refuses the
two together; `minus` is how a total subtracts.

`ekwo pack check` refuses a statement whose totals form a cycle, a line that is
both summed and computed, a computed line carrying a sign, two lines that catch
one account on the same side, two lines that carry the same fact key, and — the
check that makes a balance sheet balance — **a chart with an account that
reaches no line of any of its statements**. A heading, an account with
children, may reach none: it straddles the lines its children are split over
and nothing is posted to it.

Every file is validated against [`packs/schema/pack.1.json`](../packs/schema/pack.1.json),
a JSON Schema draft 2020-12 that describes all of them: the manifest is the
root, the others are `$defs`. Two formats and no third: JSON for anything with
a shape, CSV for the chart, which is flat, long, and what Odoo, Xero and
QuickBooks all exchange — a reviewer reads one line per account in a diff, and
an accountant opens it in a spreadsheet.

`accounts.csv` is a **strict subset** of CSV: a header line, no newline inside
a field, a field quoted only when it holds a comma or a quote, a quote doubled
inside a quoted field. The parser is forty lines and refuses anything else.

## Compiling

```sh
ekwo pack list           # the packs this checkout carries, and their certification
ekwo pack describe be    # everything one pack says; every pack with no country named
ekwo pack build be       # writes supabase/seed/10_pack_be.sql, and the lists of packs
ekwo pack build --all
ekwo pack check be       # validate one pack, compare its seed and the lists of packs
ekwo pack check --all    # exit 1 if a committed seed or list is not the output of the packs
ekwo pack check --all --links   # … and open every URL of every source register
```

All of them run in a checkout of the repository and touch no database: they walk
up from the command's own file looking for a directory holding both `packs/`
and `supabase/seed/`, and say so plainly when there is none — a published
installation carries the compiled seeds and no `packs/` folder, and there is
nothing there to build.

`--links` is the one thing under `packs/` that reaches the network, which is
why it is an option and why the CI never passes it. It opens every URL of
every [source register](#the-register-of-sources) and names the ones that did
not answer, and **it never changes the exit code**. A link that is quiet today
is not a wrong pack: Légifrance refuses a request with no browser behind it —
all four of its entries come back `403` here — Riigi Teataja serves the same
page for a text and for a typo, and a ministry moves a form the week before a
deadline. A gate on any of that would fail a contributor's pull request for
something nobody in it did, and the cheapest way to make it green would be to
delete the link. So it reports a reading, and a maintainer decides.

`ekwo pack list` prints every pack of the checkout — the framework first,
then each country with its version, its charts and their accounts, its taxes,
its statements, its languages, its certification and its golden scenario. An
excerpt, as it read on the day this was written:

```
Packs (…)
  generic  Generic framework 1.1.1 · 2 statements · no country · certification maintained
          no golden — A framework is not a country: this pack carries statements and nothing else …
  be  Belgium 1.15.0 · 2 chart(s), 706 accounts · 22 taxes · 3 statements · fr, nl, de, en · certification maintained · golden: 12 documents, 4 payments, 4 period(s)
          filing — BE-VAT-PERIODIC (31 boxes) · cadence: month · deadline: in the pack · file: vat-consignment · settles to: 451900
          default (default) — PCMN — plan comptable minimum normalisé, 355 accounts, BE-BNB-ABBR-BS, BE-BNB-ABBR-IS, BE-BNB-ABBR-AF
          asbl — PCMN — associations et fondations, 351 accounts, generic statements only
  …
```

### The packs of this checkout

The table below is **generated**: `ekwo pack build` writes it from the
manifests under `packs/`, and `ekwo pack check` refuses it when it no longer
says what they say. `ekwo pack describe <cc>` is everything one of them says.

<!-- generated:packs -->
| Pack | Country | Seed | Languages | Certification |
|---|---|---|---|---|
| [`au`](../packs/au/) | Australia | `40_pack_au.sql` | en | `community` |
| [`be`](../packs/be/) | Belgium | `10_pack_be.sql` | fr, nl, de, en | `maintained` |
| [`bf`](../packs/bf/) | Burkina Faso | `23_pack_bf.sql` | fr | `community` |
| [`bj`](../packs/bj/) | Bénin | `22_pack_bj.sql` | fr | `community` |
| [`ci`](../packs/ci/) | Côte d’Ivoire | `21_pack_ci.sql` | fr | `community` |
| [`cm`](../packs/cm/) | Cameroun | `24_pack_cm.sql` | fr | `community` |
| [`de`](../packs/de/) | Germany | `18_pack_de.sql` | de, en | `community` |
| [`ee`](../packs/ee/) | Estonia | `13_pack_ee.sql` | et, en | `community` |
| [`es`](../packs/es/) | España | `19_pack_es.sql` | es, en | `community` |
| [`fr`](../packs/fr/) | France | `11_pack_fr.sql` | fr, en | `maintained` |
| [`gb`](../packs/gb/) | United Kingdom | `14_pack_gb.sql` | en | `community` |
| [`ie`](../packs/ie/) | Ireland | `16_pack_ie.sql` | en | `community` |
| [`lu`](../packs/lu/) | Luxembourg | `12_pack_lu.sql` | fr, de, en | `community` |
| [`mx`](../packs/mx/) | México | `42_pack_mx.sql` | es, en | `community` |
| [`ne`](../packs/ne/) | Niger | `33_pack_ne.sql` | fr | `community` |
| [`nl`](../packs/nl/) | Nederland | `17_pack_nl.sql` | nl, en | `community` |
| [`sg`](../packs/sg/) | Singapore | `50_pack_sg.sql` | en | `community` |
| [`sn`](../packs/sn/) | Sénégal | `20_pack_sn.sql` | fr | `community` |
| [`us`](../packs/us/) | United States | `15_pack_us.sql` | en | `community` |
<!-- /generated -->

The SQL is a **build artefact**, like `docs/schema.md`. The source is the
pack; the output is committed so that `supabase db push` and `psql -f` install
a country without the CLI ever running; the CI's *hygiene* job runs
`ekwo pack check --all` so the two cannot drift. Never edit a generated seed:
the next `pack build` overwrites it and the CI refuses it in the meantime.

### The number a seed carries is the pack's own

`seed_sequence` in the manifest. It is **required**, and it is **immutable once
published**: the seeds are applied in file-name order and listed by name in
`supabase/config.toml`, so a release that renamed one would rename a file an
installation already holds — harmless, because the seeds upsert, and baffling
to anyone reading the list a year later.

It used to be the pack's rank in the alphabetical list of slugs, which is
stable exactly until a country is added in the middle of it: inserting `ee`
between `be` and `fr` moved France and Luxembourg one place each. Nothing sorts
anything now. `ekwo pack check` refuses a pack that declares no number, and
`ekwo pack build` refuses two packs claiming the same one.

**Four kinds of file are generated, and `check` compares all four.**

| Source | Output |
|---|---|
| `packs/generic/` | `supabase/seed/05_framework_generic.sql` |
| `packs/<cc>/` | `supabase/seed/<n>_pack_<cc>.sql`, where `<n>` is the number the manifest declares in `seed_sequence` — the table [above](#the-packs-of-this-checkout) gives each pack's. **A number that has shipped never moves**, whatever is added beside it |
| `packs/<cc>/assets.json`, where the pack has one | `supabase/seed/modules/assets/<n>_pack_<cc>.sql`, applied by the module migration runner and by nothing else |
| every pack, together | the lists that name them outside `packs/`: `[db.seed] sql_paths` in `supabase/config.toml`, the `psql -f` lines of the README, the `/packs/<cc>/` lines of `.github/CODEOWNERS` and the table above. Only the block between `generated:<name>` and `/generated` is written; the prose around it is not. A handle written on a pack's CODEOWNERS line is kept, and a new pack gets the owner of `*` |

The compiler writes `chart_templates`, `account_templates`,
`journal_templates`, `tax_templates`, `tax_posting_templates`,
`tax_report_templates`, `tax_report_box_templates`, `statement_templates`,
`statement_line_templates`, `statement_line_rules`, `legal_mention_templates`,
`country_defaults`, `country_packs` and — for a module section —
`assets.country_rules` and `assets.category_templates`, and **nothing that
belongs to a company**. Every insert upserts on the natural key —
`(country, chart_code, code)` for an account, `(country, code)` for the rest —
which matters more than it sounds: the seeds used to say
`on conflict do nothing`, so an instance installed last month received no
correction at all — not even for a company created afterwards, since a company
copies the templates when it is installed.

What an upsert cannot do is remove. A template deleted from a pack stays in
the database, which is the rule anyway: **nothing is ever deleted from a
pack**. An account is deprecated, a tax gets a `valid_to`, a form version gets
a new `valid_from`.

### The seed carries a checksum of the pack

`country_packs.checksum` is a sha256 over every file of `packs/<cc>/`, its path
and its bytes. It is what lets an installation say which pack it is holding
rather than which version number somebody typed, and it has one consequence
worth knowing while you work: **changing any file of a pack makes the committed
seed stale**, including a file the compiler never reads, such as
`i18n/README.md`. `ekwo pack build` again and commit the result.

The three generated files under `golden/` are the deliberate exception —
`vat_return.json`, `statements.json` and `trial_balance.json` are outside the
checksum, and `golden/scenario.json` is inside it. A scenario is a decision
about what a country's books look like, and moving it moves the pack; the
expectations are what the engine made of that scenario, so a checksum that
moved because the statements function gained a line would tell every operator
that Belgium had changed.

### What a stale seed looks like

```
Checking
  · 05_framework_generic.sql
✗ 10_pack_be.sql is not the output of packs/be
          golden: 12 documents, 4 payments, 4 period(s) of Exercice 2026
  · modules/assets/10_pack_be.sql
  · 21_pack_ci.sql
          golden: 12 documents, 4 payments, 4 period(s) of Exercice 2026
  …
✗ supabase/config.toml (generated:seeds) is not what packs/ says
  · README.md (generated:seeds)
  · README.md (generated:countries)
  · docs/packs.md (generated:packs)
  · .github/CODEOWNERS (generated:packs)

  Run `ekwo pack build --all` and commit the result.
```

Exit 1. A pack that fails **validation** rather than drifting exits 1 as well,
and stops there: the packs after it are not checked.

```
Checking
✗ pack_invalid: packs/be — 2 problem(s)
  taxes.json[0]: missing "legal_reference"
  taxes.json BE-S-12.invoice: box ZZ:base is not a base box of this form
```

Problems are collected and reported together rather than one per run, in
`<file> <where>: <what>` form, structure first and the translations last, with
the first twenty printed and the rest counted. A usage fault — an unknown pack,
no country and no `--all` — exits 2 instead, and names what the checkout
carries.

## What a tax says, and where its postings land

A tax in `taxes.json` says how much and what kind; its `postings` say where
the money goes, per kind of document.

| Field | What it decides |
|---|---|
| `kind` | `vat`, `gst`, `sales_tax`, `withholding`, `other`. A label for the reports, never an input to the calculation. Defaults to `vat`. |
| `recoverable` | `false` when the buyer never gets the tax back — American sales tax, Canadian PST, a wholly non-deductible VAT. |
| `price_include` | The unit price of a line carrying this tax already holds it (British, Australian and most retail). The engine adds the tax to the gross of the **tax group**, rounds it once as BR-CO-14 requires, takes it back off to get the base, and shares that base over the lines in proportion to their gross with the remainder on the last — so the document totals the price that was quoted, to the unit. A discount applies to the gross, before the conversion. Only a percentage tax may declare it: a fixed amount has no rate to divide by, and `ekwo pack check` refuses one. |
| `jurisdiction` | ISO 3166-2 **with** the country prefix (`CA-QC`, `US-CA`) for a tax levied by a state. Null in Europe. |
| `cash_basis`, `cash_basis_transition_account` | The tax falls due when the invoice is paid, not when it is issued. `post_document` books it — and the base it is computed on — on the transition account and on no declaration box; the matching moves the settled share to the account and the box it is declared on. A cash-basis tax has to name its transition account and takes **one** `tax` posting per document kind, with no `tax_on_base`: `ekwo pack check` refuses the rest. |

A posting has one of three types:

- **`base`** — the taxed amount itself. It carries no account: the account is
  the one the document line names.
- **`tax`** — an amount on a tax account, which it must name.
- **`tax_on_base`** — a share of the tax that is *not* recoverable. It carries
  no account either, and for the same reason as `base`: non-deductible VAT is
  part of what the thing cost, so it lands on the accounts of the lines it
  taxes, split in proportion to their bases.

`factor` is the share of the amount that reaches the ledger, `box_factor` the
share reported in the box, and the two are independent because a box is filled
with the sign and the fraction the form expects. The Belgian vehicle tax uses
both:

```json
{
  "code": "BE-P-21-50-I",
  "rate": 21,
  "scope": "purchase",
  "legal_reference": "Code de la TVA, art. 45, par. 2",
  "postings": {
    "invoice": [
      { "type": "base", "box": "83" },
      { "type": "tax", "factor": 50, "account": "411000", "box": "59", "box_factor": 50 },
      { "type": "tax_on_base", "factor": 50, "box": "83", "box_factor": 50 }
    ]
  }
}
```

On a 1 000 € car: 1 000 on the vehicle, 105 on the deductible VAT account, 105
more on the vehicle, 1 210 owed to the supplier. Grid 83 reports 1 105 —
Belgium asks for the base **plus** the non-deductible VAT, which is what the
form's « TVA déductible non comprise » means. A wholly non-deductible tax is
the same shape with one `tax_on_base` posting at 100 % and no `tax` posting.
France needs no `box` on its `tax_on_base` posting at all: the CA3 carries no
grid for the base of a purchase.

The postings of one side share out the tax of the group, which is rounded once
(EN 16931 BR-CO-14); the last posting of each side takes the remainder, so two
halves of 0,63 come out as 0,32 and 0,31 rather than 0,32 twice.

`defaults.rounding_method` and `defaults.cash_rounding_unit` belong to the same
rule: a pack says how its country rounds, and a pack that says nothing gets the
column's own default. The compiler writes `default` rather than a value of its
own, so there is exactly one place where the mechanism is decided and no
country is anybody's fallback.

`rounding_method` is read. It is half of the pair `round_amount()` applies to
every amount the schema writes; the other half is `decimal_places` on the
currency the pack names in `defaults.currency`, which says that the yen has
none and the dinar has three. A pack that declares `half_even` therefore
changes what its country's ledger holds, and the four methods — half up, half
even, down, up — are all applied to the absolute value, so a credit note is
always its invoice with the sign flipped. `cash_rounding_unit` is still
declared and read by nothing: the socle has no cash-payment path to round a
total on.

### A base is written once, and printed as often as the form likes

**A tax carries one `base` posting per kind of document**, so a taxable amount
has one definition. `ekwo pack check` refuses a second one. A form that prints
the same base twice is therefore never a tax with two base postings, and it is
printed twice in one of two ways: **by a total when the second place is a sum**,
and **by the posting itself when it is not**.

Luxembourg is the case to read, because the eCDF return asks for the taxable
amount of a sale twice: as turnover in section I, and in the rate breakdown of
section II. The pack defines it in the breakdown, where the rate makes it
unambiguous:

```json
{ "code": "LU-S-17", "rate": 17, "scope": "sale",
  "postings": { "invoice": [ { "type": "base", "box": "701" },
                             { "type": "tax", "account": "461411", "box": "702" } ] } }
```

Section I then reads that box instead of being posted to. `472` is declared a
total, not a base:

```json
{ "box": "472", "kind": "total", "name": "b) Autres ventes / recettes", "sequence": 170,
  "plus": ["701", "901", "703", "903", "705", "905", "031",
           "457", "014", "015", "016", "017", "481", "482", "226",
           "018", "423", "424", "019", "419"] }
```

— the seven rate bases of section II, then the exemptions, the franchise
regimes and the operations taxed elsewhere — and `454` adds `471` and `472`,
and `012` adds `454` to the two private-use boxes. One figure is posted, and
every line of the form that shows it again is derived from that one.

That is the first way, and it is the one to reach for: the second place is a
sum of things the postings already wrote, so it is written down as a sum.

The second way is for a parent that is **not** a sum. Form KMD reports an
intra-Community acquisition of goods in box 6.1, in box 6 around it and in box
1 around that — and box 6 is not the total of the boxes printed under it,
because the rest of box 6 is services received, which the form never prints on
its own. The British VAT Return does the same sideways: the value of a service
received from a supplier established abroad goes in box 6, which is outputs,
and in box 7, which is inputs, and neither box contains the other. There is no
total to write in either case, so the posting **names every box it prints in**:

```json
{ "code": "EE-P-ICG-24", "rate": 24, "scope": "purchase",
  "treatment": "intracom_acquisition_goods",
  "postings": { "invoice": [ { "type": "base", "box": ["1", "6", "61"] },
                             { "type": "tax", "account": "2311", "box": "5" },
                             { "type": "tax", "factor": -100, "account": "2310", "box": "4" } ] } }
```

One amount, printed in three boxes, and still one `base` posting and one
definition. `box` takes a string or a list of strings; the first of the list is
the box the posting is known by, and `box_factor` is the share reported — the
same share in each, because a form that prints one figure in three places
prints the same figure in all three. `ekwo pack check` refuses an empty list, a
box named twice by one posting, a box the form does not carry, and a box the
form declares a `total`: a total is added up from the boxes below it, so an
amount written straight into one would be counted twice.

**When you meet it**, ask whether the second place is a sum. If it is — the
turnover line above a rate breakdown, the box that adds the four boxes printed
under it — declare a `total` naming what the postings wrote. If it is not,
name both boxes on the posting. What is never right is two base postings: two
definitions of one figure, kept in step by whoever reads the pack next, and
`pack check` refuses them before that can start.

A `hidden` box has one use left after this, and it is the Belgian one: an
intermediate `total` the form works out inside a formula and does not print. A
hidden box that a posting writes into is the old workaround for exactly the
shape above, and there is no longer a reason for one.

## What a tax says on the invoice: treatment, category and reason

A tax says the same fact three times over. `treatment` is Ekwo's own word for
what the operation is. `vat_category` is BT-118 and BT-151 of EN 16931, from
the UNCL5305 subset the standard publishes. `exemption_code` is BT-121, from
the VATEX list. Neither of the last two is read by the ledger or by the
declaration — they are read by whoever renders the invoice — so until
`ekwo pack check` learned the correspondence, a pack could declare an export
taxed at the standard rate and every test in this repository would pass.

Three published sources decide the whole table, and nothing here is anybody's
opinion:

- **UNCL5305 (UN/CEFACT D.16B, the OpenPEPPOL subset)** for what each code
  means. `K` is *VAT exempt for EEA intra-community supply of goods **and
  services***, which settles a question the Ekwo vocabulary asks twice.
- **Technical guidance for tax codes in EN 16931, version 1** (European
  Commission, Technical Advisory Group on Electronic Invoicing, use cases
  dated 1 July 2024), whose six use cases give the pair for each case. Its
  fourth is "export outside the EU", which is the Union's border because the
  seller it addresses is established in a Member State; what UNCL5305 itself
  says of `G` is *free export item, VAT not charged*, so the border is the one
  of whoever levies the tax.
- **The VATEX code list itself**, which carries the pairing as a remark on
  eight of its codes: `VATEX-EU-AE` *only use with category code AE*,
  `VATEX-EU-IC` with `K`, `VATEX-EU-G` with `G`, `VATEX-EU-O` with `O`, and
  `VATEX-EU-D`, `-F`, `-I`, `-J` with `E`.

| `treatment` | Side | `vat_category` | `exemption_code` |
|---|---|---|---|
| `domestic` | either | `S` above zero, `Z` at zero | none |
| `domestic_reverse_charge` | either | `AE` | `VATEX-EU-AE` |
| `self_assessed` | purchase | none | none |
| `intracom_goods` | sale | `K` | `VATEX-EU-IC` |
| `intracom_services` | sale | `K` | `VATEX-EU-IC` |
| `intracom_triangular` | sale | `K` | `VATEX-EU-IC` |
| `intracom_acquisition_goods` | purchase | `K`, or none | `VATEX-EU-IC` |
| `intracom_acquisition_services` | purchase | `K`, or none | `VATEX-EU-IC` |
| `foreign_services_received` | purchase | none | none |
| `export` | sale | `G` | `VATEX-EU-G` |
| `import` | purchase | none | none |
| `exempt` | either | `E` | the article claimed, from the VATEX list |
| `not_subject` | either | `O` | `VATEX-EU-O` |

**That table is the Union's, and the last column applies where the Union's VAT
does.** EN 16931 is a European standard and the VATEX list is published by the
European Commission: its own codes name articles of Directive 2006/112/EC, and
its national codes — `VATEX-FR-CGI261-1` and the rest — belong to Member States
that publish them. So a pack for a country the common system of VAT does not
reach reads the table with two changes:

- **`exemption_code` is null**, and the article the line is exempt under goes in
  `legal_reference`, where it was going to go anyway — and is required there
  wherever the category asks for a reason, because it is what the invoice
  states instead of a code. A VATEX code is refused by name, the national
  spelling included: `VATEX-EU-G` on an export from a third country claims an
  article of a Directive that does not bind the seller.
- **The five `intracom_*` treatments are refused outright.** An intra-Community
  supply is an operation of the common system, and a country outside it makes
  none.
- **`vat_category` is no longer required, unless the pack declares an
  e-invoicing profile.** BT-151 is a term of an invoice governed by EN 16931.
  A country the common system does not reach whose sellers issue no such
  invoice has no category of anybody's to record, and asking for one is a
  European standard asking a question nobody reads the answer to: the first
  pack of a country with no value added tax at all had to write `S`, `E` and
  `O` on codes no American invoice carries the field for. So the requirement
  follows the invoice. Where `einvoicing.profile` names a profile —
  `peppol-bis-3`, `factur-x-en16931`, `xrechnung`, a PINT, each built on the
  semantic model of EN 16931 and each carrying BT-151 — a tax that can reach a
  sale still has to name a category. Where the pack names no profile, the
  column is free, the way it already is on a purchase-only tax.

Everything else holds: the column being free is not the column being unchecked.
A category a pack *does* name is still held to the treatment, to its reason and
to its rate, everywhere. The categories are UNCL5305, a UN/CEFACT list: `E`, `G`,
`O` and `AE` keep their meanings, a sale still has to name one, and the rate
rules of EN 16931 still fix what it may be charged at.

Should a country outside the Union one day publish reason codes of its own —
none has, and PINT is where it would surface — the column takes them, on one
condition: the pack's register declares that list, as the entry of
`certification.sources` that says so of itself with `"reason_codes": true`.
What is checked is that a list is named and that the value is a code rather
than a sentence, never that the code is in the list.

**It is the entry that says so, and not the first `standard` in the register.**
That flag exists because `standard` means "a technical norm or code list", which
the FASB Accounting Standards Codification and FRS 102 are as much as VATEX is:
reading the first one found made a pack that cites its country's accounting
standards declare a list of exemption reason codes without knowing it, and
silently authorised a code on any of its taxes. At most one entry of a register
may carry the flag, and it has to be a `standard`, because a published list of
codes is one; `ekwo pack check` refuses a second and refuses the flag on any
other kind. That is exactly what is checked of a VATEX code inside
the Union, where the check holds no copy of the list either.

Which side of that line a pack is on is **not** written anywhere in the code.
It is a row of `territories`, the reference table of the framework that
`ec_sales_list()` already reads — `eu_vat_scope` at the pack's `released_at`,
with `full` meaning the common system reaches the country. `ekwo pack check`
runs on a checkout with no database, so it parses
`supabase/seed/00_territories.sql`, which is the file the database itself is
seeded from; `tests/vat_codes.test.ts` holds its answer against
`eu_vat_scope_of()` for every territory on every date the table names. Two
consequences worth knowing:

- **The day is `released_at`, not today.** A pack is a transcription of a law
  and `released_at` is the day it says that transcription is true. Asking today
  would make a pack pass in the morning and fail in the evening with nothing
  committed in between, on the day a State acceded or left. Asking a tax's own
  `valid_from` would be worse: the taxes of a pack span decades, so one pack
  would speak two regimes and a British rate of 1994 would be asked for a code
  from a list that did not exist.
- **A country `territories` carries no row for is held to the table above.**
  Every rule in this section narrows what a pack may say, and narrowing on a
  missing row would refuse a valid pack for a country nobody has added to the
  reference data yet. Silence is not a no. A pack of this repository never
  reaches that fallback, because the test suite refuses one whose country is
  not in the table.

Three more things in that table are decisions, and all three are worth reading
before filling a column in.

**A category is a term of the invoice, so on a purchase it is the
supplier's.** A purchase tax describes how the buyer books and declares
somebody else's invoice, and BT-151 on that invoice was chosen by the seller.
An intra-Community acquisition is therefore `K`: the supplier made an
intra-Community supply, and rule BR-IC-10 binds them to `K` and
`VATEX-EU-IC`. It is not `AE`, which the guidance gives for a reverse charge
*within* one Member State — the case where the supplier is established in the
buyer's country and national law moves the liability. A pack that does not
want to record the seller's answer may leave the column null on a
purchase-only tax; a value that contradicts the treatment is refused either
way, and a tax that can reach a sale has to name one.

**Where no invoice governed by the standard exists, the category is absent.**
Import tax is assessed on a customs document, and a service received from a
supplier the Union's rules do not reach arrives on an invoice the Directive
does not govern. There is no seller's category to record, so `import` and
`foreign_services_received` carry none. `S` there would claim the supplier
levied the standard rate, which is the one thing that certainly did not
happen.

**A triangular supply is `K`, not `AE`.** `intracom_triangular` is the middle
supply of a triangular arrangement — A sells to B, B sells to C, the goods go
straight from A to C — that is, B's sale to C, relieved by article 141 of
Directive 2006/112/EC and reverse-charged to C by article 197. A's supply is an
ordinary `intracom_goods` and C's purchase an ordinary
`intracom_acquisition_goods`, so there is one value to add and not three. `AE`
is the guidance's case for a reverse charge *within* one Member State, where
the supplier is established in the buyer's country; this is the opposite shape,
the goods leaving the seller's State, and what the line is — in the words of
UNCL5305 — is *VAT exempt for EEA intra-community supply of goods and
services*. On the invoice it is the **reverse-charge** sentence that comes out
and not the intra-Union exemption: the supply is not exempt under article 138,
and article 226(11a) requires the mention that says the customer owes the tax.
A pack that declares such a tax gets `triangular` out of `ec_sales_list()` for
free, and the four recapitulative-statement bricks already have a column and a
code for it.

`self_assessed` is the treatment for **a tax a buyer owes directly to an
administration under that administration's own law**, and computes and declares
themselves. American use tax is the case it was written for: section 6201 of
California's Revenue and Taxation Code imposes the tax on the storage, use or
consumption of property bought from a retailer, and section 6202(a) makes the
buyer liable for it. Mechanically it looks like the reverse charge above, and
it is not one — there is no exempt supply behind it, no supplier who was
relieved of anything, no recapitulative statement, and nothing at all is
recovered at the other end, which is why such a tax usually carries a
`tax_on_base` posting as well. It carries no category and no reason code, for
the reason `import` and `foreign_services_received` carry none: a buyer
assessing a tax on themselves holds no invoice EN 16931 governs, and there may
be no supplier the levying State can reach at all. It is **not** refused inside
the common system — a Member State levying a duty of its own that a buyer
self-assesses would be describing this and not article 194 — and what tells the
two apart is the law each tax cites.

`foreign_services_received` is the treatment for a service bought from a
supplier who is not established in the buyer's country and charges no tax on
it, the buyer accounting for it themselves under the general
business-to-business rule — articles 44 and 196 of Directive 2006/112/EC. It
is the sibling of `intracom_acquisition_services` for a supplier the
intra-Union rules do not reach, and it says nothing about where that supplier
is: the rule turns on **establishment**, which is why the name is not
`import_services`. It is also why it is not `import`, which in this vocabulary
means goods declared to customs — a different mechanism behind a different
document. On the invoice, it is the reverse-charge sentence that comes out:
the same mechanism as a domestic reverse charge, under a different article.

The rate is checked on sales only. There the pack's `rate` is the BT-152 the
seller prints, and the business rules of EN 16931 fix it per category —
BR-S-05 wants a standard-rated line above zero, and BR-Z-05, BR-E-05,
BR-AE-05, BR-IC-05, BR-G-05 and BR-O-05 want zero. On a purchase the rate is
the one the buyer self-assesses at, 21 % on a line the supplier invoiced at
zero, so the same rule there would refuse every reverse charge ever written.

What the check does **not** hold is a copy of the VATEX list. The list grows,
two published renderings of it already disagree on which codes it carries, and
a code it has not heard of is not a contradiction. So a reason code is checked
for its shape — `VATEX-EU-<article>`, or `VATEX-<country>-<article>` for a
national one — and for the pairings the list itself states.

## What an exemption depends on

A tax code is the answer. Sometimes the *question* is not in the books either,
and `conditions` is where a pack says which question it was.

Three exemptions of one American pack make the case. A sale for resale is
untaxed because the seller holds a resale certificate — section 6091 of
California's Revenue and Taxation Code presumes every receipt taxable until
they take one from the purchaser, and Regulation 1668 says what it has to
contain. A sale of food is untaxed under section 6359 unless it is hot, or
carbonated, or alcoholic, or eaten where admission was charged. And a seller
collects in a State at all only once a running total of sales into it has been
crossed, which since *South Dakota v. Wayfair* is what economic nexus is. None
of the three is a fact the ledger holds, and before this field a reader of the
chart saw three zero-rated codes and one long sentence each.

```json
{ "code": "US-CA-S-RESALE", "rate": 0, "scope": "sale", "treatment": "exempt",
  "conditions": ["buyer_certificate"],
  "legal_reference": "Revenue and Taxation Code, section 6091 — …" }
```

Five words, and the vocabulary is closed:

| `conditions` | The answer turns on |
|---|---|
| `buyer_certificate` | a document the buyer hands the seller, which the seller has to hold and be able to produce |
| `buyer_status` | a quality of the buyer the statute names — a government, a body the law exempts as such |
| `transport_evidence` | proof that what was sold went where the exemption requires it to have gone |
| `seller_threshold` | a running total the seller crossed, or has not: economic nexus, a distance-selling limit, a small-business franchise |
| `supply_nature` | what is supplied, classified more finely than any ledger holds it |

**It says what the question is and never how to answer it.** There is no value
beside a word here: no threshold amount, no certificate number, no date, no
operator and no expression. That is the first invariant of this format and this
field is where it would have been easiest to break — a `conditions` that could
carry `sales_into_territory > 500000` would be a pack that evaluates, and the
next country would want a second operator. The amount a threshold is set at and
the contents a certificate must have are in the article the tax already cites,
which is where a reviewer reads them.

**Nothing in the core reads it**, exactly like `treatment`: it documents the
tax so that an application can put the question to a human being instead of
pretending to answer it, and what the tax *does* is said by its postings. It
compiles to `tax_templates.conditions` and stops there, the way `source_key`
does — this is the pack's transcription of a country's rule, not a property of
the tax a company went on to edit, and `taxes` carries `country` and `code`,
which is the join.

**What it does not record is the evidence itself.** There is still no place on
a contact for a certificate and its validity, and no place anywhere for a
rolling total per territory. Both are larger than the pack format — one is
document management, the other is reporting — and
[`international.md`](international.md) keeps them on the list. A pack states
the code a bookkeeper reaches for once the answer is known, says what the
question was, and invents no rule that would pretend to know it.

## Which declaration a box belongs to

A box number is unique inside one form and nowhere else. Belgium and France
each file one periodic return, so `59` has never been ambiguous; a Canadian
company files the federal GST/HST return and the Québec one at the same time,
and line `101` of one is not line `101` of the other. Every posting therefore
carries a `report_code`, which the compiler fills from the `code` of
`tax_report.json` — `BE-VAT-PERIODIC`, `FR-CA3` — and which a posting may
override with `"report": "…"` when a country files more than one.

## The boxes of a declaration, and how a total is computed

`tax_report.json` is one form — `BE-VAT-PERIODIC`, `FR-CA3` — and its boxes.
A `base` or a `tax` box is summed from what the postings wrote on the ledger;
a `total` is computed from the others:

```json
{ "box": "71", "kind": "total", "name": "TVA à payer à l'État", "sequence": 320,
  "plus": ["XX"], "minus": ["YY"], "floor_zero": true }
```

There is **no expression language**: a list to add, a list to subtract and a
floor at zero. That covers the Belgian 71/72, the French 16, 23, 25 and 28, and
the British box 5; the one other shape a form writes out, a rate applied to
another box, is below. `hidden` marks an intermediate total the form does not
print — `vat_return()` returns it with the flag rather than dropping it.

**How often the form is filed is part of the form.** `period` is the list of
cadences it accepts — `["month", "quarter"]` in Belgium, France and Luxembourg,
`["month"]` in Estonia, `["month", "bimonth", "year"]` in Ireland — and there is
no default for it. Six cadences exist, each a whole number of months anchored on
1 January: `month`, `bimonth` (January–February, March–April…), `quarter`,
`four_month` (from January, May, September), `half_year` (from January, July)
and `year`. A form lists only the ones a text of its register allows: a pack that names none is refused, because
the column this compiles to used to default to "monthly or quarterly" and a
country that had never thought about its cadence filed on Belgium's without
anybody deciding that. A single string is still read, `month_or_quarter`
meaning the two cadences it names, so a pack written before the list keeps
working.

**What the form is filed on unless the company has asked for something else**
is `period_default`, one of the cadences `period` lists. Declare it where the
law of that country gives one answer **to everybody**, and say which text does
in `legal_reference`; leave it out where the cadence depends on a fact about the
company, because proposing one of several lawful answers there is choosing a
filing deadline for somebody the pack knows nothing about. The two are a reading
of the law and not a count of the list: the United Kingdom files its return
monthly, quarterly or annually and reg. 25(1) of the Value Added Tax
Regulations 1995 still makes three months the prescribed accounting period for
everybody, a month and a year being what the Commissioners allow or direct on
application. So `packs/gb` proposes `quarter` on a form filed on three cadences.
Belgium and France propose `month` for the same reason in reverse — each
country's code makes the monthly return the rule and the quarterly one an
authorisation granted on turnover — and Luxembourg proposes nothing, because
there the cadence follows turnover with no answer the law gives everybody.
Estonia's form is filed on one cadence and proposes it.

**When the form is due** is `deadline`, a rule rather than a date, in a closed
vocabulary of three words, each with the text that sets it in
`legal_reference`:

| `rule` | The date it produces |
|---|---|
| `day_of_month_after_period` | the `day` of the month that follows the period (Belgium's and Estonia's twentieth, Luxembourg's fourteenth) |
| `last_day_of_month_after_period` | the last day of that month (California; the United Kingdom with `plus_days: 7`) |
| `depends_on_taxpayer` | none: the administration assigns the day per filer, and the pack says so and cites the text that assigns it (France, where it falls between the fifteenth and the twenty-fourth by place of filing, legal form and registration number) |

`plus_days` adds an extension to the first two and is refused on the third,
which has no date to add it to; `day` is required by the first and refused by
the others. Leave `deadline` out only when nobody has read the text yet: that
is the one meaning a missing deadline has, and the country page prints it as a
gap. `filing_deadline()` answers null for both — the core cannot know which
slice of a per-taxpayer schedule a company falls in.

**The unit the form is filed in** is `rounding`, and almost every form leaves
it out: its figures are filed at the decimals of its currency. A form filed in
coarser units says so, with the text that sets it —

```json
"rounding": {
  "unit": 1,
  "legal_reference": "CDTFA-401-A — \"please round cents to the nearest whole dollar\"",
  "source": "cdtfa-401-a"
}
```

`unit` is a power of ten (1, 10, 1000); `ekwo pack check` and the database both
refuse anything else, because a unit of 0.05 is a coin and belongs to
`defaults.cash_rounding_unit`. The ledger keeps its cents and `vat_return()`
answers the exact figures; `prepare_filing()` freezes each box at the unit, from
its own exact figure, and `filing_drift()` compares at the same unit, so the
cents a ledger holds are not a drift. A frozen box has no scale of its own: a
return in a currency without decimals freezes `1000000`, not `1000000.00`.

`defaults.vat_period` is where this used to be said, on the country rather than
on the form. It is still read, so a pack written before the move keeps working,
and a pack that says both and says two different things is refused: one fact,
one place.

Which cadence a given company files a given declaration on is a row of
`company_filing_periods`, settled at install — one row per form, because a
company is subject to several declarations and the cadence of one says nothing
about the cadence of another. `ekwo init` asks once per form the pack declares
and preselects nothing but the form's own `period_default`; `--vat-period`
answers for the periodic return outside a terminal and `--filing-period
<report_code>=<cadence>`, repeatable, for any of them. A company that has not
decided is recorded as not having decided. `companies.vat_period` is still
published and is the mirror of the row for the country's periodic return.
`vat_return()` then refuses a period the company does not file **that form** on
— and only when the refusal is certain: a cadence is recorded for this
declaration, the form is filed on it, the dates are themselves a whole cadence
of that form, and the two differ. A fortnight, a half-year asked of a form not
filed half-yearly, and a form the company has recorded nothing about all go
through. `ec_sales_list()` applies the
same guard to the form it is told it is preparing, and refuses nothing when it
is told none.

A reference is bare (`54`) where the form carries the box once, and qualified
(`08:tax`) where it carries a base and a tax on the same line, as the CA3
does. `ekwo pack check` refuses:

- a reference to a box the form does not carry;
- a bare reference that would match two kinds — qualify it;
- a total that names itself, and a box that is a rate of itself;
- boxes that are worked out from each other, by name — the cycle a dependency
  order cannot survive. Declaring a total **after** the total it names is not a
  cycle and is not refused: a form prints what it likes in the order it likes;
- a formula or a rate on a box that is summed from the ledger;
- a rate beside a `plus` or a `minus` list, which would be two ways of
  computing one figure, and a `rate` without a `rate_of` or the reverse;
- the same box declared twice with the same kind;
- a tax that posts to a box the form does not declare;
- a form that names no cadence, and a proposed cadence the form is not filed on.

The form is reference data and is never copied into a company: a chart of
accounts is customisable, a form is not. A new version of a form is a **new
code** with its own `valid_from`, like a new VAT rate is a new tax code, and
`vat_return()` takes the one in force at the end of the period.

### A total is a list of boxes, or a rate of one box

A total is a list of boxes in every European return, because a European return
reports a tax the ledger already worked out, document by document. A sales tax
return does not: it works the taxable total out for the period and then states
each tax line as a multiplication in as many words. CDTFA-401-A says *multiply
line 12 by 0.06*, and the pack says the same thing with two named fields:

```json
{ "box": "13", "kind": "total", "name": "State tax 6.00 percent", "sequence": 200,
  "rate": 6.0, "rate_of": "12" }
```

`rate` is a percentage and `rate_of` is the box it applies to, resolved exactly
as a `plus` reference is — bare, or qualified with its kind. A rate is not an
expression: there is nothing to parse, nothing a pack could execute, and a
reviewer reads *six per cent of line 12* in the diff. It is the one arithmetic
a declaration form actually writes out, which is why it is the only one the
format gained.

A box is a list **or** a rate, never both, and only a computed box carries
either: `ekwo pack check` and a check constraint both refuse the rest. Where
the second line of a form is a sum of what the postings already wrote, it is a
`plus` list and not a rate — the rule of "a base is written once" above is
unchanged.

### `sequence` is where a box is declared, `print_sequence` where it is printed

The order the totals are worked out in is **neither**: it is the boxes each one
names. `evaluate_totals()` resolves by dependency, so a form may print a
subtotal above the boxes it adds up — the eCDF sections do, and CDTFA-401-A
prints line 11 on page 1 and computes it from Sections A and B on page 3 — and
the pack says both orders instead of choosing one:

```json
{ "box": "11", "kind": "total", "name": "Total nontaxable transactions reported",
  "sequence": 180, "print_sequence": 40, "plus": ["45"] }
```

`print_sequence` is optional and means `sequence` when it is left out, which is
what every pack written before it says. `vat_return()` answers the resolved
value beside `sequence`, so a renderer orders by one column. A cycle — a box
worked out from itself, or two worked out from each other — is refused by
`ekwo pack check`, by name; at runtime it is `formula_cycle`, and never a loop.

## Which province a party is in

`defaults.region` is the other half of the same story: Canadian tax follows
the buyer's province, so `companies.region` and `contacts.region` exist (ISO
3166-2 without the country prefix — `QC`, `BC`). Nothing reads them before the
Canadian pack; the declarative rules that turn a region into a *suggested*
tax, and the group tax that puts GST and QST on one line, are phase 1. The
core never chooses a tax for anyone, in any country.

## Where a tax applies: `applies_when` on a tax

A tax may say where the parties have to be, and that is a different question
from the one above: `region` is a province, a short list a Canadian company
picks from, and this is the body of tax law a party is under. California levies
a sales tax and the United States does not; Northern Ireland is inside the
common system of VAT for supplies of goods and Great Britain is outside it
altogether, under one registration. Neither can be composed out of a country
and a region — `XI` is not spelled `GB-NI` in any register the Union uses — so
a territory is a column of its own and a key of `territories`.

```json
{ "code": "US-CA-S-725", "rate": 7.25, "scope": "sale",
  "jurisdiction": "US-CA",
  "applies_when": { "seller_in": "US-CA", "supply_in": "US-CA" },
  "postings": { "invoice": [ … ] } }
```

Four keys, and every one present has to hold:

| `applies_when` | The tax applies only where |
|---|---|
| `seller_in` | the seller is in this territory |
| `buyer_in` | the buyer is in this territory |
| `supply_in` | the supply takes place in this territory |
| `supply_vs_seller` | `same`: the supply lies inside the seller's territory; `other`: it lies outside it |

There is no operator, no negation, no disjunction and no nesting — the same
closed vocabulary the mentions' own `applies_when` is. What a pack can say is
that a party is in a place, and that the supply is or is not where the seller
is. The fourth key is a relation between two facts the document carries, not a
negation of a territory: California's section 6396 exempts a sale shipped to a
point outside the State, and `US-CA-S-SHIPPED` says so with
`"supply_vs_seller": "other"`.

**`supply_vs_seller` is read at the level of the seller.** A seller in `US-CA`
shipping to `US-AZ` is `other`; one whose territory is a whole country has no
level to be compared at, and `post_document()` refuses the document with
`no_party_territory`, asking for the seller's `territory_code`. `ekwo pack
check` refuses the key outright on a pack whose country has no territory inside
it in `territories`, because no document of its companies could ever meet it.

**A condition is satisfied by the territory named and by every territory inside
it.** `territories.parent_code` draws the tree, so `seller_in: "GB"` reaches a
seller in Northern Ireland and `seller_in: "XI"` does not reach one in Great
Britain. That is what lets one country's pack carry two sets of taxes and offer
each where it applies.

**Except where the parent's own tax stops.** The tree is geography, and the
Canary Islands are in Spain; Spanish VAT does not apply there (Ley 37/1992,
art. 3). `territories.outside_parent_tax` records that, row by row and with the
national text in the row's `legal_reference`, and the engine judges a tax's
conditions with `territory_within_for_tax()`, which stops at such a row. So
`supply_in: "ES"` refuses a supply in `ES-CN`, `ES-CE` or `ES-ML` without the
pack writing a word about them. The flag is reference data of the release; a
pack never sets it.

**Where each party is** is resolved by the core and never guessed at by a pack:

- **The seller and the buyer** are the company on one side and the contact on
  the other, decided by the kind of document — a purchase invoice is somebody
  else's sale. Each resolves to `territory_code` on its own row, and failing
  that to its country: `companies.fiscal_country`, `contacts.country`.
- **The supply** is `documents.supply_territory_code`, failing that
  `documents.delivery_country` — BG-15 of EN 16931, which is where the goods
  went and not where the invoice was addressed — and failing that the buyer's
  territory, because a supply nobody said anything else about is delivered to
  the person who bought it.

**The engine refuses; it does not choose, and it keeps what it saw.**
`post_document()` writes the three answers on the document —
`seller_territory_code`, `buyer_territory_code`, `supply_territory_resolved` —
where they are frozen with the rest of a posted document. It compares the
conditions of every tax on the document with the three answers above and raises
`tax_territory_mismatch` where they disagree, naming the tax, the party, the
territory asked for and the territory found. Where a tax asks about a party the
document says nothing about, it raises `no_party_territory` and names what would
answer. The core still picks no tax for anybody, in any country: what it does is
refuse one that cannot apply.

**A territory a tax names has to be a row of `territories`.** `ekwo pack check`
refuses a code the table does not carry, and so does the column — the three are
foreign keys. It refuses a `jurisdiction` the table does not carry for the same
reason, now that there is a table to check it against, and it refuses a
`seller_in` outside the pack's own country, because a pack is keyed on the
country its companies file under. This is the second time `docs/packs.md`'s
"adding a country touches `packs/<cc>/` and nothing else" is not quite true: a
pack outside the common system adds a row to
[`supabase/seed/00_territories.sql`](../supabase/seed/00_territories.sql), and
so does a pack that conditions a tax on a territory below the country.

**The regime a tax is held to follows the territory too.** Whether the VATEX
list of EN 16931 reaches a tax used to be a question about the pack's country;
where a tax names `seller_in`, it is a question about that territory. A tax
applying in a territory whose `eu_vat_scope` is `goods` is inside the common
system exactly where its treatment is a supply or an acquisition of goods, and
outside it everywhere else — which is the Protocol on Ireland/Northern Ireland
stated as a check.

**What it cannot say.** A tax cannot name a place a party is *not* in. A supply
the contract requires to be shipped **out of** the taxing territory is therefore
still written as an ordinary exemption with the article in `legal_reference`;
the condition exists, the word for it does not. `docs/international.md` carries
that gap under the United States, where it belongs.

## What a country puts on an invoice

Three sections of the manifest — `documents`, `einvoicing` and `bank` —
compile into twenty-three columns of `country_defaults` and into
`legal_mention_templates`. None of them has a default: a pack that says
nothing leaves null, and a reader that needs the value says which one is
missing rather than borrowing another country's law. One null is read, and
said to be: a pack silent on `posted_edit_policy` keeps a posted document as
it was posted, which is the stricter answer rather than another country's.

```json
"documents": {
  "numbering": "gapless_per_year",
  "number_format": "{CODE}/{YYYY}/{NNNN}",
  "legal_payment_days": 30,
  "late_payment_reference": "…où le taux et l'indemnité sont fixés",
  "tax_point": "invoice_if_issued",
  "posted_edit_policy": "reversal_only",
  "references": {
    "numbering": {
      "legal_reference": "Arrêté royal n° 1 du 29 décembre 1992, art. 5, § 1er, 1° — …",
      "source": "ar-1"
    },
    "payment_terms": {
      "legal_reference": "Loi du 2 août 2002, art. 4, § 1er — …",
      "source": "retard-de-paiement"
    },
    "tax_point": {
      "legal_reference": "Code de la TVA, art. 16, § 1er et art. 22, § 1er pour le principe, art. 17, § 1er et art. 22bis, § 1er pour la dérogation — …",
      "source": "code-tva"
    },
    "posted_edit_policy": {
      "legal_reference": "Code de droit économique, art. III.87, § 2 et art. III.88 — …",
      "source": "pcmn"
    }
  },
  "mentions": [
    {
      "code": "reverse_charge",
      "applies_when": "reverse_charge",
      "text": "Autoliquidation — taxe à acquitter par le cocontractant.",
      "sequence": 10,
      "legal_reference": "Arrêté royal n° 1 du 29 décembre 1992, art. 20"
    }
  ]
},
"einvoicing": {
  "profile": "peppol-bis-3",
  "mandatory_from": "2026-01-01",
  "obligation": "mandatory",
  "party_scheme": "0208",
  "vat_scheme": "9925",
  "legal_reference": "Loi du 6 février 2024 modifiant le Code de la TVA, art. 53, § 2 — …",
  "source": "facturation-electronique"
},
"bank": {
  "statement_formats": ["coda", "camt.053"],
  "payment_formats": ["pain.001"]
}
```

**The number.** `numbering` is `gapless_per_year`, `gapless`, `sequential` or
`free`, and the first two compile to `numbering_gapless = true`. Whether the
counter restarts each year is readable in `number_format`, which carries the
year or does not. The pattern is four tokens and literal text around them:

| Token | Is |
|---|---|
| `{CODE}` | the journal or series code |
| `{YYYY}`, `{YY}` | the year of the document |
| `{MM}` | the month |
| `{NNNN}` | the counter, zero-padded to as many `N` as are written |

Nothing reads the pattern yet — `next_entry_number()` builds `CODE/YYYY/NNNN`
— so a pack declares what its numbers look like, and the day a numbering
engine consumes a format it produces the same numbers it always did.
`ekwo pack check` refuses a token nobody defined and a pattern with no
counter, or with two.

**Whether the profile is obligatory** is `einvoicing.obligation`, in a closed
vocabulary of three words, because a null `mandatory_from` used to say two
different things — "there is no obligation" and "nobody looked up the date":

| Value | Says | `mandatory_from` |
|---|---|---|
| `mandatory` | a statute obliges companies to exchange the profile between themselves | required: the day it starts |
| `on_request` | no statute obliges every company, but a seller has to issue one when a buyer the law entitles to ask does — Estonia since 1 July 2025 | refused: the day the right began goes in the legal reference |
| `none` | at `released_at`, no statute obliges companies to exchange electronic invoices between themselves — the United Kingdom, where an obligation is announced for 2029 and not legislated | refused |

An obligation towards the public sector alone, or one announced and not
legislated, is written in `legal_reference` and does not change the word.
`none` may stand without a `profile`, for a country with no profile to name —
the United States — and the country page then prints that answer instead of a
missing profile. A
pack that leaves `obligation` out is described as `mandatory` where it names a
date, and as saying nothing where it does not; only a declared word reaches
`country_defaults.einvoice_obligation`.

**The tax point** is the country's general rule, in a closed vocabulary of
five words:

| Value | The rule it says |
|---|---|
| `invoice_date` | the invoice fixes it, and nothing displaces it |
| `delivery_date` | the supply fixes it |
| `payment_date` | collection fixes it |
| `invoice_if_issued` | the supply is the principle, and an invoice displaces it where the country requires one |
| `earliest_of_delivery_or_payment` | whichever of a supply and a payment came first |

The last two exist because most of Europe is one of them and neither could be
said in a single word before. Belgium puts the fait générateur at the supply
(art. 16, § 1er and art. 22, § 1er) and derogates to the invoice (art. 17, § 1er
and art. 22bis, § 1er); Luxembourg is art. 21 and art. 24, par. 1er in the same
shape; the United Kingdom is VATA 1994 s. 6(2)–(3) and s. 6(4)–(5). All three
had declared `invoice_date`, which is the derogation given as if it were the
principle — and all three said so in their own citation, which is how it was
found. Estonia keeps the first of a supply and a payment (KMS § 11 lg 1, two
branches) and had declared `delivery_date`, which is the first branch alone.

**Declare the principle and its derogation together, not the derogation
alone.** A word that names half a rule reads exactly like one that names all of
it, and the reader who finds out is the one filing a return.

A tax that departs from the country rule says so itself, with `cash_basis` —
which is how France taxes goods on delivery (CGI art. 269, 1, a and 2, a) and
services on collection (art. 269, 2, c) without the country model contradicting
itself, and why France declares `delivery_date` and is right to.

**What the engine does with it.** `tax_point_of()` is the only function that
reads the column, and it turns the word plus a document's own dates into one
date. `post_document()` writes that date onto `documents.tax_point_date` — EN
16931's BT-7, which a document may also state itself, and a stated fact
outranks a rule — and onto every ledger line a tax posting writes;
`vat_return()` puts a figure in the period its tax fell due in rather than the
period its entry was booked in. A document that says nothing new answers
exactly as it did: null means the entry's own date. Two limits are written down
in [`docs/international.md`](international.md): the payment branch is honoured
only through `cash_basis`, because Ekwo has no prepayment document, and the
recapitulative statement still reads the entry date, because the moment an
intra-Community supply arises is a different article in every country.

**The schemes** are ISO 6523 identifier codes, four digits, and there are two
because they are not the same identifier: `party_scheme` is how a party is
addressed on the network (`0208` the Belgian enterprise number, `0009` the
French SIRET) and `vat_scheme` is the VAT identifier (`9925`, `9957`). Where a
country has two registration identifiers, declare the one its invoices carry
and name the other in the legal reference.

**The article behind each rule** is `documents.references`, one entry per
rule and not one for the section. A tax and a box of a declaration form are
rows and carry their own `legal_reference` and `source`; the rules here are
words — `gapless_per_year`, `30`, `invoice_date` — with nowhere to write
either, and a word looks exactly the same whether somebody read the decree or
guessed. Three entries, because they are three articles of two or three
different texts in every country covered so far: `numbering` answers for the
style and the pattern together, `payment_terms` for `legal_payment_days` alone
(the interest and the indemnity stay in `late_payment_reference`, which is a
sentence to print rather than a citation), and `tax_point` for the tax point.
`einvoicing` writes its `legal_reference` and `source` flat, beside the
profile, because the section is one rule. All four pairs compile into
`country_defaults`, beside the rule each belongs to.

Where the value declared is a derogation rather than the country's principle,
say so in the reference — and, since `invoice_if_issued` and
`earliest_of_delivery_or_payment` exist, prefer a value that does not need the
excuse. The Luxembourg pack declares `invoice_if_issued` and its citation names
art. 21 as the principle and art. 24, par. 1er as the derogation, with the two
cases the derogation does not reach; a reader who opens the text is then not
left wondering whether the pack read the wrong article.

**Whether a posted document goes back to draft** is `posted_edit_policy`, and
it is the one document rule that loosens rather than binds. `reversal_only`:
a posted document is undone by a credit note that names it, `cancel_document()`,
and in no other way. `unpost_if_untouched`: it may also go back to draft,
through `unpost_document()`, while nothing about it has left — never sent nor
on Peppol, not settled, not credited, no declaration gone over it, its period
open and, where `numbering` is gapless, its number the last one its journal
drew, which then goes back to the counter. Say nothing and the country reads
as `reversal_only`. Declare `unpost_if_untouched` only with the article that
allows it under `references.posted_edit_policy` — `ekwo pack check` refuses it
without one, on every status — and say in it why the irreversibility your own
accounting law gives a recorded entry does not reach a document nobody
received. Belgium and France declare `reversal_only`, and cite why: both make
a validated entry irreversible (Code de droit économique, art. III.87, § 2;
PCG, art. 921-3), and France numbers its invoices continuously.

**The bank formats** are a known list rather than free text — `camt.052`,
`camt.053`, `camt.054`, `mt940`, `mt942`, `coda`, `cfonb120`, `ofx`, `qif`,
`bai2`, `csv` for statements; `pain.001`, `pain.008`, `cfonb160`, `mt101`,
`ach`, `bacs`, `eft`, `csv` for payments — because a parser is written against
a format and not against a name somebody typed. The list grows with the
country that needs it.

### The mentions, and when each applies

`applies_when` is a closed vocabulary and never an expression: an accountant
reads the value and knows what it means, and a pack that could write a
condition would be a pack that executes.

| `applies_when` | Applies when |
|---|---|
| `always` | every document of the country |
| `reverse_charge` | a line carries a tax the **customer** owes: a domestic reverse charge, a service received from a supplier who is not established here, or the middle supply of a triangular arrangement — three articles behind one sentence |
| `intra_eu_goods` | a line carries an intra-Union supply or acquisition of goods |
| `intra_eu_services` | the same, for services |
| `export` | a line carries a supply outside the Union |
| `exempt` | a line carries an exemption that is none of the above |
| `late_payment` | the document is one the seller issues |
| `cash_basis` | a line carries a tax that falls due on collection |
| `small_business` | never selected — see below |

`document_legal_mentions(document_id)` is the view that decides. It joins on
the company's **fiscal country**, on the **document's own date** — so a reprint
of an old invoice carries the wording of its own year — and on the treatments
of the taxes the lines already carry, which is why nothing extra has to be
recorded on a document for its mentions to come out right.

`small_business` is the exception and it is deliberate: a franchise regime is a
property of the seller and the core records no such column, so the sentence is
in the table for a renderer that knows the regime and the view never selects
it. The day the regime becomes a column, the view gains one branch.

A mention cites the article that requires it. `ekwo pack check` refuses one
that does not, a duplicate code, and a validity that runs backwards. Retiring
a wording is a `valid_to` and a new row, never an edit — the rule that governs
a tax rate and a box of a form governs a sentence too.

## Versions, and what a company holds

`pack.json.version` is semver:

| Change | Version |
|---|---|
| A label, a translation, a legal source, a legal reference | patch |
| An account, a tax, a box, a statement line; a validity that closes | minor |
| A new declaration form, a new statement framework | major |

The generated seed writes one row in **`country_packs`**: the version this
installation holds, the certification status, and a sha256 of every file of
the pack. `install_country_template` writes **`company_packs`**: which version
that company copied, and when. `ekwo status` prints both and says so when a
company is behind.

### Where a company stands, and moving it

Two commands read an installation rather than a checkout, so they need a
connection and know nothing about `packs/`.

```sh
ekwo pack status --db-url "$EKWO_DB_URL"
```

```
Packs loaded here (…)
  BE Belgique  1.5.0
  FR France    1.4.0
  …

Companies (2)
  · Example One  BE/default  copied 1.0.0, loaded 1.5.0
        4 addition(s), 1 closure(s) — applied by rule; 2 to review
  · Example Two  FR/default  copied 1.4.0, loaded 1.4.0 — up to date
```

It changes nothing and exits 1 while a company is behind, so a cron can ask.

```sh
ekwo pack upgrade "Example One" --db-url "$EKWO_DB_URL"
```

```
Example One — BE pack 1.0.0 → 1.5.0
  · tax BE-P-21-50-I — added from the pack
  · tax BE-S-06 — added from the pack
  · tax BE-S-21 — validity closed on 2026-12-31
  4 change(s) applied: an addition and a closed validity take nothing away.

To review (2)
  Not applied. Read them, then run again with --apply if the pack is right.
  ! account 700000 — differs: {"pack":{…},"company":{…}}
  ! tax_posting BE-S-21 — differs: {"pack":[…],"company":[…]}

Yours, not the pack's (1)
  Never applied by an upgrade: nothing is removed from a company's books.
  account 999500 — held here, not in the pack

Version
  still 1.0.0: 2 difference(s) are waiting to be decided.
```

The difference is computed by natural key — an account code, a journal code, a
tax code — and every difference falls into one of three rules:

| Rule | What an upgrade does |
|---|---|
| `addition` | The pack has something the company does not. Copied in. |
| `closure` | The pack has closed the validity of a tax the company still holds open. Applied — this is how a rate change reaches a company: the old one stops, the new one is an addition. |
| `review` | Everything else: a label that differs, a rate that differs on the same code, a posting that books somewhere else. **Listed and never applied without `--apply`.** |

A row the company holds and the pack does not is listed under its own heading
and is never applied, whatever is asked: nothing is removed from a company's
books by an upgrade. An account may carry entries and a tax may be on a posted
document, and a pack that retires a code retires it with a `valid_to`.

**The recorded version moves only when nothing is left waiting.** A company
that still holds a difference it has not decided on has not finished
upgrading, and moving the number would hide that difference at the next run.

The same three rules are in the schema — `pack_upgrade_diff(company)` and
`pack_upgrade(company, country, apply)` — so an application, a module or an
assistant asking the same question gets the same answer, and every upgrade
writes a `pack_upgraded` row into [`audit_log`](schema.md) naming what it
applied and what it left. Installing again in the meantime adds what is
missing and changes nothing that exists.

**Immutable once published**: the country of a pack; the code of an account
and its type — reclassifying a code would reclassify history; the code of a
tax and what it means; the identifier of a box inside a version of a form. A
new VAT rate is a new tax code plus a `valid_to` on the old one, never an
edit, which is how the return of a past period keeps giving the same answer.

## Languages

The pack's own files are written in `defaults.language`. Every other language
is one file, `i18n/<lang>.json`, and that file is the only place a translation
lives — the manifest carries no second wording and neither does `assets.json`.
One file per language means a contributor edits one file and a reviewer reads
one file.

```json
{
  "language": "nl",
  "pack_name": "België",
  "charts":           { "default": "MAR — minimum algemeen rekeningenstelsel" },
  "accounts":         { "400000": "Handelsdebiteuren" },
  "journals":         { "SAL": "Verkoopdagboek" },
  "taxes":            { "BE-S-21": "Verkoop 21 %" },
  "tax_report_boxes": { "54": "Btw op de handelingen van de roosters 01, 02 en 03" },
  "statement_lines":  { "BE-BNB-ABBR-BS:10/15": "EIGEN VERMOGEN" },
  "legal_mentions":   { "reverse_charge": "Btw verlegd — …" },
  "asset_categories": { "machinery": "Installaties, machines en uitrusting" }
}
```

A box is keyed by the same reference its formulas use — `59`, or `08:tax`
where a form carries a base and a tax on one line. A statement line is keyed
`<statement>:<line>`, because two statements may both carry a line `20`.

**The manifest declares which languages the pack publishes**, and that
declaration is a promise rather than a description:

```json
"languages": ["nl", "de", "en"]
```

`ekwo pack check` fails, naming every missing key, if a declared language stops
covering the accounts of every chart, the journals, the taxes, the boxes, the
statement lines, the legal mentions or the asset categories. A file that is
**not** declared may be partial — a key it does not carry falls back to the
pack's own label — which is how a language is contributed one section at a
time. A label under a code the pack does not carry is refused either way.

The labels land in `name_i18n` / `text_i18n` on every template table, and
`install_country_template(company, country, language)` copies the chosen one
into `name` while keeping the whole object beside it, so a company installed in
Dutch can be read in English later without importing anything again.
[`languages.md`](languages.md) is the whole mechanism, including how a reader's
own preference comes before the company's.

## Golden scenario

A pack that compiles says nothing about whether it adds up. A tax that posts
to the wrong grid and a grid that expects the wrong postings agree with each
other: the seed builds, every unit test passes, and the return is wrong.
`packs/<cc>/golden/` is the second opinion — one year of books somebody wrote
down, and beside it the declaration, the statements and the trial balance the
engine makes of them, to the cent, in the pack's own currency.

`scenario.json` is the input, and it is declarative like everything else in a
pack. Nothing in it executes and nothing in it is an amount that was computed:

```json
{
  "name": "Une année d'un commerce belge assujetti, déclarant par trimestre",
  "chart": "default",
  "fiscal_year": { "name": "Exercice 2026", "start": "2026-01-01", "end": "2026-12-31" },
  "periods": [{ "code": "2026-T1", "from": "2026-01-01", "to": "2026-03-31" }],
  "statements": ["BE-BNB-ABBR-BS", "BE-BNB-ABBR-IS"],
  "contacts": [{ "ref": "client-be", "name": "Atelier Lumen SRL", "type": "customer", "country": "BE" }],
  "documents": [
    { "ref": "V1", "type": "sale_invoice", "contact": "client-be", "date": "2026-01-20",
      "why": "Une vente au taux normal : la grille 03 et la TVA due de la grille 54.",
      "lines": [{ "name": "Marchandises", "quantity": 10, "unit_price": 1000,
                  "tax": "BE-S-21", "account": "700000" }] }
  ],
  "payments": [
    { "ref": "E1", "direction": "inbound", "date": "2026-02-20", "amount": 12100,
      "contact": "client-be", "journal": "BNK", "match": "V1",
      "why": "Un encaissement qui solde exactement sa facture." }
  ]
}
```

`why` is required on every document and every payment. A golden grows by
accident otherwise: somebody adds a line to make a figure move, and two years
later nobody can say what the document was for or whether dropping it would
lose anything.

**Three optional fields say where the parties are**, and a pack needs them only
where its taxes ask. `territory` beside `chart` is the territory the company of
the scenario is established in; `territory` on a contact is the party's own; and
`supply_territory` on a document is where the goods went, when it is neither the
buyer's territory nor the country. `packs/us/` uses all three, because the
Californian codes are conditioned on a Californian delivery and the year has
sales into three other states. A pack whose country taxes uniformly leaves all
three out and nothing changes.

**Three expectation files** sit beside the scenario and are generated, never
written by hand:

| File | Holds |
|---|---|
| `vat_return.json` | every box of the return that came to something, per period, keyed `<box>:<kind>` |
| `statements.json` | every line of every statement named, over the financial year |
| `trial_balance.json` | every account that moved or ended with a balance: debit, credit, closing |

```sh
UPDATE_GOLDEN=1 npm test -- tests/golden.test.ts
```

rewrites those three and **never the scenario** — a runner that could rewrite
its own inputs proves nothing. The diff is then the thing to review.

### What only this pack can claim

A fourth file may sit beside the three, and it is the only one under `golden/`
written by hand: `expectations.json`. It holds what a pack states that neither
its own files nor a generic test can check — a fact key of a national filing
taxonomy, an arithmetic a law writes into a declaration form. The rest of a
pack checks itself: a test that compared `statements.json` to a copy of
`statements.json` would prove nothing.

```json
{
  "note": "Claims about this pack that no other pack can make.",
  "statement_facts": {
    "BE-BNB-ABBR-BS": { "20/58": "met:am1|bas:m25|part:m1" }
  }
}
```

Every block is optional, and a pack that carries no file at all is read as an
empty one. One runner in `tests/` loads whichever blocks a pack states and
checks them against the pack and against the seed, so a contributor adds a
claim by editing their own pack and never a test.

Like the other files under `golden/` beside `scenario.json`, it is **outside
the pack checksum**: it is evidence about the pack, not part of it, so adding
one does not change `country_packs.checksum` and does not make a seed stale.

**`ekwo pack check` validates the scenario**, against the schema and against
the pack: the chart, every account code, every tax code and its scope and its
validity, every journal, every statement, and every `match` that has to name a
document of the scenario and a payment going the right way. It refuses fewer
than ten documents. The full list is under "What `ekwo pack check` refuses".

**`tests/golden.test.ts` is one runner for every pack.** It reads `packs/`,
installs a company on each from what that pack's scenario declares, replays the
documents and the payments through `post_document`, `post_payment` and
`reconcile`, and compares. Nothing in it knows a country — what it asks of a
scenario, it asks of the *pack*: both directions, more than one positive rate,
a credit note, a matched payment and an unmatched one; an intra-Union reverse
charge on each side the pack offers one; a tax due on collection and a partly
recoverable tax **where the pack has them**. A country with no cash-basis tax
is not asked for one.

One assertion is not read from a file: the posted ledger balances. A golden
regenerated from a broken engine would agree with itself; double entry would
not.

**A pack with no golden is refused** — by `readPack`, so by `ekwo pack check`
and by the CI — unless the manifest says why:

```json
"golden": { "exempt": "A framework is not a country: this pack carries statements and nothing else …" }
```

which `ekwo pack check` and `ekwo pack list` print. `packs/generic/` is the
one exemption in this repository, and the reason is structural: a framework
has no chart, no journal, no tax and no currency, so no company can be
installed on it and there is no year of books to replay. Its lines are proved
where they are reachable — through a chart that names no statement of its own
and falls back to it.

**What a golden does not prove.** That the figures are the law. A box expected
wrongly and a posting written wrongly pass together, which is the whole reason
the two things under "Certification, and who may say what" exist: a source on
every tax and every box, and a status that says out loud how much anyone has
read. It is also
worth knowing what the balance sheet of an open year looks like — the result
is not on it until `close_fiscal_year()` puts it there, so assets exceed
liabilities by exactly the result of the income statement, in every country.

## What `ekwo pack check` refuses

Two passes, and the first one is where nearly everything is caught. Every file
is validated against [`packs/schema/pack.1.json`](../packs/schema/pack.1.json)
— its shape, its required fields, its closed vocabularies — and then against
the rest of the pack, which is what a schema cannot do: a tax may not post to a
box the form does not carry, and only the pack knows which boxes the form
carries. The second pass compiles and compares the committed seeds. A pack that
fails the first never reaches the second.

The list below is the whole of it. It is long because a pack is data somebody
will file a return with, and every line of it exists because the alternative
was a figure that is wrong and looks right.

**The manifest, and the charts.** A chart whose `accounts` file does not
exist. No chart marked `"default": true`, or more than one — `ekwo init` would
have nothing to install when nobody names one. Two charts with the same code.
A chart naming a statement the pack does not carry.

**The chart of accounts.** The same account code twice in one chart. A
`parent` that is not in the same chart. A row missing `code`, `type` or
`name`, or carrying an `account_type` that is not one of the eighteen. The CSV
itself: an empty file, a row with a different number of fields from the header,
a quote that opens mid-field, a quoted field that never closes, a
`reconcilable` that is not `true` or `false`, a `sequence` that is not a whole
number.

**The roles and the journals.** A code in `defaults.roles` that is missing
from **any one** chart of the pack, named with the chart it is missing from —
a second chart is exactly where this goes wrong. A `defaults.journal_roles`
entry naming something that is not a journal. A role name the schema does not
know, which is how a typo in a role is caught rather than silently ignored.

**The closing style.** A pack that declares `closing_style` and does not name
the accounts that style needs: `retained_earnings` for the first,
`current_year_result_profit` and `current_year_result_loss` for the other two.
No `journal_roles.opening`. An opening journal that exists but is not of
journal type `opening` — which is the mistake worth naming, because the code
resolves and the year-end entries would land on a journal that carries ordinary
traffic.

**The taxes and their postings.** Two taxes with the same code. A `group`,
which is reserved for the country that stacks two taxes on one line and which
the core does not carry yet. More than one `base` posting on a document kind. A
`tax` posting with no account, or a `base` or `tax_on_base` posting carrying
one — those two land on the account of the line they tax, so an account on them
is a misunderstanding worth stopping. An account, or a
`cash_basis_transition_account`, that is missing from a chart. A posting whose
`box` the declaration form does not carry — each of them, where the posting
names several — an empty list of them, the same box named twice by one posting,
or a box the form declares a `total`.

The three code lists a tax tells one fact in have seven of their own, all of
them from the table under "What a tax says on the invoice", and every message
names the tax, its treatment, what it says, what the source says instead and
which source. A `vat_category` the treatment contradicts — an export that is
not `G`, an intra-Community acquisition that is `AE` rather than `K`. A
category on `import` or on `foreign_services_received`, where no invoice
governed by EN 16931 exists and there is nothing of a supplier's to record. No
category at all on a tax that can reach a sale, wherever an invoice of that
country carries BT-151. An `exemption_code` the VATEX list reserves for another category, and
one on a line that is taxed, which is exempt under nothing. A category that
asks for a reason and names none. A reason that is not shaped like a VATEX
code. And, on the sale side only, a rate the category forbids: a standard rate
of zero, or an exempt line at 21 %. A treatment declared on the side it does
not happen on — an `import` that is a sale, an `export` that is a purchase —
is refused in the same pass, because that is what makes the expected category
knowable.

Five more of them turn on one fact that is in `territories` and not in the
pack: whether the common system of VAT reaches the country on the day the
manifest's `released_at` names. Where it does not, an `exemption_code` taken
from the VATEX list is refused, because that list belongs to a system this
country is not in; a reason code from any other list is refused unless the
pack's register declares that list with `"reason_codes": true`, and refused
again if it is a sentence rather than a code; a line whose category asks for a
reason and that names neither a code nor a `legal_reference` is refused, because
the article is what the invoice states there; any of the five `intracom_*`
treatments is refused outright; and the requirement to name a `vat_category` at
all is lifted, unless the pack declares an e-invoicing profile whose invoices
carry BT-151. Every one of those messages names the country,
the day and the `eu_vat_scope` the table gives it, so a reader is never left
wondering why a code they read in the standard was turned down.

A cash-basis tax has four of its own: it has to name its transition account; it
takes exactly one `tax` posting per document kind; it takes no `tax_on_base`
posting, because a share nobody gets back is a cost and a cost is not deferred
to a payment; and its `tax` posting has to name a box, or the amount waits on
the transition account for ever.

The territories a tax names have three more, and the first two are the reason
those fields are foreign keys rather than strings. A code — in any key of
`applies_when`, or in `jurisdiction` — that `territories` carries no row for: a
territory nobody can look up is a place two packs can spell two ways. An
`applies_when.seller_in` outside the pack's own country, because a pack is keyed
on the country its companies file under and its taxes are the ones their seller
owes; the buyer and the place of supply are deliberately unconstrained, since a
supply is taxed where it lands. And the four refusals above move with the
territory: where a tax names `seller_in`, the regime it is held to is the one of
**that territory** on the day the manifest speaks of, so a tax applying where
`eu_vat_scope` is `goods` is inside the common system for a supply or an
acquisition of goods and outside it for everything else.

**The declaration form.** The same box declared twice with the same kind. A
formula on a `base` or a `tax` box, which is summed from the ledger. A
reference to a box the form does not carry, or to a kind it does not carry. A
bare reference that matches two kinds — `08` where the form carries `08:base`
and `08:tax` — which is refused with both spellings offered rather than
resolved to one of them. A total that names itself. A total that names a total
computed at the same `sequence` or later.

**The statements.** Two statements with the same code; two lines of one
statement with the same code. A `parent` that is not a line of the same
statement. A formula naming a line of another statement, or its own line. A
line that is both summed from the ledger and computed from other lines, in
either direction. Totals that depend only on each other. One account reaching
two lines other than as a debit side and a credit side. **An account of a chart
that reaches no line of any statement covering that chart** — the check that
makes a balance sheet balance.

The fact keys have five of their own. A statement carrying any `xbrl` key must
name its `taxonomy`; a key is at least a metric and one domain member, each
part a qualified name such as `bas:m9`, with no empty or padded part and no
dimension twice; and two lines of one statement may not carry the same key,
which is how a key missing a member shows up.

**The register of sources.** Two entries claiming one key — a reference would
resolve to whichever came first. An entry that is not shaped like one: a field
missing, a field nobody defined, a `kind` outside the six, a `url` that is not
absolute and `https`. A `source` naming a key the pack's register does not
carry, which reads as a text and is a typo; the message lists the keys there
are. A pack whose status is not `community` and whose register holds no entry
anybody can open, because `maintained` and `reviewed` are both claims that
somebody keeps this current and neither is sayable about a list of titles. And
on a `reviewed` pack, a tax or a box that names no source at all — that one is
a warning on a `maintained` pack and nothing on a `community` one. A bare
string in the register is a warning everywhere: it is the shape the field had
before, and a pack written against it still compiles.

**The legal mentions and the document rules.** Two mentions with the same
code. A `valid_to` before its `valid_from`. A mention with no
`legal_reference` — a sentence the law requires cites the article that requires
it. A `number_format` carrying a token nobody defined, or no counter, or two.
An `einvoicing.mandatory_from` with no `profile`: a day an obligation starts
and nothing that says what becomes obligatory. An `obligation` of `mandatory`
with no `mandatory_from`, one of `on_request` or `none` with one, and any
`obligation` with no `legal_reference`. A `source` under
`documents.references` or in `einvoicing` naming a key the register does not
carry. And on a `reviewed` pack, a document rule that is declared and cites no
article at all — that one is a warning on every other status, including
`community`, because a country whose law nobody has written down yet is the
normal state of a new pack and not a defect of it. The exception is
`posted_edit_policy: unpost_if_untouched`, which lets a posted entry be taken
away: it is refused without an article on every status.

**The bank formats, as a warning.** A `bank.statement_formats` entry that no
brick of `packages/formats/` reads is printed once per format, and never
fails the check: the name is true — the banks of the country send that file —
and the debt is kept by name in `tests/bank_statement_formats.test.ts`, which
is what fails when a new one appears unaccounted for.

**The languages.** A label under a code the pack does not carry — an account,
a journal, a tax, a chart, a mention, an asset category, a box, a statement
line — in any i18n file, declared or not. And for a language the manifest
**declares**: the file has to exist, it has to carry `pack_name`, and it has to
cover every key of every section, with the missing ones named and counted. A
declared language that is the pack's own `defaults.language` is refused too:
the pack is already written in it.

The language of a translation file is read from its `language` field and not
from its name, so `i18n/nl.json` declaring `"language": "fr"` registers as
French. A file that is not declared may be partial, which is how a language is
contributed one section at a time.

**The golden scenario.** No `golden/scenario.json` and no `golden.exempt` in
the manifest; or both at once. Fewer than ten documents. A `chart` that is not
a chart of the pack. A financial year that does not start before it ends, a
period running backwards, and any date — a period bound, a document, a payment
— falling outside the financial year. A duplicate `ref` among the contacts, the
documents or the payments. A document naming a contact the scenario does not
declare. A line naming an account that is not in the installed chart, a tax
that is not a tax of the pack, a tax whose `scope` contradicts the side of the
document, or a tax not in force on the document's own date. A payment on a
journal the pack does not carry, a `match` naming no document of the scenario,
a payment going the wrong way for what it settles, or a payment dated before
the document it settles.

`check` validates the scenario and does not replay it. The replay is
`tests/golden.test.ts`, and the two are different questions: whether the
scenario is sayable, and whether the engine still makes the same figures of it.

**The framework pack**, `packs/generic/`, has two of its own: every rule has to
be an `account_type` rule, because the other three kinds name a chart and a
framework has none; and the exemption from a golden is required, in at least a
sentence.

**The module sections.** For `assets`: a disposal style that does not name the
accounts it needs — `net_result` the gain, `gross` both the proceeds and the
value — two categories with the same code, a declining balance with no
coefficient, a coefficient on a method that is not declining, and a category
with no `legal_reference`, because a usual duration comes from somewhere.

**What it does not refuse, and why that is worth knowing.** An extra column in
the CSV is ignored rather than rejected. A posting whose `report` names a form
other than the one in `tax_report.json` is not cross-checked, because the pack
carries one form; the day a country files two, it will be. A pack with no
`certification` block compiles as `community` without a word, and `by` and `on`
are not refused on a pack that is not `reviewed` — the status is a claim a
person makes, and `.github/CODEOWNERS` is what puts a name next to it.

## The register of sources

A `legal_reference` says which article a rule claims. It has been required on
every tax and every box since the format existed, and it is half an answer: a
reviewer holding *Arrêté royal n° 20 du 20 juillet 1970, tableau A* has a
citation and a search engine. The other half is **where that text can be
read**, and it belongs in one place rather than on four hundred rules.

`certification.sources` is that place. Each entry is a text:

```json
"certification": {
  "status": "maintained",
  "sources": [
    {
      "key": "ar-20",
      "title": "Arrêté royal n° 20 du 20 juillet 1970 fixant les taux de la taxe sur la valeur ajoutée et déterminant la répartition des biens et des services selon ces taux",
      "publisher": "SPF Justice — Moniteur belge (Justel)",
      "url": "https://www.ejustice.just.fgov.be/eli/arrete/1970/07/20/1970072012/justel",
      "consulted_on": "2026-09-15",
      "kind": "regulation"
    }
  ]
}
```

and every rule of the pack names the key of the text its own reference is in:

```json
{ "code": "BE-S-21", "rate": 21, "scope": "sale",
  "legal_reference": "Arrêté royal n° 20 du 20 juillet 1970, art. 1er, § 1er — taux normal",
  "source": "ar-20" }
```

**The article stays on the rule and the link stays in the register.** A
publisher that reorganises its site is then one line of the pack to change
rather than a sweep across every tax that cites the same statute, and a
reviewer opening a pack has the reading list before they have read a rule.

| Field | Is |
|---|---|
| `key` | how the rest of the pack names this text. Unique inside the pack, lower case, and stable once published |
| `title` | the text as it is cited, in the pack's own language |
| `publisher` | who publishes it officially: SPF Finances, Légifrance, Legilux, Riigi Teataja, Maksu- ja Tolliamet, the European Commission. A reviewer checks the publisher before the link |
| `url` | absolute and `https`, and a permanent identifier wherever the publisher has one — an ELI on Legilux and on the Moniteur belge, a `LEGITEXT` on Légifrance, a short alias such as `/akt/kms` on Riigi Teataja |
| `consulted_on` | the day somebody opened it and read what it served |
| `kind` | one of six, below |
| `reason_codes` | optional, and true on the one entry that publishes this country's exemption reason codes — see [What a tax says on the invoice](#what-a-tax-says-on-the-invoice-treatment-category-and-reason). At most one per register, and it has to be a `standard` |

Six kinds, and the vocabulary is closed so that a register reads the same
across countries:

| `kind` | Is |
|---|---|
| `law` | a consolidated legal text — a code, a statute |
| `regulation` | the decree or order that applies it |
| `form` | a declaration form, or the administrative notice that explains its boxes |
| `standard` | a technical norm or a code list: EN 16931, UNCL5305, VATEX, an XSD |
| `portal` | where the declaration is actually filed — Intervat, eCDF, e-MTA, an `impots.gouv.fr` professional space |
| `guidance` | an official administrative comment or circular: the French BOFiP, an Estonian *juhend* |

**A `source` may sit beside any `legal_reference` the format carries** — a
tax, a box, a chart, a statement and its lines, a sentence of an invoice, a
rule of the fixed-assets section. It is optional everywhere and named nowhere
twice.

**The register never holds a copy of the text.** A quotation ages without
anybody noticing, and a pack carrying one would be a second, unversioned
edition of a statute. A pack says where the law is; the law says what it says.

**A bare string is the deprecated form.** The field used to be a list of
titles, and those are still read so that a pack written before the register
goes on compiling. `ekwo pack check` warns on each one and refuses none:

```
! packs/xx: pack.json certification.sources: "Code de la TVA, art. 37" is a title
  with nowhere to read it. The register takes an object — key, title, publisher,
  url, consulted_on, kind — and the bare string is deprecated.
```

A chart that carries its own `certification` may name the texts that reading
went through, and they join the same register: **a key is unique in a pack,
not in a section of one.** The Belgian `asbl` chart is the case — it declares
the Code des sociétés et des associations, which the rest of the pack does not
need.

The register compiles into `country_packs.sources`, so an application can
answer "where do these rules come from" without reading the pack, and the key
travels with the rule it belongs to in `tax_templates.source_key` and
`tax_report_box_templates.source_key`. The MCP tool `describe_pack` returns
all of it. What a register entry is **not** is a foreign key: a pack is
upserted one statement at a time and the register lives in a jsonb column, so
the check that a key resolves is `ekwo pack check`'s, before the seed is
written.

## Certification, and who may say what

A golden test proves that a pack is internally coherent. It does not prove
that it is legally right, and no test can. Three things carry the rest, and all
three are enforced rather than encouraged.

**Every tax and every declaration box names where it comes from.**
`legal_reference` is a required field, not a convention: `ekwo pack check`
refuses a pack that leaves one out, on a tax or on a box, and `"TODO"` is not a
source. A box nobody can trace to a source is a box nobody can review. Beside
it, `source` names the text that article is in, out of the register the
manifest carries in `certification.sources` — see
[The register of sources](#the-register-of-sources).

**What the status costs in sources** is the other half of what the status
claims:

| Status | The register | Every tax and every box |
|---|---|---|
| `community` | anything, including the deprecated bare titles | nothing asked |
| `maintained` | at least one text somebody can open, or the pack is refused | a warning, naming the first few and counting the rest |
| `reviewed` | the same | **refused** where one of them names no source |

The third row is the substance of a review. A professional who reads a pack
against the law reads *something*, and a status that let them leave that
unsaid would be a signature rather than a review. The second is a warning
rather than a refusal because the register landed after four packs did, and a
missing link is a link that is missing — never a figure that is wrong.

**The manifest says out loud how much anyone has read it**, and `ekwo init`
prints it in as many words before anyone books anything:

| Status | What it means | Who sets it |
|---|---|---|
| `community` | contributed, not read by an accountant | whoever proposes the pack. It is the honest answer for a new pack, and the right one until the row below happens |
| `maintained` | maintained by Ekwo, not yet reviewed by an accountant | the maintainers, on a pack they keep up to date themselves. Nobody else, because nobody else is committing to keep it current |
| `reviewed` | read by a named professional, on the date shown | the reviewer, in the pull request that carries their name. Not the pack's author, unless the author is the professional and says so under their own name |

A pack with no `certification` block at all compiles as `community`, which is
the safe reading of silence.

**There is deliberately no status that means "certified by Ekwo".** Writing a
pack and testing that it holds together is not reviewing it. *Certified*
describes a professional reading a pack against the law, and nothing else. The
value `ekwo` that used to exist is deprecated, refused by the schema, and moved
to `maintained` by migration `20260912081015`. **Belgium and France are
`maintained`; every other pack is `community`** — the
[table of packs](#the-packs-of-this-checkout) is generated from the manifests
and says it pack by pack.

### What a reviewer signs

`reviewed` carries two more fields, and they are the whole substance of it:

```json
"certification": {
  "status": "reviewed",
  "by": "A. Example, chartered accountant, IEC/IAB 00000",
  "on": "2027-03-14",
  "sources": [ … the register of texts they worked from … ]
}
```

`by` is a person, named, with whatever qualification makes the name mean
something in their country. Not a firm, not a team, not a handle: the point of
the field is that somebody can be asked. `on` is the date they read it, and it
is there because a pack that was right in March may not be right in October —
a reviewed pack whose date is three years old tells an operator exactly as much
as it should.

What a review is: a good-faith reading of the chart, the taxes, the boxes of
the declaration and the statement mappings against the rules the reviewer
applies in practice, given to the community for free. What it is not: an
engagement letter, an audit, or a guarantee, for the reviewer or for anyone
else. [`DISCLAIMER.md`](../DISCLAIMER.md) says so in the same words, and an
operator reads that one.

A review is recorded in the pack it reviewed, in the pull request that makes
the change, alongside a version bump — a status is part of what a version says.
It is never edited afterwards to a later date without a later reading.

### CODEOWNERS: the name next to the pack

`.github/CODEOWNERS` carries one line per pack. It is not certification and it
does not claim to be: it is who gets asked when a pull request moves that pack.
A rate, a box or a chart is right or wrong against a law, and the person who
knows is the person who applies it.

```
/packs/schema/          @Ekwo-ai/maintainers

# generated:packs
/packs/be/              @Ekwo-ai/maintainers
/packs/ci/              @Ekwo-ai/maintainers
…
# /generated
```

The lines between the two markers are written by `ekwo pack build`: a pack
added to `packs/` gets its line with the owner of the `*` line, and a pack
removed loses it. **The owner a line names is kept** — to own the pack you
contributed, put your handle on its line, once; the next build leaves it there.

The schema is deliberately not owned by any one pack's owner: a change there
changes what every country is allowed to say. A pack a contributor owns is
listed with their handle, and its status stays `community` until a professional
has read it — the two are different questions and the file says so at the top.

## Adding a country in a day

A country is data, so adding one is a day of reading the law and half an hour
of tooling. What follows is the whole path, in order, with the command that
tells you whether you are still on it. Copy Belgium or France — whichever
resembles your country's accounting more — and change what differs.

Nothing here needs a database. Every command runs in a checkout, and the pull
request you open at the end contains the pack, and the seed and the lists
`ekwo pack build` writes from it.

### 0. Open the four things you are going to transcribe

Before a line of JSON, find where your country publishes what you are about to
copy, and keep the tabs open. Four of them, and they are the four kinds of
source most packs need:

1. **The consolidated text** of your VAT law or its equivalent, on the site
   that publishes it officially — not a commentary, not a law firm's copy.
   Look for a permanent identifier: an ELI, a code identifier, a short alias.
2. **The decree or order** that fixes the rates and the chart of accounts,
   which is usually a different text from the law.
3. **The declaration form and its notice.** This is what the boxes of
   `tax_report.json` are, and the notice is what tells you which amount goes in
   which box.
4. **The portal** where the return is filed. It is not a legal source and it is
   in the register anyway: whoever installs your pack will need it, and the
   register is the one place in the pack where they will look.

Each of them becomes an entry of `certification.sources` with a key you will
use for the rest of the day — see
[The register of sources](#the-register-of-sources). Write them as you open
them, with `consulted_on` set to today, and never write a URL you have not
opened. A link nobody followed is worth less than no link: it reads as checked.

This is step 0 rather than step 9 because every later step cites one of these
texts, and the citation is cheaper to write while the tab is open than to
reconstruct from a rate you no longer remember reading.

**If your country is outside the common system of VAT, there is one more thing
to do before step 1**, and it is the only edit a pack ever makes outside its own
folder. `ekwo pack check` decides whether the VATEX list of EN 16931 reaches
your taxes by looking your country up in `territories`, and a country the table
carries no row for is held to the Union's table — so an exempt sale with no
`exemption_code` would be refused and you would be told to write a code that
names an article of a Directive your seller is not bound by. Add a row to
`supabase/seed/00_territories.sql`: your ISO code, `eu_vat_scope` `none`, no
window, no `vat_prefix`, and a `legal_reference` saying why the common system
does not reach you. `tests/territories.test.ts` refuses a pack whose country the
table does not carry, so the check is enforced from both sides.

### 1. Copy a pack and give it its identity

```sh
cp -r packs/be packs/xx        # `xx` being your ISO 3166-1 alpha-2 code, lower case
rm -rf packs/xx/golden packs/xx/i18n
```

Open `packs/xx/pack.json` and set `country` (upper case), `name`, `version` to
`0.1.0`, `released_at`, and `certification` to `{ "status": "community",
"sources": [ … the register from step 0 … ] }`.
Leave `schema_min` where it is: it is the migration your pack needs, not a
number you choose. Set `seed_sequence` to the **first number no pack has
taken** — `ls supabase/seed/` shows what is in use — and **never change it
afterwards**: a published number never changes, because it is the name of a
file other people's installations already hold. Empty the `languages` array for now — a declared language is
a promise that `ekwo pack check` holds you to, and you will make it in step 8.

Set `defaults.currency`, and `defaults.language` to the language you are going
to write the pack's own labels in.

### 2. The chart of accounts

`accounts.csv`, one line per account: `code, parent, type, reconcilable, name,
sequence`. Two things decide whether the rest of the day goes well.

**Give every account one of the eighteen `account_type` values.** Nothing is
guessed from a code prefix anywhere in Ekwo, in any country, ever — `411` is
*customers* on the French chart and *recoverable VAT* on the Belgian one. The
type is what the generic financial statements read, what the ageing reads and
what a close reads.

**Make the headings headings.** An account with children is a heading: nothing
is posted to it, and the statement check below expects it to reach no line.

If your country has a second chart — associations, sole traders, a small-company
variant — add it as a second file and declare both under `charts`, exactly one
of them `"default": true`. The journals, the taxes and the declaration form are
common to the charts of a country; only the accounts differ, and the statements
that present them.

### 3. The roles, the journals and the close

In `defaults.roles`, name the accounts the installer wires: `receivable` and
`payable` are required, and `suspense`, `rounding`, `retained_earnings`,
`sales`, `purchase`, `bank` and `cash` are what a company needs to be installed
and to book. If the pack declares a periodic return, name `tax_payable` — the
account `settle_filing()` carries a declared period's net to — and
`tax_receivable` for a period that ends in a credit, both reconcilable and
apart from the accounts the taxes post to. Leave `tax_receivable` out only
where the chart keeps one control account for both signs; say which article
makes the credit a claim on the administration in the pack's README, since a
role carries no citation of its own. Add `fx_gain` and `fx_loss` if any company of your country will
ever invoice in another currency: a matching that realises a difference is
refused by name when they are missing, and only then.

Every code has to exist in **every** chart your pack ships. `readPack` refuses
the pack before the compiler writes any SQL, and it names the chart the code is
missing from.

Then say how the year is closed: `defaults.closing_style`, its result accounts,
and `defaults.journal_roles.opening`, which must name a journal of type
`opening`. The table below says which style a chart needs.

#### Which closing style a chart needs

| Style | The result goes | Chosen when |
|---|---|---|
| `retained_earnings` | straight into retained earnings | the chart has no current-year result account — Balance Sheet Format 1 of the British small companies regime has five items under capital and reserves and none of them is the result of the year (United Kingdom, United States) |
| `result_accounts` | into a current-year result account on the balance sheet | the chart keeps the result of the year apart until a meeting allocates it (France: 120 and 129) |
| `appropriation_accounts` | through an appropriation account of the income statement, then to retained earnings | the statutory income statement ends on an appropriation section (Belgium: 693 and 793, to 140 and 141) |

The accounts a style names have to be of the right kind, and the close says so
rather than finding out later: `appropriation_accounts` needs accounts that do
*not* carry forward, the other two need accounts that do. What a general
meeting then decides — a dividend, a reserve — is never part of a close, in
any country.

**There is no default.** Leave `closing_style` out and `close_fiscal_year`
refuses with `no_closing_defaults`; leave `journal_roles.opening` out and it
refuses with `no_opening_journal`. Nothing falls back on a Belgian or a French
value, because a default closing style would be one country's mechanism given
to every country that has not spoken. `ekwo pack check` refuses a pack that
declares a style without the accounts it needs, and an opening journal that is
not of journal type `opening`, so the gap is found when the pack is written and
not on somebody's year end.

### 4. The taxes, and where each one posts

`taxes.json`. One entry per code, and a code is a rate at a date: a new rate is
a new code plus a `valid_to` on the old one, never an edit, which is how the
return of a past period keeps giving the same answer.

Each tax carries a `legal_reference`, and it is required — the article, not the
word "TODO" — and a `source` naming which text of step 0 that article is in. Its `postings` say where the money goes, per kind of document, out
of the three posting types described above. Start with the plain cases in both
directions, then the ones that are actually specific to your country: a partly
deductible tax, a reverse charge, a tax due on collection.

`treatment`, `vat_category` and `exemption_code` are three tellings of one
fact, and `ekwo pack check` refuses them when they disagree — so the table
under "What a tax says on the invoice" is the fastest way to fill the last two
in. Read the two decisions under it before you fill a purchase-side tax: the
category there is the one the *supplier's* invoice carries, and where no
invoice governed by EN 16931 exists there is none to record. And read the
paragraph above them first if your country is not in the common system of VAT:
there, `exemption_code` stays null on every tax, the article goes in
`legal_reference`, the `intracom_*` treatments do not exist, and `vat_category`
is asked for only if you declare an e-invoicing profile.

Where a code is the answer to a question the books do not hold — a certificate
the buyer signed, a threshold the seller crossed — say which question in
`conditions`, from the five words under
[What an exemption depends on](#what-an-exemption-depends-on). It is a word and
never a test: the figure a threshold is set at belongs in the article, and the
article is already in `legal_reference`.

### 5. The declaration form

`tax_report.json` is one form and its boxes. A `base` or a `tax` box is summed
from what the postings wrote on the ledger; a `total` is a list to add, a list
to subtract and a floor at zero — or, where the form states a line as a
multiplication, a `rate` and the `rate_of` box it applies to. There is no
expression language, in any country. The totals are worked out in the order
they depend on each other, so declare the boxes in whatever order reads best
and give a box a `print_sequence` where the administration prints it somewhere
else. Every box carries its own `legal_reference` and, like a tax, the `source`
of the text it is in — usually the form itself, which is the entry of step 0
the boxes actually came from.

Then go back to `taxes.json` and put a `box` on each posting. The two files are
checked against each other, which is the first place a country pack usually
turns out to be wrong.

Each tax takes **one `base` posting per kind of document**. Where your form
prints the same taxable amount somewhere else — a turnover line above a rate
breakdown, a memo box inside a box — that second place is a `total` naming the
first where it is a sum, and one more box on the posting's own `box` list where
it is not. Never a second posting: see "A base is written once, and printed as
often as the form likes".

### 6. The financial statements

`statements.json`, one entry per scheme your country prescribes, with the
`rules` that sum each line from the ledger. If your country prescribes none —
or you are not ready to map them — leave the file out and let your chart fall
back to `packs/generic/`, the country-less pack whose rules are all
`account_type`. That is what the eighteen account types buy, and it gives a
chart with no legal codes a balance sheet that ties out.

Add `xbrl` fact keys only for a taxonomy you can verify, and leave them null
otherwise. A wrong key is worse than no key.

### 7. Check what you have so far

```sh
npm run build
node packages/cli/dist/bin.js pack check xx
```

Read every line it gives you. The common first run:

```
Checking
✗ pack_invalid: packs/be — 2 problem(s)
  taxes.json[0]: missing "legal_reference"
  taxes.json BE-S-12.invoice: box ZZ:base is not a base box of this form
```

The rules are listed one by one above, under "What `ekwo pack check`
refuses". The one that catches the most is the last: **every postable account
of a chart has to reach a line of one of that chart's statements**. An account
that reaches none is an account that would vanish off a balance sheet, and the
error names it.

### 8. The other languages

One file per language, `i18n/<lang>.json`, and that file is the only place a
translation lives. Add the languages your country's books are actually kept in
to `manifest.languages` **once they are complete**: a declared language has to
cover the accounts of every chart, the journals, the taxes, the boxes, the
statement lines, the legal mentions and the asset categories, and `pack.json`
declaring one it does not cover is a pack that does not build. A file that is
not declared may be partial, which is how a language is contributed one section
at a time.

### 9. A year of books, and the figures it produces

This is the step. Everything above can be internally consistent and wrong.

Write `golden/scenario.json`: a financial year, its periods, the contacts, at
least ten documents and the payments that settle some of them. Every document
and every payment carries a `why` — one sentence saying what it is there to
prove. A golden grows by accident otherwise: somebody adds a line to make a
figure move, and two years later nobody can say whether dropping it would lose
anything.

Then:

```sh
UPDATE_GOLDEN=1 npm test -- tests/golden.test.ts
```

which writes `golden/vat_return.json`, `golden/statements.json` and
`golden/trial_balance.json`, and never the scenario. **Read what it wrote.**
That reading is the step: a figure you cannot explain is a defect in your pack,
found before anybody files anything with it. The runner knows no country — what
it asks of your scenario, it asks of your pack: both directions, more than one
positive rate, a credit note, a matched payment and an unmatched one, and an
intra-Union reverse charge, a tax due on collection or a partly recoverable tax
**only where your pack has one**.

One assertion is not read from a file: the posted ledger balances. A golden
regenerated from a broken engine would agree with itself; double entry would
not.

If your country's filing taxonomy names facts your statements carry, or its
form owes an arithmetic to a text, write them into `golden/expectations.json`
— see "What only this pack can claim". That file and the pack folder are the
only two places you write: no test of this repository has to change for your
pack to be checked.

### 10. Compile, open the pull request

```sh
node packages/cli/dist/bin.js pack build xx
node packages/cli/dist/bin.js pack check --all
```

`build` writes `supabase/seed/<n>_pack_xx.sql` — and
`supabase/seed/modules/assets/<n>_pack_xx.sql` if your pack carries an `assets`
section — and then **every list that names the packs outside `packs/`**: the
seed goes into `[db.seed] sql_paths` of `supabase/config.toml` and into the
`psql -f` lines of the README, your country into the README's list and into
the [table of packs](#the-packs-of-this-checkout), and `packs/xx/` gets its line
in `.github/CODEOWNERS`. You edit none of them; `check` refuses them the day
they stop saying what `packs/` says. The module seed stays out of
`sql_paths` deliberately, because it is applied by the module migration
runner, on installations that carry the module.

Commit what it wrote with the pack. It is a build artefact that is
committed on purpose, so that `supabase db push` and `psql -f` install your
country without the CLI ever running.

Then run

```sh
node packages/cli/dist/bin.js pack check xx --links
```

once, by hand, and read what it says: it opens every URL of your register and
names the ones that did not answer. It fails nothing and the CI never runs it —
a publisher that turns away anything without a browser is not a wrong pack — so
open the ones it names yourself before deciding anything.

If you are going to own the pack, put your handle on the line `build` wrote
for `packs/xx/` in `.github/CODEOWNERS` — the next build keeps it. Add a line
to `CHANGELOG.md` under `[Unreleased]`, and open the pull request.
Set `certification.status` honestly: `community` is the right answer until an
accountant has read it, and an issue titled "Review: <country>" is how one is
asked to.

## The two places a pack is written

Adding a country touches **two** places, and nothing else:

1. **`packs/<cc>/`** — the manifest, the charts, the taxes, the declaration
   form, the statements, the document rules, the translations, and the seed
   compiled from them.
2. **`packs/<cc>/golden/`** — the scenario, the three generated expectation
   files, and `expectations.json` where the pack states what only it can state.

Everything else the pull request changes is written by `ekwo pack build`: the
seed under `supabase/seed/`, and the generated blocks of
`supabase/config.toml`, `README.md`, `.github/CODEOWNERS` and this page. A
contributor runs the command and commits its output, exactly as for the seed.

A pack whose currency no pack used before adds its row — the ISO 4217 code,
its name, its symbol and its decimals — to `supabase/seed/00_currencies.sql`.
A member State of OHADA finds all three already written: its code in `members`
in `packs/ohada/manifest.json`, which is how it receives the chart the members
share, its currency and its territory — so it touches its own folder and
nothing else. [`packs/ohada/README.md`](../packs/ohada/README.md) is that
path.

A country **outside the common system of VAT** adds a third, and exactly one
row of it: `supabase/seed/00_territories.sql`, for the reason step 0 gives. It
is framework reference data and not a country literal in the core — the table
exists precisely so that no function holds a list of countries — and it is
still a file outside `packs/`, so a pull request that adds one says so.

A pack that **conditions a tax on a territory below the country** adds rows to
the same file, one per territory it names — and one per territory its golden
scenario delivers to, because `documents.supply_territory_code` is a foreign
key as well. `packs/us/` adds four: the three states its codes belong to and
the one its last invoice ships to. The rows grow with the packs and not with the
world: a state nothing says anything about has no row.

**Nothing under `tests/` or `modules/*/tests/`.** A test about the core walks
`listPacks()` and reads its expectation from the pack — a role from the
manifest, an account from a chart, a box from the form — so a pack that lands
is checked the day it lands rather than the day somebody remembers to add it to
a list. `tests/helpers/packs.ts` is where that starts: `allPacks` to loop over
everything, `packWhere('taxes on collection', …)` to pick the pack that carries
the property under test rather than the country that happens to have it, and
`somePack` for a test that needs a pack and does not care which.

A guard keeps it that way:

```sh
node scripts/check-no-country-literals-in-tests.mjs
```

It runs in CI and fails on three things: a country code inside an `expect(…)`
next to the word `country`, a list of two or more country codes or pack slugs
anywhere, and a pack named by hand where `listPacks()` would have found it.
Setting up may still name a country — a scenario books invoices somewhere, and
saying where is how it stays readable. Expecting one may not. Where a literal
is genuinely right, one comment says so and why:

```ts
// country-literal: the demo company is Belgian, and this reads its books
```

## What is not in a pack

The engine: posting, matching, the returns, the installer. Also deliberately
out — the rates of American sales tax (thousands of jurisdictions, monthly
changes; the form belongs here, a maintained rate feed does not), the XML of
the filing formats, analytics, fixed assets, payroll, and the translation of
the application itself. A handful of stable rates published by the
administration *is* data and belongs in the pack — Canada's fifteen GST/HST
combinations would be — and a feed that moves every month is not.
