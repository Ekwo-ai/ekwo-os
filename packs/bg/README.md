# Bulgaria

Everything Bulgaria adds to Ekwo, as data: a chart of accounts built on the
layout the official balance sheet and income statement schemes prescribe, the
journals, the VAT rates and where each one posts, the boxes of the monthly
справка-декларация по ЗДДС, the balance sheet and the income statement of
Национален счетоводен стандарт 1, and the sentences the law puts on an
invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file says
which decisions the content rests on, so that a Bulgarian счетоводител or
данъчен консултант can disagree with a specific sentence rather than with
the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `bg`.** The pack's own labels are written in Bulgarian, which is
also the language of every text in the register below; no second language
file is declared.

## The currency is EUR, not BGN

Bulgaria joined the euro area on 1 January 2026, and the euro became the sole
legal tender on 1 February 2026, after a one-month dual-circulation period
with the lev — European Central Bank press releases of 8 July 2025 and
1 January 2026 (register keys `ecb-bg-euro` and the Council of the EU
statement it links). The fixed, irrevocable conversion rate is
1 EUR = 1.95583 BGN. Every figure a Bulgarian company books and declares —
including the VAT registration threshold in art. 96 ЗДДС, 51 130 EUR — is in
euro, so this pack declares `"currency": "EUR"` and not BGN.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds ten texts.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, registration threshold, deduction, declaration, invoicing | Закон за данък върху добавената стойност (ЗДДС), consolidated to ДВ бр. 115/2025 | damtn.government.bg, republishing a Ciela-maintained consolidated text |
| Rates and registration threshold, summarised | НАП — ДДС в България | nra.bg |
| Filing service and deadline | НАП — Справка-декларация по ЗДДС | nra.bg |
| The declaration form's boxes | Приложение № 13 към чл. 116, ал. 1 ППЗДДС (a blank template mirroring the pre-2022 form, rates corrected in this pack) | tera-bg.com, a Ciela-branded blank |
| Balance sheet and income statement layout | Национален счетоводен стандарт 1 — Представяне на финансови отчети, Приложения № 1—3 | kik-info.com, reproducing the standard |
| No national chart of accounts | Закон за счетоводството, чл. 16, ал. 1 | registryagency.bg |
| Late-payment interest | Постановление № 347 от 29 декември 2025 г. на Министерския съвет | dv.parliament.bg |
| The euro changeover | European Central Bank press releases | ecb.europa.eu |
| Invoice categories and exemption codes | EN 16931, UNCL5305, VATEX | European Commission (docs.peppol.eu) |

