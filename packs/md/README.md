# Moldova

Everything Moldova adds to Ekwo, as data: a functional subset of the official
national chart of accounts, the journals, the VAT rates with their history and
where each one posts, the boxes of the monthly VAT return (forma TVA12), an
abridged balance sheet and profit-and-loss account, and the sentences the
invoicing rules put on a factura fiscală. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Moldovan accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `ro`.** The pack's own labels are written in Romanian, the
language Moldova's own Codul fiscal and Standardele Naționale de Contabilitate
are published in. `en` is declared as a second language
([`i18n/en.json`](i18n/en.json)) so an English-reading bookkeeper can install
the same pack; the reference chart of accounts (Ordinul Ministerului
Finanțelor nr. 119/2013) carries no official English version, so the English
labels here are this pack's own translation and not a citation — flagged in
[`i18n/README.md`](i18n/README.md).

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds ten texts: the consolidated Codul fiscal (Legea nr. 1163-XIII
din 24.04.1997), Titlul III; the State Tax Service's own generalised database
on the rates and on the HORECA change; the order approving forma TVA12 and its
instructions; the public-procurement e-invoicing communiqué; the reporting
portal itself; the order approving the Planul general de conturi contabile;
the accounting law (Legea nr. 287/2017); S.N.C. 5, "Prezentarea situațiilor
financiare"; and the Civil Code's late-payment interest article.

**One residual gap in the register, disclosed rather than guessed around:**
`legis.md`, the Ministry of Justice's own legislative portal, refuses a
request from a client with no browser behind it — the same behaviour
`docs/packs.md` already documents for Légifrance — so this pack's research
could not open the consolidated Codul fiscal directly for a final check of
art. 115 alin. (1)'s exact current wording (the filing deadline). An older
consolidated copy read through a different channel showed "the last day of
the month following the period", while every 2024-2025 secondary source
consulted — the State Tax Service's own communications, the reporting
portal's practice, professional accounting outlets — agrees on the 25th, the
date this pack declares. A reviewer with access to the current consolidated
text should confirm the article's wording directly.

## The chart of accounts

**Moldova publishes an official numbered chart of accounts**, like Romania and
unlike Turkey: Ordinul Ministerului Finanțelor nr. 119 din 06.08.2013, in
force from 1 January 2014 and mandatory from 1 January 2015 for every entity
keeping double-entry books that is not a public institution and does not apply
IFRS, fixes nine classes (1-9). This pack transcribes classes 1-7 — long-term
assets, current assets, equity, long-term liabilities, current liabilities,
income, expenses — using the official first- and second-degree synthetic
account codes (`cont de gradul I`, three digits, mandatory; `cont de gradul
II`, four digits, left to each entity's own convention by the order itself).
Classes 8 (internal management accounts) and 9 (off-balance-sheet accounts)
are left out: the order itself says both are of a recommended rather than a
mandatory character, and neither is read by the VAT return or by the
statements this pack carries.

Two second-level accounts are this pack's own convention, not a subdivision
the order fixes: `53441` "TVA colectată" and `53442` "TVA deductibilă" (with
`53443` for the self-assessed VAT of an imported service) split the postings
of the VAT taxes from `534`'s child `5344`, "Datorii privind taxa pe valoarea
adăugată", which the order carries as a single grade-II account with no
posting subdivision of its own. `5344` is kept as the reconcilable settlement
account the VAT return is closed against (`defaults.roles.tax_payable`) —
distinct from the accounts the taxes post to, the rule learned on `packs/sk/`
— and `7148`, "Alte cheltuieli operaționale", an existing official account, is
this pack's choice for the rounding role rather than an invented one.

## The taxes

Eight codes. The standard rate is 20% (Codul fiscal, art. 96 lit. a)). The
reduced rate is 8% (art. 96 lit. b)), which since 31 December 2023 covers, in
one rate, several categories the law lists separately — bread and bakery
products, milk and dairy products (excluding the products for infants that are
exempt outright), medicines and a list of medical goods by tariff position,
natural and liquefied gas, primary livestock and horticultural production,
beet sugar, solid biofuel, feminine hygiene products, and accommodation and
restaurant/catering services classified under section I of the Moldovan
economic activity classifier (the HORECA sector, which paid 12% before the
state of emergency of 2022-2023 and was set permanently at 8% by Legea nr.
212/2023 once that emergency ended). `MD-S-8` carries one rate for all of
them, the same choice `packs/ro/` makes for its own reduced-rate bracket.

