# Madagascar

Everything Madagascar adds to Ekwo, as data: a chart of accounts, the journals,
the value-added tax (TVA) at 20 %, the reduced rate of 5 % for butane gas, the
zero rate of exports and the exemptions of article 06.01.06, the monthly return
as the Code des impôts describes it, the balance sheet and the income statement
by nature of the Plan comptable général 2005, and what the Code does with a
service bought from a supplier without an establishment in Madagascar. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that a Malagasy
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files a Malagasy VAT return has reviewed it.
The figures are replayed against two months of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**French only.** The official languages are Malagasy and French; the Code and
the Plan comptable are published in French, so the pack's names and legal
references are in French and it declares no other language. The currency is the
Malagasy ariary (MGA, two decimals in ISO 4217).

## Sources

- **Code des impôts, following the finance law 2024** — Book I, VAT: articles
  06.01.01 to 06.01.29. Read in full for VAT in a consolidated PDF that the
  programme pS-Eau hosts; the Direction générale des impôts' own site
  (impots.mg) loads its documents through a script and serves no file to a
  command-line reader. The text read is that of the finance law 2024.
- **Plan comptable général 2005** (decree 2004-272 of 18 February 2004) — annex 1,
  the models of financial statements, read in a copy on SlideShare because the
  official address of the Conseil supérieur de la comptabilité (csc.mg) did not
  answer.
- **The Direction générale des impôts portal** (`https://www.impots.mg`), where
  returns are filed online.

## The chart of accounts, and why this one

The Plan comptable général 2005 is compulsory and its detailed list of accounts
was **not readable** from the machine that wrote this pack. The chart here is
therefore the pack's own: four digits, in the seven classes of the Plan (1
capital, 2 fixed assets, 3 stocks, 4 third parties, 5 treasury, 6 expenses, 7
income), and with the lines of the annex 1 statements in mind. 119 accounts.
The account numbers are **not** claimed to be those of the official list; a
Malagasy accountant is asked to compare them (see the last section).

Five accounts carry VAT: 4457 collected, 4456 deductible, 4458 import VAT owed
to Customs until it is settled, 4455 the balance to pay after a return and 4459
the credit to carry forward or to claim back. The settlement accounts (4455,
4459) are distinct from the accounts a tax posts to, as the filing tests
require. Account 6318 receives the VAT the Code does not let a business deduct.
Only receivables, payables and the two settlement accounts are reconcilable.

## Taxes

| Code | Rate | What |
|---|---|---|
| `MG-S-20` | 20 % | Sale of goods or services made in Madagascar (art. 06.01.02, 06.01.12) |
| `MG-S-5` | 5 % | Sale of butane gas and its container (art. 06.01.12) |
| `MG-S-EXP` | 0 % | Export of goods and services (art. 06.01.12) |
| `MG-S-EX` | exempt | Operations of art. 06.01.06 (tuition fees, bank interest, life insurance…) |
| `MG-P-20` | 20 % | Local purchase, tax deducted in full (art. 06.01.17 A 1°) |
| `MG-P-5` | 5 % | Local purchase of butane gas, tax deducted |
| `MG-P-20-ND` | 20 % | Purchase whose tax art. 06.01.18 excludes (private cars, furniture, some fuels…), posted to 6318 |
| `MG-P-EX` | exempt | Purchase of an exempt good or service |
| `MG-P-IMP` | 20 % | Import: tax collected by Customs (art. 06.01.14), deducted (06.01.17 A 2°), held on 4458 |
| `MG-P-RC` | 20 % | Service from a supplier without an establishment: the beneficiary pays the tax (art. 06.01.09 bis) and deducts it |

A line names its tax by code. The threshold of art. 06.01.04 (annual turnover of
400 000 000 Ar or more, or the option for the *régime du réel*) is not checked
by the pack: a company below it is not a VAT payer and should not use these
codes.

## The return

Monthly: article 06.01.16 has the taxpayer calculate the tax at the end of each
month and pay it, with the return, at the latest on the **15th of the following
month**, return filed even when nothing is due. The pack's deadline is
`day_of_month_after_period`, day 15. The return form (an *imprimé* supplied by
the Administration) was not readable: the boxes in `tax_report.json` are the
pack's own rows, grouped under the amounts the Code names (tax collected,
deductions, balance), and their codes (`S20`, `P20`, `IMP`…) are internal
labels, not form numbers. `T3` is positive for tax to pay and negative for a
credit, which art. 06.01.23 lets be carried to the following months.

**Reverse charge.** Art. 06.01.09 bis makes the beneficiary of a taxable service
from a person without an establishment liquidate and pay the tax by the 15th
of the following month, on a separate form from its own return. The pack posts
the tax in box `RC` and the deduction in box `RCD` of the same return; the
separate form was not read.

## Fiscal year

The Code lets the financial year coincide with the calendar year or run from
1 July to 30 June; the pack declares `calendar`.

## Electronic invoicing

No structured e-invoice obligation was found in the text read:
`einvoicing.obligation` is `none` and the profile is null.

## What this pack does not say yet, and why

- **The Plan comptable général account list.** Its numbering could not be read;
  the chart is the pack's own (above). The statements follow the annex 1
  models in fewer lines, without the gross/depreciation columns.
- **The finance laws 2025 and 2026.** The text read is the 2024 edition; any
  later change of a rate, a threshold or an exemption is a gap.
- **The return form** on the portal and the separate form of art. 06.01.09 bis.
- **The list of exemptions**: art. 06.01.06 and 06.01.08 hold more cases than the
  one code carries, and the exemption of definitive imports of equipment
  (06.01.07) and of suspended regimes are not modelled.
- **Proportional deduction** (prorata) of art. 06.01.17 A 2° for mixed
  businesses, the payment-by-bank condition of A 1°, the petroleum rules of B.
- **Refund of credits** (art. 06.01.24) for exporters and investors, and the
  export formalities it requires.
- **The invoice particulars** of art. IV-21 of the Code des procédures fiscales,
  not read: the numbering is sequential, not gapless. The time of supply of
  services is also unread; `invoice_if_issued` is the nearest value.
- **The reduced 5 % rate on the import of butane gas**: only sales and local
  purchases have a code.
- **Other taxes**: IRSA (tax on salaries), IR (income tax), the synthetic tax and
  customs duties have accounts but no tax code.
- **A Malagasy translation.**

## Reviewing this pack

A Malagasy accountant is asked to confirm: the account numbers against the
official Plan comptable général 2005; the rates and threshold against the
current finance law; the return's rows against the form on the portal; the cases
of art. 06.01.18 behind `MG-P-20-ND`; the treatment of a service from abroad in
a partly exempt business; and the filing day when the 15th falls on a day off.
