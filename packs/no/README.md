# Norway

Everything Norway adds to Ekwo, as data: a chart of accounts written directly
from regnskapsloven §§ 6-1 and 6-2, the journals, the merverdiavgift (mva)
rates and where each one posts, the codes of the mva-melding (the modern,
code-based VAT return that replaced form RF-0002 in April 2022), and what the
invoicing rules of the bokføringsforskrift require. The format is
[`docs/packs.md`](../../docs/packs.md); this file records what the pack
deliberately leaves out and why, so that a Norwegian regnskapsfører or revisor
reading it can disagree with one line rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against two months of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `nb` (bokmål), no second language shipped.** The pack's own
labels — the chart, the tax names, the boxes and the statement lines — are
Norwegian throughout: this pack invents no chart from a foreign model, so
there was no point at which an English label stood in for a missing
Norwegian one.

## Sources

Every rate, code and mention carries its own `legal_reference` and names the
entry of `certification.sources` its article is in. Fifteen texts are
registered; the ones a reviewer should open first:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, export, registration threshold, import, reverse charge | Merverdiavgiftsloven (LOV-2009-06-19-58) | Lovdata |
| The rates in force each year | Stortingsvedtak om merverdiavgift for 2026 (18 December 2025) | Lovdata/Stortinget |
| The periods and the deadline of the mva-melding | Skatteforvaltningsforskriften (FOR-2016-11-23-1360), §§ 8-3, 8-3-3, 8-3-7, 8-3-10 | Lovdata |
| The mva-koder the return is built from | Standard Tax Codes, the SAF-T tax code list | Skatteetaten, GitHub |
| The invoice's number and issuance deadline | Bokføringsforskriften (FOR-2004-12-01-1558), §§ 5-1-3, 5-2-2 | Lovdata |
| The balance sheet and income statement structure | Regnskapsloven (LOV-1998-07-17-56), §§ 6-1, 6-2 | Lovdata |
| The chart's own confirmation that no chart is prescribed | Norsk RegnskapsStandard 8 (January 2022) | Norsk RegnskapsStiftelse |
| The obligation to send EHF/Peppol to the public sector | Forskrift om elektronisk faktura i offentlige anskaffelser (FOR-2019-04-01-444) | Lovdata |

The merverdiavgiftsloven and the two forskrifter were read article by
article on lovdata.no on 25 September 2026 — §§ 2-1, 3-6, 3-30, 5-1 through
5-12, 6-1, 6-4, 6-8, 6-21, 6-22, 8-1, 11-1 of the law; §§ 8-3, 8-3-3, 8-3-7,
8-3-10 of the skatteforvaltningsforskrift; §§ 5-1-1, 5-1-3, 5-2-2 of the
bokføringsforskrift. The SAF-T tax code list was read from its raw CSV on
GitHub, not from a secondary description of it, because two rounds of
research summarising it disagreed with each other on what the codes meant —
the CSV itself is the only reading this pack relies on.

## The chart of accounts, and why this one

**Norway prescribes no chart of accounts.** Regnskapsloven § 6-1 and § 6-2 fix
only the *presentation* of the income statement and the balance sheet — a
list of named items, not account numbers. What most Norwegian bookkeeping
follows in practice is NS 4102 *Kontoplan for regnskap*, a standard published
and sold by Standard Norge, whose own page states plainly: "Loven krever ikke
at denne standarden brukes" — the law does not require this standard to be
used. This pack does not copy it, for the same reason `packs/ch/` does not
copy the Swiss Kontenrahmen KMU: NS 4102 is not free to reproduce, and a
pack's chart has to be written down in full. The chart here is original and
follows the order of §§ 6-1 and 6-2 directly, four-digit codes, one range per
Roman-numeral item of § 6-2 and one range per numbered item of § 6-1 — see the
`legal_reference` on each statement line for the exact mapping. A reader
coming from NS 4102 will find a similar shape, because that standard also
follows the same two articles, and different account numbers throughout.

