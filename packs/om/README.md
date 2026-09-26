# Oman

Everything Oman adds to Ekwo, as data: a chart of accounts, the journals,
the 5% value added tax with its zero-rated exports, basic food, medicines
and investment metals, its list of seven exempt activities, a quarterly
return built box for box from the Tax Authority's own return-filing guide,
the statement of financial position and the income statement of full IFRS
Accounting Standards, and what the Law puts on a tax invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content
came from and which decisions it rests on.

**Status: `community`.** Nobody who files an Omani VAT return has reviewed
it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**Language.** `defaults.language` is `ar`, the language the Value Added Tax
Law's Executive Regulations and the Tax Authority's own portal are written
in first. This pack's research did not extend to verified Arabic accounting
terminology, so every label — the chart, the journals, the taxes, the boxes
of the return, the statement lines — is written in English directly, with
`en.json` an exact mirror rather than a second language. See
[`i18n/README.md`](i18n/README.md) for why, and for what a reviewer fluent
in Omani Arabic should do about it.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds eight texts, every one of them opened on 26 September
2026. The four the rest of this file leans on most:

| What | Text | Where |
|---|---|---|
| The rate, zero-rating, exemptions, registration, tax invoices, the tax point | Value Added Tax Law, Royal Decree No. 121/2020 (Tax Authority's own English translation) | `tms.taxoman.gov.om` |
| Detail behind those articles — invoice content, blocked input tax, the reverse charge | Executive Regulations, Decision No. 53/2021, as amended (Arabic official text; this pack's research found no Tax Authority English translation of the Regulations, unlike the Law itself) | `tms.taxoman.gov.om` |
| The mandatory and voluntary registration thresholds | Chairman's Decision Determining the Mandatory and Voluntary Registration Thresholds | `tms.taxoman.gov.om` |
| The live boxes of the quarterly return | VAT Taxpayer Guide — VAT Return Filing, Version 1, June 2021, whose own screenshot of "Content of VAT return" this pack's `tax_report.json` transcribes box for box | `tms.taxoman.gov.om` |

**This pack leans on a secondary reading for one framework fact: that full
IFRS, not the IFRS for SMEs Standard, is what an Omani company not trading
publicly actually prepares under.** The IFRS Foundation's own Jurisdictional
Profile for Oman states it in as many words ("For those SMEs that are not
required to use the IFRS for SMEs Accounting Standard, what other
accounting framework do they use? Full IFRS Standards"), but the three
Omani texts the Profile cites — Article 282 of the Executive Regulation of
the Capital Market Law, Article 30 of the Law of Organising the Accountancy
and Auditing Profession, and Article 79 of the Income Tax Law with Article
61 of its own Executive Regulations — this pack's research could not open
at a directly-fetchable primary source in this pass. See "The statements"
below.

## The chart of accounts, and why this one

**This pack's research found no chart of accounts an Omani company is
legally required to use.** Neither the Tax Authority nor the Capital Market
Authority publishes one.

- **Four digits, by class**, the same shape as `packs/ae` and `packs/sa`:
  `1` assets, `2` liabilities, `3` equity, `4` revenue and other income, `5`
  cost of sales, `6` other expenses, `7` finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges `statements.json`
  reads.
- **The accounts an Omani company actually keeps**: VAT input and output
  tax, the amount payable to and refundable by the Tax Authority, import
  VAT self-assessed under the postponed-accounting Article 86 of the Law
  permits, income tax under the Income Tax Law (Royal Decree 28/2009,
  standard rate 15%, outside this VAT-focused pack's own research), and an
  end-of-service benefits provision every Omani employer owes under the
  Labour Law — this research pass did not trace the provision to a
  specific article and a reviewer should check that citation.

113 accounts, all postable. None was copied from a published chart.

## Taxes

**One standard rate, 5%, since 16 April 2021** (Value Added Tax Law,
Article 36 — the Law itself commenced 180 days after its 18 October 2020
publication, under its own Article Four).

**What a sale can be:**

| | Code | Box |
|---|---|---|
| Standard-rated | `OM-S-SR` | 1a, tax in 1a2 |
| Export of goods or services, Article 52–53 | `OM-S-ZR-EXPORT` | 3a |
| Zero-rated: specified food, medicines and medical equipment, investment gold/silver/platinum, international and intra-GCC transport, Article 51(1)–(5) | `OM-S-ZR-FOOD`, `OM-S-ZR-MED`, `OM-S-ZR-METAL`, `OM-S-ZR-TRANSPORT` | 1b |
| Exempt: financial services, healthcare, education, undeveloped land, resale of a residential property, local passenger transport, residential rental, Article 47(1)–(7) | `OM-S-EX-FIN`, `OM-S-EX-HEALTH`, `OM-S-EX-EDU`, `OM-S-EX-LAND`, `OM-S-EX-RESI`, `OM-S-EX-TRANSPORT`, `OM-S-EX-RENT` | 1c |
| Out of scope, place of supply outside the Sultanate | `OM-S-OS` | none |

**What a purchase can be:**

| | Code | Box |
|---|---|---|
| Standard-rated, fully deductible | `OM-P-SR` | 6a, tax in 6a2 |
| Entertainment or a motor vehicle available for personal use, input tax blocked | `OM-P-BL-ENT`, `OM-P-BL-CAR` | none — lands on the cost of the line |
| Zero-rated | `OM-P-ZR` | 6a |
| Exempt | `OM-P-EX` | none |
| From a supplier not registered for VAT | `OM-P-NR` | none |
| Import of goods, VAT payment postponed under Article 86 | `OM-P-IMP` | 4a/4a2, recoverable in 6b2 |
| Imported services, reverse charge, Article 12(2) and 20(2) | `OM-P-RC-SVC` | 2b/2b2, recoverable folded into 6a2 |

**Article 47's seven exemptions are the whole exempt list — there is no
reduced rate.** A supply not on that list and not zero-rated under Article
51–53 is standard-rated; this pack invents no further exemption.

**The blocked-input-tax codes carry a citation gap.** Secondary compliance
guidance describes input tax on entertainment and on a personal-use motor
vehicle as blocked from deduction, matching the restriction `packs/ae`
Article 53(1) and `packs/sa` Article 50 of their own Executive Regulations
carry, but this pack's research could not open the equivalent article number
of Oman's own Executive Regulations at a directly-fetchable text. A
reviewer with access to Decision No. 53/2021 should locate and cite it.

**An import of goods models only the postponed-accounting path.** Article
86 lets a taxable person defer the import VAT to the return of the period
the goods entered the Sultanate — the mechanism `OM-P-IMP` posts, into boxes
4a and 6b2. An import whose VAT is paid directly to Customs at the border is
a different figure the return's own box 4(b) asks for and this pack does
not drive; see "What this pack does not carry".

**Every base is a value without VAT**, as boxes 1a, 1b, 1c, 2b, 3a, 4a and
6a ask.

## The return

`tax_report.json` files quarterly, with no other cadence: the VAT Taxpayer
Guide states the Tax Period for VAT as "three months i.e., a quarter of a
year", and this pack's research found no text assigning any Omani taxpayer
a shorter period the way the Federal Tax Authority does for larger UAE
taxpayers (`packs/ae`).

**The deadline is 30 days after the end of the quarter, for filing and for
payment alike.** Value Added Tax Law, Article 72 (filing) and Article 82
(payment).

**Boxes 1(d), 1(e) and 2(a) exist on the live return and are undriven.**
The Guide's own text against each reads "Not activated until GCC rules
apply": the intra-GCC electronic verification the Common VAT Agreement
conditions these boxes on is not yet in force between the Sultanate and
another Implementing State. No tax code of this pack posts to them, and
they stay at zero in the golden scenario — a fact about the GCC framework,
not a gap this pack invented.

**No floor at zero.** Article 38 entitles the Taxable Person to a refund,
or to carry the excess forward, where Input Tax exceeds Output Tax for a
period; box 7(c) is signed accordingly.

## The statements

`statements.json` carries the statement of financial position and the
income statement built on the minimum line items of **IAS 1** — not the
IFRS for SMEs Accounting Standard `packs/ae` and `packs/sa` use for the
same GCC mechanics — because the IFRS Foundation's own Jurisdictional
Profile for Oman records that the Sultanate has not adopted that Standard
and that every company outside it prepares under full IFRS. See "Sources"
for the citation gap behind that reading.

**VAT is a receivable and a payable, not current tax.** Current tax is
income tax under the Income Tax Law, outside this VAT-focused pack's
research; the accounts (`1350`, `2130`, `8000`) exist for a company to book
the charge by hand.

**No fact keys.** Nothing checked here says which taxonomy, if any, an
Omani filing uses, so `xbrl` and `taxonomy` are null throughout.

## Closing the year

`fiscal_year_default` is `calendar`, a proposal and nothing more: this
pack's research found no statute fixing an Omani company's financial year
end. `closing_style` is `retained_earnings`: the chart carries no
current-year result account.

## On the invoice

**Numbering is `sequential`.** Executive Regulations, Article 144(3) — a
Tax Invoice carries the sequential number of the invoice, a running,
identifying number and not, in the text this pack's research could open, an
explicit no-gap rule.

**No default payment term and no late-payment interest** are declared:
this research pass found no Omani statute setting either between
businesses absent an agreement, and did not look long enough to say there
is none.

**One invoice mention: the reverse charge, Article 151 of the Executive
Regulations.** The customer liable for the tax must record its value in
Omani Rial on the invoice issued in the non-resident supplier's favour; this
research pass found no article requiring a specific printed sentence,
unlike the Saudi Implementing Regulations `packs/sa` cites for the same
case, so the wording in `pack.json`'s `documents.mentions` is this pack's
own, addressed to whoever reads the invoice.

**The tax point is an approximation of a three-way rule.** Article 26: tax
is due on the earliest of the date of supply, the date of the tax invoice,
or the date of payment — three triggers, where the closed vocabulary of
`tax_point` has room for two. `earliest_of_delivery_or_payment` is the
nearest value and what the rule reduces to whenever no invoice is issued
ahead of delivery or payment, the same gap `packs/ae` and `packs/sa` record
for the same three-way wording in the Common VAT Agreement and Federal
Decree-Law No. 8 of 2017.

## Electronic invoicing

**No statute obliges an Omani taxable person to exchange electronic
invoices at `released_at`.** The Tax Authority's own Fawtara FAQ, updated
30 June 2026, answers "Are there released or upcoming regulations for
e-invoicing compliance?" with "Regulation for e-invoicing will be released
in due time." `pack.json`'s `einvoicing.obligation` is therefore `none`,
and the other three fields stay null.

**What exists is a project, not yet a law.** The Tax Authority became an
OpenPeppol Authority and published the PINT OM technical specification in
2026, a five-corner Peppol model with an accredited Service Provider
validating and exchanging the invoice and reporting tax data to the
Authority. The FAQ's own words are narrower than the four-phase calendar
this pack's research found repeated on unofficial tax-technology sites:
"The first rollout is in August 2026. Subsequent rollouts will follow
according to the timeline that will be prescribed in the legislation." That
first rollout is a named, individually-notified group of about 100 large
taxpayers, checked one VATIN at a time — not a rule reaching every
registrant, and not a date this pack invents an `obligation: mandatory`
around.

**No brick of `packages/formats` writes PINT OM** or talks to an Accredited
Service Provider, so the four fields would describe a capability this pack
does not have even for a taxpayer already onboarded. The Peppol participant
identifier scheme list carries one Omani entry, ICD `0248`, "Oman Value
Added Tax Identification Number (VATIN)" — named in
`pack.json`'s `einvoicing.legal_reference` and not in `party_scheme` or
`vat_scheme`, because nothing yet obliges its use.

## What this pack does not carry

- **The article number of the blocked-input-tax rule** for entertainment
  and personal-use motor vehicles — see "Taxes".
- **An import of goods paid directly at Customs**, box 4(b) of the return —
  see "Taxes" and "The return".
- **The GCC intra-supply reverse charge**, boxes 1(d), 1(e) and 2(a) — not
  yet in force between the Sultanate and another Implementing State; see
  "The return".
- **The profit margin scheme for used goods**, Article 39 of the Law and
  boxes 1(f)/1(f2) of the return, which the Regulations refer to a
  mechanism this pack does not model.
- **Income tax**, named only where the balance sheet needs an account for
  it (`1350`, `2130`, `8000`).
- **The registration threshold as a rule the core enforces.** OMR 38,500
  mandatory, OMR 19,250 voluntary — the Chairman's Decision this pack cites
  in `certification.sources`. The core has no registration threshold of its
  own to enforce in any country.
- **Fixed assets.** No `assets.json`: whether a usual depreciation duration
  is prescribed by a text this research pass could open was not
  established.
- **Bank formats.** Nothing checked here says which formats Omani banks
  send.
- **Filing.** The return is filed and paid on the Tax Authority's own
  portal; submitting it is a credential, not a pack.
- **Fawtara e-invoicing** — see "Electronic invoicing" above and
  [`docs/international.md`](../../docs/international.md), "From Oman."

## Reviewing this pack

Open an issue titled "Review: Oman". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what". The points an Omani-qualified accountant should read first,
roughly in the order the author is least sure of them:

1. **The blocked-input-tax article number**, cited here from secondary
   guidance rather than a directly-fetchable text — see "Taxes".
2. **Full IFRS rather than the IFRS for SMEs Standard** as the reporting
   framework, resting on the IFRS Foundation's own secondary reading of
   three Omani articles this pack's research could not open — see
   "Sources" and "The statements".
3. **The statutory reserve line (`EQ.2`)**, whose Commercial Companies Law
   article this research pass did not trace.
4. **The end-of-service benefits provision**, whose Labour Law article this
   research pass did not trace.
5. **`earliest_of_delivery_or_payment` as the tax point**, which drops the
   invoice-date trigger Article 26 also names.
6. **The Fawtara timeline**, carried with only the Tax Authority's own FAQ
   wording and none of the later phase dates secondary sources publish.
