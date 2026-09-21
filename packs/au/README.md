# Australia

Everything Australia adds to Ekwo, as data: a chart of accounts, the journals,
the goods and services tax and where each code posts, the business activity
statement, the statement of financial position and the statement of profit or
loss of the Tier 2 simplified disclosures, and the sentences the law puts on a
tax invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on, so that an
Australian accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who lodges an Australian activity statement has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**This is the first pack of Oceania**, and the second, after the United
Kingdom, of a country whose tax is a value added tax that owes nothing to the
Directive. The New Zealand pack is meant to be read against this one: the same
shape of chart, the same Peppol profile, the same way of writing a return that
is filed on three cadences. What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "From Australia".
None of it was patched for this pack's sake.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds thirty-five texts, and every one of them was opened on
21 September 2026: the Commonwealth texts on the Federal Register of
Legislation, the ATO's instructions on ato.gov.au, the standard on the register
too, where the AASB's standards are legislative instruments. The ones the rest
of this file leans on:

| What | Text | Where |
|---|---|---|
| The charge, the rate, GST-free and input-taxed supplies, the reverse charges, tax periods, returns, attribution, tax invoices | A New Tax System (Goods and Services Tax) Act 1999 | `legislation.gov.au/C2004A00446` |
| The registration threshold, the tax invoice threshold, deferred GST on imports, financial supplies | A New Tax System (Goods and Services Tax) Regulations 2019 | `legislation.gov.au/F2019L00417` |
| Withholding where no ABN is quoted, and paying it to the Commissioner | Taxation Administration Act 1953, Schedule 1, ss. 12-190 and 16-70 | `legislation.gov.au/C1953A00001` |
| What each label of the statement holds | Business activity statement NAT 4189, and the ATO's *Instructions for completing your BAS*, steps 1 to 5 | `ato.gov.au` |
| The accounts method, GST-exclusive reporting, cash or accruals | ATO, *Choose a method to complete your full BAS*, *Identify your accounting basis*, *Choosing an accounting method for GST* | `ato.gov.au` |
| Who prepares and lodges accounts, and the financial year | Corporations Act 2001, ss. 45A, 286, 292 to 296, 319 and 323D; Acts Interpretation Act 1901, s. 2B | `legislation.gov.au` |
| The form of the statements | AASB 1060, paragraphs 35 to 58 | `legislation.gov.au/F2020L00288` |
| Electronic invoicing | PINT A-NZ Billing, OpenPeppol; ATO, *eInvoicing for government*, *Tax invoices* | `docs.peppol.eu`, `ato.gov.au` |

`ekwo pack check au --links` found all thirty-five answering on the day of
writing. The ATO's site serves a page to a browser and often refuses a script
that asks for its text, so every `ato.gov.au` entry was also read in a browser;
the statement itself is a PDF the ATO serves under a content identifier rather
than a readable path, and is the entry most likely to move.

## The chart of accounts, and why this one

**Australia prescribes no chart of accounts.** The Corporations Act 2001,
s. 286, requires a company to keep written financial records that correctly
record and explain its transactions and would let true and fair statements be
prepared, and says nothing about a ledger. What it does govern is who prepares
statements: s. 292 makes every public company and every large proprietary
company prepare a financial report each year, and a small proprietary company
only when shareholders with 5 % of the votes (s. 293) or ASIC (s. 294) direct
it. A proprietary company is large when it meets two of the s. 45A thresholds,
which ASIC gives as $50 million of consolidated revenue, $25 million of gross
assets and 100 employees for years from 1 July 2019. Most Australian
companies are small and lodge no accounts with anybody; their books still feed
the income tax return and the activity statement, which is what this pack is
mostly for.

So the chart is written, not transcribed, and it follows what an Australian
ledger looks like:

- **Four digits, by class.** `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` goods and materials used, `6` other expenses,
  `7` finance costs, `8` income tax. No legal code and no class per caption:
  the classes are the order a trial balance is read in.
- **Flat.** No parent accounts. Every account is a leaf and the grouping is
  done by the ranges of `statements.json`, cut so that each range reaches one
  line item of paragraph 35 of AASB 1060.
- **Cost and accumulated depreciation are adjacent**, `1630` and `1631`, so
  one range reaches the carrying amount.
- **The accounts the law asks about have names an Australian bookkeeper
  recognises**: superannuation guarantee payable, PAYG withholding payable,
  payroll tax, fringe benefits tax, annual and long service leave, the ATO's
  own activity statement.

156 accounts, all postable. None of them was copied from a published chart,
and no commercial package's chart was used as a model.