`closing_style` is `retained_earnings`: § 6-2's equity section (C.I innskutt
egenkapital, C.II opptjent egenkapital) has no separate "result of the year"
item, so the result closes straight into "Annen egenkapital" (2120), the same
choice `packs/ch/` and `packs/gb/` made for the same reason.

## The taxes

Ten codes, all dated from 1 January 2026 (the rates of Stortingsvedtak om
merverdiavgift for 2026, unchanged from 2025: §§ 2-4 fix 25 %, 15 % and 12 %).
Six on the sale side — the standard rate, the medium rate (næringsmidler,
food), the low rate (persontransport, overnatting and the other services of
§§ 5-3 to 5-11), a domestic zero rate with full deduction (books, § 6-4 — the
taux-zéro case), an export (§§ 6-21/6-22), and an exempt supply with no
deduction (financial services, § 3-6 — the exemption case). Four on the
purchase side: the standard and low rates deductible on a domestic purchase,
the import of goods (§ 11-1, third paragraph) and a remotely-deliverable
service bought from a supplier established outside the VAT area (§ 3-30 —
Norway's reverse charge, narrower than the European Union's general
business-to-business rule: it reaches only services that can be delivered
remotely, not every cross-border service).

`exemption_code` is null on every tax: Norway is outside the common system of
VAT (`territories.eu_vat_scope = 'none'`, added by this pack to
`00_territories.sql`, since Norway's membership of the European Economic Area
does not extend to VAT — the EEA Agreement's annexes do not carry the VAT
directives), so the VATEX list does not reach it and the article is in
`legal_reference` instead. `vat_category` is filled in on every sale-side tax
because `einvoicing.profile` names `peppol-bis-3` — the profile the public
sector receives — which is what makes the category a requirement rather than
a courtesy; it is left null on the four purchase-side taxes, following the
same reading `packs/ch/` and `packs/gb/` give: `import` and
`foreign_services_received` carry no invoice this pack's country governs, so
there is no supplier's category to record.

### The self-assessed liability of import and of a foreign remote service

The Standard Tax Codes list has a code for the *deductible* side of an import
(`14`) and of a foreign remote service (`86`), each paired with its own base
code (`21`, `86`), but no code of its own for the *liability* side — the
amount the buyer owes on that same base. Reading the list alongside
`packs/gb/`'s own `GB-P-20-PVA` and `GB-P-20-RCS` (which the United Kingdom's
guidance sends to the *same* box the ordinary domestic output tax uses, box
1, and not to a box of their own) is what this pack follows: the self-assessed
liability of `NO-P-IMPORT-25` and `NO-P-FOREIGN-25` is booked to the ordinary
standard-rate output box, `3`, with `factor: -100` flipping it onto a
liability account distinct from the tax_payable settlement account and from
the ordinary output-VAT accounts. **This reading has not been checked against
a worked example from Skatteetaten or against a Norwegian accounting
system's own SAF-T export** — see "Before this pack is reviewed" below.

### What the mva-melding does not ask for at all

An exempt sale (`NO-S-EXEMPT`, financial services under § 3-6) carries a
`base` posting with **no box at all**. The Standard Tax Codes list has no
code for exempt turnover that carries no deduction consequence, unlike the
European Union's common-system forms, which generally ask for the total of
exempt supplies somewhere on the return. Since April 2022 the mva-melding is
built entirely from the codes a company's postings actually use, and there is
no code among them that means "unntatt omsetning" — so this pack reports
nothing there, rather than inventing a box the return does not carry.

## The declaration form

`tax_report.json` is not a form with numbered boxes printed on paper: since
April 2022 the mva-melding is submitted as a set of lines, each carrying one
of Skatteetaten's standardised `mvaKode` values (the same codes the SAF-T
Financial file uses) with a base amount and a tax amount. This pack's
"boxes" are therefore those codes, transcribed as a **subset** of the
published list — the ones the ten taxes above actually reach (`1`, `3`, `5`,
`13`, `14`, `21`, `31`, `33`, `52`, `86`) — and not the whole list, which also
carries codes for raw fish, gold and emission-allowance trading, and the
non-deductible half of an import or a foreign service, none of which this
pack's taxes model yet.