Zero rate covers export and international transport (`MD-S-0-EXPORT`, art. 104
lit. a)). An exemption without the right of deduction is illustrated by the
lease of housing and land (`MD-S-EXE`, art. 103 alin. (1) pct. 1)) — one line
of a much longer list at art. 103, not transcribed in full: see "What the
socle cannot do" below.

Purchase-side, four codes: domestic purchases at both rates (`MD-P-20`,
`MD-P-8`), an ordinary import of goods (`MD-P-IMPORT`, valued at customs value
per art. 100), and the self-assessment of an imported service (`MD-P-IMPORT-SRV`,
art. 94 lit. c) and art. 101 alin. (4)), which posts to the return's own pair
of rows (7/8) rather than to the domestic purchase rows, and separately feeds
row 20, the VAT due to the budget on imported services — a liability apart
from the net VAT of row 19, exactly as forma TVA12 keeps the two apart.

## The declaration

`MD-TVA12` transcribes the declaration form approved by Ordinul Inspectoratului
Fiscal Principal de Stat nr. 1164 din 25.10.2012 and its "Modul de completare",
still the form and instructions in force. Only the rows this pack's taxes
reach are declared, together with the four totals that can be computed from a
single period's postings (rows 10, 11, 18, 19, 20); the informational
sub-rows (1.1, 2.1, 11.1) and the rows that carry a balance across fiscal
periods (17, 21, 22) are not — see "What the socle cannot do" below. The
fiscal period is the calendar month (art. 114 alin. (1)); art. 114 alin. (1¹)
sets a calendar quarter for the narrower category of taxpayers named at art.
94 lit. d), a fact about the company this pack's scenario has no reason to
carry, so `period_default` proposes the month, the rule for everyone else.
The deadline is the 25th of the month following the period — see the
residual gap on art. 115 alin. (1) noted above.

## Invoices

- **Numbering**: `gapless`. Codul fiscal art. 117 alin. (2) pct. 1) asks only
  for "the current number of the invoice" — a sequential number, with no
  annual reset required by the text itself. In practice a factura fiscală
  carries a series and a number either assigned by the State Tax Service (a
  typeset form) or self-printed within a series and a number range the Service
  allocated (Ordinul Ministerului Finanțelor nr. 118 din 28.08.2017);
  `number_format` proposes one shape as a convention, not a citation.
- **Tax point**: `invoice_if_issued` — delivery is the rule (art. 108 alin.
  (1)), displaced by an earlier invoice or an earlier payment, whichever comes
  first (art. 108 alin. (4)-(5)). The payment branch, when no invoice was
  issued first, is a second derogation this field cannot carry beside the
  first — see "What the socle cannot do" below.