**Five GST accounts, and why five.** `2100` holds the GST on sales and `1150`
the GST credits on purchases: the two the taxes post to. `2105` and `1152` hold
the GST of documents accounted for on a cash basis until they are paid. `2115`
holds deferred GST on imports until the statement that carries it. None of them
is where a lodged statement's balance lands — see "Where the balance of a
statement lands" below.

## Taxes

**One rate, since 1 July 2000.** Section 9-70 has put GST at 10 % of the value
of a taxable supply since the Act commenced (s. 1-2), and nothing has moved it,
so every code starts on that day and none has a `valid_to`. The one code that
starts later is the withholding below.

**GST-free is not input taxed, and the difference is the credit.** Australia
has no "exempt" supply in the European sense; it has two kinds of supply that
carry no GST and treat the supplier's own purchases differently:

| | GST on the sale | Credits on what went into it | Codes | Category |
|---|---|---|---|---|
| GST-free (Division 38) | none | claimable | `AU-S-FRE-FOOD`, `-HEALTH`, `-EDU`, `AU-S-FRE`, the two exports | Z, G |
| Input taxed (Division 40) | none | not claimable (s. 11-15(2)(a)) | `AU-S-ITS-FIN`, `AU-S-ITS-RES` | E |

The food, health and education codes are separate so that a reviewer can check
each against its Subdivision; they post identically. The purchase that a
business makes to produce an input-taxed supply carries `AU-P-GST-ITS`, whose
GST lands on the account of the line.

**Every base is a value without GST.** See "The statement" for why.

**Five things a purchase can be besides a plain credit**, and the statement
treats each differently:

| Code | What it is | Labels |
|---|---|---|
| `AU-P-GST-NCI` | entertainment and the other non-deductible expenses of s. 69-5: no credit | G11; the GST follows the line |
| `AU-P-RC-ITS` | an offshore service reverse charged under Division 84, which applies precisely because the buyer cannot claim the whole credit | G1, G11, 1A; the GST follows the line |
| `AU-P-RC-AGREED` | a non-resident's supply whose GST the buyer agreed to pay, s. 83-5 | G1, G11, 1A, 1B |
| `AU-P-DGST` | an importation under the deferred GST scheme | G11, 7A, 1B |
| `AU-P-NOABN-47` | a supplier who quoted no ABN: 47 % withheld | G11, W4 |

**The reverse charge of Division 84 is not the European one.** A registered
business buying a service from abroad for a fully creditable purpose owes no
GST on it at all: s. 84-5(1A)(b) reaches only a recipient who does *not*
acquire it solely for a creditable purpose. The pack therefore carries the
reverse charge as the business that *pays* it meets it — one that makes
input-taxed supplies and gets no credit back — and the golden year books the
tenancy software of a company that lets a flat. A partly creditable
acquisition, which is the common case, needs an apportionment no code can
hold.

**Withholding where no ABN is quoted is on the purchase, at 47 %.** Section
12-190 of Schedule 1 to the Taxation Administration Act 1953 makes the payer
withhold from a supplier who does not quote an ABN, and the ATO sets the amount
at 47 % of the invoice from 1 July 2017. It is a tax of kind `withholding` with
one posting, `-100` to `2120`, so the supplier is owed 53 % and the rest waits
for the statement, where it is label W4. The earlier rates are not carried.

**Cash accounting is a regime of the business, carried as codes.** Section
29-40 lets a small business entity — below $10 million of aggregated turnover,
as the ATO puts it — account for GST when it is paid rather than when it is
invoiced, for everything it sells and buys. The core has no regime of a
company, so the pack carries `AU-S-GST-CASH` and `AU-P-GST-CASH` beside the
accruals codes, as the Irish pack does; nothing stops a company from mixing
them, and a company that has made the choice should use nothing else for
taxable supplies. The golden year uses both only to show where their figures
land.

## The statement

`tax_report.json` is the business activity statement NAT 4189, as the ATO
prints it in September 2025, and label 7A from the monthly statement of an
importer approved for deferred GST.

**The accounts method, with GST-exclusive amounts.** The ATO offers two ways
of completing the GST labels. The calculation worksheet method reports every
label with GST in it and derives 1A and 1B by dividing by eleven. The accounts
method takes 1A and 1B straight from the records, and lets G1 be reported
without GST, a choice the filer marks under G1 and that then governs every
other label. A ledger holds exactly that: bases without GST and GST posted
document by document. So this pack reports on the accounts method, GST
excluded, and every figure it produces is the ledger's own. A business that
completes the worksheet method does its arithmetic on the side; the worksheet
labels G4 to G9 and G12 to G20 are kept in its records and not reported, and
the pack does not carry them.

