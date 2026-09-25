# Cyprus

Everything Cyprus adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the boxes of the VAT return, the
balance sheet and the income statement, and the sentences the law puts on an
invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Cyprus accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Cyprus return has reviewed it
against the law they apply. The figures are replayed against a year of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves
nothing about whether it is right.

**Language: English.** Cyprus has no legally prescribed chart of accounts in
any language (see below), so there is no reference chart to translate — this
pack simply follows the convention `packs/ie/` and `packs/gb/` set for a
country with no chart of its own. The Value Added Tax Law itself exists only
in Greek, the Republic's official language; every legal citation in this pack
that quotes it is this pack's own translation from the Greek, marked as such,
and a reader who wants the original reads the Greek text the `vat-law-95-2000`
entry of `certification.sources` points to.

## Sources, and how they were read

Both `gov.cy` and `mof.gov.cy` — the Tax Department's own site — answered
every automated request made while building this pack with a `403`, and the
Department's VAT guide PDF has moved since whatever indexed it: its old
address now redirects to a `gov.cy` page that does not carry it, and no
snapshot of the old one exists on the Wayback Machine either. Two consequences
follow, and a reviewer should read both before trusting a citation here.

**The law itself was read at [cylaw.org](https://www.cylaw.org/), not at a
`.gov.cy` address.** cylaw.org is the Cyprus Legal Information Institute, a
free-access consolidator in the same family as BAILII for the United Kingdom
or AustLII for Australia, and it is the consolidation Cyprus lawyers actually
cite; it is not, itself, the government. Its pages are served in the
`Windows-1253` Greek encoding, and a tool that decodes them as UTF-8 — which
several were tried before this was noticed — reads the operative articles as
mojibake and cannot quote them at all. Every article cited below was read
after decoding the page correctly.

**The box-by-box content of the VAT return could not be sourced from the
Department at all.** `Έντυπο Φ.Π.Α.4`, Form 4, is not published anywhere this
pack could reach in a form describing what each box asks for. The nearest
thing found is *VAT Definitive Guides, Issue 2*, an unofficial translation of
the form and its completion notes published by Chelco VAT Ltd, a Cyprus VAT
advisory firm — cited as `cy-vat4-guide-chelco`, and named as unofficial on
every box of `tax_report.json` that leans on it. **This is the single
weakest point of this pack** and the first thing worth someone with a
browser — rather than an automated fetch — checking against the Department's
own site or against the return itself on
[Tax For All](https://taxforall.mof.gov.cy/), the portal it is filed on.

| What | Text | Where |
|---|---|---|
| The rates, the schedules, the exemption, export and intra-Community provisions, the reverse charges, the registration threshold, the time of supply | Ν. 95(Ι)/2000, the Value Added Tax Law, consolidated — articles 6, 9, 11, 11Β, 12Α, 17, 18, 18Α, 18Β, 25, 26 and the First, Fifth, Sixth, Seventh, Twelfth and Fifteenth Schedules | `cylaw.org/nomoi/enop/non-ind/2000_1_95` |
| Filing periods, the deadline, mandatory invoice particulars | Κ.Δ.Π. 314/2001, the VAT (General) Regulations 2001, regulations 11, 12 and 17 | `cylaw.org/KDP/data/2001_1_314.pdf` |
| The temporary 5 % rate for accommodation, catering and passenger transport | Κ.Δ.Π. 268/2020 | `cylaw.org/KDP/data/2020_1_268.pdf` |
| Payment terms and late payment | Ν. 123(Ι)/2012, transposing Directive 2011/7/EU | `cylaw.org/nomoi/enop/non-ind/2012_1_123` |
| The absence of a legal chart of accounts, and of a statutory statement format | Companies Law, Cap. 113, s. 141A and the repealed Eighth Schedule | `companies.gov.cy` (official PDF translation) |
| The layout of the balance sheet and the income statement | IFRS for SMEs Accounting Standard (2015), sections 4 and 5 | IFRS Foundation, `ifrs.org` |
| Electronic invoicing | eInvoicing in Cyprus | European Commission, Digital Building Blocks |
| The VAT return's boxes (unofficial) | VAT Definitive Guides, Issue 2 | Chelco VAT Ltd |

## The chart of accounts, and the statements built on it

**Cyprus prescribes no chart of accounts and, since 2003, no statutory
balance sheet or profit and loss format either.** The Companies Law, Cap.
113, s. 141A requires every company's accounts to give a true and fair view
in accordance with International Financial Reporting Standards as adopted by
the European Union (Regulation (EC) No 1606/2002). Before that, the Eighth
Schedule to Cap. 113 set out a statutory format transposing the Fourth
Company Law Directive (78/660/EEC), in the same shape as Ireland's Schedule
3A or the United Kingdom's Format 1; s. 20 of Ν. 167(Ι)/2003 repealed it when
the IFRS requirement came in, and IAS 1's own layout is deliberately not a
fixed table of captions the way a transposed Fourth Directive schedule is.

The 161 accounts of `accounts.csv` are, for the same reason, original —
there is nothing published to copy — and follow the four-digit convention
this pack's Irish and British neighbours use: `0` non-current assets, `1`
current assets, `2` current liabilities, `3` non-current liabilities and
equity, `4` income, `5` cost of sales, `6` distribution costs, `7`
administrative expenses, `8` finance costs and tax.

**`statements.json` gives that chart a statement of financial position and a
statement of comprehensive income of its own**, rather than leaving every
account to fall back onto `packs/generic/`. Full IFRS as adopted by the EU
prescribes no fixed table of captions, so there is no statutory list of line
items to transcribe the way `packs/ie/` transcribes Schedule 3A; what this
pack transcribes instead is the **minimum line items of the IFRS for SMEs
Accounting Standard**, sections 4.2 and 5.5 — a real IFRS text with a
concrete list of captions, used here as an illustrative layout precise
enough to group a chart against, and **not** because Cyprus law requires or
even permits a company to report under that Standard in place of full IFRS.
A reviewer should read `CY-IFRS-SME-BS` and `CY-IFRS-SME-IS` as this pack's
own choice of presentation, not as a second statutory format beside the one
that was repealed. Both statements present a single statement of
comprehensive income (section 5.3), because none of this pack's accounts
carries an item of other comprehensive income to show apart from profit or
loss. `E-LEGAL` reads the non-distributable reserve of s. 55 of Cap. 113; the
33 remaining lines carry no Cyprus-specific citation of their own, only the
IFRS for SMEs line item they transcribe.

**Two VAT posting accounts and two settlement accounts**, as the framework's
own rule for a periodic return asks: `2200` output tax and `1140` input tax
are where a tax's own postings land, and `2210` VAT payable and `1150` VAT
recoverable are what `settle_filing()` carries a filed period's net into,
reconcilable so a payment or a refund can be matched against them.

`closing_style` is `retained_earnings`: the result goes straight to `3400`,
because — as for the United Kingdom — nothing in Cyprus law asks for a
separate current-year-result line, and IFRS's own statement of changes in
equity shows the year's result inside retained earnings rather than beside
it.

## The taxes

Twenty codes. A code is a rate at a date, so a rate change is a new code with
a `valid_to` on the old one, never an edit.

| Rate | Codes | Article and Schedule |
|---|---|---|
| Standard 19 % | `CY-S-19`, `CY-P-19` | article 17 — 19 % confirmed, with its 13 January 2014 commencement date, directly in the consolidated text |
| Reduced 9 % | `CY-S-09`, `CY-P-09` | article 18Α, Twelfth Schedule |
| Temporary 5 % (accommodation, catering, passenger transport) | `CY-S-05-COVID` | Κ.Δ.Π. 268/2020, 1 July 2020 to 10 January 2021, read directly in the Gazette PDF |
| Reduced 5 % | `CY-S-05`, `CY-P-05` | article 18, Fifth Schedule |
| Reduced 3 % (books, newspapers, magazines) | `CY-S-03`, `CY-P-03` | article 18Β, Fifteenth Schedule, since 21 July 2023 |
| Zero rate | `CY-S-00` | article 25, Sixth Schedule |
| Exempt | `CY-S-EXEMPT`, `CY-P-EXEMPT` | article 26, Seventh Schedule |
| Export outside the EU | `CY-S-EXPORT` | article 25(6) |
| Intra-Community supply of goods | `CY-S-ICG` | article 25(8)(α) |
| Service to a taxable person in another Member State | `CY-S-ICS` | article 44 of the Directive — see the gap noted below |
| Intra-Community acquisition of goods, 19 % | `CY-P-ICG-19` | article 12Α |
| Service from a taxable person in another Member State, 19 % | `CY-P-ICS-19` | article 11 |
| Service from a supplier outside the EU, 19 % | `CY-P-FSR-19` | article 11 |
| Construction services, domestic reverse charge | `CY-S-RCC`, `CY-P-RCC` | article 11Β |

**The commencement dates of articles 18 and 18Α were not independently
confirmed.** The consolidated text names the Schedules each rate reads from
and confirms both rates are in force today, but article 17's own text is the
only one of the three that states its effective date in so many words; 13
January 2014 is used for 18 and 18Α on the inference that Cyprus restructured
its rate bands together at that date, which is well attested by professional
commentary but was not independently verified against the Official Gazette
for this pack. `CY-S-03`'s date of 21 July 2023 rests on the same kind of
secondary sourcing (KPMG Cyprus, PwC Cyprus) rather than a Gazette text read
directly, though the article and Schedule it names were read directly in the
consolidated law.

**One reverse charge, one article.** Article 11 of Ν. 95(Ι)/2000 is, on the
reading taken here, the general mechanism by which a Cyprus recipient
self-accounts for a service received from abroad, whether the supplier is in
another Member State or outside the Union — unlike Ireland's or the United
Kingdom's law, it did not need a separate general place-of-supply article,
because article 11 states the self-accounting duty directly. Article 12Α is a
different mechanism, confined to goods: it is *acquisition*, a term of art of
Title V, Chapter 2 of the Directive, and this pack reads box 2 of the return
— "Output VAT on acquisitions from other Member States" — as confined to it,
with a service reverse-charged under article 11 posting through box 1
instead, whichever side of the Union its supplier is on.

**No article was found for the general business-to-business place-of-supply
rule itself** — the rule that makes `CY-S-ICS` an intra-Community supply
rather than a domestic one from the seller's side. `CY-S-ICS` cites article
44 of Council Directive 2006/112/EC directly rather than a Cyprus article,
which is the gap this pack is least happy with; see "What this pack does not
carry" below.

**No non-deductible input tax category is modelled.** Every EU Member
State's VAT law excludes some input tax from deduction — cars, entertainment,
the Irish and British packs each carry several — and this pack found no
Cyprus provision to transcribe in the time available. A company's cars and
entertainment therefore deduct in full here, which is very likely wrong; see
below.

## The return

`CY-VAT4` carries twelve boxes: 1 output tax, 2 output tax on intra-Community
acquisitions of goods, 3 their total, 4 input tax, 5 the net (box 3 less box
4, negative for a credit — there is no floor at zero), 6 and 7 the total
value of sales and of purchases, 8A and 8B the intra-Community share of box
6, 9 the zero-rated share of box 6, and 11A and 11B the intra-Community share
of box 7. Every box's structure rests on the unofficial Chelco translation
noted above; boxes 1 through 5 read as an ordinary output/input/net shape
close to the United Kingdom's own return, and were the part of that source
this pack trusted most.

**Filed quarterly, on regulation 17 of Κ.Δ.Π. 314/2001**, read directly: a
period of a quarter, or such other three-month period as the Commissioner
notifies a filer. Whether that second branch is routinely used to stagger a
filer's quarters away from the calendar one — as several other Member
States' administrations do — was not confirmed in the sources consulted;
the golden scenario books a plain calendar quarter, and `period` declares
only `quarter` either way, there being one cadence regardless of which
three months it covers. **The deadline** is the tenth day after the end of the
month that follows the period — the last day of that month, plus ten — read
directly in the same Regulation: a quarter ending 31 March falls due 10 May.

The golden year of books checks to the cent against these boxes; read
`golden/vat_return.json` beside `golden/scenario.json` for the figures
themselves.

## Invoices

Numbering is `sequential` (regulation 12(1) of Κ.Δ.Π. 314/2001 requires an
identifying number; this pack found no requirement against a gap), payment
terms 30 days (Ν. 123(Ι)/2012), and the tax point `invoice_if_issued`, on
article 9: the basic time is delivery or performance (article 9(2)–(3)), an
advance invoice or payment brings it forward to that date (article 9(4)), and
an invoice issued within fourteen days after the basic time brings it forward
too (article 9(5)), unless the taxable person has opted out by written notice
to the Commissioner. That fourteen-day mechanism, rather than an unconditional
"invoice if issued", is what `invoice_if_issued` stands for here; the
advance-payment branch of article 9(4) is not modelled, Ekwo having no
prepayment document.

**No B2B electronic invoicing obligation exists today.** Public bodies must
be able to *receive* an EN 16931 invoice since April 2019 (central) and April
2020 (sub-central government), under Directive 2014/55/EU; nothing obliges a
Cyprus business to issue one to another, and the European Commission's own
country page records a wider obligation as under discussion with no date
fixed. `profile` and `mandatory_from` are both null and `obligation` is
`none`, on the same reading `packs/ie/` gives Ireland for the years before its
own phased mandate was legislated.

**Bank formats**: `camt.053` only, the one statement format Ekwo reads that a
Eurozone bank is expected to send; no payment format is declared, because
Ekwo writes none.

## What this pack does not carry

- **The place-of-supply article for a business-to-business service** — see
  above. `CY-S-ICS` cites the Directive rather than the transposing Cyprus
  article, which this pack was not able to identify.
- **Non-deductible input tax** — cars, entertainment, and whatever else
  Cyprus law excludes. Not one category of it is modelled; every purchase tax
  of this pack deducts in full.
- **The Seventh Schedule's exemptions, item by item.** `CY-S-EXEMPT` and
  `CY-P-EXEMPT` cite article 26 and the general reason code of article 132 of
  the Directive; the Schedule's own list of exempt activities was not read
  line by line.
- **Article 11Α (gas and electricity from a non-established supplier),
  article 11Γ (scrap metal), article 11Δ (land and buildings before first
  occupation) and article 11Ε and 11ΣΤ (mobile phones, precious metals)** —
  five more domestic reverse charges the consolidated law carries, none of
  them transcribed here. Only article 11Β, construction, is.
- **The registration threshold of €15,600** (article 6, First Schedule) —
  confirmed but not modelled: nothing in this pack's mechanics depends on
  whether a company is registered.
- **VIES statements**, the Tax For All portal's filing mechanics, corporate
  tax, the Special Contribution for Defence beyond an account to book it to,
  and Social Insurance and GeSY contributions beyond an account each.
- **The 2020 hospitality measure's box mechanics were not separately
  golden-tested**: `CY-S-05-COVID` is declared and dated but no document of
  the golden scenario uses it, the scenario's year being 2026.

## What a reviewer should read first

1. **The VAT4 box structure**, sourced from an unofficial translation because
   the Department's own guide could not be retrieved — see "Sources" above.
   This is the one thing in this pack most worth checking against the current
   Tax For All portal by someone who can log into it.
2. **The dates of articles 18 and 18Α** (9 % and 5 %), inferred rather than
   read directly — see "The taxes" above.
3. **Whether article 11 is really the whole mechanism** for a service
   received from abroad, EU or not, or whether a place-of-supply article this
   pack did not find changes which box a European one belongs in.
4. **The non-deductible input tax gap.** A Cyprus accountant will know at
   once which purchases this pack wrongly deducts in full.
5. **The choice of the IFRS for SMEs line items** for `statements.json`,
   built on this pack's own chart rather than falling back to
   `packs/generic/`'s eighteen account types — and whether a Cyprus
   accountant would group these accounts, or name these lines, differently
   even though no statute prescribes either.
