# Pakistan

Everything Pakistan adds to Ekwo, as data: a chart of accounts, the journals,
the federal sales tax on goods at 18 % with the 4 % further tax on supplies to
unregistered buyers, reduced rates, zero rate, exemption, the five sales taxes
on services that the four provinces and the Islamabad Capital Territory levy
apart from it, the monthly sales tax return (form STR-7, filed on FBR IRIS),
and the statement of financial position and the statement of profit or loss of
the IFRS-based frameworks. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Pakistani accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Pakistani sales tax return has
reviewed it. The figures are replayed against two months of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Law in force.** The Sales Tax Act, 1990 as amended up
to 30 June 2026, which carries the Finance Act, 2026 (published on 26 June
2026), and the Sales Tax Rules, 2006 as updated to 6 August 2025. The standard
rate was 17 % until the Finance (Supplementary) Act, 2023 substituted 18 %;
`PK-S-17` and `PK-P-17` are kept as closed codes so that books of the earlier
months still resolve. No code claims to cover periods before 1 July 2022.

**English only.** English is the language of the tax and accounting texts the
pack cites. Urdu labels for the main accounts and taxes were not written;
`languages` is empty and a translation can be added as `i18n/ur.json` without
touching anything else.

What the core could not say is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## What is in it

| File | Holds |
|---|---|
| `pack.json` | the register of sources, the roles, the journals, the chart, the numbering and time-of-supply rules, the e-invoicing statement |
| `accounts.csv` | 172 accounts in four digits |
| `taxes.json` | 27 codes: 14 on sales, 13 on purchases |
| `tax_report.json` | form STR-7, 22 boxes |
| `statements.json` | statement of financial position, statement of profit or loss |
| `golden/` | two months of books of a Lahore trading and services company, 24 documents and 5 payments |

The taxes:

| Code | Rate | What | Boxes of STR-7 |
|---|---|---|---|
| `PK-S-18` | 18 % | sale of goods, standard rate, s. 3(1) | 9A, 9AT |
| `PK-S-18-FT` | 18 % + 4 % | sale to an unregistered buyer, s. 3(1) and 3(1A) | 9A, 9AT, 23a |
| `PK-S-10` | 10 % | photovoltaic cells and panels, Eighth Schedule serial 90, from 1 July 2025 | 10, 10T |
| `PK-S-1` | 1 % | locally assembled electric vehicles, Eighth Schedule serial 71, to 30 June 2027 | 10, 10T |
| `PK-S-17` | 17 % | former standard rate, closed 13 February 2023 | 9A, 9AT |
| `PK-S-ZR-EXP` | 0 % | export of goods, s. 4(a) | 11 |
| `PK-S-ZR-DOM` | 0 % | local zero-rated supply, Fifth Schedule | 9A |
| `PK-S-EX` | 0 % | exempt supply, Sixth Schedule | — |
| `PK-S-NS` | 0 % | supply outside the federal tax | — |
| `PK-S-PRA-16` | 16 % | service, Punjab (PRA) | — |
| `PK-S-SRB-15` | 15 % | service, Sindh (SRB) | — |
| `PK-S-KPRA-15` | 15 % | service, Khyber Pakhtunkhwa (KPRA) | — |
| `PK-S-BRA-15` | 15 % | service, Balochistan (BRA) | — |
| `PK-S-ICT-15` | 15 % | service, Islamabad Capital Territory | — |
| `PK-P-18` | 18 % | local purchase, tax adjustable | 1, 1T |
| `PK-P-17` | 17 % | former standard rate, closed | 1, 1T |
| `PK-P-10` | 10 % | local purchase at a reduced rate | 1, 1T |
| `PK-P-18-CAP` | 18 % | capital goods, tax adjustable | 4, 4T |
| `PK-P-18-NC` | 18 % | vehicle, appliance, furniture or office equipment — tax not allowed, s. 8(1)(i) | — |
| `PK-P-UNREG` | 0 % | purchase from an unregistered supplier | 2 |
| `PK-P-EX` | 0 % | exempt purchase | — |
| `PK-P-IMP-18` | 18 % | import, tax paid at Customs | 3, 3T |
| `PK-P-PRA-16`, `-SRB-15`, `-KPRA-15`, `-BRA-15`, `-ICT-15` | 15–16 % | services bought, one input account per authority | — |
| `PK-P-PRA-16-NR`, `PK-P-SRB-15-NR` | 16 %, 15 % | service from a non-resident, reverse charge on the recipient (Punjab, Sindh) | — |