**What is on the form, and what is summed from the ledger.**

| Labels | How |
|---|---|
| G1, G2, G3, G10, G11 | bases, summed from the ledger; an export posts to G1 and G2 at once, a GST-free sale to G1 and G3 |
| 1A, 1B, 7A, W4 | taxes, summed from the ledger |
| W1, W2, W3, 5A, 5B, 7 | declared and empty: payroll, income tax instalments and deferred company instalments are not in the ledger's taxes |
| W5, 4, 8A, 8B, 9 | the form's own arithmetic, stated in `golden/expectations.json` |

**Label 9 is a subtraction, and a refund comes out negative.** The form prints
a positive figure and asks whether 8A is more than 8B. In the golden year the
December quarter, whose GST on a credit note and whose deferred GST outweigh
its sales, comes to −50.00.

**Three cadences, one default.** Section 27-5 of the Act makes a quarter the
tax period for everybody, unless the business elects months (s. 27-10) or the
Commissioner determines them, as s. 27-15 requires above $20 million of GST
turnover. Division 151 provides annual periods, which the ATO offers to a
business registered voluntarily below $75,000. So `period` lists the three and
`period_default` is `quarter`.

**The deadline is the monthly one, on purpose.** A monthly statement is due on
the 21st of the following month (s. 31-10); a quarterly one on 28 October,
28 February, 28 April and 28 July (s. 31-8), with up to two more weeks for a
statement lodged online except for the December quarter. A form carries one
rule, so the pack declares the 21st: never later than the law, seven days early
for a quarterly filer, five weeks early for the December quarter.

**Cents, not whole dollars.** The ATO asks for whole dollars with the cents
dropped and no negative figure. `tax_report.json` can now say a form is filed
in whole units (`rounding.unit`), and this pack deliberately does not: the core
rounds a frozen box half up, at the country's rounding method, and the statement
rounds every label down, so 1,170.60 would be frozen as 1,171 where the ATO
wants 1,170. The pack reports what the ledger holds, to the cent and signed,
until a unit can carry its direction.

**Where the balance of a statement lands.** `tax_payable` is `2110`, the
activity statement payable to the ATO, and `tax_receivable` is `1155`, the
refund due. Both are reconcilable, because the payment to the ATO or its refund
is matched against them, and no tax posts to either. Label 9 nets
the PAYG withheld at W4 with the GST, so the settlement carries both to the
same account.

## The accounts

`statements.json` carries the statement of financial position and the
statement of profit or loss of AASB 1060, the Tier 2 standard of simplified
disclosures, which an entity preparing general purpose financial statements
without public accountability may apply.

**The lines are the paragraph 35 items, in the order Australian practice
prints them.** Paragraph 42 prescribes neither the order nor the format, so the
lines are the minimum items of paragraph 35 — cash, receivables, inventories,
financial assets, current tax, property, plant and equipment, investment
property, intangibles, associates, joint ventures, deferred tax, payables,
financial liabilities, provisions, equity — split current and non-current under
paragraphs 37 to 41, with "other current assets" and "net assets" as the
additional lines paragraph 36 allows. Biological assets, non-controlling
interests and assets held for sale are not lines, because the chart holds no
account for them.

**GST is a receivable and a payable, not current tax.** Paragraph 35(m) is
about current tax, which in Australia is income tax, so GST collected, GST
credits and the activity statement balance report among trade and other
receivables and payables. A reviewer who presents the GST net as a single
figure changes nothing in the ledger.

**Expenses by nature.** Paragraph 58 allows nature or function, and a small
company's ledger holds nature without any allocation.

**No fact keys.** Nothing here was verified against a taxonomy, so `xbrl` and
`taxonomy` are null on both statements.

## Closing the year

`fiscal_year_default` is `july`: the financial year of the Commonwealth's
statutes is twelve months starting on 1 July (Acts Interpretation Act 1901,
s. 2B), and it is the income year of the income tax. A company may fix another
under s. 323D of the Corporations Act; the default is a proposal.

`closing_style` is `retained_earnings`: the result goes straight into `3200
Retained earnings`. An Australian statement of financial position carries no
current-year result line and paragraph 44(f) names retained earnings as a class
of equity. `3210 Dividends paid` sits beside it and is booked by hand.

No income tax provision is booked by the close. The chart carries `8000` to
`8020`, `2300` and the deferred tax accounts so that it can be.

## On the invoice

