# Cabo Verde

Everything Ekwo carries for Cabo Verde is data: the Código de Contas of the national
accounting system (SNCRF) as a chart of 224 accounts, the value added tax (IVA) at 15 %
with six exemptions, the export exemption and the tax assessed on services bought from
abroad coded, the monthly return in the numbering of the official form (Modelo 106),
and a balance sheet and an income statement. The format is in
[`docs/packs.md`](../../docs/packs.md); this file says where each line comes from and what
the pack does not do, so that a Cabo Verdean accountant can argue with one sentence
rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The figures are
recomputed from a year of books by `tests/golden.test.ts`, which proves the pack agrees
with itself and not that it is right in law.

**What was read, and what was not.** The Código do IVA was read in the Boletim Oficial
that republishes it (Lei n.º 51/VIII/2013, in force from 1 January 2014) and in the
amendment of 2015 (Lei n.º 81/VIII/2014). The Modelo 106 was read from the form on the
site of the tax administration (DNRE). The Código de Contas was read in the Boletim
Oficial that publishes it (Portaria n.º 49/2008). **Nothing later than the 2015
amendment was searched**: the budget laws of 2016 to 2026 may have changed an exemption,
a deadline or a form, and the current consolidated text was not found on the DNRE site.
A Cabo Verdean reader must confirm that article 17 still reads 15 % and that the
Modelo 106 is still version 3.4.

**Language.** The chart, the taxes and the journals are in Portuguese
(`defaults.language: "pt"`), the official language. Cape Verdean Creole is not carried.

## Sources

| For | Text | Where |
|---|---|---|
| IVA: scope, exemptions (art. 9, 13), rate (art. 17), deduction (art. 21), payment (art. 23), obligations (art. 25), monthly return (art. 37) | Código do IVA, republished by Lei n.º 51/VIII/2013, 27 December 2013 | boe.incv.cv |
| IVA: amendments of arts 14, 32 and 80 | Lei n.º 81/VIII/2014, 8 January 2015 | boe.incv.cv |
| Return: the boxes and their formulas | Modelo 106, version 3.4 | mf.gov.cv (DNRE) |
| Chart of accounts | Portaria n.º 49/2008, Código de Contas of the SNCRF | boe.incv.cv |
| Accounting system | Decreto-Lei n.º 5/2008 (SNCRF); Decreto-Lei n.º 17/2010 (small entities) | boe.incv.cv |
| Electronic invoices | e-Fatura platform of the DNRE | efatura.cv |
| Administration | Direção Nacional de Receitas do Estado | dnre.gov.cv |

## What the pack says

1. **One rate: 15 %** (`CV-S-15`, article 17). The Código has no reduced rate: what the
   legislator spares is exempt, not taxed lower.
2. **Exports and the like** (`CV-S-EXPORT`, article 13): exempt with the right to
   deduct, reported in field 08.
3. **Exempt without the right to deduct** (field 09, article 9): teaching and vocational
   training, medical services, banking, financial and insurance operations, the letting
   of immovable property, and agricultural, forestry, livestock and fishing production.
   The Código lists more than thirty exemptions; the other cases are for the user's
   accountant, and the annexed list of goods (essential goods, medicines, inputs) was not
   read.
4. **Input tax split as the form splits it**: inventories (fields 19–20, account 24421),
   investments (17–18, 24422), other consumer goods (21–22, 24423) and services (23–24,
   24423).
5. **Services bought from a provider with no seat in Cabo Verde** (`CV-P-15-NR`, article
   6(6) and 23(2)): the buyer assesses the tax (field 13, account 24433) and deducts it
   (field 12, account 24423) in the same return, base in field 11.
6. **The return** (`CV-IVA-M106`): every month, even without an operation (article
   25(2)), by the end of the following month (article 37). The boxes carry the field
   numbers of the form; the totals 32, 33, 34, 35 and 36 follow the form's formulas, 38
   is the tax payable and 40 the credit carried to the next period.
