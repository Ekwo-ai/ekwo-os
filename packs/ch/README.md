# Switzerland

Everything Switzerland adds to Ekwo, as data: a chart of accounts written for
Art. 959/959b OR, the journals, the federal VAT (Mehrwertsteuer/MWST) rates
and where each one posts, the boxes of form No. 4470 (MWST-Abrechnung,
effective method), and what the invoicing rules of Art. 26 MWSTG require. The
format is [`docs/packs.md`](../../docs/packs.md); this file records what the
pack deliberately leaves out and why, so that a Swiss Treuhänder or
accountant reading it can disagree with one line rather than with the whole
of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `de`, with a complete `fr`.** The pack's own labels are written
in German, the language this pack's research read the law in most closely.
`i18n/fr.json` is declared and complete — the taxes and the boxes of the
return use the wording ESTV itself publishes on the French specimen of form
No. 4470 and in the French text of the MWSTG, and the chart, the journals and
the two statements are translated for this pack the same way its German
labels are written, since Art. 959/959b OR carries no official French
wording of its own beyond the three lettered items the article itself
names. See `i18n/README.md` for which French term came from which official
page. Italian is not shipped in this version: a `i18n/it.json` declared
incomplete fails `ekwo pack check` outright, and completing the roughly two
hundred labels a declared language commits to — every account, every
journal, every statement line — needs more time than the rest of this pack
took; it is a welcome follow-up contribution, not started at random.

## Sources

Every rate, box and mention carries its own `legal_reference` and names the
entry of `certification.sources` its article is in. The register holds ten
texts. The two loads-bearing ones were read article by article, not
summarised from a secondary page:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, exports, the acquisition tax, the return's deadlines | Mehrwertsteuergesetz (MWSTG) vom 12. Juni 2009, SR 641.20 | Fedlex |
| Payment terms, default interest, minimum accounting/financial-statement structure | Obligationenrecht (OR), SR 220, Art. 75, 104, 957–963b | Fedlex |
| Net tax rate coefficients by branch | Verordnung der ESTV, SR 641.202.62 | ESTV |
| The boxes of the return, their exact wording | Formular Nr. 4470 (Muster, gültig ab 1.1.2024) | ESTV |
| E-invoicing standards and their non-binding status | eCH-0217, eCH-0069, "Verbindlichkeit der eCH-Standards" | Verein eCH |
| The QR-bill and the date it replaced the red/orange payment slips | QR-bill standard page | SIX Group |
| Where the return is filed | Décompter la TVA en ligne (portail AFC) | ESTV |

