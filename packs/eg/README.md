# Egypt

Everything Egypt adds to Ekwo, as data: a chart of accounts, the journals,
the 14% value added tax with its reduced rate on production machinery, its
zero-rated exports and free-zone supplies, its exempt list, the Table Tax
that stacks on top of VAT for some goods and services and stands alone for
others, a monthly return built from what the Unified Tax Procedures Law
requires a return to hold, the statement of financial position and the
income statement of the small-and-medium-entities requirements of the
Egyptian Accounting Standards, and what the law puts on a tax invoice. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on.

**Status: `community`.** Nobody who files an Egyptian VAT return has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**Language.** The pack's own labels — the chart, the journals, the taxes,
the boxes of the return, the statement lines — are written in Arabic,
`defaults.language`, with a full English translation in
[`i18n/en.json`](i18n/en.json); see [`i18n/README.md`](i18n/README.md) for
why the two split the way they do. The `legal_reference` commentary
throughout is in English.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds eight texts, every one of them opened on 25 September
2026. The three the rest of this file leans on most:

| What | Text | Where |
|---|---|---|
| The rate, the reduced rate, zero-rating, exemptions, the Table Tax, registration, tax invoices | Value Added Tax Law No. 67 of 2016, as amended, and its Executive Regulations (Minister of Finance Decree No. 66 of 2017), both in ETA's own English translation | `eta.gov.eg` |
| The monthly return's filing and payment deadline | Unified Tax Procedures Law No. 206 of 2020, article 31(a) and article 32 (read from the Arabic original: this pack's research found no ETA English translation of this law) | `eta.gov.eg` |
| The reporting framework behind the statements | Egyptian Accounting Standards (EAS), issued by the Minister of Investment | IFRS Foundation, Jurisdictional Profile: Egypt |

**One fact this pack could not verify at a directly-fetchable primary
text: the exact live boxes of the monthly return.** The Executive
Regulations named the form "form No. 10 VAT" in an article repealed in 2021,
and this research pass found no current, directly-fetchable text or screen
naming its boxes as ETA's own workspace shows them. `tax_report.json`'s
boxes — `a1` through `j` — are therefore this pack's own construction, built
letter by letter on what a registrant's books have to hold and what the two
laws above actually require a return to declare, not a transcription of the
live portal. A reviewer who has filed on `workspace.eta.gov.eg` should check
this first.

## The chart of accounts, and why this one

**This pack's research found no chart of accounts a private Egyptian company
is legally required to use.** The historic Uniform Accounting System
(النظام المحاسبي الموحد) is a public-sector numbering scheme, and this
research pass found no text extending it to companies generally. What the
law does prescribe is the reporting framework: the Minister of Investment
issues Egyptian Accounting Standards (EAS) by ministerial decree published
in the Official Gazette, close to IFRS Accounting Standards but not
identical to them, with a dedicated simplified standard for small and
medium-sized entities effective 1 January 2016 (IFRS Foundation,
Jurisdictional Profile: Egypt). This research pass could not open the
Arabic decree text listing that standard's own chart, if it names one.

- **Four digits, by class**, the same shape as `packs/ae` and `packs/sa`:
  `1` assets, `2` liabilities, `3` equity, `4` revenue and other income, `5`
  cost of sales, `6` other expenses, `7` finance costs, `8` corporate tax.
- **Flat**, every account a leaf, grouped by the ranges `statements.json`
  reads.
- **The accounts an Egyptian company actually keeps**: VAT input and output
  tax apart from Table Tax collected, the net amount payable to or
  refundable by the Egyptian Tax Authority, and an end-of-service benefits
  provision every Egyptian employer owes under the Labour Law — this
  research pass did not trace the provision to a specific article and a
  reviewer should check that citation.

105 accounts, all postable. None was copied from a published chart.

## Taxes

**One standard rate, 14%, since 1 July 2017** (13% the year before): VAT Law
article 3, first paragraph. **One reduced rate, 5%**, on machinery and
equipment bought or imported for use in manufacturing a commodity or
providing a service — buses and passenger cars excepted — refundable on the
buyer's first tax return under article 30 item 4 if it is not already fully
deductible.

**What a sale can be:**

| | Code | Box |
|---|---|---|
| Standard-rated, or the reduced rate on production machinery | `EG-S-STD`, `EG-S-CAPEQ` | a1, tax in a2 |
| Export, article 3 last paragraph and article 6 first paragraph | `EG-S-EXPORT` | b |
| Supply to a free zone project for its licensed operations, article 6 second paragraph | `EG-S-FREEZONE` | b |
| Exempt, the List of Goods and Services Exempted from VAT (58 items) | `EG-S-EXEMPT` | c |
| Professional and consultancy services, Table Tax alone, no VAT | `EG-S-TABLETAX-PROF` | d1, tax in d2 |

