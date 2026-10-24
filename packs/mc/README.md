# Monaco

Everything Monaco adds to Ekwo, as data: a chart of accounts, the journals, the
value added tax (taxe sur la valeur ajoutée, TVA) rates and where each one
posts, the boxes of the periodic return, and the invoicing rules of the annex
to the Code des taxes sur le chiffre d'affaires. The format is
[`docs/packs.md`](../../docs/packs.md); this file records what the pack
deliberately leaves out and why.

**Status: `community`.** Nobody has reviewed it against the law it applies.
The figures are replayed against two months of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `fr`, no further language.** The official language of the
Principality is French.

## Sources

Five texts, every one of them opened on 24 October 2026:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, places of supply, deduction, exigibility, the return, invoices | Code des taxes sur le chiffre d'affaires (CTCA), consolidated at 1 August 2026, with its annex | Legimonaco |
| Books, annual inventory, ten-year retention, annual accounts | Code de commerce, consolidated at 17 October 2026 (art. 10–13, 51-6, 51-7) | Legimonaco |
| Structure of the chart | Règlement ANC 2014-03 (plan comptable général) | Autorité des normes comptables, France |
| Numbering of the return's boxes | Form 3310-CA3-SD, French model | DGFiP, France |
| Where the administration is reached | Page "how to declare a business to the Department of Tax Services" | MonEntreprise |

## How Monaco's VAT relates to France's

Article 15 of the Franco-Monegasque tax convention of 18 May 1963, which the
preliminary article of the CTCA recalls, has the turnover taxes applied in the
Principality "on the same bases and at the same rates as in France". The CTCA
is therefore a Monegasque text with French content: the same four rates, the
same exemptions, the same places of supply, the same exigibility rules, filed
with the Monegasque tax administration (Direction des Services Fiscaux, DSF)
and paid to it. For the European Union's common system, Monaco is treated as
France, which the core already records in `territories` (`MC`, parent `FR`,
`eu_vat_scope = 'full'`, prefix `FR`), so the pack adds no territory row.

## The taxes

Twenty-two codes, dated from 1 January 2014 (the date from which the current
wording of art. 51 applies, per the Ordonnance Souveraine 4.199 of 20 February
2013). The rates are 20 % (art. 51), 10 % (arts 52, 56, 56 bis), 5.5 %
(art. 52-0) and 2.10 % (arts 58, 59, 95). Services follow art. 40, 2, c: the
tax falls due when the price is collected, unless the DSF authorised the
company to account on invoices (art. A-64). The three `-ENC` sale codes and
the three `-ENC` purchase codes carry that rule through `cash_basis`; a company
that has the authorisation uses the codes without the suffix.

Also present: the intra-Community delivery (art. 31, I, 1°), the export outside
the Union (art. 29, 1° and 2°), the service to a taxable person established in
another Member State (art. 11, hence outside the Monegasque tax), the
acquisition of goods from another Member State (art. 2, I), the service bought
from a supplier established outside Monaco and France (art. 62, 2), the
purchase of fixed assets (own box) and the purchase with no tax.

## The return, and what is not verified about it

The pack declares one periodic return, `MC-TVA`. By art. 70, 1 of the CTCA it
is filed every month; art. 70, 2 admits a quarterly filing when the tax due in
a year is under EUR 4 000. Monthly is the default because the law gives it to
everybody. Art. A-144 has the director of the DSF assign each category of
taxpayer the part of the month in which the return is due and, failing that,
sets the 25th; the pack therefore declares the deadline as
`depends_on_taxpayer`, with that text, rather than a day that would be wrong
for some filers.

**The model of the return itself was not readable.** Art. 70, 1 says the return
follows "the model prescribed by the Administration"; the government's pages on gouv.mc answered
403 to every automated read, and no copy of the Monegasque form was found on a
page that opened. The pack takes the numbering of the French form 3310-CA3 as
its reference (lines 01, 03, 04, 05, 06, 08, 09, 9B, 13, 15 to 23, 25 to 28).
That is an assumption: the content comes from art. 70, 4 of the CTCA, the
numbers come from the French form, and nobody has checked that the Monegasque
form numbers its lines the same way. The French lines that belong to French
schemes (the overseas rates, the leave-allowance lines, the imports lines
3A and 24) are left out.

## The chart of accounts

Monaco's law prescribes **no** chart. The Code de commerce asks for a daily
book, an annual inventory and ten years' retention (art. 10 to 13) and says
what the annual accounts are, but names no layout. No Monegasque text that was
read makes the French plan comptable général compulsory. The pack's chart
follows its structure (classes 1 to 7, with the 6-digit leaf accounts the VAT
postings need) because the tax rules it carries are French and because
Monegasque companies are generally understood to keep to it. The second half
of that sentence is not sourced: it is the pack's working hypothesis, and a
Monegasque accountant should confirm or replace it.

The balance sheet and the income statement are an abbreviated presentation by
class of the plan, built on the same ranges as the chart. No Monegasque text
that was read fixes their lines; the Code de commerce names the documents (the
balance sheet, the profit-and-loss account and the annex) and nothing finer.

## What the pack does not say yet

- **Corporate income tax.** The impôt sur les bénéfices (ISB) applies to some
  businesses only; no section of the pack computes it.
- **Imports.** VAT on goods imported into the Principality is collected through
  the French customs; the pack has no import code, and the CTCA's lines on
  imports and on the suspensive regimes are not booked.
- **The recapitulative statement of intra-Community supplies** (état récapitulatif,
  art. 73) is a condition of the exemption on a delivery to another Member
  State, and the pack does not produce it.
- **Special schemes**: margin schemes (art. 93 A), the other options of art. 15
  and following, the real-estate regimes, the partial deduction coefficients
  (annex, art. A-73 and following) and the refunds of art. A-109 and following
  are not modelled. The refund request is a box (26) and nothing more.
- **Late payment between businesses.** No statutory payment term or recovery
  fee was found in the Code de commerce; `legal_payment_days` is 0.
- **Structured e-invoicing.** Art. 71, VI of the CTCA admits it among the
  forms an invoice may take; no obligation to exchange structured invoices was
  found, and the Government's pages on the subject did not open.
- **The portal.** The pack records the DSF's page on the declaration of
  existence as its source for the payee. The place where the return is filed
  online was not found on a page that opened.
