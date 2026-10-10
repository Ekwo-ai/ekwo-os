# Greece

Everything Greece adds to Ekwo, as data: a chart of accounts built on the
subgroups of the ΕΓΛΣ, the journals, the VAT rates of the Κώδικας ΦΠΑ (Ν.
5144/2024) with where each one posts, the boxes of the periodic VAT return
(Φ2), and the sentences the invoicing rules put on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says which decisions the
content rests on, so that a Greek accountant can disagree with a specific
sentence rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources

Every rate, box and mention carries its own `legal_reference` and the key of
the text it is in. The register in `pack.json` holds the Κώδικας ΦΠΑ (Ν.
5144/2024, which replaced Ν.2859/2000 on 11 October 2024), the AADE circulars
that read it, the official 2025 edition of the Φ2 form, and the laws and decisions
behind electronic invoicing and myDATA. Some AADE pages refuse automated
requests; `pack check gr --links` names the ones that do not answer.

## The chart of accounts

**Greece has no chart of accounts a company is legally bound to number a
particular way, since 1 January 2015.** The Ν.4308/2014 (Ελληνικά Λογιστικά
Πρότυπα, ΕΛΠ), άρθρο 3 and Παράρτημα Γ, fixes what a chart must have, not a
numbering; the Π.Δ. 1123/1980 (the ΕΓΛΣ, eight groups, two-digit subgroups)
stopped applying to periods after 31 December 2014 (ΣΛΟΤ opinion 2334
ΕΞ/13.9.2022). `accounts.csv` uses the ΕΓΛΣ two-digit subgroups anyway, as
the near-universal convention a reviewer already knows. **Only the first two digits of a code are the
ΕΓΛΣ's own**; the two that follow (domestic/EU/third-country splits on
receivables, payables and sales; the split of the VAT control accounts) are
this pack's own analytic convention. Language: the pack is written in Greek
(`defaults.language: el`); no administration publishes an official English
rendering, so the English labels of `i18n/en.json` are a translation for a
reader and never a filing — see `i18n/README.md`.

## The statements

`GR-ELP-BS` and `GR-ELP-IS` carry the **συνοπτικός** (abridged) Ισολογισμός
and Κατάσταση Αποτελεσμάτων of Υποδείγματα Β.5 / Β.6, Παράρτημα Β of
Ν.4308/2014 — the form άρθρο 16 παρ. 7 lets a "πολύ μικρή οντότητα" file
instead of the full Β.1 / Β.2 models, and the one the flat chart maps onto
without inventing splits (fixed assets net in one figure; one "Απαιτήσεις"
line).

Two lines of the official Β.6 do not appear: "Μεταβολές αποθεμάτων" and
"Αγορές εμπορευμάτων και υλικών", because `accounts.csv` does not yet
separate cost of goods sold from the closing inventory — account `2002`
(purchases of the period) reads whole into `GR-ELP-BS:AC-INV`, as stock.
**The statement also stops at "Αποτέλεσμα προ φόρων"**: the chart carries no
income-tax or τέλος επιτηδεύματος expense account yet (only the withheld/
prepaid amount as a liability, `5403`), so "Αποτέλεσμα περιόδου μετά από
φόρους" is not modelled rather than approximated. Both gaps are named on the
lines themselves, in `legal_reference`.

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
prints in), and import VAT deducted at the rate assessed by customs
(`GR-P-IMPORT`).

**A service bought from a supplier abroad is reverse-charged on the
customer.** A software subscription, hosting or an API billed by a taxable
person not established in Greece is supplied where the Greek business is
established (Ν.5144/2024, άρθρο 18 παρ. 2 α)), and the customer is liable for
the tax (άρθρο 40 παρ. 1 στ)), charging and deducting it at once. The Φ2
splits the input side by the supplier's origin, so the pack does too:
`GR-P-ICS-24` (`intracom_acquisition_services`, article 196 of Directive
2006/112/EC) for a supplier established in another Member State, in boxes
303/333 and 365/385; `GR-P-3RD-24` (`foreign_services_received`) for a
supplier established outside the Union, in boxes 303/333 and 366/386 (*λοιπές
πράξεις λήπτη*), with no recapitulative statement. Both post like
`GR-P-ICG-24`: deductible VAT debited to `5401`, VAT owed credited to `5400`.
The chart has no payable account for suppliers abroad, so a foreign supplier
sits on the trade payables with the others.

**The 30 % reduced rate on certain Aegean islands is documented and not
modelled as a tax code.** Ν.5144/2024, άρθρο 26, as amended by Ν.5246/2025 and
read by the AADE circular Ε.2113/31.12.2025, reduces the three rates above by
30 % (so 17 %, 9 %, 4 %) for supplies established on a named list of islands —
currently Lesvos, Kos, Samos, Chios, the rest of the Region of the North
Aegean (Lemnos, Ikaria, Oinousses, Fournoi, Psara, Agios Efstratios),
Samothrace, and the Dodecanese islands with a population at or under 20 000
at the most recent census (Kalymnos, Karpathos, Kasos, Leros, Nisyros, Patmos,
Symi, Tilos, Chalki, Lipsi, Agathonisi, Megisti) — tobacco products and means
of transport excluded even there. The list is drawn island by island, by a
circular, and moves (the Dodecanese and North Aegean islands were added back
from 1 January 2026); no row of `territories` matches it. It is named in
`certification.sources` (`e2113-2025`). The Φ2 form's own island boxes
(304-306, 309) are not declared in `tax_report.json` for the same reason.

## The Φ2 periodic VAT return