**What a purchase can be:**

| | Code | Box |
|---|---|---|
| Standard-rated or the reduced rate, fully deductible | `EG-P-STD`, `EG-P-CAPEQ` | f1, f2 |
| Imported goods, tax collected by Customs on release | `EG-P-IMPORT` | f1, f2 |
| A service imported from a non-resident with no Egyptian registration, self-assessed | `EG-P-IMPSVC` | e1, e2, deductible share in f2 |
| Exempt | `EG-P-EXEMPT` | none |
| Professional and consultancy services, Table Tax not deductible from VAT | `EG-P-TABLETAX-PROF` | none — lands on the cost of the line |

**An import of goods is paid at the border, not self-assessed on the
return.** VAT Law article 31, second paragraph: "Tax on imported goods shall
be paid upon release by Customs Authority according to procedures set for
payment of customs duties." That is the opposite mechanism from an imported
*service*, article 5 third paragraph and Executive Regulations article 32,
where the Egyptian beneficiary calculates and pays the tax itself within 30
days — the reverse charge `EG-P-IMPSVC` models.

**The Table Tax is a second tax, not a VAT rate.** VAT Law article 36: it is
charged on goods and services listed in the Table attached to the Law, at
the rates and values the Table sets, in addition to VAT unless a special
provision excludes it. `EG-S-TABLETAX-PROF` and `EG-P-TABLETAX-PROF` carry
`kind: "other"` and model the one Table item this pack's golden scenario
exercises: professional and consultancy services, First:12 of the Table, 10%
of value, Table Tax alone and no VAT.

**What this pack does not model: an item taxed by both VAT and Table Tax on
the same line.** The Table's "Second" section — soft drinks, alcoholic
beverages, mobile telecommunication services, cosmetics, television sets,
air conditioners, most passenger cars — is charged VAT *and* Table Tax on
one base. `docs/packs.md` reserves a `group` mechanism for a country that
stacks two taxes on one line "and which the core does not carry yet." This
pack carries no tax of that section: a company selling one of them records
the VAT this pack's `EG-S-STD` carries and posts the Table Tax by hand until
the socle gains a `group` mechanism. See
[`docs/international.md`](../../docs/international.md), "From Egypt."

**Every base is a value without VAT**, as boxes a1, b, c, d1, e1 and f1 ask.

## The return

`tax_report.json` files monthly, with no other cadence: Unified Tax
Procedures Law article 31(a), read from the Arabic original since this
research pass found no ETA English translation of Law No. 206 of 2020.

**The deadline is the last day of the month following the tax period, for
filing and for payment alike.** Article 31(a): "every taxpayer files a
monthly return for VAT and/or Table Tax due... during the month following
the end of the tax period"; article 32 makes payment due "on the same day"
the return is filed electronically. This replaced a two-month deadline the
Executive Regulations' own article 16 stated before Ministerial Decree
No. 286 of 2021 repealed it. **A return is due even where nothing was sold
or bought in the period** (article 31(a), second paragraph).

**No floor at zero.** A negative net figure is a credit balance carried
forward under article 22 third paragraph, item 3, or — past six successive
tax periods, article 30 item 3 — refundable on request.

## The statements

`statements.json` carries the statement of financial position and the
income statement built on the minimum line items of the general IFRS for
SMEs Accounting Standard, for the reason given under "Sources": this
research pass could not open the Arabic decree text of EAS's own
small-and-medium-entities requirements, so no EAS-specific line list could
be transcribed. The income statement is by nature, which a small company's
ledger holds without an allocation to functions.

**VAT and Table Tax are a receivable and a payable, not current tax.**
Current tax is corporate tax, outside this VAT-focused pack's research; the
accounts (`1350`, `2130`, `8000`) exist for a company to book the charge by
hand.

**No fact keys.** Nothing checked here says which taxonomy, if any, an
Egyptian filing uses, so `xbrl` and `taxonomy` are null throughout.

## Closing the year

`fiscal_year_default` is `calendar`, a proposal and nothing more: an
Egyptian company chooses its own financial year end, and only the State's
own fiscal year runs from July to June — a fact about the budget, not about
a private company's books. `closing_style` is `retained_earnings`: the
chart carries no current-year result account.

## On the invoice

**Numbering is `sequential`.** The repealed text of Executive Regulations
article 13 required invoice numbers "serialised according to issuance dates
and free of any strikes or scratches" — a running, date-ordered sequence,
not an explicit no-gap rule.

**No default payment term and no late-payment interest** are declared: this
research pass found no Egyptian statute setting either between businesses
absent an agreement, and did not look long enough to say there is none.