**A service bought from a supplier abroad is a provincial reverse charge.**
The federal Sales Tax Act taxes goods; a software subscription, hosting or an
API billed by a non-resident is a *service*, and it is the province where it
is received that taxes it. The Punjab Sales Tax on Services Act, 2012, and the
Sindh Sales Tax on Services Act, 2011, both make a service provided to a
resident person by a non-resident person in the course of an economic
activity a taxable service (s. 3(2) of each), treat an office inside the
province and one outside it as separate persons (s. 3(3)), and put the
liability on *"the person receiving the service"* (Punjab s. 11(2), formerly
s. 9(2); Sindh s. 9(2)). `PK-P-PRA-16-NR` and `PK-P-SRB-15-NR` book the tax
owed on the province's payable account (`2103`, `2104`) and the same amount
on its input account (`1151`, `1152`), adjustable like the other provincial
inputs, on no box of the federal STR-7. Khyber Pakhtunkhwa, Balochistan and
the Islamabad Capital Territory have services statutes of the same shape; their
reverse-charge sections were not read for this pack, so no code carries them
yet. A foreign supplier sits on the trade payables with the others.

## The federal return

The tax period is one calendar month (s. 2(43)). The return is the form
**STR-7**, *Sales Tax and Federal Excise Return*, of the Sales Tax Rules, 2006
(rule 14(1)), filed electronically under rule 18 on FBR IRIS with Annex-A
(purchases), Annex-C (sales) and Annex-I (debit and credit notes). The pack
carries rows 1 to 5, 8, 9, 10, 11, 15, 17, 23a, 30 and 32 and gives each row
its taxable value and its sales tax as two boxes (`1` and `1T`). Row 9 is the
total of the supplies at the standard rate (`9A`, `9AT`) and those at reduced
rates (`10`, `10T`), which the form also prints in row 10.

**The date the pack keeps: the 18th.** Two dates are on the record, and both
are true. Section 2(9) of the Act makes the *due date* the 15th day of the
month after the tax period, and rule 18(9) of the Rules says that where the
due date is the 15th the tax is deposited by the 15th and the return is
submitted electronically by the 18th. The FBR page on due dates says the same
(Annexure C on the 10th, payment on the 15th, return by the 18th). A report
in Ekwo is the return, so the rule is `day_of_month_after_period` with day 18;
the payment date is said in the rule's reference. Electricity distribution
companies, independent power producers, gas companies, petroleum exploration
companies, CNG dealers and brick kilns have the later dates of the table to
rule 18(9) and are not modelled.

**What the boxes do not do.** The form closes with a ceiling: under section
8B(1) a registered person may not adjust input tax above ninety per cent of
the output tax of the period, except on fixed assets and capital goods and
unless the Board excludes the person, and rows 24 to 26 state the result with
a least-of and a conditional. A box can only add, subtract and floor at zero,
so box `32A` is the net **before** that ceiling and the pack says so on the
box. A taxpayer subject to section 8B owes more than the pack's box 32 says.
The credit brought forward (row 6), the inadmissible input tax (rows 6a, 6b, 7
and 7a), the sales tax deducted by withholding agents (row 16), the CNG, steel
and ship-breaking rows, the federal excise duty and the petroleum levy are not
carried.

## Further tax, the 4 % on the same value

Section 3(1A) adds four per cent, "in addition to the rate specified" in
section 3(1), where taxable supplies are made to a person who has not obtained
a registration number or is not an active taxpayer. The Finance Act, 2023 took
it from three to four. It is paid to FBR and reported in row 23a of STR-7. The
two charges stand on the same value, so `PK-S-18-FT` carries 22 % and splits
the tax between account 2100 (the sales tax, row 9) and account 2101 (the
further tax, row 23a).

