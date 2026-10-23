# Andorra

Everything Andorra adds to Ekwo, as data: a chart of accounts, the journals,
the general indirect tax (IGI, *impost general indirecte*) at the general rate
of 4.5 %, the special rate of 2.5 %, the reduced rate of 1 %, the super-reduced
rate of 0 % and the increased rate of 9.5 % on banking and financial services,
exports, other exempt operations, the IGI paid at customs on imports, one
declaration whose period follows the turnover of the year before, and a balance
sheet and an income statement laid out on the headings of the *Pla general de
comptabilitat*. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files an Andorran IGI declaration has
reviewed it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and proves
nothing about whether it is right.

**Language.** `defaults.language` is `ca`, the official language of Andorra;
every label is written in Catalan and the pack carries no second language.

## Sources

| Key | What it is |
|---|---|
| `igi-law` | Llei 11/2012, of 21 June, on the *impost general indirecte*, as published in the BOPA of 18 July 2012 (in force on 1 January 2013): articles 57 to 60 (rates), 14 (exports), 61 to 63 (deduction), 78 (settlement and its periods). |
| `igi-law-2014` | Llei 10/2014, which adds article 60 bis, the special rate of 2.5 %, in force from 1 July 2014. |
| `tax-calendar` | The Govern's tax calendar (2023 edition), which shows the three cadences of the IGI settlement. |
| `accounting-law`, `pgc` | Llei 30/2007 on the accounts of businesses (consolidated text) and Decret 479/2025, the new *Pla general de comptabilitat*. |
| `e-tramits` | The Govern's electronic office, where the declaration is filed. |

## What was read, and what was not

The text of Llei 11/2012 read is the one published in the BOPA in 2012, with
Llei 10/2014 on top. **Amendments after 2014 were not read**, nor was the
IGI regulation or the invoicing regulation. A rate, a list of operations or a
threshold changed since is not in the pack. The lists behind the 1 %, 0 % and
2.5 % rates were read in outline and are carried by one code each: which item
of the list applies is the preparer's judgement. Chapter three of the law
(operations exempt inside the territory) is carried by one code, without
reading it item by item.

## The declaration

Article 78 of the law sets the period by the net turnover of the previous year:
below EUR 250,000 a semi-annual settlement (July and January), below
EUR 3,600,000 a quarterly one (April, July, October, January), and a monthly
one above. The declaration is `AD-IGI` with `month`, `quarter` and `half_year`.

**The lines of `tax_report.json` are the pack's own layout, not the boxes
printed on the official model.** The model (form 900, and 910 for the
semi-annual filer, according to the profession's guides) was not available as a
readable text, so the lines follow what the law makes a settlement of: tax
charged by rate, imports, exports, other exempt operations, deductible and
non-deductible purchases, and the result. A preparer must carry the figures to
the official form on the Govern's electronic office. **The pack states no
deadline**: the day by which the declaration is due is set by regulation, which
was not found.

## The chart of accounts

No numbered chart of accounts was found in Llei 30/2007 or in the *Pla general
de comptabilitat*; the chart is original: four digits, 134 accounts, grouped as
the plan the profession uses (1 equity and long-term debt, 2 non-current assets,
3 stocks, 4 third parties and the IGI accounts, 5 financial accounts, 6
expenses, 7 income). The accounts the declaration depends on:

| Account | Role |
|---|---|
| 4720 | IGI borne, debited by every deductible purchase |
| 4770 | IGI charged, credited by every taxable sale |
| 4780 | IGI on imports owed to customs at the border |
| 4700 / 4750 | Settlement accounts of a declaration filed: IGI refundable / IGI payable |

## The statements

The balance sheet and the income statement are the headings of the *Pla
general de comptabilitat*. **The printed models are images in the text read**,
so the lines are the pack's own abridged layout over those headings, and the
statement of changes in equity, the cash-flow statement and the notes of the
normal model are not carried. The decree reduces the models of annual accounts
to a normal and an abridged one.

## Not carried

- Reverse charge on services bought from a supplier established abroad: no
  article of the text read makes the buyer assess the tax (recorded in
  `not_taxed`); if a rule exists elsewhere it is a gap.
- The simplified special regime, the refund regime for businesses not
  established in Andorra (article 73), the pharmacy refund option and the other
  special regimes of the law.
- Customs exemptions on import (articles 36 to 41): one is not coded; an
  exempt import is a purchase at `AD-P-0`.
- The IGI invoicing rules: no e-invoicing obligation was found, and
  `einvoicing.obligation` is `none` for want of a text.
- Corporate income tax, the tax on income from economic activities and the
  social security contributions: only the accounts to book them.
- Hand-reviewed by an Andorran accountant: nothing here has been.