**No invoice mention is declared.** This research pass found no Egyptian
statute requiring a specific printed sentence for a reverse charge, an
export or an exemption, unlike Belgium's or Saudi Arabia's; the repealed
text of Executive Regulations article 13 lists only the ordinary particulars
— serial number, date, both parties' names and registration, a description
of the goods or services, the rate and the tax due.

**The tax point is an approximation of a three-way rule.** VAT Law article
1, definition of "Sale": ownership transfer or service provision is deemed
to occur, whichever precedes, on invoice, delivery, or payment — three
triggers, where the closed vocabulary of `tax_point` has room for two.
`earliest_of_delivery_or_payment` is the nearest value and what the rule
reduces to whenever no invoice is issued ahead of delivery or payment; a
supply invoiced first is the case this approximation misses, the same gap
`packs/sa` and `packs/ae` record for their own three-way wording.

## Electronic invoicing

Electronic invoicing is obligatory in Egypt, and `pack.json`'s `einvoicing`
block still leaves `profile`, `mandatory_from`, `party_scheme` and
`vat_scheme` all null, for the reason `packs/sa`, `packs/vn` and `packs/kr`
leave theirs null: the ETA electronic invoice (business-to-business) and
electronic receipt (business-to-consumer) systems are a **clearance
regime** — a document is submitted to the Egyptian Tax Authority, which
validates it and returns a UUID and a signature reference before it is a
valid invoice — not an exchange between two parties' own access points, and
not an EN 16931 profile any brick of `packages/formats` writes. The format
refuses a `mandatory_from` with no `profile` to say what became obligatory
on it, so the obligation is stated in prose, in `einvoicing.legal_reference`,
and not in the fields.

**One date this pack could verify at a directly-fetchable ETA page:** "As of
April 1, 2023, no entity will be allowed to import, export or deal with the
customs system except for entities that issue and deal with electronic tax
invoices" (`eta.gov.eg`, home page). The rollout itself was phased by
taxpayer size from November 2020; this research pass could not open
Ministerial Decision No. 188 of 2020, or the later wave-by-wave decisions,
at a directly-fetchable official text, and does not invent the intermediate
dates from a secondary source. A separate, later-tightened obligation
reaches business-to-consumer receipts; this research pass could not open
ETA Decision No. 281 of 2025 either.

`party_scheme` and `vat_scheme` stay null: Egypt issues no ISO 6523
identifier and is not on the Peppol participant identifier scheme list.
What an Egyptian electronic invoice carries instead is the seller's and the
buyer's Tax Registration Numbers and the ETA-issued UUID, neither of which
these fields hold.

## What this pack does not carry

- **Any item of the Table's "Second" section**, where VAT and Table Tax
  apply to the same base — see "Taxes" above and
  [`docs/international.md`](../../docs/international.md).
- **The registration threshold as a rule the core enforces.** VAT Law
  article 16: EGP 500,000 of sales of taxable and exempt goods and services
  over the preceding twelve months. Some secondary compliance sources
  describe a lower figure following a later decree; this research pass
  could not verify one at a directly-fetchable official text and carries
  only the figure the law itself states. The core has no registration
  threshold of its own to enforce in any country.
- **The e-invoice and e-receipt clearance protocol itself** — the UUID, the
  digital signature under Law No. 15 of 2004, the JSON/XML schema ETA
  publishes on its SDK site — none of which a brick of `packages/formats`
  speaks. See "Electronic invoicing" above.
- **Withholding tax** on payments to residents or non-residents, a distinct
  regime this VAT-focused pack's research did not open.
- **Corporate tax**, named only where the balance sheet needs an account for
  it (`1350`, `2130`, `8000`).
- **Fixed assets.** No `assets.json`: whether a usual depreciation duration
  is prescribed by a text this research pass could open was not
  established.
- **Bank formats.** Nothing checked here says which formats Egyptian banks
  send.
- **Filing.** The return is filed and paid on `workspace.eta.gov.eg`;
  submitting it is a credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Egypt". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what". The points an Egyptian-qualified accountant should read
first, roughly in the order the author is least sure of them:

1. **The boxes of `tax_report.json`**, this pack's own construction and not
   a transcription of the live monthly return on `workspace.eta.gov.eg`.
2. **The statement of financial position and the income statement against a
   real EAS-prepared small-entity statement** — no Egyptian-specific
   citation backs the choice of line items; see "The statements".
3. **The registration threshold**, where secondary sources disagree with
   the law's own text — see "What this pack does not carry".
4. **The end-of-service benefits provision**, whose Labour Law article this
   research pass did not trace.
5. **`earliest_of_delivery_or_payment` as the tax point**, which drops the
   invoice-date trigger VAT Law article 1 also names.
6. **The phased e-invoicing timeline**, carried with only its final,
   verified date and none of the intermediate wave dates.