**A limit of the core shows here.** The share of a posting is stored with
three decimals (`numeric(7,3)`), and 18/22 is 81.818181… per cent. The code
uses 81.818 and 18.182, which are exact to the paisa while the tax of the line
stays below about 2,700 rupees (a value of about 12,500). On a larger value the
two shares can differ by a few paisa from 18 % and 4 % computed separately,
and their sum is still the 22 % of the line. The golden keeps its
unregistered-buyer sales below that value for this reason. A user selling large
amounts to unregistered buyers can enter the sale on two lines, one with
`PK-S-18` and one with a code at 4 % on the same value. The remedy belongs to
the core; see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

The Federal Government may exempt classes of supplies from the further tax by
notification; none is modelled.

## The sales taxes on services

Services are taxed by the provinces and, in Islamabad, by the Federation under
a separate Ordinance. Each has its own statute, authority, registration,
portal and return; none is declared on STR-7.

| Authority | Statute | Rate | Source |
|---|---|---|---|
| Punjab Revenue Authority (PRA) | Punjab Sales Tax on Services Act, 2012 | 16 % | the Punjab Laws portal's consolidated text, secondary reading — see below |
| Sindh Revenue Board (SRB) | Sindh Sales Tax on Services Act, 2011 | 15 % | the Act as amended by the Sindh Finance Act, 2025, s. 8(1) |
| Khyber Pakhtunkhwa Revenue Authority (KPRA) | Sales Tax on Services Act, 2022 | 15 % | the Act, updated with the Finance Act, 2024, s. 9(1) |
| Balochistan Revenue Authority (BRA) | Sales Tax on Services Act, 2015 | 15 % | the Act, Second Schedule |
| Islamabad Capital Territory | Islamabad Capital Territory (Tax on Services) Ordinance, 2001 | 15 % | the Ordinance as updated to 30 June 2025, Table-1 |

The Islamabad rate is uncertain. The Finance Act, 2022 substituted fifteen
percent for the earlier sixteen and seventeen in the Ordinance's Schedule, and
the 2025 edition still reads fifteen; some commentators give sixteen, which is
the Punjab rate. The pack keeps fifteen. Whether the Finance Act, 2026 moved
it should be checked.

Each tax is a posting to its own payable account (2103 to 2107) and a purchase
posts to its own input account (1151 to 1154, 1156): the provincial laws let a
registered person adjust the tax paid against the tax collected for the same
authority, and the federal Act (s. 8(1)(j)) bars the input tax of a service
where the provincial law bars it. Payment dates in the provincial statutes
read: Sindh, the 15th day of the following month (s. 2(36)); Balochistan, the
15th (s. 2(18)); Khyber Pakhtunkhwa, the 15th for payment and the 18th for the
return (s. 2(x)). The Punjab Act is reported to read the 15th; the Ordinance of Islamabad was not found to define a due date. The
provinces change dates and reduced rates by notification; **reduced rates**
(restaurants paying by card, hotels, telecommunications at 19.5 % and others)
are not modelled, and a service at such a rate needs a code of its own.

**The Punjab rate rests on a secondary reading.** The 16 % and its 2021
insertion are taken from the Punjab Laws portal's consolidated text as
quoted, not from the Act itself; a Punjab accountant should confirm them
against the Act as amended by the Punjab Finance Act, 2026.

The core files one return per pack. The five authorities' returns are
therefore not boxes of Ekwo's filing: their tax is booked on its own accounts
and is paid to each authority from there. See
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Electronic invoicing

Pakistan has no Peppol-style exchange between businesses, so
`einvoicing.obligation` is `none`. What it has is a real-time reporting regime the
vocabulary cannot hold: section 23(1) of the Act asks for a verifiable and
unique FBR invoice number from the time the Board notifies, section 23(5) lets
the Board require any person or class of persons to integrate their invoicing
system with its computerized system, section 23(6) has licensed integrators
(PRAL among them) do it and requires all Tier-1 retailers to integrate their
outlets with the Board's system for real-time reporting of sales, and Chapter
XIV of the Sales Tax Rules (rules 150Q onwards) sets what the integrated person
must do, among it that Annexure-C of the return is auto-filled from the
electronic invoices. The Finance Act, 2026 added non-compliance with section
23(5) and (6) to the grounds on which the Commissioner may suspend or blacklist
a registration (s. 21(2)); invoices of a suspended person are not entertained
for refund or input tax credit (s. 21(3)). The extension of the obligation to
every registered person came through S.R.O. 709(I)/2025; the dates of its
phases, revised since, are not in the pack.
The pack produces no FBR invoice number, no QR code and no call to the
integration interface; the books issue the sequence `{CODE}-{YYYY}-{NNNN}`.

