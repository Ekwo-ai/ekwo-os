# Germany

Everything Germany adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the Kennzahlen of the
Umsatzsteuer-Voranmeldung, the balance sheet of § 266 HGB and the income
statement of § 275 HGB, and the sentences the law puts on an invoice. The
format is [`docs/packs.md`](../../docs/packs.md); this file gives the sources
and the decisions, so that a German accountant or Steuerberater can disagree
with a specific sentence.

**Status: `community`.** Nobody has reviewed it against the law they apply. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The register
holds twenty texts, each with its consultation date:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, invoice particulars, the return and its deadline | Umsatzsteuergesetz (UStG) | gesetze-im-internet.de |
| Small invoices, invoices of small businesses, the deadline extension | Umsatzsteuer-Durchführungsverordnung (UStDV) §§ 33, 34a, 46 to 48 | gesetze-im-internet.de |
| Books, the balance sheet and the income statement | Handelsgesetzbuch §§ 238, 239, 266, 275 | gesetze-im-internet.de |
| An entry that may not be altered | Abgabenordnung § 146 Abs. 4 | gesetze-im-internet.de |
| Payment term, default interest, the 40 euro fee | BGB §§ 286, 288 | gesetze-im-internet.de |
| The Kennzahlen and the instructions for them | BMF-Schreiben of 29 December 2025, form USt 1 A 2026 and guide USt 1 E | bundesfinanzministerium.de |
| E-invoicing | BMF-Schreiben of 15 October 2025 and the BMF's questions and answers | bundesfinanzministerium.de |
| E-invoice formats | XRechnung (KoSIT), ZUGFeRD (FeRD), EN 16931 | xeinkauf.de, ferd-net.de, European Commission |
| Code lists | UNCL5305, VATEX, EAS | docs.peppol.eu |
| Where the return and the recapitulative statement are filed | ELSTER, Bundeszentralamt für Steuern | elster.de, bzst.de |
| The base rate the default interest is added to | Basiszinssatz | bundesbank.de |
| Corporate income tax: the rate, what is not deductible, the limit on losses | Körperschaftsteuergesetz (KStG) §§ 7, 8, 10, 23; Einkommensteuergesetz (EStG) §§ 4, 7, 10d, 37, 52 | gesetze-im-internet.de |
| Useful lives of the usual fixed assets | AfA-Tabelle für die allgemein verwendbaren Anlagegüter ("AV"), BMF-Schreiben of 15 December 2000 | bundesfinanzministerium.de |

The Kennzahlen, the line numbers, the three unnumbered sums and the
instructions quoted in the box references are those of the BMF's PDF edition
of the form.

## The chart of accounts, and why this one

**Germany prescribes no chart of accounts.** § 238 HGB obliges a merchant to
keep books and says nothing about their accounts. What most German bookkeeping
runs on is SKR 03 or SKR 04, the standard charts of **DATEV eG**. They are
published under DATEV's copyright and no open licence, so this pack copies
neither their numbers nor their labels, and nobody should read it as an SKR.

Instead the chart follows the law's own structure: four digits, flat, and
every digit means something in the HGB:

| First digit | Is |
|---|---|
| `1` | Aktiva A, Anlagevermögen — the second digit is the roman numeral (I, II, III), the third the item |
| `2` | Aktiva B, Umlaufvermögen — same reading: `2240` is B.II.4, sonstige Vermögensgegenstände |
| `3` | Aktiva C, D and E |
| `4` | Passiva A, Eigenkapital — `4400` is A.IV, `4500` A.V |
| `5` | Passiva B, Rückstellungen — the second digit is the item |
| `6` | Passiva C, Verbindlichkeiten — the second digit is the item, so `64xx` is C.4 and `68xx` C.8 |
| `7` | Passiva D and E |
| `8` | Items 1 to 8 of § 275 Abs. 2 — the second digit is the item, the third the letter (`8520` is 5 b) |
| `9` | Items 9 to 16 of § 275 Abs. 2 — the second digit is the item less eight |