Two entries are not the primary government text. The declaration form's box
list rests on a blank template from a private site; it still prints the
reduced rate at its pre-2022 value of 7 %, and this pack corrects every box
that carries it to the 9 % now in force and says so at the box. Национален
счетоводен стандарт 1 rests on kik-info.com's transcription. Both should be
checked against the official texts — see [What only an accountant should
settle](#what-only-an-accountant-should-settle-before-this-pack-is-reviewed).

## The chart of accounts, and why this one

**Bulgaria prescribes no national chart of accounts.** Закон за
счетоводството, чл. 16, ал. 1 leaves the individual chart
(„индивидуален сметкоплан") to each undertaking's own management; the
historical „Национален сметкоплан" of 1998 is still widely taught and used as
a reference in practice, but it is not a rule, and this pack does not
reproduce it.

It follows the structure of Национален счетоводен стандарт 1 instead: a
four-digit chart, written for this pack, whose first digit points at the
section of the balance sheet or of the income statement (Приложения № 1 and
№ 2 of the standard) the account belongs to:
`1` Нетекущи активи (Раздел Б, актив), `2` Текущи активи (Раздел В, актив, and
Раздел Г — deferred expenses), `3` Записан, невнесен капитал (Раздел А,
актив), `4` Собствен капитал (Раздел А, пасив), `5` Провизии и сходни
задължения (Раздел Б, пасив), `6` Задължения, incl. financing and deferred
income (Раздел В and Г, пасив), `8` Разходи (Приложение № 2, Раздел А), `9`
Приходи (Приложение № 2, Раздел Б).

**The income statement is by nature** (Приложение № 2); Приложение № 3, by
function, is not modelled.

**Depreciation is booked directly against the gross value** of the fixed
asset, with no separate accumulated-depreciation account.

**Receivables and payables by counterparty nature** (from group undertakings,
from associated and mixed undertakings) are kept as separate accounts
(`2220`/`2225`, `6600`/`6650`), because Приложение № 1 lists them as distinct
lines; the maturity split (до/над 1 година) of each liability line of
Раздел В is folded into one account per nature.

## The taxes

Eleven codes. The standard rate is 20 % (чл. 66, ал. 1 ЗДДС, in force since
1 July 2022) and the reduced rate is 9 % (чл. 66а, ал. 1 ЗДДС, same date,
т. 1 raised from 8 % to 9 % on 1 January 2023) — this pack models only the
hotel-accommodation case of т. 1; books and press (т. 2) and baby products
under приложение № 4 (т. 3) are not modelled. **The reduced rate no longer
covers restaurant and catering services, nor bread and flour**: both reverted
to the standard rate on 1 January 2025 when § 15г, ал. 3 of the transitional
provisions expired and was not renewed. This rests on general economic press
(segabg.com); the official text should be checked.

The zero rate covers intra-Community supply of goods (`BG-S-VOD`, чл. 53,
ал. 1) and export outside the Union (`BG-S-EXPORT`, чл. 28); a domestic
exemption is illustrated by the letting of a dwelling to a natural person who
is not a trader (`BG-S-EXEMPT-NAEM`, чл. 45, ал. 4). Services under the
general B2B rule to a taxable person established in another Member State
(чл. 21, ал. 2) are declared in box 17, outside the common declaration total.

On the purchase side, two codes cover the self-assessment mechanisms the law
carries today: intra-Community acquisition of goods (`BG-P-VOP-20`, чл. 84)
and a service received under the general rule from a supplier established in
another Member State (`BG-P-USLUGI-ES-20`, чл. 82, ал. 2, т. 3). Each posts its
base once, repeated in the box of the tax due and in the box of the
deductible credit (see [`docs/packs.md`](../../docs/packs.md)). `BG-P-EXEMPT`
illustrates a purchase with no credit right (an insurance premium, чл. 47).

## The declaration

`BG-VAT-SD` transcribes the „Справка-декларация за ДДС" — Приложение № 13 към
чл. 116, ал. 1 ППЗДДС — filed for a single, non-optional monthly period
(чл. 87, ал. 1 ЗДДС: „данъчният период по този закон е едномесечен"), by the
14th of the following month inclusive (чл. 125, ал. 5 ЗДДС), together with the
purchase and sale ledgers (дневник за покупките, дневник за продажбите). The
box numbers and the formulas that combine them (box 01 = sum of boxes 11
through 16, box 20 = sum of boxes 21 through 24, box 50/60 = box 20 − box 40,
floored at zero on each side) are read straight off the form.

## What the socle cannot do

**Box 40's exact formula.** The form computes total deductible tax as
„кл. 41 + кл. 42 × кл. 33 + кл. 43" — box 42 (VAT with a *partial* credit
right) multiplied by the pro-rata coefficient of box 33 (чл. 73, ал. 5 ЗДДС),
plus boxes 41 and 43. `tax_report.json` boxes cannot express a product of two
boxes inside a larger sum, so this pack declares box 40 as `41 + 42 + 43`,
which is the official formula for a company with no partly deductible input
tax, as in the golden scenario. A company that does partially deduct would
see box 40 overstate its credit by `42 × (1 − коефициент)` (see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)).

**SAF-T (e-reporting) is not e-invoicing, and neither is modelled.** НАП's
SAF-T project page (register key `nra-dds`, section on „Система за
счетоводно отчитане") states a schema version (XSD v1.0.2) in force from
1 April 2026 under § 17 of the additional provisions of ДОПК, for the largest
taxpayers first; the turnover thresholds and rollout schedule are reported
only by tax-advisory firms and are not transcribed here. SAF-T is a periodic
bookkeeping-data extract, not a structured invoice exchanged between trading
partners, which is what the `einvoicing` section describes.

**No general e-invoicing obligation exists today.** A Ministry of Finance
draft bill put out for public consultation on 23 September 2026 would make
structured e-invoicing between Bulgarian businesses mandatory only from
1 January 2028, with sanctions from 1 July 2028; it is not yet a law.
`einvoicing.obligation` is therefore declared `none`.

**Not modelled, for lack of a case in the scenario or of a reasonable scope
for a `community` pack:** partial input-tax deduction (чл. 73, ал. 5 —
coefficient and box 42/33/40 interaction, see above); the annual correction
of чл. 73, ал. 8 and чл. 147, ал. 3 (box 43); domestic reverse charge on a
supply by a non-established supplier (чл. 82, ал. 2, т. 1—2); import of goods
and the customs-document mechanism; the margin scheme for travel agents and
second-hand goods; investment gold; the simplified triangular transaction; the
cash-basis regime for small taxable persons; bad-debt relief; corporate income
tax, outside the scope of a pack that covers only VAT and bookkeeping.

## What only an accountant should settle before this pack is reviewed

A reviewer should look first at:

1. **The declaration form's exact box list.** Transcribed from a private,
   Ciela-branded blank template with the reduced rate corrected from 7 % to
   9 %; nobody has read it against the NRA's own current file. A wrong box
   number here would pass every test in this repository and still be wrong.
2. **The balance sheet and income statement layout.** Read from
   kik-info.com's transcription of Национален счетоводен стандарт 1, not from
   minfin.bg or registryagency.bg directly.
3. **Chapter Four's boundaries beyond the two examples modelled** (residential
   letting, insurance): a reviewer should check the other articles of
   чл. 38—50 before a company relies on this pack for an exemption it does
   not yet carry a code for.
4. **The reduced-rate history.** That the 9 % catering and 0 % bread/flour
   provisions lapsed on 1 January 2025 is reported here from general economic
   press, not from the official text of § 15г of the transitional provisions
   or of Държавен вестник бр. 42/2024.
5. **Invoice numbering.** чл. 114, ал. 1, т. 2 ЗДДС requires a sequential,
   digits-only number based on one or more series; this pack reads that as
   `gapless` with a `{CODE}` series prefix per journal — needed so that the
   socle's own entry numbering, which reuses this pattern across every
   journal of a company and not only the sales journal, does not collide
   between journals. Whether ППЗДДС's further ten-digit, no-duplicate rule
   (reported only by secondary sources here) changes that reading is worth a
   second opinion.