`GR-F2` carries the boxes of the 2025 edition of the έντυπο 050 Φ.Π.Α.:
the three positive-rate boxes of Category I outputs (301/331, 302/332,
303/333) and their total (307/337), the exempt/out-of-scope, intra-Community
and export boxes (310, 342, 345, 348) and the turnover total (311), the
domestic, import and intra-Community-acquisition input boxes (361/381,
363/383, 364/384) and their total (367/387), and the two clearance boxes
(480 payable, 470 credit). Not carried: the island rates, the fixed-asset
purchase box (362) and the carry-forward/refund mechanics (401-404, 502-523),
each named in the box `legal_reference`s as not modelled.

**Periodicity has no single default.** Ν.5144/2024, άρθρο 59, ties the
cadence to how a taxpayer keeps its books — monthly for double-entry
bookkeeping and for the first 24 months of any new registration since 1 April
2025, quarterly for single-entry bookkeeping begun before 2024 — so
`period_default` is left undeclared.

**No `deadline` is declared.** The return is due on the last *business* day
of the month that follows the period (Εθνικό Μητρώο Διοικητικών Διαδικασιών
"Μίτος", διαδικασία "Δήλωση ΦΠΑ"). `deadline.rule`'s
`last_day_of_month_after_period` means the last *calendar* day, which can be
a Saturday, a Sunday or a public holiday the true deadline is not.

## Invoices

- **Numbering**: `gapless_per_year` — Ν.4308/2014, άρθρο 8, requires a
  unique, continuous number per series; the annual restart is this pack's
  convention (matching myDATA's yearly series), not a legal requirement.
- **Tax point**: `invoice_if_issued` — due at delivery of goods or completion
  of the service (Ν.5144/2024, άρθρο 21 παρ. 1), displaced to the invoice
  date where the invoice is issued earlier (παρ. 2 περ. α), and to the date
  an advance is collected for the part it covers (παρ. 2 περ. γ, not modelled:
  the core has no prepayment document).
- **Payment terms**: 30 days by default (Ν.4152/2013, υποπαράγραφος Ζ.3),
  ECB refinancing rate plus eight points as the default interest, a flat
  €40 recovery compensation (υποπαράγραφος Ζ.7) (Directive 2011/7/EU).
- **Mentions**: reverse charge, intra-Community supply of goods, intra-
  Community services, export and domestic exemption, each citing its article.
- **`posted_edit_policy`: `reversal_only`.** A document already transmitted
  to myDATA is corrected by a credit note that names it, never withdrawn
  (Απόφαση Α.1138/2020, άρθρο 4).

### E-invoicing and myDATA

**Three obligations sit under this word.** myDATA (Ψηφιακά Βιβλία ΑΑΔΕ,
Απόφαση Α.1138/2020, άρθρο 15Α του Ν.4174/2013) has required, since 2021,
that every business transmit a summary of each invoice to AADE in near real
time — a reporting obligation to the state, which answers no field of
`einvoicing`. Business-to-government electronic invoicing (Ν.4601/2019,
άρθρα 148-154, as amended) is a separate obligation this pack does not carry.

**Business-to-business electronic invoicing is legislated and partly in
force; `einvoicing.profile` is null.** Council Implementing
Decision (EU) 2025/502 lets Greece derogate from articles 218 and 232 of
Directive 2006/112/EC from 1 July 2025; the national law is άρθρο 239 of
Ν.5222/2025 (ΦΕΚ Α' 134/28.07.2025), adding a sixth paragraph to άρθρο 14 of
Ν.4308/2014, and Απόφαση Α.1128/2025 (ΦΕΚ Β' 4937/16.09.2025) sets the
calendar: entities with 2023 turnover above €1,000,000 must issue
exclusively electronically from 2 February 2026 (dual issuance tolerated to
31 March 2026); every other entity, from 1 October 2026 (tolerated to 31
December 2026). The invoice format required is EN 16931, but transmitted
through AADE's own "Τιμολόγιο" application or a certified
πάροχος ηλεκτρονικής τιμολόγησης — a provider model, not confirmed to run
over the Peppol network. No brick of `packages/formats/` produces what either
channel requires, so `profile` and `obligation` are left undeclared (see
`einvoicing.legal_reference`). Re-confirm the phased dates at `aade.gr`.

## What a reviewer should look at first

1. **The chart of accounts is a convention, not a citation** past its first
   two digits.
2. **The statements are the abridged Β.5/Β.6 models**, the account-to-line
   mapping is this pack's own reading, and the income statement stops at
   the pre-tax result.
3. **The 30 % island rate is not modelled** — a company established on one
   of the named islands needs a professional's rates.
4. **`GR-S-ICS`'s box (345)** and **`GR-P-ICG-24`'s shared box (303/333)**
   rest on a secondary copy of the official 2025 Φ2 form; a reviewer should
   confirm the box numbers against the form itself before this pack is
   relied on for a real filing.
5. **No domestic purchase-side reverse charge** is modelled (construction
   subcontracting, precious metals). Reverse-charged services received from
   abroad are (`GR-P-ICS-24`, `GR-P-3RD-24`, boxes 365/385 and 366/386);
   their article numbers (18 παρ. 2 α), 40 παρ. 1 στ)) rest on professional
   summaries of the 2024 code, and the ΦΕΚ itself should be checked.
6. **No `deadline` on the Φ2 return**: deliberate, see above.
7. **The exemption reason code of `GR-S-EXE`** (`VATEX-EU-132`) matches the
   treatment and the article cited; worth a second reading.
