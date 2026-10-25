# Palau

Everything Palau adds to Ekwo, as data: a chart of accounts, the journals, the
Palau Goods and Services Tax (PGST) at 10 %, the zero rate and the exemption of
financial services, the monthly PGST return Tax 500 with its lines A to P, and
the statement of financial position and the statement of profit or loss in the
layout of IAS 1. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and what it does not say yet.

**Status: `community`.** Nobody who files a Palau PGST return has reviewed it. The
figures are replayed against a month of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the Act, of the Regulations and of
the forms of the Bureau of Revenue and Taxation (BRT). Palauan is also an
official language; the pack declares `en` alone. The currency is the United
States dollar (USD, two decimals).

## Sources

Nine texts, all from the BRT and the Ministry of Finance of Palau or the IFRS
Foundation, in `pack.json`: RPPL No. 11-11 (the Act), the PGST Regulations, the
form Tax 500 and its instructions, the BRT's note on input tax credits and
returns, its pages on the types of supplies and on the registration threshold,
the taxpayer calendar, IAS 1 and the BRT page. The Act was read at source, in its
published PDF.

## Decisions

- **The tax started on 1 January 2023.** It replaced the Gross Revenue Tax
  (GRT) for the persons who register for PGST. The codes open on that date.
- **One return, monthly.** The PGST period is a calendar month (§ 1202). The
  pack declares the period `month` and nothing else.
- **The form has two columns.** The amount excluding PGST (column 1) and the
  PGST (column 2). Boxes with both columns are two boxes of the pack, the
  `base` and the `tax` of one line: A, E, G, J and K. The totals D, I, N, O
  and P are computed. Line P is signed: negative is a credit carried forward
  (§ 1262), not a payment.
- **Imports.** The PGST on a taxable import is collected at the time of import
  (§ 1214, § 1283) and sits on the import account until it is paid; it is claimed
  in line G.
- **Imported services.** Lines J and K of the form apply to a person who makes
  exempt supplies as well. `PW-P-RC-SVC` credits the whole service; the share used
  for exempt supplies is the preparer's adjustment. A person whose supplies are all
  taxable uses `PW-P-0` (Regulations § 312(a)).
- **Exemption.** The only exempt supply is a financial service (§ 1213); the
  code posts to line C.

## What the pack does not say yet

- **The due date.** The Act says thirty days after the end of the period, the form
  the thirtieth of the following month. The pack uses the thirtieth of the following
  month: for January it is two days earlier than the Act (2 March), and the move to
  the next working day is not applied.
- **Capital assets.** Lines L and M are declared and empty; no code knows whether
  an item is a capital asset.
- **Apportionment.** An input credit for acquisitions made partly for exempt
  supplies (Regulations § 401) is the preparer's; the codes credit what they are
  given in full.
- **Transitional credit** on stock at the start of the tax (Tax 500A), the
  **continuation sheet** by business licence, and the **refund application** are not
  produced. The return has to be filed on the form or the Tax Filing App of the BRT.
- **Registration.** The threshold (USD 300,000 of average taxable supplies) and the
  voluntary band are not modelled.
- **Remote services through a platform, tourism products, second-hand goods,
  vouchers, agents** (Regulations Part 3) are not modelled.
- **Time of supply** (§ 1232) is replaced by the invoice date; the payment basis is
  not carried.
- **Other taxes** (business profits tax, wages and salary tax, gross revenue tax of
  the persons not registered, hotel and remittance taxes) are not in the pack beyond
  a few liability accounts. A business not registered for PGST files the GRT, which
  this pack does not carry.
- **Statements.** No Palau text prescribes a layout; the statements follow IAS 1
  with expenses by nature. The IFRS Foundation page of Palau could not be read.
- **E-invoicing.** None found, so `obligation` is `none`.
