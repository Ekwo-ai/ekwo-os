# Mozambique

Everything Mozambique adds to Ekwo, as data: a chart of accounts taken from the
legal code of accounts, the journals, value added tax (IVA) at 16 %, the
reduced rate of 5 %, the closed 17 % rate, exports and the other zero-rated
supplies, exemptions with and without a right to deduct, the reverse charge on
services and digital goods bought from non-residents, the monthly periodic
return (Modelo A), and the balance sheet and income statement of the national
accounting system. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that
a Mozambican accountant can disagree with a specific sentence rather than with
the whole.

**Status: `community`.** Nobody who files a Mozambican return has reviewed it.
`tests/golden.test.ts` replays a month of books (18 documents, 4 payments)
against figures worked out by hand; that proves the pack is coherent and
proves nothing about whether it is right.

**Portuguese only.** The VAT Code, the accounting decree and the return are
published in Portuguese, which is `defaults.language`; the pack declares no
other language and invents no translation.

## Sources

The register in `pack.json` holds seven texts, opened on 9 October 2026. The
Código do IVA (Lei n.º 32/2007) was read in the consolidated text that
includes Lei n.º 10/2025; the Boletim da República itself could not be fetched,
so the consolidated copy is cited and its footnotes name the amending laws.
The Autoridade Tributária (AT) sites answer with an untrusted certificate to
some clients, which is why the return is cited from the form served by the
e-Declaração portal and the filing portal from the Portal do Contribuinte.

| What | Text |
|---|---|
| Rates, exemptions, zero rating, reverse charge, deduction, invoices, return deadlines | Código do IVA, arts. 6, 7, 8, 9, 13, 17, 17-A, 18, 19, 20, 25, 26, 27, 32 |
| What changed on 1 January 2026 | Lei n.º 10/2025, de 29 de Dezembro, in the Code's footnotes and in a law-firm summary |
| Return boxes | Modelo A, the e-Declaração form |
| Chart and statements | Decreto n.º 70/2009, chapters 1.5 and 1.6 |
| Invoice reporting | Aviso n.º 40/AT/DGI/2025 |

## The chart of accounts

**The legal chart is the chart.** Decreto n.º 70/2009 approves the Sistema de
Contabilidade para o Sector Empresarial: full IFRS for large and listed
entities, the PGC-NIRF for medium entities and the PGC-PE for small ones. The
decree prints the code of accounts of the PGC-NIRF (chapter 1.5) in eight
classes. This pack transcribes the codes and names of that detailed table at
the depth a trading company uses (339 accounts), with the dots between levels
dropped: 4.4.3.3.1 is `44331`. Four accounts are additions, named as such in
the chart's `legal_reference`: `44324` (deductible VAT on imports), `4691`
(import VAT owed to customs), `4699` (suspense) and `68991` (rounding).

The PGC-PE chart for small entities is not carried; a small entity can use
this chart and its subset of accounts.

**Purchases are booked straight to `6112`** (cost of goods sold) and not to
the periodic-inventory account 2.1 the decree lists, so that `purchase`
has an expense account to land on; a company that keeps the periodic method
adds its own accounts.

**Only four accounts are `reconcilable`:** customers `411`, suppliers `421`
and the two VAT settlement accounts `4437` (VAT payable) and `4438` (VAT
recoverable). Neither bank nor cash nor the suspense account is.

**The VAT settlement accounts are not posting accounts.** Output tax posts to
`44331` (general operations) and `44333` (special operations, the reverse
charge); deductible tax posts to `44321` (inventories), `44322` (fixed
assets), `44323` (other) and `44324` (imports), mirroring boxes 06, 05, 07
and 08 of the return.

## Taxes

| Code | Rate | Box | Legal basis |
|---|---|---|---|
| `MZ-S-16` | 16 % | 01, 02 | art. 17(1), Lei 22/2022, from 1 Jan 2023 |
| `MZ-S-5` | 5 % | 01, 02 | art. 17-A: private health, private education, vocational training, private lessons |
| `MZ-S-17` | 17 % | 01, 02 | closed code, 2008-01-01 to 2022-12-31 |
| `MZ-S-EXP`, `MZ-S-EXP-SVC` | 0 % | 03 | art. 13(1): exports and international transport, with a right to deduct |
| `MZ-S-EX-STAPLES` | exempt | 03 | art. 9(10) with art. 19(1)(b)(v): exempt with a right to deduct |
| `MZ-S-EX-FIN` | exempt | 04 | art. 9(4) and (6): banking, finance, insurance |
| `MZ-S-EX` | exempt | 04 | art. 9: public health and education, housing rent, others |
| `MZ-P-16-INV`, `-FA`, `-SVC` | 16 % | 06, 05, 07 | art. 18: deductible, by nature of the purchase |
| `MZ-P-17` | 17 % | 07 | closed code |
| `MZ-P-16-FUEL` | 16 % | 07 (half) | art. 20(1)(b): diesel, 50 % deductible |
| `MZ-P-16-EXC` | 16 % | none | art. 20(1): cars, travel, hospitality, mobile phones, luxury |
| `MZ-P-16-ND5` | 16 % | none | art. 19(2), from 1 Jan 2026: input tax of 5 % supplies |
| `MZ-P-5-ND` | 5 % | none | art. 20(2): tax paid at 5 % is not deductible |
| `MZ-P-EX` | exempt | none | art. 9 |
| `MZ-P-IMP` | 16 % | 08 | arts. 7(1)(c), 18(1)(b): import VAT paid at customs |
| `MZ-P-RC-16` | 16 % | 01, 02, 07 | art. 6(7), 26(3)–(4), 18(1)(c)–(d) |

