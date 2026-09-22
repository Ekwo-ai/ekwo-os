# Austria

Everything Austria adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the Kennzahlen of the
Umsatzsteuervoranmeldung (form U30), the balance sheet of § 224 UGB and the
income statement of § 231 UGB, and the sentences the law puts on an invoice.
The format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that an Austrian
Steuerberater reading the pack can disagree with a specific sentence rather
than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, invoice particulars, the return and its deadline | Umsatzsteuergesetz 1994 (UStG 1994) | RIS (ris.bka.gv.at) |
| Books, the balance sheet and the income statement | Unternehmensgesetzbuch (UGB) §§ 189 to 231 | RIS |
| Declaration deadlines, rounding | Bundesabgabenordnung (BAO) §§ 134, 204 | RIS |
| Payment term of a debt with no agreement | Allgemeines bürgerliches Gesetzbuch (ABGB) § 907a, Zahlungsverzugsgesetz 2013 | RIS |
| The Kennzahlen and the instructions for them | Formular U30 2026 and its guide U30a | Bundesministerium für Finanzen (BMF) |
| Where the return, the annual declaration and the recapitulative statement are filed | FinanzOnline | BMF |
| Overview pages confirming rate thresholds, filing cadence, the small-business scheme, e-invoicing to the public sector | Unternehmensserviceportal (USP) | BMF / BMAW |
| E-invoicing to the federal government | erechnung.gv.at | BMF |
| Code lists | EN 16931, UNCL5305, VATEX, EAS | European Commission / OpenPEPPOL |
| The base rate the default interest is added to | Basiszinssatz | Oesterreichische Nationalbank (OeNB) |

**RIS (ris.bka.gv.at) answered every automated request with HTTP 503 while
this pack was written**, so its own paragraphs were read through the BMF and
USP pages that summarise them, and through jusline.at, a private mirror that
republishes the RIS text of a statute verbatim including its `Gesetzesnummer`.
The RIS URLs in `certification.sources` are the citable ones; a reviewer who
opens them directly, in a browser, is the check this pack could not run on
itself.

## The chart of accounts, and why this one

**Austria prescribes no chart of accounts.** UGB § 189 makes companies and
some partnerships subject to the Third Book from a size threshold; § 190
says how the books are kept and says nothing about their accounts. What most
Austrian bookkeeping runs on is the **Einheitskontenrahmen (EKR)**, a
Fachgutachten (KFS/BW6) of the Kammer der Steuerberater und Wirtschaftsprüfer
(KSW). It is the KSW's own document, under its own copyright, and whether a
chart of accounts is protectable at all is a question this repository is not
the place to settle. So this pack does not copy it — neither its class
numbers nor its labels — and nobody should read it as an EKR.

What it does instead is follow the law's own structure. The chart is written
for this pack, four digits, flat, and every leading digit means something in
the UGB:

| First digit | Is |
|---|---|
| `1` | Aktiva A, Anlagevermögen |
| `2` | Aktiva B, Umlaufvermögen |
| `3` | Aktiva C and D, Rechnungsabgrenzung und aktive latente Steuern |
| `4` | Passiva A, Eigenkapital |
| `5` | Passiva B, Rückstellungen |
| `6` | Passiva C, Verbindlichkeiten |
| `7` | Passiva D, Rechnungsabgrenzungsposten |
| `8`, `9` | Items 1 to 21 of § 231 Abs. 2 |

Unlike the German balance sheet this pack's neighbour uses, § 224 UGB carries
**no separate line for the result of the year**: Passiva A has only four
sub-items (Nennkapital, Kapitalrücklagen, Gewinnrücklagen, Bilanzgewinn), and
the last one already is what a year's result becomes once the accounts close.
That is why this pack declares `closing_style: retained_earnings` — the
result goes straight into account `4400`, and there is no
`current_year_result_profit` account to keep apart from it.

Depreciation is booked directly on the asset, so there are no
accumulated-depreciation accounts, the same practice as under the HGB.

## The taxes

Sixteen codes: three positive rates (20 %, 13 %, 10 %), five zero-rated or
exempt sale codes, and eight purchase-side codes, six of them reverse charges
the buyer self-assesses.