## What this pack does not do

- **Clearance and integration.** Reporting each invoice to FBR at issue and
  storing the number returned is a function of the book-keeping software, not
  of the pack.
- **Withholding of sales tax.** The Eleventh Schedule makes federal and
  provincial departments, companies and other withholding agents deduct a share
  of the tax on a supplier's invoice and pay it for them; row 16 and row 22 of
  STR-7 report it. Accounts 2102 and 1157 are kept for it; no code posts to
  them. Income tax withholding at source (section 153 and the others of the
  Income Tax Ordinance, 2001) is also outside the pack.
- **The Third Schedule.** Goods listed in the Third Schedule are taxed on their
  printed retail price, not on the supply price; the Finance Act, 2026 widened
  the Schedule (edible oils, confectionery, footwear and others, according to
  the commentary on the Finance Bill). A retail-price tax needs a value the
  document does not carry; no code is provided.
- **Fixed-rate regimes.** Brick kilns, CNG, steel melters and the sector
  adjustments of STR-7 (rows 12, 14, 18 to 21) are not modelled, nor the
  quarterly return that some classes file.
- **Federal excise duty and petroleum levy**, rows 31, 33 and 34 of STR-7.
- **Other reduced rates** of the Eighth Schedule: the tribal-area ladder
  (10 % rising to 16 % by 2028-29), jewellery at 3 %, pharmaceutical
  substances and raw materials at 1 %, DAP at 5 %, imported computers at 10 %.
  `PK-S-10` and `PK-S-1` are the two reduced rates the pack carries; adding another
  rate is a new code.
- **Customs.** Duty, the value addition tax on commercial imports and the
  advance income tax on imports are not modelled.
- **Time of supply.** The Act as updated has no stand-alone rule of the kind a
  value added tax statute carries; `delivery_date` follows the invoice being
  due at the time of supply (s. 23(1)).

## The chart of accounts, and why this one

There is no legal chart of accounts in Pakistan. The chart is the pack's own,
four digits, blocked so that each range reaches one line of the statements. It
is original: it keeps the federal sales tax and the further tax apart from each
provincial tax; a net payable account (2110) and a net refundable account
(1155), the two accounts a filed return settles to; sales tax owed to Customs
on imports (2125); and the accounts a Pakistani company needs that others do
not — EOBI and provincial social security contributions, gratuity, the Workers'
Profit Participation Fund and the Workers' Welfare Fund, Islamic financing and
the super tax.

## The statements

Pakistan has no prescribed layout in the sense of a numbered form. The Companies
Act, 2017 requires financial statements prepared under the framework the Third
Schedule assigns to the class of company — full IFRS for listed, public
interest and large-sized companies, IFRS for SMEs for medium-sized ones and the
Revised AFRS for small-sized entities — in the layout and with the disclosures
of its Fourth and Fifth Schedules. `statements.json` carries the minimum line
items of IAS 1 and of sections 4 and 5 of the IFRS for SMEs, as a statement of
financial position and a statement of profit or loss. The cash-flow statement,
the statement of changes in equity, other comprehensive income and the
Schedules' disclosure formats are not carried. The framework is labelled
`IFRS-SME`, the nearest value the format offers.

## To be read by a Pakistani accountant

1. The Punjab 16 % and the date it applies from (secondary reading).
2. The Islamabad 15 %, and whether the Finance Act, 2026 changed it.
3. The 2026-27 provincial rates, against the provincial Finance Acts of 2026.
4. Where STR-7 reports a local zero-rated supply (the pack puts it in row 9 at
   nil tax) and exempt and non-taxable supplies (the form has no row for them).
5. Whether the IRIS return of 2026 still has the rows of the STR-7 of the Rules
   updated to August 2025.
6. The ceiling of section 8B and the persons excluded from it, which the boxes
   do not apply.
7. The tax point (`delivery_date`).
8. The date from which the 18 % applies to a supply invoiced around 14 February
   2023.
9. The citation of section 223 of the Companies Act, 2017 as the section for
   the content of the financial statements, and the reading of the Fourth and
   Fifth Schedules.
