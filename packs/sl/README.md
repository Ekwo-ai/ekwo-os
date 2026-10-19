# Sierra Leone

Everything Sierra Leone adds to Ekwo, as data: a chart of accounts, the
journals, goods and services tax (GST) at 15 %, the zero rate and the
exemptions, a monthly GST return built from the net-amount calculation of the
Act, the statement of financial position and the statement of profit or loss of
an IFRS-based presentation, and what section 24 of the Act does with a service
bought from abroad. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that a
Sierra Leonean accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Sierra Leonean GST return has
reviewed it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English only.** English is the official language of the Goods and Services Tax
Act and of every document of the National Revenue Authority ("the Authority",
NRA). This pack declares `en` alone. The currency is the new leone (**SLE**, two
decimals), in force since the redenomination of 1 July 2022 (1 SLE = 1,000 of
the old SLL). The old code SLL is not used anywhere. The tax is called GST, not
VAT, in every label.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text it comes from. The register in `pack.json` holds seven
texts:

| What | Text | Where |
|---|---|---|
| The charge to tax, the 15 % rate, registration, reverse charge, input tax, invoices, returns, the four schedules | Goods and Services Tax Act, 2009 (Act No. 6 of 2009) | `sierra-leone.org` (Gazette copy) |
| The exempt supplies (Second Schedule replaced by 25 items), the tourism levy | The Finance Act, 2023, ss. 5 to 7 | `archive.gazettes.africa` |
| Single rate, categories of supply, invoice contents, filing and payment dates, tax periods | NRA, Goods & Services Tax | `nra.gov.sl` |
| Due dates and rates of the other taxes | NRA, Domestic Taxes & Rates | `nra.gov.sl` |
| The electronic cash register | NRA, Electronic Cash Register | `nra.gov.sl` |
| Where the return is filed | ITAS | `itas.nra.gov.sl` |
| The accounting framework | IFRS Foundation, jurisdiction profile | `ifrs.org` |

**What the sources are, and are not.**

- The Act is the Gazette text of 2009 as enacted. **It is not a consolidated
  edition.** Later Finance Acts amended it (the registration
  threshold, the electronic cash register of s. 34, digital services, the
  schedules, the due date of payment); only the Finance Act 2023 was read here,
  and the copy found is the *Bill* supplement of the Gazette of 28 March 2023,
  not the enacted Act.
- The Authority's GST page still describes the 2009 launch (a threshold of
  Le 200,000,000, a month for turnover above Le 600,000,000 and two months for
  the others). Those amounts are in the old leone and were not found restated in
  new leones.
- Some secondary commentary reports changes by the Finance Acts 2024 and 2026
  (a higher registration threshold, an end-of-month payment date, a revised list
  of zero-rated items, an obligation to replace faulty cash registers). None of
  it could be tied to an official text, so none of it is in the pack.
- `mail.nra.gov.sl` is the host of the Authority's pages that could be opened
  from the machine this pack was written on; its certificate was invalid there,
  so link checks (`ekwo pack check sl --links`) may report the NRA pages
  unreachable. `parliament.gov.sl`, which also serves the Act, answered with an
  error and was not used.

## The chart of accounts, and why this one

There is no legal chart of accounts in Sierra Leone. This one is original: four
digits, blocked so that each range reaches one line of the statements, 147
accounts. Beyond a general IFRS-style chart it carries what a Sierra Leonean
company owes: GST output and input, the net GST settlement account, import GST
at the border, PAYE, NASSIT contributions, payroll tax, withholding tax, the
tourism levy and excise duty payable, and two cost accounts for the GST the law
does not let a buyer recover (6520 and 6530).

Only trade receivables, trade payables and the two GST settlement accounts
(1155 and 2110) are reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `SL-S-15` | 15 % | Sale, standard rate (s. 14) |
| `SL-S-Z-EXP` | 0 % | Zero-rated: export of goods other than minerals; goods shipped as stores on a vessel or aircraft leaving (First Schedule items 1 and 2) |
| `SL-S-EX` | 0 % | Exempt sale (Second Schedule) |
| `SL-P-15` | 15 % | Purchase, input tax deductible (ss. 28, 29) |
| `SL-P-15-ND` | 15 % | Purchase whose input tax is barred: entertainment, motor vehicles for 12 or fewer passengers, mobile phone handsets (s. 28(2)) |
| `SL-P-EX` | 0 % | Purchase of an exempt supply |
| `SL-P-IMP` | 15 % | Import of goods, GST collected at the border (ss. 14, 39, 40) |
| `SL-P-RC-SVC` | 15 % | Service imported from a non-resident, reverse-charged to the extent it serves exempt supplies, private use or entertainment (s. 24) |

Choices worth reading:

- **Services are never zero-rated by the Act's First Schedule**, which lists
  exports of *goods* only. A consultant billing a foreign client therefore has
  no code of its own here; whether such a supply is taxable at 15 % or outside
  the charge is a question for the accountant, and the pack does not guess.
- **Exports of minerals are not zero-rated.** The First Schedule excludes
  rutile, iron ore, bauxite, gold, diamonds and other minerals; the 2009 Second
  Schedule listed the export of all minerals as exempt, and the Authority's page
  still does. The 25-item schedule of the Finance Act 2023 (as the Bill reads)
  does not list them. The pack carries no code for them rather than choose.