The MWSTG was read from the Fedlex PDF-A in force on 31 March 2025
(Art. 1–93 read in full — assujettissement, exclusions, exemptions, rates,
invoicing, the acquisition tax, the periods and the deadlines of Titre 5).
The OR was read from the Fedlex PDF-A for Art. 75, 102, 104 and 957–960
(bookkeeping and the minimum structure of the balance sheet and income
statement). Form No. 4470 was read as the specimen PDF itself, box by box —
the numbers, the two rate columns ("dès le 01.01.2024" / "jusqu'au
31.12.2023") and the arithmetic of Ziffer 289, 299, 399, 479, 500 and 510 are
that edition's.

## The chart of accounts, and why this one

**Switzerland prescribes no chart of accounts.** Art. 957a OR requires books
that are complete, faithful and systematic; Art. 959/959a/959b OR fix the
*minimum structure* a balance sheet and an income statement must show, and
nothing more. What most Swiss bookkeeping is taught from is the "Schweizer
Kontenrahmen KMU" (in French, "Plan comptable PME"), a book published by
veb.ch with no legal status of its own — a practice of place, exactly like
DATEV's SKR 03/04 in Germany. This pack does not copy it, neither its numbers
nor its labels: the chart is written for this pack and follows the law's own
structure directly, the same choice `packs/de/` and `packs/gb/` made for the
same reason. A reader coming from the Kontenrahmen KMU will find a similar
shape — because that book also follows Art. 959/959b — and different account
numbers throughout.

Four-digit codes, one range of the first two digits per item of Art. 959
Abs. 5/6 or Art. 959b Abs. 2, so that every account reaches exactly one
statement line by the head of its code:

| Range | Is |
|---|---|
| `1000`–`1099` | Flüssige Mittel und kurzfristig gehaltene Aktiven mit Börsenkurs (Art. 959 Abs. 5 Ziff. 1 Bst. a) |
| `1100`–`1119` | Forderungen aus Lieferungen und Leistungen (Bst. b) |
| `1140`–`1189` | Sonstige kurzfristige Forderungen, einschliesslich der Vorsteuerkonten (Bst. c) |
| `1200`–`1299` | Vorräte (Bst. d) |
| `1300`–`1399` | Aktive Rechnungsabgrenzungen (Bst. e) |
| `1500`–`1699` | Sachanlagen (Abs. 5 Ziff. 2 Bst. c) |
| `1700`–`1799` | Finanzanlagen und Beteiligungen (Bst. a/b) |
| `2000`–`2029` | Verbindlichkeiten aus Lieferungen und Leistungen (Abs. 6 Ziff. 1 Bst. a) |
| `2030`–`2399` | Übrige kurzfristige Verbindlichkeiten, Rückstellungen, passive Rechnungsabgrenzungen (Bst. b–d) |
| `2400`–`2799` | Langfristiges Fremdkapital (Ziff. 2) |
| `2800`–`2899` | Kapital und Reserven (Ziff. 3 Bst. a–c) |
| `2900`–`2999` | Bilanzgewinn/-verlust (Ziff. 3 Bst. d) |
| `3000`–`3099` | Nettoerlöse (Art. 959b Abs. 2 Ziff. 1) |
| `4000`–`4099` | Materialaufwand (Ziff. 3) |
| `5000`–`5999` | Personalaufwand (Ziff. 4) |
| `6000`–`6570`, `8950`–`8969` | Sonstiger betrieblicher Aufwand (Ziff. 5), plus the technical rounding account |
| `6600`–`6699` | Abschreibungen (Ziff. 6) |
| `6900`–`6949` / `6950`–`6999` | Finanzaufwand / Finanzertrag (Ziff. 7) |
| `7900`–`7999` / `7500`–`7899` | Betriebsfremder Aufwand / Ertrag (Ziff. 8) |
| `8900`–`8949` / `8500`–`8899` | Ausserordentlicher Aufwand / Ertrag (Ziff. 9) |
| `8990`–`8999` | Direkte Steuern (Ziff. 10) |

`closing_style` is `retained_earnings`: Art. 959 Abs. 6 Ziff. 3 gives no
separate "current year result" item the way Belgium's appropriation accounts
do, so the result closes straight into `2900`.

## The taxes

Twelve codes, all dated from 1 January 2024 (Verordnung des EFD vom
9. Dezember 2022, in Kraft seit 1.1.2024, following the popular vote of 25
September 2022 on the additional financing of the AHV). Six on the sale side
— the standard rate (8,1 %), the reduced rate (2,6 %), the special rate for
lodging (3,8 %, Art. 25 Abs. 4 MWSTG, itself capped "bis längstens
31. Dezember 2027" by the law's own wording unless Parliament extends the
window of Art. 196 Ziff. 14 Abs. 1 BV — this pack sets no `valid_to` for that
reason and says so on the code itself), an export (Art. 23, zero-rated with
full input deduction — this pack's "taux zéro" case), a supply outside the
scope of the tax (Art. 8/`not_subject`), and an excluded supply with no
option (Art. 21, `exempt`, no input deduction — this pack's "exonération"
case, and the opposite of the export in exactly the way Art. 21 and Art. 23
are opposites in the law itself).

Six on the purchase side: the standard and reduced rates split by
Ziffer 400/405 of the return (operating expense vs. investment — the same
distinction France draws between its ordinary purchase codes and the ones
suffixed `-I`), a non-deductible purchase (`tax_on_base`, Art. 29 Abs. 1, no
box because the form has none for it), the acquisition tax on a service
bought from abroad (Bezugsteuer, Art. 45–49, Ziffer 383 — a genuinely
non-EU mechanic: there is no domestic reverse charge in Swiss VAT law the way
several EU States have one for construction or gold, and the closest EU
counterpart is a cross-border reverse charge for services, not a domestic
one), and an import of goods (Art. 50–54, Ziffer 405 only — the import tax
itself is assessed and paid to the customs authority, BAZG, not declared as
a liability on this return, so the code carries only the recoverable side,
exactly as `packs/gb/` books its own import VAT on the supplier's own
document rather than a separate customs one).

`exemption_code` is null on every tax: Switzerland is outside the common
system of VAT (`territories.eu_vat_scope = 'none'`, added by this pack — see
below), so the VATEX list does not reach it and the article is in
`legal_reference` instead, as [`docs/packs.md`](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason)
prescribes. `vat_category` is filled in anyway, the way `packs/gb/` fills it
in: UNCL5305 is a UN/CEFACT list, not an EU one, and it reads the same
whether or not `einvoicing.profile` asks for it.

## What this pack does not model, and why

**The prior generation of rates (7,7 % / 2,5 % / 3,7 %, in force until
31 December 2023).** Form No. 4470 itself still carries a second column for
them (Ziffer 302/312/342/382), which this pack declares and leaves unposted,
exactly as `packs/de/` leaves Kennzahlen 35/36 unposted for a 2020 rate it
does not carry. The exact day that generation itself began was not
independently verified against a primary text in the time this pack had, so
no tax code claims a `valid_from` for it. A later contribution that reads
that text can add the two codes without touching anything else.

**The option for taxation of an excluded supply (Art. 22 MWSTG, Ziffer
205).** A landlord or a bank may elect to tax a supply Art. 21 would
otherwise exclude, recovering the input tax that comes with it. Nothing in
the core records such an election per line, so the box is declared and
nothing posts to it.

**The reporting procedure for a business transfer (Meldeverfahren, Art. 38
MWSTG, Ziffer 225)** and **margin taxation of collectors' items (Art. 24a,
Ziffer 280)** are declared boxes with the same limitation: neither is a
document this pack's engine has a shape for.

**The cash method of accounting for the whole company (Art. 39 Abs. 2
MWSTG, "Abrechnung nach vereinnahmten Entgelten").** The default this pack
declares — `tax_point: invoice_date` — is the ordinary method of Art. 39
Abs. 1 and Art. 40 Abs. 1 Bst. a (tax point = invoicing). The elective
alternative is a whole-company switch, not a per-tax flag the way France's
`cash_basis` is: a company elects it for every sale at once, on request to
the AFC. Ekwo's `cash_basis` is a property of one tax code, so it cannot
express a company-wide election, and this pack does not attempt to.

**The net tax rate method (Saldosteuersätze, Art. 37 MWSTG).** A taxpayer
under CHF 5'024'000 of turnover and CHF 108'000 of tax may settle by
multiplying gross turnover by a single coefficient the ESTV fixes per branch
(examples verified in the register's ordinance: lawyers 6,2 %, a hairdressing
salon's services 5,3 %, new-car dealers 0,6 %) instead of deducting actual
input tax, filed half-yearly instead of quarterly. This is a second,
mutually exclusive way of computing the same tax the effective method
already covers, not a rate or a box this format is missing — modelling it
would need a company-level election the schema does not carry any more than
the cash method above does. `tax_report.json`'s `period` lists `half_year`
for this reason, with no `period_default`, exactly as `packs/lu/` proposes
none where the cadence follows a fact about the company the law states for
nobody in particular.

**Discounts and rebates on the return (Ziffer 235)** and **the
non-consideration items of Art. 18 Abs. 2 MWSTG (subsidies, tourist taxes,
donations — Ziffer 900/910)** are declared boxes with nothing posted to
them, for the same reason as the three above: none is a fact this pack's
golden scenario exercises, and a box declared unused is a smaller thing to
be wrong about than a posting invented to fill it.

## What the socle cannot say — see `docs/international.md`

Two things this pack could not express are recorded in this pack's own
section of [`docs/international.md`](../../docs/international.md), not
patched here: the 60-day deadline of Art. 71/86 MWSTG, which counts calendar
days from the end of the period rather than naming a day of a following
month, and the QR-bill's structured payment reference, which the banking
formats this pack declares (`pain.001`, `camt.053`) carry the data for but
do not render.

## Before this pack is `reviewed`

1. **The prior rate generation** (7,7 % / 2,5 % / 3,7 %) and its exact start
   date, from a primary text.
2. **The chart**, read by someone who books in the Kontenrahmen KMU daily:
   which accounts a small Swiss GmbH or Einzelfirma will miss.
3. **The Bezugsteuer and import codes**, which are the two most
   Switzerland-specific mechanics in the pack and the ones a reviewer should
   read first against Art. 45–54 MWSTG.
4. **`documents.numbering: "free"`** — confirm that no cantonal or sectoral
   rule imposes a stricter numbering than the federal MWSTG does.
5. **`legal_payment_days: 0`** — confirm this reads Art. 75 OR correctly:
   absent an agreed term, payment is due immediately, which is not the same
   answer the EU's Late Payment Directive gives and does not bind
   Switzerland.
