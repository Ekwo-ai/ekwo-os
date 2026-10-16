# The Bahamas

Everything The Bahamas adds to Ekwo, as data: a chart of accounts, the
journals, the value added tax (VAT) at 10 %, the reduced rate of 5 %, the zero
rate and the exemptions, the monthly or quarterly VAT return, and the statement
of financial position and the statement of profit or loss in the IFRS style.
The format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that a Bahamian
accountant can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Bahamian VAT return has reviewed
it. The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and nothing about whether it is right.

**Language.** English, the language of the law and of the Department of
Inland Revenue.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
ten texts.

| What | Text | Where |
|---|---|---|
| The charge, the rates, the Schedules, imports, input tax, invoices, the return | Value Added Tax Act, 2014 (Ch. 370A), reprint as at 1 July 2024 | `inlandrevenue.finance.gov.bs` |
| The rate of 10 % | Value Added Tax (Amendment) (No. 2) Act, 2021 (No. 32 of 2021), gazetted 13 December 2021 | `inlandrevenue.finance.gov.bs`, `orbitax.com` |
| The reduced rate of 5 % and the Fourth Schedule | Value Added Tax (Amendment) Act, 2025 | `inlandrevenue.finance.gov.bs` |
| A proposal to exempt the Fourth Schedule goods from 1 April 2026 | Value Added Tax (Amendment) Bill, 2026 | `inlandrevenue.finance.gov.bs` |
| The lines of the return | Guidance on completing a VAT return (2017) and the return worksheet | `inlandrevenue.finance.gov.bs` |
| The due date | Value Added Tax Act s. 47 and the Department's payment page | `inlandrevenue.finance.gov.bs` |
| Where the return is filed | The Department's VAT pages; the service is `vat.revenue.gov.bs` | `inlandrevenue.finance.gov.bs` |

The law is read from the Department's own copies. The Act of December 2021 is an
image scan and was not read: the rate of 10 % rests on the reprint of 2024, which
cites that Act, and the date it took effect (1 January 2022) on Orbitax's report
of the gazette.

## The rates

- **10 %**, the standard rate, from 1 January 2022 (12 % before it,
  no code). Books of 2021 and before are for the accountant.
- **5 %**, the reduced rate of the Value Added Tax (Amendment) Act, 2025, from
  1 April 2025, on the goods of the Fourth Schedule (meat, fish, dairy, grains,
  vegetables and the other headings it lists) **sold unprepared by a food store**
  — a business with at least 10 % of its 2024 turnover from unprepared food, or a
  pharmacy. Whether a seller is a food store, and whether the goods are
  unprepared, is for the user.
- **The 2026 Bill.** The Department publishes a Value Added Tax (Amendment) Bill,
  2026, that would make the same goods *exempt* from 1 April 2026 instead of
  reduced-rated. A Bill was read; whether it was passed was not confirmed. The
  5 % codes carry no end date. **Confirm with the Department or an accountant
  before booking food sales after 31 March 2026.**
- **Zero rate**: exports of goods and services directly tied to goods or
  property outside The Bahamas (First Schedule, Parts I and II). The long
  list of zero-rated domestic goods and services held in the Regulations
  (the « breadbasket », medication, the supply of real property) was not read,
  so there is no code for them; the user chooses the closest zero-rated code
  only when the Regulations say so, and otherwise brings in the accountant.

## The chart of accounts

Original, four digits, 146 accounts, blocked so that each range reaches one
line of the statements. The VAT accounts are 1150 (input tax), 2100 (output
tax), 2110 and 1155 (the net settlement of a filed return, reconcilable), 2125
(VAT Customs collects on imports) and 2140 (VAT withheld under section 23A).
The Bahamas has no tax on the income of companies or individuals; accounts
1350, 1900, 2300, 2500 and 8000 to 8020 are for taxes paid abroad and for the
domestic minimum top-up tax of large multinational groups.

## Taxes

Fourteen codes: the standard rate on sales and purchases; the reduced rate on
sales and purchases; zero-rated exports of goods and of services; exempt
supplies; purchases with the input tax refused by section 50(1) (a passenger
vehicle not used wholly for taxable supplies, entertainment, club fees); purchases
from unregistered suppliers; zero-rated and exempt purchases; and imports at
10 %, zero-rated and exempt.

## The return

Monthly (the tax period of section 46(2)) or quarterly where the Comptroller has
allowed it; the pack declares both and leaves the choice to the company. The
return and the payment are due **twenty-one days after the end of the period**
(s. 47(1)); a large taxpayer has fourteen days, which the pack does not carry.
The boxes carry the line numbers of the Department's guidance on completing the
return (standard method, version of 1 January 2017): 1, 2, 4 and 5 (4I is line 4
as printed, VAT included), 7 to 10, 12, 14, 18, 19 and 25 to 27. **The guidance
and the worksheet online are those of 2017 and still print 7.5 %**; the reduced
rate boxes (R4 and R5) are the pack's own, and the preparer places their figures
on the current online form. The return is filed on the Department's online
service, `vat.revenue.gov.bs`.

## Electronic invoicing

None. No structured electronic invoice or clearance system was found in the
texts consulted; `einvoicing.obligation` is `none`.

## What this pack does not carry

- **Zero-rated domestic supplies** of the Regulations and VAT Rules (the
  breadbasket, medication, the supply of real property and its Third Schedule
  rates): no code. See above.
- **The reverse charge on imported services** (section 45): the importer or
  recipient files a return and pays within seven to twenty-one days depending on
  the case. The services that are taxable and the matching input tax are for the
  user and the accountant (`not_taxed` in `pack.json`).
- **VAT withholding** (section 23A, Forms 73 and 74): account 2140 exists, but no
  code or return carries the withholding mechanism, including the 2026 Bill's
  extension to Government contracts.
- **Time of supply** (section 32): `invoice_date` is a convention, not the Act's
  rule; a deposit or payment before the invoice may bring the supply forward.
- **Tax-inclusive pricing** (section 10): documents compute tax on top of a net
  price.
- **Apportionment of input tax** for a business with taxable and exempt supplies
  (s. 31 of the Regulations): the pack claims the whole of the tax entered.
- **Special schemes**: the cash accounting and flat rate schemes, the
  transitional rules, public entertainment events, the VAT free shopping scheme,
  Grand Bahama Port Authority licensees (bonded supplies), the deferral of import
  VAT.
- **The credit brought forward and the fines** of the return (sections D and E of
  the worksheet), which settle one period against the next and are not documents.
- **Other taxes**: business licence fees, real property tax, stamp duty and
  customs duties, National Insurance, and the domestic minimum top-up tax are not
  modelled; the Department's pages list them.
- **Fixed assets and corporate tax sections**: none.
- **Statutory layout of the accounts**: none was found; the statements follow
  IAS 1 and the rules that map accounts to lines are this pack's own.
- **Registration**: the threshold is $100,000 of taxable supplies in twelve
  months (s. 21); the pack does not check it.
