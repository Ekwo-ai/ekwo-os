# Greece

Everything Greece adds to Ekwo, as data: a chart of accounts built on the
subgroups of the ΕΓΛΣ, the journals, the VAT rates of the Κώδικας ΦΠΑ (Ν.
5144/2024) with where each one posts, the boxes of the periodic VAT return
(Φ2), and the sentences the invoicing rules put on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content
came from and which decisions it rests on, so that a Greek accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources

Every rate, box and mention carries its own `legal_reference` and the key of
the text it is in. The register in `pack.json` holds the Κώδικας ΦΠΑ (Ν.
5144/2024, which replaced Ν.2859/2000 on 11 October 2024 — a reference built
against the old code would already be wrong), the AADE circulars that read
it, the official 2025 edition of the Φ2 form, and the laws and decisions
behind electronic invoicing and myDATA. Several AADE pages answer a direct
fetch with a `403` — the URLs are still the correct, citable ones; they were
read through a cached copy, and a maintainer should reopen them by hand
before relying on this pack (`pack check gr --links` names the ones that do
not answer).

## The chart of accounts

**Greece has no chart of accounts a company is legally bound to number a
particular way, since 1 January 2015.** The Ν.4308/2014 (Ελληνικά Λογιστικά
Πρότυπα, ΕΛΠ), άρθρο 3 and Παράρτημα Γ, fixes what a chart must have —
nomenclature, level of analysis, content — and not a numbering: the older
Π.Δ. 1123/1980, which had fixed one (the ΕΓΛΣ, eight groups, two-digit
subgroups), stopped applying to periods after 31 December 2014. An official
opinion of the Συμβούλιο Λογιστικής Τυποποίησης, ΣΛΟΤ 2334 ΕΞ/13.9.2022,
confirms this in as many words: a company may keep the ΕΓΛΣ numbering or any
other that meets Παράρτημα Γ.

`accounts.csv` uses the ΕΓΛΣ two-digit subgroups anyway, because it remains
the near-universal convention of Greek accounting software and of every
textbook — a reviewer already knows what group `54` or `70` means. **Only
the first two digits of a code are the ΕΓΛΣ's own**; the two that follow
(domestic/EU/third-country splits on receivables, payables and sales; the
split of the VAT control accounts) are this pack's own analytic convention
and should be read as such, the way `packs/it` and `packs/de` already say of
their own numbering. Language: the pack is written in Greek
(`defaults.language: el`); no administration publishes an official English
rendering to translate from, so the English labels of `i18n/en.json` are a
translation for a reader and never a filing — see `i18n/README.md`.

## The statements

`GR-ELP-BS` and `GR-ELP-IS` carry the **συνοπτικός** (abridged) Ισολογισμός
and Κατάσταση Αποτελεσμάτων of Υποδείγματα Β.5 / Β.6, Παράρτημα Β of
Ν.4308/2014 — the form άρθρο 16 παρ. 7 lets a "πολύ μικρή οντότητα" file
instead of the full Β.1 / Β.2 models. Two reasons drove that choice over the
full models: it is the format the chart's ΕΓΛΣ subset — a flat list with no
group headers a company posts to — maps onto without inventing a split
`accounts.csv` does not carry (fixed assets net of accumulated depreciation
in one figure, not gross and provision on two lines; one "Απαιτήσεις" line,
not the finer debtor categories of Β.1); and it is what the filed example
this pack's captions and ordering were checked against actually uses (a
real Β.5/Β.6 pair, retrieved and read line by line — see
`certification.sources.n4308-2014`).

Two lines of the official Β.6 do not appear: "Μεταβολές αποθεμάτων" and
"Αγορές εμπορευμάτων και υλικών", because `accounts.csv` does not yet
separate cost of goods sold from the closing inventory — account `2002`
(purchases of the period) reads whole into `GR-ELP-BS:AC-INV`, as stock, the
way it did under the generic framework this version replaces. **The
statement also stops at "Αποτέλεσμα προ φόρων"**: the chart carries no
income-tax or τέλος επιτηδεύματος expense account yet (only the withheld/
prepaid amount as a liability, `5403`), so "Αποτέλεσμα περιόδου μετά από
φόρους" is not modelled rather than approximated — a professional's
computation, not this pack's, until a future version adds the account. Both
gaps are named on the lines themselves, in `legal_reference`.

## Taxes

Three positive rates, Ν.5144/2024, άρθρο 21 and Παράρτημα ΙΙΙ:

| Rate | Name | Applies to |
|---|---|---|
| 24 % | κανονικός | everything Παράρτημα ΙΙΙ does not name |
| 13 % | μειωμένος | food, non-alcoholic drinks, hotel accommodation, among others |
| 6 % | υπερμειωμένος | medicine and vaccines, books, newspapers and periodicals, electricity, natural gas, among others |

