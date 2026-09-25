# Slovenia

Everything Slovenia adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the boxes of the obračun DDV (form
DDV-O), the balance sheet and income statement of the 65th and 66th articles
of ZGD-1, and the sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a slovenski davčni svetovalec
reading the pack can disagree with a specific sentence rather than with the
whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Pack language.** This pack is written in Slovenian (`defaults.language:
sl`), the language of the statutes it transcribes; `i18n/en.json` carries an
English translation of every label, none of it official — no Slovenian
administration publishes an English rendering of ZDDV-1, of ZGD-1 or of the
DDV-O. There was, in the end, no label of this pack for which Slovenian
terminology was missing, so `languages` names only `en`; had a reference
account or a form label existed only in English, this file would say so
plainly rather than let a silent gap read as an oversight.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, the return, invoice particulars | Zakon o davku na dodano vrednost (ZDDV-1) | PISRS |
| Books, the balance sheet and the income statement | Zakon o gospodarskih družbah (ZGD-1), 65. and 66. člen | PISRS |
| The Priloga I and Priloga IV rate lists, worked case by case | FURS, *Davek na dodano vrednost — Stopnje DDV*, 14th edition, June 2026 | FURS |
| The boxes of the DDV-O and their instructions | Priloga X k Pravilniku o izvajanju ZDDV-1 (obrazec DDV-O and its Navodilo) | Uradni list RS |
| VAT registration threshold, the DDV-O deadline | FURS guidance and the English overview page | FURS |
| Payment term and late-payment interest | Zakon o preprečevanju zamud pri plačilih (ZPreZP-1) | PISRS |
| B2G e-invoicing | Zakon o opravljanju plačilnih storitev za proračunske uporabnike (ZOPSPU-1), UJP | PISRS, UJP |
| B2B e-invoicing | Zakon o izmenjavi elektronskih računov in drugih elektronskih dokumentov (ZIERDED) | Uradni list RS |
| Code lists | EN 16931, UNCL5305, VATEX, EAS | European Commission / OpenPEPPOL |

**PISRS (pisrs.si) answered every automated request with only its page shell
while this pack was written** — it is a client-side application that this
tool could not run — so its articles were read through professional
secondary sources that republish the consolidated text article by article
(zakonodaja.com, racunovodstvo.net, racunovodja.com), cross-checked against
each other, and against primary FURS and Uradni list documents wherever one
could be fetched directly. Two primary documents *were* fetched in full and
read directly for this pack: FURS's own *Stopnje DDV* guidance (a Word
document, 14th edition, June 2026, confirming the three rates and working
through Priloga I and Priloga IV case by case) and the Uradni list's Priloga
X — the DDV-O form and its Navodilo za izpolnjevanje, in the version Uradni
list RS, št. 104/2010 last republished it. The PISRS URLs in
`certification.sources` are the citable, official ones; a reviewer who opens
them in a browser is the check this pack could not run on itself.

## The chart of accounts, and why this one

**Slovenia prescribes no numbered chart of accounts by statute.** ZGD-1, 65.
and 66. člen, prescribe only the *structure* (členitev) of the balance sheet
and of the income statement — section letters and Roman numerals, not account
numbers. In practice, Slovenian bookkeeping runs on the **Enotni kontni
okvir**, adopted by the strokovni svet of the Slovenski inštitut za revizijo
(SIR) as an annex to the Slovenski računovodski standardi (SRS). It is the
SIR's own document: si-revizija.si publishes it under an explicit copyright
notice restricting use to personal, non-commercial purposes and forbidding
any commercial copying or redistribution. So this pack does not copy it —
neither its class numbers nor its account labels — and nobody should read it
as the Enotni kontni okvir.

What it does instead is follow the law's own structure, exactly as
`packs/at` does against the EKR it could not copy either. The chart is
written for this pack, four digits, flat, and every leading digit means one
section of ZGD-1's own balance sheet or income statement:

| First digit | Is |
|---|---|
| `1` | A. Dolgoročna sredstva (65. člen) |
| `2` | B. Kratkoročna sredstva |
| `3` | C. Kratkoročne aktivne časovne razmejitve |
| `4` | A. Kapital (stran obveznosti do virov sredstev) |
| `5` | B. Rezervacije in dolgoročne pasivne časovne razmejitve |
| `6` | C. Dolgoročne obveznosti |
| `7` | Č. Kratkoročne obveznosti, and D. Kratkoročne pasivne časovne razmejitve |
| `8`, `9` | Items 1 to 19 of the izkaz poslovnega izida (66. člen, drugi odstavek) |