So every account reaches exactly one statement line by the head of its code,
with four exceptions that are split by side: the bank accounts, which are
an asset in debit and a liability to the bank in credit; the VAT settlement
account `6820`; the clearing account `2249`; and the shareholder current
account `6860`.

Depreciation is booked directly on the asset (German practice under the
HGB): there are no accumulated-depreciation accounts.

## The taxes

Twenty-two codes. The standard rate is 19 % since 1 January 2007 and the reduced
rate 7 %; the temporary 16 % and 5 % of the second half of 2020 (§ 28 UStG) are
carried with their validity and post to Kennzahlen 35 and 36, which is where
the 2026 guide says a correction of such a supply goes. The 0 % of § 12 Abs. 3
for photovoltaic systems has its own code and Kennzahl 87, and is a rate rather
than an exemption, so its category is `Z`.

The reverse charges are three codes on the purchase side, one per line of the
form: services from another Member State (§ 13b Abs. 1, Kennzahlen 46 and 47),
supplies by a supplier established outside the Union (§ 13b Abs. 2 Nr. 1,
Kennzahlen 84 and 85) and the domestic cases of § 13b Abs. 2 Nr. 4 to 11
(Kennzahlen 84 and 85 as well). All three deduct through Kennzahl 67.

## The return

`DE-USTVA-2026` is form USt 1 A for 2026, Kennzahl by Kennzahl. A Kennzahl is
the box code. Where the form prints a tax beside a base on the same line and
gives the tax no number of its own — lines 13, 14, 25 and 26 — the tax is the
`tax` kind of the same box (`81:tax`). The three sums the form prints without a
Kennzahl carry their line number: `Z37`, `Z45`, `Z48`. Kennzahl 83 is signed,
as the form asks: a surplus comes out negative.

Kennzahlen 62 (import VAT), 39 (the special advance payment), 50 and 37 (the
reductions for irrecoverable debts) are declared and nothing posts to them; see
`docs/international.md` for why.

## Before this pack is `reviewed`

A reviewer should look at these first:

1. **The chart.** Whether a reference chart that follows §§ 266 and 275 is
   usable by a German bookkeeper who thinks in SKR 03 or SKR 04, and which
   accounts a small GmbH will miss.
2. **The split accounts** — `6820`, `2249`, `6860` and the banks — and
   whether the debit side belongs in B.II.4.
3. **The 2020 rates.** Kennzahlen 35 and 36 for 16 % and 5 % follow the 2026
   guide; the 2020 form itself is not carried.
4. **Kennzahl 21 and 45.** An intra-Community service is `intracom_services`
   and goes to 21; a service to a business outside the Union is `not_subject`
   and goes to 45.
5. **The non-deductible code** `DE-P-19-NA`, written for § 15 Abs. 1a; mixed
   use under § 15 Abs. 4 is a share nobody can put in a pack.
6. **The e-invoicing profile.** `xrechnung` is named; ZUGFeRD in its EN 16931
   profile is equally lawful.

## Corporate income tax: what `corporate_tax.json` leaves out

The section estimates the **Körperschaftsteuer alone**, from the
Jahresüberschuss (item 17 of § 275 Abs. 2 HGB, since the income statement
prints no result before tax), adding back the accounts `9610` to `9620`. Dates
are the earliest year the pack carries, not the day a rule came into force.
Each rule missing below makes an estimate too high or too low.