Beside them: exports outside the Union (άρθρο 29, `GR-S-EXP`), intra-Community
supplies of goods (άρθρο 33, `GR-S-ICG`), the general B2B rule for services
supplied to a taxable person of another Member State (άρθρο 14 παρ. 2, reverse
charge on the customer, `GR-S-ICS`), a domestic exemption for hospital and
medical care (άρθρο 27 παρ. 1 δ)/ε), `GR-S-EXE`), the mirrored purchase-side
rates (`GR-P-24`, `GR-P-13`, `GR-P-6`), the self-assessed intra-Community
acquisition of goods (`GR-P-ICG-24`, one `base` posting on the two boxes it
prints in, exactly as the Estonian example of `docs/packs.md` shows), and
import VAT deducted at the rate assessed by customs (`GR-P-IMPORT`).

**The 30 % reduced rate on certain Aegean islands is documented and not
modelled as a tax code.** Ν.5144/2024, άρθρο 26, as amended by Ν.5246/2025 and
read by the AADE circular Ε.2113/31.12.2025, reduces the three rates above by
30 % (so 17 %, 9 %, 4 %) for supplies established on a named list of islands —
currently Lesvos, Kos, Samos, Chios, the rest of the Region of the North
Aegean (Lemnos, Ikaria, Oinousses, Fournoi, Psara, Agios Efstratios),
Samothrace, and the Dodecanese islands with a population at or under 20 000
at the most recent census (Kalymnos, Karpathos, Kasos, Leros, Nisyros, Patmos,
Symi, Tilos, Chalki, Lipsi, Agathonisi, Megisti) — tobacco products and means
of transport excluded even there. **This list is a name, not a subdivision**:
unlike Portugal's Azores and Madeira, which are ISO 3166-2 regions the common
system of VAT reaches at a rate the region itself sets, Greece's list is drawn
island by island, by a circular rather than by the law itself, and has moved
sharply in the last decade — most of the larger, touristic islands (Rhodes,
Corfu, Mykonos, Santorini among them) were taken off it in 2015-2017, and the
Dodecanese and North Aegean islands were added back from 1 January 2026. No
row of `territories` matches this list at any useful grain, and building one
that must be re-verified against a ministerial circular every time it moves
is a materially different commitment than Portugal's two stable regions. A
future version may add it once the shape of the framework and this list's
own stability both bear the weight; until then it is a gap, named here, in
`docs/international.md`, and in `certification.sources` (`e2113-2025`). The
Φ2 form's own island boxes (304-306, 309) are not declared in
`tax_report.json` for the same reason.

## The Φ2 periodic VAT return

`GR-F2` carries the boxes of the 2025 edition of the έντυπο 050 Φ.Π.Α.:
the three positive-rate boxes of Category I outputs (301/331, 302/332,
303/333) and their total (307/337), the exempt/out-of-scope, intra-Community
and export boxes (310, 342, 345, 348) and the turnover total (311), the
domestic, import and intra-Community-acquisition input boxes (361/381,
363/383, 364/384) and their total (367/387), and the two clearance boxes
(480 payable, 470 credit). It does not yet carry every box the real form
does — the island rates, the fixed-asset purchase box (362), reverse-charged
services received (365/366) and the carry-forward/refund mechanics
(401-404, 502-523) are all named in the box `legal_reference`s as not
modelled, rather than guessed at.

**Periodicity has no single default.** Ν.5144/2024, άρθρο 59, ties the
cadence to how a taxpayer keeps its books — monthly for double-entry
bookkeeping and for the first 24 months of any new registration since 1 April
2025, quarterly for single-entry bookkeeping begun before 2024 — so
`period_default` is left undeclared, the way `packs/fr` and `packs/lu` leave
it for the same reason.

**No `deadline` is declared.** The return is due on the last *business* day
of the month that follows the period (Εθνικό Μητρώο Διοικητικών Διαδικασιών
"Μίτος", διαδικασία "Δήλωση ΦΠΑ"). `deadline.rule`'s
`last_day_of_month_after_period` means the last *calendar* day, which can be
a Saturday, a Sunday or a public holiday the true deadline is not — the same
one-day risk `packs/it` and `packs/pt` already declined to approximate for
their own second-month and business-day deadlines. See "From Greece" in
`docs/international.md`.

## Invoices

- **Numbering**: `gapless_per_year` — Ν.4308/2014, άρθρο 8, requires a
  unique, continuous number per series; the annual restart is this pack's
  convention, matching the yearly structure myDATA itself gives a
  characterisation series, not a separate legal requirement.