`closing_style: result_accounts` follows directly from 65. člen: unlike
Austria's UGB, which has no separate line for the year's result, ZGD-1's
equity section keeps **VI. Preneseni čisti poslovni izid** (retained earnings
carried forward, account `4300`) apart from **VII. Čisti poslovni izid
poslovnega leta** (the current year's result, account `4400`) — the shape
`result_accounts` is named for, a result account that sits on the balance
sheet until the shareholders' meeting allocates it, rather than one that
closes straight into retained earnings.

The income statement follows 66. člen's second paragraph (`različica I`), the
version most double-entry bookkeeping runs on; the third paragraph's
cost-of-sales variant is not modelled, the same choice Italy's pack makes for
its own civil code.

## The taxes

Fourteen codes: three positive rates (22 %, 9.5 %, 5 %), four zero-rated or
exempt sale codes, and seven purchase-side codes, four of them
self-assessments the buyer carries.

**Slovenia's own form bundles several rates and several mechanisms into one
box, and the postings follow that rather than fight it.** Box `11` (Dobave
blaga in storitev) is not "domestic sales at the standard rate": the DDV-O's
own Navodilo, read directly from Priloga X, lists exempt export deliveries
among the amounts a filer writes into box 11, alongside every domestically
taxed rate — so `SI-S-22`, `SI-S-9_5`, `SI-S-5` and `SI-S-EXP` all carry a
`base` posting to box `11`, and the box is one combined bucket rather than
one box per rate the way `packs/at` and `packs/it` do it. The same pattern
repeats on the deduction side: box `41` (odbitek DDV po splošni stopnji)
bundles domestic purchases, intra-EU acquisitions of goods, services received
from the EU, services received from a third country and 76.a-člen domestic
reverse-charge purchases — all at 22 % — into one figure, exactly as its own
Navodilo says. A reviewer used to a form with one box per rate should read
the Navodilo text quoted in each box's `legal_reference` before assuming a
mistake.

**Box `22a` (the 5 % rate) is the one part of the box structure this pack
could not verify against a machine-readable primary source.** The DDV-O's own
Priloga X was only fetched in the version Uradni list RS republished in
2010 — before the general rate rose from 20 % to 22 % (2013) and before the
9.5 % rate and the 5 % rate replaced the old 8.5 % rate and were added
(2020) — so its box numbers for `21` and `22` are certain (the rates written
beside them in this pack are not the ones the 2010 text shows, and each
box's own `legal_reference` says so) but box `22a` does not appear in that
text at all. Its existence and number come from professional secondary
sources (accounting portals discussing the 2020 form update) rather than
from a form or a PDF this pack's author opened directly. **A reviewer with
access to the current DDV-O on eDavki should confirm box `22a` before this
pack moves past `community`.**

**The domestic reverse charge modelled is construction under 76.a člen,
točka a)** — the case every Slovenian bookkeeping guide leads with, and the
one `packs/at` and `packs/de` also lead with for their own construction
reverse charge. Other operations 76.a člen and its Priloga IIIa cover (waste,
scrap and recovered materials, among others) are not modelled: no source
consulted while writing this pack gave the full, current Priloga IIIa list
with enough confidence to write a second tax code against it.

**The exemption modelled is renting immovable property (44. člen).** The
precise točka number of 44. člen this pack cites was not pinned down to the
same standard as the rest of the article: secondary sources agree the
article exempts insurance, lending and the renting of immovable property
(with the exceptions the Directive itself carries — hotel-type
accommodation, garages and permanently installed equipment), but none of the
sources this pack could read gave the exact sub-point number renting sits
under. `legal_reference` says so; a reviewer with the PISRS text open should
add the točka.

**The small-business threshold (94. člen) is 60 000 EUR**, with a 66 000 EUR
tolerance before registration becomes mandatory — raised from 50 000 EUR by
ZDDV-1O (Uradni list RS, št. 104/24), in force since 1 January 2025. It is
written on `documents.mentions` and is not a tax code: like the German and
Austrian Kleinunternehmerregelung, it is a property of the seller and not a
fact one document line states.

**A cash-accounting scheme (posebna ureditev po plačani realizaciji, 131. to
134. člen) exists for taxpayers under 400 000 EUR of taxable turnover**, but
is optional and not modelled: no `cash_basis` tax is declared, the same
restraint `packs/at` shows toward its own Istbesteuerung.

## The return

`SI-DDV-O` is the obrazec DDV-O, box by box, read from Priloga X's own
Navodilo za izpolnjevanje. `period` lists `month` and `quarter` (89. člen:
quarterly by default under 210 000 EUR of the previous year's turnover,
monthly above it or as soon as an intra-Community recapitulative statement is
due); `period_default` is left out because the cadence follows the
taxpayer's own turnover rather than one answer the law gives everybody — the
same reasoning `packs/at` and `packs/lu` apply to their own turnover-linked
cadences.

**The deadline is the last business day of the month following the period**
(88. člen ZDDV-1), confirmed directly on FURS's English overview page: *"A
taxable person shall submit a tax return to the tax authority by the last
business day of the month following the expiration of the tax period."*

Boxes `51` (Obveznost DDV) and `52` (Presežek DDV) are the two signed halves
of one figure, exactly as the Navodilo describes them: `51` is what is owed
when calculated VAT (boxes 21 to 26) exceeds deductible VAT (boxes 41 to
43), `52` the other way round. This pack's own golden year ends in a credit
(box `52`), which a floor at zero on both boxes reproduces without either
one going negative.

## Before this pack is `reviewed`

A reviewer should look at these first:

1. **The PISRS text itself**, article by article — this pack was written
   with PISRS serving no readable text to automated tools, against
   professional secondary sources and against the two primary documents this
   README names, rather than against the primary statute directly throughout.
2. **Box `22a` of the DDV-O**, on the current eDavki form — see above.
3. **The exact točka of 44. člen** under which renting immovable property is
   exempt.
4. **The chart.** Whether a reference chart that follows 65. and 66. člen of
   ZGD-1 is usable by a Slovenian bookkeeper who thinks in Enotni kontni
   okvir classes.
5. **ZPreZP-1's interest-rate mechanism** (13. člen) — this pack states the
   40 EUR flat recovery fee (14. člen) and the 30-day default payment term
   (12. člen) with more confidence than the exact statutory cross-reference
   for the default interest rate itself, which secondary sources describe
   as the ECB reference rate plus a margin without this pack's author
   reading the rate-setting article directly.
6. **Priloga IIIa's full list** for 76.a člen, beyond construction.