**Zero rating is an exemption with a right to deduct.** Mozambique writes
exports as exempt operations (art. 13) and gives them the right to deduct
(art. 19(1)(b)); the effect is a zero rate, and the codes use treatment
`export`, rate 0.

**The 5 % rate carries no right to deduct.** Art. 20(2) (Lei 22/2022) excludes
the tax paid on 5 % supplies, and art. 19(2) (Lei 10/2025) excludes the
deduction of input tax attributable to them. `MZ-P-16-ND5` and `MZ-P-5-ND`
make the purchase tax part of the cost and reach no box. The pack cannot split
a mixed-use purchase between 16 % and 5 % supplies: it offers the two ends
(wholly deductible, wholly disallowed) and no ratio. Art. 22 (partial
deduction) is not modelled either.

**Digital goods and services of non-residents.** Since 1 January 2026
art. 6(7)(k) taxes digital goods and services supplied by someone with no seat
or establishment in Mozambique; art. 26(4) puts the obligations on a taxable
buyer. `MZ-P-RC-16` self-assesses the tax and deducts it in the same return.
**The Modelo A has no field for self-assessed output tax**, so the pack posts
the base and the output tax to boxes 01 and 02 and the deduction to box 07. That
is an assumption for a reviewer. The B2C side, where the non-resident supplier
must register (art. 26(1)), is the supplier's obligation and is not modelled.

**The 17 % start date.** The closed 17 % codes begin on 2008-01-01, when the
Code took effect; the consolidated text only records that Lei 22/2022 replaced
17 % with 16 % from 1 January 2023.

## The return

**Modelo A, boxes 01 to 15.** `tax_report.json` reproduces the boxes of the
e-Declaração form: 01 and 02 (base and tax of taxed supplies), 03 (exempt with
a right to deduct), 04 (no right to deduct), 05 to 08 (deductible tax: fixed
assets, inventories, other, imports), 09 and 10 (adjustments, filled by hand;
no tax writes into them), and the totals 11 to 15. The form still prints the
old rate of 17 % in its caption; the pack follows the law.

**Two deadlines, one declared.** Art. 32(1), as written by Lei 10/2025: the
15th of the following month for a return showing a credit or no operations;
the last day of the following month for a return with tax to pay; the 10th of
the following month for the operations of art. 26(4) (digital supplies
bought from non-residents). The format holds a single deadline per return, so
the pack declares `last_day_of_month_after_period`, the date of a return with
tax to pay. A company in credit files by the 15th; the golden scenario is
a credit position and so would be due on the 15th.

**What the pack leaves out of the form:** the identification and "no
operations" tables, the use of credits from earlier periods (boxes 16 and 17),
the amount due and interest (boxes 18 to 20) and the credit carried forward or
refunded (boxes 21 to 23). The refund period moved from 30 to 150 days with a
ten-year limit (Lei 10/2025).

**Filing at 5 %.** The Portal do Contribuinte notes that taxpayers whose supplies
are taxed at 5 % submit a payment slip at an AT collection unit and request
the GARE payment document, until the portal is adapted. The pack cannot tell
a 5 % filer from another.

**Repealed regimes.** Lei 10/2025 (art. 3) repeals the exemption regime and the
simplified regime; every taxable person files the normal return.

## Electronic invoicing

`einvoicing.obligation` is `none`: no Mozambican text obliges companies to
exchange structured invoices between themselves. What exists is reporting to
the tax authority. Art. 27(10) of the Code and Aviso n.º 40/AT/DGI/2025 (27
March 2025) oblige taxpayers who issue invoices by computer program to submit,
every month from May 2025 through e-Declaração, the file of the previous
month's invoices (XML, XLSX or CSV), extracted from billing software certified
by the AT. The full SAF-T (Moz) file, the software certification regulation
and the fiscal machines tied to the AT (Regulamento das Máquinas Fiscais,
reported as Decreto n.º 92/2014 by a search result that was not opened) are
announced or being phased in; no real-time clearance is in force. Ekwo does not
produce the monthly invoice file or any SAF-T (Moz) structure, does not
certify as billing software, and does not talk to a fiscal machine. These gaps
are written up in [`docs/international.md`](../../docs/international.md)
under "Mozambique".

Art. 27(5)(f) asks for the Bank Identification Number (NIB) on the invoice; the
pack's `documents.mentions` is empty and carries no mention for it.

## Not in this pack

- Real-time or periodic invoice clearance, SAF-T (Moz), certified billing
  software, fiscal machines.
- Withholding at source (IRPC, IRPS, payments on account) and the corporate
  income tax return; INSS contributions have an account and no tax code.
- The PGC-PE chart for small entities, the cash flow statement and the
  statement of changes in equity (the format knows two statement kinds only).
- Partial deduction (art. 22) and the reduced taxable bases of art. 15(2)(j)–(m)
  (energy, aeronautical fees, public works, drinking water), whose deduction is
  reduced in the same proportion (art. 18(6)).
- Specific taxes: excise and stamp duty are not VAT.

## Reviewing this pack

A Mozambican accountant is asked to check:

1. Where self-assessed VAT on imported services goes on the Modelo A (boxes
   01/02 and 07 are an assumption).
2. Whether the form still numbers its fields 01 to 23 after the 2026 reform,
   and how a 5 % filer is expected to declare.
3. The 17 % start date, 2008-01-01.
4. The treatment of mixed supplies (16 % and 5%) and of the reduced-base
   operations of art. 15(2).
5. The classification in art. 19(1)(b)(v) of the exempt-with-deduction
   supplies of art. 9, which this pack reads for staples, and not for the other
   sub-items it lists.
6. The statement mappings (Decreto n.º 70/2009, chapter 1.6), which are this
   pack's selection.