Four more boxes — `UTSUM`, `INNSUM`, `BETALES`, `TILGODE` — are this pack's
own, not Skatteetaten's: the modern return computes its net figure
(`fastsattMerverdiavgift`) from the codes without naming an intermediate
total anywhere a human reads, so this pack declares one, the way `packs/ch/`
declares boxes `500`/`510` for the same arithmetic.

**No `deadline` is declared.** Skatteforvaltningsforskriften § 8-3-10 states
the deadline as "en måned og ti dager etter utløpet av hver
skattleggingsperiode" — one month and ten days after the period ends — which
for a two-month period is not the same shape as either
`day_of_month_after_period` (a fixed day of *the following* month) or
`last_day_of_month_after_period`: for a period ending in February the
deadline is 10 April, two months later and ten days, not one. The third
period of the year (May–June) is due 31 August instead of the 10 August the
formula would give, a one-off summer exception the regulation states by name
and that no rule of this format's closed vocabulary can express either. Both
gaps are recorded in this pack's section of
[`docs/international.md`](../../docs/international.md).

## What this pack does not model, and why

**The reduced rates for raw fish (11,11 %) and the domestic reverse charge on
gold and emission allowances (mvaKoder `32`, `51`, `91`, `92`).** Neither is a
fact this pack's golden scenario exercises, and modelling the gold/emissions
reverse charge without a verified reading of merverdiavgiftsloven § 11-1,
third paragraph's exact scope would risk inventing a rule rather than
transcribing one.

**The non-deductible half of an import or a foreign service** (`82`, `84`,
`87`, `89`, `92` in the Standard Tax Codes list) — this pack's two purchase
codes assume full deduction, which is the ordinary case for a wholly taxable
business and the one the golden scenario exercises.

**The annual filing cadence for a small business or a primary-sector
enterprise** (skatteforvaltningsforskriften §§ 8-3-3 and 8-3-7) is declared as
a cadence the form accepts (`"period": ["bimonth", "year"]`) but not
proposed as the `period_default`, since it depends on the company's own
turnover or activity and not on a rule the law gives everybody — exactly the
reason `packs/lu/` proposes none for its own turnover-dependent cadence.

**SAF-T Financial on request.** Bokføringsloven § 13 b requires bookkeeping
data that is already electronic to stay electronically available for three
years and six months after the fiscal year ends; the further duty to hold it
in the SAF-T format specifically, and the turnover threshold that duty
applies above, are in bokføringsforskriften chapter 7, which this pack's
research could not re-open for a verbatim citation in this session — the
figure commonly cited is five million kroner, unverified here. Ekwo has no
SAF-T Financial export brick regardless of the threshold; the gap is
recorded in `docs/international.md`.

**A default payment term.** `documents.legal_payment_days` is left `null`:
forsinkelsesrenteloven § 3 fixes the *interest* due once a payment is late,
which this pack states, but no text was verified in this session that gives
a default *term* the way Swiss OR art. 75 does — see "Before this pack is
reviewed".

## Before this pack is `reviewed`

1. **The self-assessed liability box for import and foreign services**
   (box `3`, described above) — the reading is reconstructed by analogy with
   `packs/gb/`'s postponed VAT accounting, not confirmed against a Norwegian
   worked example.
2. **The default payment term**, if Norwegian law gives one absent an
   agreement (kjøpsloven § 49 or a general principle of contract law) — only
   the interest rate is sourced here.
3. **The tax point** (`invoice_date`): no article of the merverdiavgiftsloven
   was found in this session that states the general tax point as opposed to
   who is liable (§ 11-1) or when an invoice must be issued
   (bokføringsforskriften § 5-2-2, one month after delivery). The value
   declared is a cautious reading of the accrual practice these two give
   together, not a verified single article.
4. **The chart**, read by someone who books in NS 4102 daily: which accounts
   a small Norwegian AS will miss.
5. **The bokføringsforskriften chapter 7 threshold** for SAF-T Financial
   electronic availability, and the exact wording of § 13 b's three-year and
   six-month rule.