7. **The chart** is the official Código de Contas, classes 1 to 7 (equity and the result
   are class 5, expenses class 6, income class 7; there is no class 8). Codes and names
   are the code's; the pack takes the levels a trading company posts to. Where it adds a
   level the code leaves free, it says so in the name: `68881 Arredondamentos`. The VAT
   sub-accounts are the code's own (`24421`–`24423` deductible, `24431`–`24433` charged,
   `24461` payable, `2447` recoverable).
8. **The statements**: a balance sheet and an income statement by nature, grouped over
   the classes of the code.

## What the pack does not do — read before relying on it

1. **No later amendment.** See above: the text read stops at 2015.
2. **Most of the Modelo 106 is not modelled**: fields 03–07 (the cash-basis regime of
   Decreto-Lei 16/2004 for public works), 10 (non-taxed operations), 14–16 (construction
   services, imports paid by the taxpayer), 25–31 (the pro rata and import VAT), 37
   (credit carried from earlier periods), 39, 41 (a refund request) and 42–50 (the
   breakdown tables), as well as the annexes of customers and suppliers. Field 38 equals
   field 35 because field 37 is absent. A return built here is a working base, not the
   file to submit.
3. **No import VAT, no customs.** The tax on imports (the Código taxes imports, article
   1) and the customs declaration are not modelled; the Direção Geral das Alfândegas is
   not read.
4. **No partial deduction and no exclusions.** Articles 20 and 22 (passenger cars,
   representation, pro rata) are not applied: the pack deducts everything that carries a
   deductible code.
5. **The invoice date rule.** `tax_point` is `delivery_date`; article 8 (the tax is also
   chargeable when the invoice is issued before the supply) is not modelled.
6. **No clearance with the tax administration.** The e-Fatura issues electronic invoices
   and tax documents as XML, signed digitally, and authorises their use in real time; it
   says taxpayers previously accredited must use it. Ekwo does not connect to it. The
   schedule of accreditation by taxpayer was not found, so `einvoicing.obligation` is
   `none` and no profile is declared.
7. **Which services article 6(6) lists.** It was read to its first item (rights,
   licences). `CV-P-15-NR` should be checked against the whole list before it is used for
   another kind of service.
8. **The periodic inventory method.** The code has purchase accounts (321, 361) closed to
   the cost of sales at the year end. The pack reads them in the income statement as cost
   of sales and does not post the closing entries; a user who counts inventory at the
   year end posts them by hand.
9. **The official forms of the statements** (the Normas de Relato Financeiro's balance
   sheet and income statement) were not read; the lines here group the classes of the
   code and a Cabo Verdean accountant must align them. The income-tax expense is read in
   account `5932`, as the code prints it, and nothing in the pack computes the income tax
   (IRPC).
10. **Payroll, social security, stamp duty and income tax** are outside this pack.

## To be read by a Cabo Verdean accountant

Everything in 1–10 above; the current rate and exemptions against the consolidated text;
the version of the Modelo 106 and the electronic filing channel (the Porton di Nos Ilha
portal is linked from the DNRE site; which channel takes the Modelo 106 was not
confirmed); the choice of accounts out of the code; the Portuguese wording of the
exemption mention printed on an invoice.

## The golden year

`golden/scenario.json` is a company with four monthly returns, checked by hand (amounts
in escudos, CVE, fictitious): January, a sale of 500 000 (tax 75 000), an export of
800 000, goods for resale bought for 300 000 (tax 45 000), so 30 000 payable; February,
sales of 600 000 less a return of 150 000, so 450 000 (tax 67 500), tuition of 200 000
exempt, services of 100 000 (tax 15 000), so 52 500 payable; March, equipment bought for
1 200 000 (tax 180 000), so a credit of 180 000; April, a sale of 100 000 (tax 15 000)
and a licence bought from abroad for 200 000, on which the buyer assesses 30 000 and
deducts 30 000, so 15 000 payable. Four payments, one of them on account and unmatched.
The contacts are named as plainly fictitious.