**The reverse charge on the Umsatzsteuervoranmeldung (form U30) is coarser
than Germany's.** Where the German USt-Voranmeldung gives every reverse-charge
case its own pair of Kennzahlen, the Austrian U30 does not: `Kennzahl 021`
alone carries the base of every reverse-charged sale a supplier reports — a
service to a business in another Member State (§ 19 Abs. 1 zweiter Satz) and
a construction service to a business itself in construction (§ 19 Abs. 1a)
post to the very same box, because the form does not ask which is which. On
the buyer's side the form goes further and drops the base entirely: `Kennzahl
057` (§ 19 Abs. 1 zweiter Satz) and `Kennzahl 048` (§ 19 Abs. 1a) carry only
the tax owed, with no box for the amount it was computed on — and Austria
does not split a service received from a supplier in another Member State
from one received from a supplier outside the Union the way Germany's § 13b
does: both reverse-charge under the same second sentence of § 19 Abs. 1 and
post to the same two Kennzahlen, `057` and `066`. `AT-P-EUDL-20` and
`AT-P-AUSL-20` are therefore two tax codes that differ only in `treatment`,
`vat_category` and their `legal_reference`, not in what they post to.

The domestic reverse charge modelled is Bauleistungen (§ 19 Abs. 1a), the
construction-sector case every Austrian bookkeeping guide leads with. Two
more domestic reverse charges of the same shape are in the form and not in
this pack — Sicherungseigentum und Grundstücke im Zwangsversteigerungsverfahren
(§ 19 Abs. 1b, Kennzahlen 044/087) and Schrott, Altmetalle, Videospielkonsolen,
Laptops, Tablet-Computer, Gas- und Elektrizitätszertifikate (§ 19 Abs. 1d,
Kennzahlen 032/089) — because no source consulted while writing this pack
gave either the precise scope or a citable text to check it against; a
reviewer who adds either should read § 19 Abs. 1b and 1d directly on RIS
first.

**The 0 % rate for photovoltaic modules that a 2023 reform introduced (§ 28
Abs. 62 and 63 UStG) is not in this pack.** It expired for new contracts on
7 March 2025 and for the remaining transition period on 31 December 2025
(Budgetsanierungsmaßnahmengesetz 2025, BGBl. I Nr. 7/2025); at this pack's
`released_at` a photovoltaic sale is taxed at the standard rate like any
other, so a dedicated zero-rate code would be dead law rather than a current
one. The golden's export line, `AT-S-AUSF`, carries the zero-rate example the
format asks for instead.

**The Kleinunternehmerregelung (§ 6 Abs. 1 Z 27 UStG) is a mention, not a
tax code**, for the same reason as in the German pack: it is a property of
the seller — every invoice of a company under the scheme is exempt — and not
a fact a single document line states. The threshold is 55 000 € of the
preceding year's turnover with a 10 % in-year tolerance, and since 1 January
2025 (Abgabenänderungsgesetz 2024) it extends to a business established in
another Member State whose Union-wide turnover does not exceed 100 000 €.

## The return

`AT-UVA` is form U30 for 2026, Kennzahl by Kennzahl. Kennzahlen `022`, `029`
and `006` carry a taxable amount and its tax on the one printed line, so the
tax is the `:tax` kind of the same box (`022:tax`). `Kennzahl 070` is a total
of the acquisition Kennzahlen the form breaks out by rate; this pack carries
only the 20 % rate of an acquisition, so the total sums one box. `Kennzahl
095` is signed, as the form asks: a surplus (Überschuss) comes out negative.

`Kennzahlen 000` and `001` are declared and nothing posts to them: they are
informational summary lines of the form's own page 1, not a figure this
pack's postings compute independently of the boxes that already carry it.

**The filing deadline is not declared.** Austria's rule — the fifteenth day
of the **second** month after the period ends (UStG § 21 Abs. 1: "bis zum
15. Tag des... zweitfolgenden Kalendermonats") — does not fit any of the
three rules `tax_report.json.deadline` currently offers: `
day_of_month_after_period` reaches only the month immediately after a
period, `last_day_of_month_after_period` the same, and `depends_on_taxpayer`
is for a per-filer schedule, not a fixed span of two months. Writing `day: 15`
under `day_of_month_after_period` would file the return a month early on
every period; that is worse than leaving the field out, so it is left out
and the gap is in [`docs/international.md`](../../docs/international.md)
under Austria.

**The filing cadence is not proposed.** `period` lists `month` and `quarter`
(UStG § 21 Abs. 1 and 2), and `period_default` is left out because the
cadence follows a company's own prior-year turnover (100 000 €) rather than
one answer the law gives everybody — the same reasoning `packs/lu` applies.

## Before this pack is `reviewed`

A reviewer should look at these first:

1. **The RIS text itself**, paragraph by paragraph — this pack was written
   with RIS refusing every automated request, against BMF, USP and jusline.at
   mirrors of it instead of the primary text directly.
2. **The chart.** Whether a reference chart that follows §§ 224 and 231 UGB
   is usable by an Austrian bookkeeper who thinks in EKR classes.
3. **The payment term**, `documents.legal_payment_days: 30` and its ABGB §
   907a / UGB § 456 citation — assembled from secondary sources that
   summarise the Zahlungsverzugsgesetz 2013 rather than from the RIS
   paragraph read directly.
4. **`Kennzahl 021` and the two boxless purchase Kennzahlen `048` and
   `057`** — whether a base with no `box` is the right reading of a form that
   truly asks for no separate figure there, or whether an unpublished
   Ausfüllhilfe note says otherwise.
5. **The Istbesteuerung exception** (§ 17 UStG) — this pack taxes every
   company on delivery or earlier payment (Sollbesteuerung, § 19 Abs. 2);
   the cash-basis exception for the professions of § 22 Z 1 EStG and for
   non-bookkeeping businesses under 110 000 € is not modelled and would need
   its own `cash_basis` tax codes.
6. **The two domestic reverse charges left out** — Sicherungseigentum
   (§ 19 Abs. 1b) and Schrott/Altmetalle/Elektronikgeräte (§ 19 Abs. 1d).