- **Payment terms**: no statutory default term between professionals (Codul
  fiscal is silent, unlike the EU's own Directive 2011/7/EU); once a term is
  missed, legal interest runs under Codul civil art. 942, at a rate this
  pack's research could not reduce to one figure — see below.
- **Mentions**: a reverse-charge sentence for an imported service, the
  zero-rate wording for an export, and the exemption wording for an exempt
  supply.

### E-invoicing

SIA "e-Factura" is mandatory, since 1 January 2021, for a taxable delivery
made within public procurement on Moldovan territory (Codul fiscal art. 117
alin. (12), introduced by Legea nr. 102 din 18.06.2020) — sectoral
procurement and concessions included, with electricity, heat, natural gas,
communal services and electronic communications services excluded. From 1
January 2025 the same obligation reaches deliveries to economic agents that
have no fiscal relationship with Moldova's budgetary system, and goods or
services financed by grants or international treaties. `einvoicing.profile`
stays null: SIA "e-Factura" is a State Tax Service platform that generates
and transmits the electronic factura fiscală directly inside a government
system, and this pack's research found no official confirmation that the
document exchanged follows an interoperable semantic model of the EN 16931
kind (Peppol BIS, Factur-X, XRechnung, a PINT) — nor does any brick of
`packages/formats/` write, validate or transmit one today. `party_scheme` and
`vat_scheme` stay null as well: a Moldovan taxpayer is addressed by its
fiscal code (IDNO/IDNP), not by a registered ISO 6523 scheme. See "From
Moldova" in `docs/international.md`.

## What the socle cannot do

**A state e-invoicing platform this repository has no writer for**, for the
scope Codul fiscal art. 117 alin. (12) currently reaches. Documented above and
in `docs/international.md`.

**A second derogation to one tax point, and the field carries one.** Codul
fiscal art. 108 alin. (4)-(5) has two branches for services: an invoice issued
before delivery moves the tax point to the invoice date, and a payment
received before delivery — with no invoice issued yet — moves it to the date
of collection. `tax_point` is a single word for the country's general rule,
and `invoice_if_issued` already states the first branch honestly; the second
would need `cash_basis` declared on a specific tax, which would misstate an
advance payment as that tax's whole regime rather than as one operation among
many — the same limit `docs/packs.md` records for Belgium and Estonia, and
`packs/ro/` for its own two-branch rule.

**The carry-forward of a period's credit is outside a return that only sums
what the ledger posted.** Rows 17 (the balance carried in from the previous
period), 21 (the balance to carry to the next one) and 22 (the amount claimed
for refund) all depend on a fact `vat_return()` cannot read from a single
period's postings — the same gap `docs/international.md` already records for
Poland's `P_39`/`P_62` and for Romania's rows 38/39/41/42. `MD-TVA12`'s row 18
therefore sums rows 13, 15 and 16 only, and row 19 is floored at zero rather
than turning negative into a row-21/22 pair.

**Article 103's full list of exemptions is not transcribed.** The article
carries some two dozen numbered points — state property bought back in a
privatisation, financial and insurance services, burial services, urban
transport, book and periodical publishing, and more — of which this pack
models one, the lease of housing and land (pct. 1), chosen for the golden
scenario. A company whose exempt activity is not that one has no ready-made
tax code here and should have a professional confirm the right article before
one is added.

**Two purchase-side mechanisms named by the TVA12 instructions and not
modelled: goods bought from a resident with no fiscal relationship with the
budgetary system, and the postponed accounting of any deferred import VAT
regime.** The instructions to rows 7 and 14 both mention "persoane rezidente
... care nu au relații fiscale cu sistemul ei bugetar" as a source of
self-assessed VAT, once for services (row 7, alongside imported services) and
once for goods (row 14, alongside imported goods) — this pack's research could
not establish with confidence, from the sources it reached, whether the goods
case additionally self-assesses an output-side liability the way the services
case plainly does through row 20, or whether it is a deduction-only
adjustment. Rather than guess at a mechanism it could not verify, this pack
models only the plain import of goods and the plain import of services.

## What a reviewer should look at first

1. **The deadline of art. 115 alin. (1)** — the residual gap in "Sources"
   above, from a text this pack's research could not open directly.
2. **`MD-S-8`'s single rate for nine different categories** — an accountant
   should confirm no category listed has since moved to a different rate or
   been withdrawn, and that the HORECA scope (section I of the CAEM) still
   reads as this pack states it.
3. **The account subset and the `53441`/`53442`/`53443` convention** — a
   Moldovan accountant should confirm nothing essential to a small company's
   books is missing from classes 1-7, and that splitting `5344` this way
   matches how a real entity's working chart is kept.
4. **The two unmodelled purchase-side mechanisms** flagged above (row 7/14
   purchases from a budget-unrelated resident) — worth a second look before
   this pack is anything past `community`.
5. **The abridged financial statements.** `MD-SNC-BS` and `MD-SNC-IS` group
   S.N.C. 5's own row numbers at the chapter and section level rather than
   transcribing every synthetic account's own row; a company whose auditor or
   bank asks for the full-detail statutory format needs more than this pack
   carries today.