| Not carried | Why |
|---|---|
| The Solidaritätszuschlag (5,5 % of the tax) and the Gewerbesteuer (the Hebesatz of the municipality) | Taxes of their own (a tax on the tax; a local rate) the section has no shape for. Their accounts are added back; no figure is computed. |
| Rounding of the tax to the euro (KStG § 31 Abs. 1 Satz 2) | The estimate is kept at the cent. |
| The instalments (KStG § 31, EStG § 37: 10 March, 10 June, 10 September and 10 December) | The Finanzamt sets every instalment by notice from the last assessment, so `prepayments` is empty. The minimum of 400 euro a year and 100 euro an instalment (§ 37 Abs. 5) is not expressible either. |
| Deferred taxes, account `9630` | Booked in item 14 with the other taxes on income; no article is cited that removes them from the base, so a company names the account in `tax.adjustments` under `income-taxes`. |
| Dividends and gains on shares, 95 % exempt (KStG § 8b) | Needs the holding thresholds of § 8b Abs. 4 and the conditions of Abs. 1 to 5. |
| A change of the limit on losses after 2027 | The consolidated text of § 10d Abs. 2 EStG carries 70 % with no end date, so the section carries one entry from 2024. The years before (60 %, and other thresholds) are not carried. |
| Loss forfeiture on a change of shareholders (KStG § 8c), the carry-back (EStG § 10d Abs. 1), the interest barrier (EStG § 4h), the group taxation of an Organschaft (KStG §§ 14 ff.) | Nothing here computes them. |
| Business entertainment, gifts, fines, supervisory board remuneration | Fixed rules, but the chart holds restaurant bills with staff entertainment on `8841` and every gift on `8842`, and has no account for fines, so none of them names an account: the company states the amount. |
| Private use of vehicles, non-deductible interest, hidden profit distributions, related-party rules | No flat rule is cited. |
| Tax credits | `credits` is empty: none is cited. |

## Fixed assets: what `fixed_assets.json` leaves out

**What it says.** The first-year charge is prorated in **months**, straight
line and declining balance alike: § 7 Abs. 1 Satz 4 EStG takes away one
twelfth for every full month before the month of acquisition, which counts
whole, and § 7 Abs. 2 Satz 3 applies the same rule to the declining balance.
§ 7 Abs. 3 allows the switch to the straight line (made as soon as it is
larger, which the law permits and does not oblige). Disposal is `net_result`:
§ 275 Abs. 2 HGB has no item for the book value or the proceeds, so the result
is one figure on `8410` (gain, item 4) or `8880` (loss, item 8). The
categories are goodwill (15 years, § 7 Abs. 1 Satz 3 EStG), business buildings
(3 % a year, § 7 Abs. 4 Satz 1 Nr. 1), passenger cars (6 years), lorries (9),
office furniture (13) and computers (3), the last four from the AfA-Tabelle AV.
Every category is a proposal: the accountant sets each asset's duration and
method, and HGB § 253 Abs. 3 bases the commercial life on expected use.

**Declining balance.** § 7 Abs. 2 EStG allows it for movable fixed assets
acquired after 30 June 2025 and before 1 January 2028 only, at a fixed
percentage of the book value of at most three times the straight-line rate
and at most 30 %. The module caps an annuity as a share of the *acquisition
value*, so `declining_cap_percent` is empty and the cap is written into each
declining category's coefficient (1.8 for a six-year car, 3 for office
furniture: 30 % and 23.08 %). The acquisition window is stated in the
category's reference and not enforced: the accountant has to know.

What is **not** in the file:

- **A tax depreciation distinct from the commercial one.** One schedule per
  asset; the Steuerbilanz and the Handelsbilanz often differ (HGB duration
  against AfA-Tabelle, § 6b, special depreciation).
- **Computer hardware and software at one year** (a BMF-Schreiben not among
  the cited texts): the computer category keeps the table's three years, and
  no category is declared for software, which the table does not list.
- **Machines and technical plant** and the BMF's branch tables: the AV table
  has no generic line for them.
- **Geringwertige Wirtschaftsgüter and the Sammelposten** (§ 6 Abs. 2 and
  2a EStG): not a notion of the module; the chart has accounts `1234` and
  `8712`, booked by hand.
- **Buildings other than business ones** (dwellings, § 7 Abs. 4 Nr. 2), the
  other building rates of § 7 Abs. 5 and the special depreciation of the Act,
  the 75 % depreciation of electric vehicles (§ 7 Abs. 2a, a fixed percentage
  table), and the unscheduled depreciation of § 253 Abs. 3 Satz 5 HGB and § 7
  Abs. 1 Satz 7 EStG: the module has no unscheduled, accelerated, special or
  percentage-table depreciation.
- **Components** of a building or a machine, depreciated over their own lives.
- **Accumulated depreciation accounts**, which `create_fixed_asset` asks for:
  the chart is net, and a company adds one to its own chart.