- **Tax point**: `invoice_if_issued` — due at delivery of goods or completion
  of the service (Ν.5144/2024, άρθρο 21 παρ. 1), displaced to the invoice
  date where the invoice is issued earlier (παρ. 2 περ. α), and to the date
  an advance is collected for the part it covers (παρ. 2 περ. γ, not modelled
  by this core, which has no prepayment document — see `docs/international.md`).
- **Payment terms**: 30 days by default (Ν.4152/2013, υποπαράγραφος Ζ.3),
  ECB refinancing rate plus eight points as the default interest, a flat
  €40 recovery compensation (υποπαράγραφος Ζ.7) — the same shape Directive
  2011/7/EU gives every Member State.
- **Mentions**: reverse charge, intra-Community supply of goods, intra-
  Community services, export and domestic exemption, each citing the article
  that requires the sentence.
- **`posted_edit_policy`: `reversal_only`.** A document already transmitted
  to myDATA is corrected by a credit note that names it, never withdrawn
  (Απόφαση Α.1138/2020, άρθρο 4).

### E-invoicing and myDATA

**Three different obligations sit under this one word, and only the first is
this pack's `documents` section.** myDATA (Ψηφιακά Βιβλία ΑΑΔΕ, Απόφαση
Α.1138/2020, άρθρο 15Α του Ν.4174/2013) has required, since 2021, that every
business transmit a summary of each invoice to AADE in near real time — a
reporting obligation to the state, not an exchange of a structured invoice
between the two parties to a sale, so it answers no field of `einvoicing`.
Business-to-government electronic invoicing (Ν.4601/2019, άρθρα 148-154, as
amended) is a separate, older obligation this pack does not carry either,
since `documents`/`einvoicing` describe a company's own sales and purchases.

**Business-to-business electronic invoicing is legislated and partly in
force, and `einvoicing.profile` is still null.** Council Implementing
Decision (EU) 2025/502 lets Greece derogate from articles 218 and 232 of
Directive 2006/112/EC from 1 July 2025; the national law is άρθρο 239 of
Ν.5222/2025 (ΦΕΚ Α' 134/28.07.2025), adding a sixth paragraph to άρθρο 14 of
Ν.4308/2014, and Απόφαση Α.1128/2025 (ΦΕΚ Β' 4937/16.09.2025) sets the
calendar: entities with 2023 turnover above €1,000,000 must issue
exclusively electronically from 2 February 2026 (dual issuance tolerated to
31 March 2026); every other entity, from 1 October 2026 (tolerated to 31
December 2026). The invoice format required is EN 16931, but transmitted
through AADE's own "Τιμολόγιο" application or a certified
πάροχος ηλεκτρονικής τιμολόγησης — a provider model, not Italy's central
clearance stamp, and not confirmed to run over the Peppol network either. No
brick of `packages/formats/` writes, validates or transmits what either
channel requires, so declaring a `profile` would claim otherwise; `obligation`
is left undeclared for the same reason `packs/it` leaves it out for the SdI —
the two named fields (`mandatory_from`, `profile`) cannot be true together
without a profile this pack does not have. The full account is in
`einvoicing.legal_reference` and in "From Greece" of `docs/international.md`.
The phased dates above have already moved once in the run-up to publication
and should be re-confirmed at `aade.gr` before anyone relies on them.

## What a reviewer should look at first

1. **The chart of accounts is a convention, not a citation** past its first
   two digits — see above.
2. **The statements are the abridged Β.5/Β.6 models, not the full ones**,
   and the account-to-line mapping past the ΕΓΛΣ group is this pack's own
   reading — see "The statements" above. The income statement stops at the
   pre-tax result for the same reason the chart carries no income-tax
   expense account.
3. **The 30 % island rate is not modelled**, only documented — a company
   established on one of the named islands needs a professional's rates,
   not this pack's, until a future version adds them.
4. **`GR-S-ICS`'s box (345)** and **`GR-P-ICG-24`'s shared box (303/333)**
   rest on a PDF extraction of the official 2025 Φ2 form read through a
   cached copy rather than a live fetch; a reviewer who can open the form
   directly should confirm the box numbers before this pack is relied on for
   a real filing.
5. **No purchase-side reverse charge besides intra-Community goods** is
   modelled — a domestic reverse charge (construction subcontracting,
   precious metals) or a reverse-charged service received from abroad both
   need their own box wiring a future version should add once confirmed.
6. **No `deadline` on the Φ2 return**: deliberate, see above — not an
   unresearched gap.
7. **The exemption reason code of `GR-S-EXE`** (`VATEX-EU-132`) matches the
   treatment and the article cited; worth a second reading given how many of
   this pack's other choices rest on secondary sources.