- **The exempt list is long** (25 items). `SL-S-EX` stands for all of them; the
  item is named in the invoice line. Several items depend on a ministerial
  gazette (approved schools, approved drugs).
- **Reverse charge on imported services** applies only to the share of the
  service used for exempt supplies, private use or entertainment (s. 24(1)); a
  fully taxable business accounts for nothing. `SL-P-RC-SVC` is for that share
  only. The tax is posted as output tax and, since the use bars recovery, stays
  in the cost account 6520.
- **Tourism levy, 2 %** on accommodation, food, drink and related services of a
  tourism establishment (Finance Act 2023, s. 7), collected under the GST rules
  of registration and filing and paid by the 15th of the following month into a
  ring-fenced account. It is a separate levy on the same sale and is **not
  computed**; account 2165 holds it.
- **Transfer of a going concern** is outside the scope of GST (Fourth Schedule);
  it has no code.
- **Relief vouchers** (Third Schedule: embassies, disaster relief and other
  institutions) are recorded on the return by the supplier; not modelled.

## The return

Monthly. Section 37 asks for a GST return per tax period in the prescribed form,
filed with the Authority; section 27 gives the net amount (output tax less input
tax credits), and section 41 makes a negative amount refundable. The pack's
boxes follow that calculation: 1 output GST, 2 input GST on domestic purchases,
3 input GST on imports, 4 total input GST, 5 GST payable or refundable, with
value rows of its own for zero-rated supplies, exempt supplies, standard-rated
supplies and purchases, and imported services. **The layout of the official
return on ITAS could not be opened**, so these box numbers are the pack's own
and may differ from the form; the gap is the first thing to confirm.

**Deadline.** The last day of the month after the period (s. 37(1)); the GST is
payable on the same day (s. 38(1)). The Act and the Authority both say the end of the month, not the 15th, and that
is what the pack carries. The 2 % tourism levy has its own 15th.

**Tax period.** A month in the Act. The Authority's page says two months for
taxpayers below Le 600,000,000, in old leones; the pack carries the monthly
return only.

**Registration.** Required when GST-exclusive taxable turnover exceeds the
threshold in twelve months, one third of it in four months, or when that is
expected (s. 15). The threshold is Le 200,000,000 in the 2009 text and
"may be amended by statutory instrument"; its present value in new leones was
not found, and the pack does not check a threshold. Registration is by form
GST 01 and a TIN.

**Records.** Six years; returns in leones. The Act and the Authority ask for a
conversion of foreign currency at the rate on the day of supply.

## Electronic invoicing: a cash register, not an exchange

Sierra Leone has no Peppol authority and no structured business-to-business
invoice, so `einvoicing.obligation` is `none`. What exists is the electronic
cash register: s. 34 of the GST Act, replaced by the Finance Act 2020, requires
every registered business to keep a register made of a Certified Invoicing
System and a Sales Data Controller that signs each receipt and transmits it to
the Authority. Ekwo does not drive such a device: **the pack documents it and
the core is not patched.** A registered business using Ekwo keeps its register
and posts the invoice in Ekwo from what the register issued.

## Other taxes, documented and not computed

From the Authority's table of rates (no date is verified beyond the page):

- **Withholding tax** on payments for supplies and services above Le 500,000
  (old leones): 5 % for local contractors, 10 % for foreign contractors, 25 % on
  natural-resource payments; paid by the 15th of the following month.
- **PAYE** (15 %, 20 %, 30 % bands), monthly by the 15th; **payroll tax** on
  foreign employees, yearly; **NASSIT** contributions (the social security
  trust) are not on that table and are not sourced here.
- **Corporate income tax** 30 % of chargeable income, with a 3 % minimum
  alternate tax on turnover from the Finance Act 2023, quarterly instalments
  and a 30 April annual return; **rent tax**, **capital gains tax**, **foreign
  travel tax**.

Accounts exist for these; no tax code does.

## What this pack does not carry

- The partial-exemption apportionment (a business with taxable and exempt
  supplies recovers only the taxable share, s. 29), bad-debt relief,
  post-supply adjustments, the special retail schemes and the GST on digital
  services supplied by non-residents (registration of non-resident providers,
  Finance Act 2023 and later).
- The 2 % tourism levy, the electronic cash register, the withholding of GST by
  appointed agents if any, and the two-month return.
- A separate code for the services exported, the exports of minerals and the
  many items of the Second Schedule beyond one exempt code.
- The exemption reason code (BT-121): Sierra Leone is outside the common
  system, so no VATEX code is carried.
- Corporate income tax, minimum alternate tax and capital allowances.
- Any change by the Finance Acts of 2024, 2025 and 2026, for want of an
  official text.

## Reviewing this pack

A Sierra Leonean accountant is asked to confirm, first: the current
registration threshold in new leones; the box layout of the ITAS GST return; the
exempt list as enacted in 2023 and amended since (minerals, water, fuel); the
zero-rated list after the Finance Act 2026 reported by commentary; the treatment
of services supplied to non-residents; whether the monthly period is the only
one in force; the due date of payment as amended in 2026; and the list of
ministry-gazetted items (approved schools, approved drugs).