**The tax invoice is a list of particulars, not a form.** Section 29-70(1)
asks that the supplier's identity and ABN, the recipient's identity or ABN
where the price is $1,000 or more, what is supplied, the extent to which each
supply is taxable, the date and the GST be ascertainable, and that the document
be clearly intended as a tax invoice. A buyer needs one to claim a credit
(s. 29-10(3)) unless the value is $75 or less before GST (s. 29-80 and reg.
29-80.01) — $82.50 with it, as the ATO says.

**Numbering is `free`.** The particulars include no invoice number, so the pack
claims none; `number_format` is a pattern a business may use.

**Two mentions.** An export and an input-taxed supply each carry a sentence
saying why no GST is charged, which is the "extent to which each supply is
taxable" of s. 29-70(1)(c)(iv). A GST-free domestic supply, the food, health and
education codes, has no mention of its own: `applies_when` resolves `export`
and `exempt` from the treatment, and a GST-free domestic supply has treatment
`domestic` like a taxable one. Its line shows no GST, which is what the
particular asks.

**The words "Tax invoice" are not a mention.** They are the title of the
document and belong on an invoice and not on an adjustment note, and a mention
cannot depend on the kind of document. A renderer prints them.

**No payment term and no late payment interest.** No Commonwealth statute sets
either between businesses; the Payment Times Reporting Act 2020 makes large
businesses report their terms to small suppliers and imposes none.

**The tax point is the earlier of the invoice and the first payment**
(s. 29-5(1)), and delivery plays no part in it. `invoice_date` is the closest
word the format has: right when the invoice comes first, wrong for a deposit
received before any invoice.

## Electronic invoicing

The profile is `pint-aunz`, the PINT A-NZ Billing specification Australia shares
with New Zealand on the Peppol network, of which the ATO is the Australian
authority. Both identifiers are the ABN, ICD `0151`. `obligation` is `none`: no
statute obliges a business to send or to accept an electronic invoice.
Non-corporate Commonwealth entities have had to be able to receive them since
2022, and are moving to eInvoicing as their default under a policy the ATO
describes and no statute enacts; both bind the buyer and not the supplier.

## What this pack does not carry

- **The calculation worksheet method** and its labels G4 to G9 and G12 to G20.
- **GST instalments** (G21 to G24) and the annual GST return.
- **PAYG withholding from wages** (W1, W2), **PAYG income tax instalments**
  (T1 to T11, 5A, 5B), fringe benefits tax, luxury car tax (1E, 1F), wine
  equalisation tax (1C, 1D) and fuel tax credits: each is a label of the
  statement and none is a tax a document carries.
- **Adjustments** other than a credit note, and the
  apportionment of a partly creditable acquisition.
- **The margin scheme** for real property, GST at settlement, the simplified
  accounting methods for food retailers, GST groups and branches.
- **Taxable importations paid at the border**, where the ABF collects the GST
  on an import declaration rather than on the supplier's invoice.
- **Fixed assets.** No `assets.json`: AASB 116 leaves the useful life to the
  entity, and the Commissioner's effective lives are an income tax table.
- **Bank formats.** No statement format is declared: Ekwo reads camt.053, and
  nothing checked says which Australian banks send it.
- **Standard Business Reporting.** The statement is lodged through Online
  services for business or SBR-enabled software; submitting it is a format
  library and a credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Australia". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what". Nine points a CPA or CA reviewer should read first, roughly in the
order the author is least sure of them:

1. **G1 and G11 on a reverse charge.** The ATO asks for the price multiplied by
   1.1 at G1 and at G10 or G11. The pack reports the price without GST, as its
   GST-exclusive choice at G1 requires everywhere else. Which of the two the
   ATO expects from an accounts-method filer who reports GST-exclusive is the
   point most worth a second reading.
2. **8A and 7A.** Form NAT 4189 prints 8A as 1A + 4 + 5A + 7; 7A is added
   from the ATO's worked example for deferred GST.
3. **The deadline.** The 21st for every cadence, for the reason under "The
   statement".
4. **GST in trade and other receivables and payables**, rather than netted or
   under current tax.
5. **The reverse charge code that gets no credit.** Whether a single
   no-credit code is the right model for Division 84, when most businesses it
   reaches are partly creditable.
6. **Withholding where no ABN is quoted** as a purchase tax, with the base still
   at G11.
7. **The cash-basis codes** beside the accruals codes, as a regime carried by
   codes.
8. **The chart's mapping onto paragraph 35 of AASB 1060**, especially right-of-use
   assets inside property, plant and equipment and the credit card inside
   financial liabilities.
9. **`numbering: free`**, which rests on s. 29-70 listing no number among the
   particulars of a tax invoice.
