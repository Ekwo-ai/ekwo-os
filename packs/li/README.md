# Liechtenstein

Everything Liechtenstein adds to Ekwo, as data: a chart of accounts drawn
along Art. 1051 PGR, the journals, the value added tax (Mehrwertsteuer, MWST)
rates and where each one posts, the boxes of the periodic return, and what
the invoicing rules of Art. 26 MWSTG require. The format is
[`docs/packs.md`](../../docs/packs.md); this file records what the pack
deliberately leaves out and why.

**Status: `community`.** Nobody has reviewed it against the law it applies.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `de`, no further language.** Liechtenstein's official language is
German. The pack's labels are written in German; Art. 1049 Abs. 1 PGR asks
for annual accounts in German or English.

## Sources

The register holds six texts, every one of them opened on 23 October 2026
except where a section below says otherwise:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, exports, acquisition tax, import, periods, deadlines | Mehrwertsteuergesetz (MWSTG) of 22 October 2009, LR 641.20, version of 1 January 2026 | Landesgesetzblatt (gesetze.li) |
| Implementing rules | Mehrwertsteuerverordnung (MWSTV), LR 641.201, version of 1 January 2025 | Landesgesetzblatt |
| Bookkeeping, annual accounts, language and currency, retention | Personen- und Gesellschaftsrecht (PGR), LR 216.0, Art. 1045–1062 | Landesgesetzblatt |
| Default interest between businesses | ABGB §§ 904, 1000, 1333 | Landesgesetzblatt |
| Numbering of the return's boxes | Swiss form No. 4470, specimen valid from 1.1.2024 | ESTV |
| Where the return is filed | eMWST-Portal | Steuerverwaltung |

## How Liechtenstein's VAT relates to Switzerland's

Liechtenstein is not in the European Union's common system of VAT
(`territories.eu_vat_scope = 'none'`, so no VATEX code and no VIES prefix). It
has a law of its own, the MWSTG of 22 October 2009, which follows the Swiss
law: the same rates, the same article structure, the same Saldosteuersätze
ceilings (CHF 5 024 000 of turnover, CHF 108 000 of tax), the same CHF 10 000
threshold for the acquisition tax. The law ties the two together at two
points the pack relies on: Art. 3 Bst. a defines the *Inland* as Liechtenstein
"and foreign territories under an agreement between the states", and Art. 50
sends the tax on imports to the Swiss rules that apply under the treaty of
28 October 1994 with Switzerland. The return is filed with the Liechtenstein
Steuerverwaltung, not with the Swiss federal tax administration.

Where the Liechtenstein text differs from the Swiss one, the pack follows
Liechtenstein: the invoice list of Art. 26 Abs. 2 is "as a rule" (*in der
Regel*), the periods sit in Art. 35 Abs. 1a (not 1bis), and the Liechtenstein
text carries **no sunset on the 3.8 % lodging rate** — the Swiss limit of
31 December 2027 is not in it, so the pack sets no `valid_to`.

## The taxes

Twelve codes, dated from 1 January 2024. The rates are 8.1 % (Art. 25 Abs. 1),
2.6 % (Abs. 2) and 3.8 % for lodging (Abs. 4); the text in force on
1 January 2026 was last amended on this by LGBl. 2023 Nr. 221. The start date
of 1 January 2024 (the earlier rates were 7.7 / 2.5 / 3.7 %) is taken from
secondary sources that report the parallel move with Switzerland; the
gazette entry itself was not read.

Six on the sale side: the three rates, an export (Art. 23, zero-rated with
full input deduction), a supply with its place abroad (Art. 8, `not_subject`)
and an excluded supply with no option (Art. 21, `exempt`, no input
deduction). Six on the purchase side: standard rate on operating expense
(box 400) and on investment (box 405), the reduced rate, a non-deductible
purchase (`tax_on_base`, Art. 29 Abs. 1), the acquisition tax on a service
bought from abroad (Art. 45–49, box 383, deducted at the same time under
Art. 28 Abs. 1 Bst. b) and an import of goods (Art. 50, only the input tax is
posted: the import tax itself is assessed by the Swiss customs authority,
BAZG, unless the importer declares it in the return under Art. 51).

## The return, and what is not verified about it

The pack declares a periodic return (`LI-MWST-ABR`, effective method). Its
periods are those of Art. 35 (quarterly by default, half-yearly under the net
tax rates, monthly or yearly on request); it is due **within 60 days** of the
end of the period (Art. 58 Abs. 1) and the tax is payable within the same 60
days (Art. 76 Abs. 1). All filing goes through the eMWST-Portal
(mwstportal.li); the portal's start page opened but is a script-driven
application whose content could not be read.

**The box numbers are those of the Swiss form No. 4470 and nothing in this
repository proves that the Liechtenstein form uses the same ones.** The
Steuerverwaltung's pages (llv.li, stv.llv.li) answer every automated read with
HTTP 403, and the portal is a script-driven application. The articles each box rests
on are the Liechtenstein ones and were read; the numbering and the arithmetic
of the totals (289, 299, 399, 479, 500, 510) are taken from the Swiss
specimen, because the treaty keeps the two laws parallel, not because a
Liechtenstein form was compared. This is the first item for the accountant
who reviews the pack.

## The chart of accounts, and why this one

**Liechtenstein prescribes no chart of accounts.** Art. 1045 PGR requires
orderly accounts; Art. 1046 Abs. 1 requires books that give an expert third
party an overview within reasonable time; Art. 1048 Abs. 2 names the annual
accounts (balance sheet, income statement, notes when needed); Art. 1051 gives
only the rough split of the balance sheet — current and fixed assets, debt
and equity, accruals. The chart is a proposal along that split, four-digit,
in the Swiss-style numbering Liechtenstein practice shares because the
country uses the Swiss franc; it is the structure of the Swiss pack, whose
ranges follow the same split. No national chart was copied. The statements
therefore reach the same lines by the head of each account's code:

| Range | Is |
|---|---|
| `1000`–`1099` | Cash, bank, securities held short term |
| `1100`–`1119` | Trade receivables |
| `1140`–`1189` | Other short-term receivables, input tax accounts |
| `1200`–`1299` | Inventory |
| `1300`–`1399` | Accrued income |
| `1500`–`1699` | Tangible fixed assets |
| `1700`–`1799` | Financial fixed assets and participations |
| `2000`–`2029` | Trade payables |
| `2030`–`2399` | Other short-term liabilities, provisions, accrued expense, VAT payable |
| `2400`–`2799` | Long-term liabilities |
| `2800`–`2899` | Capital and reserves |
| `2900`–`2999` | Retained earnings |
| `3000`–`3099` | Net revenue |
| `4000`–`4099` | Cost of materials |
| `5000`–`5999` | Personnel expense |
| `6000`–`6570`, `8950`–`8969` | Other operating expense, and the rounding account |
| `6600`–`6699` | Depreciation |
| `6900`–`6999` | Financial expense / income |
| `7500`–`7999` | Non-operating income / expense |
| `8500`–`8949` | Extraordinary income / expense |
| `8990`–`8999` | Direct taxes |

`closing_style` is `retained_earnings`: the result closes straight into
`2900`. The currency is the Swiss franc; Art. 1049 Abs. 1 PGR also allows
euro and US dollar for annual accounts, which a company chooses at set-up.

## What this pack does not model, and why

- **Supplies to and from Switzerland.** Art. 3 Bst. a MWSTG makes foreign
  territories under a treaty part of the *Inland*, and the VAT treaty of
  28 October 1994 is the one the law names. The treaty text itself was not
  read, so the pack neither treats a delivery to a Swiss customer as an export
  nor posts a Swiss supplier's invoice differently: a user with Swiss
  counterparties needs the accountant before booking them. The golden uses
  Liechtenstein, German, Irish and Chinese counterparties only.
- **The prior generation of rates** (7.7 / 2.5 / 3.7 %) is declared as boxes
  302, 312, 342 and 382 and left unposted.
- **The option to tax an excluded supply** (Art. 22, box 205), **the
  reporting procedure for a business transfer** (Art. 38, box 225),
  **margin taxation** (Art. 24a, box 280), **discounts** (box 235) and the
  **non-consideration items** of Art. 18 Abs. 2 (boxes 900, 910) are declared
  boxes with nothing posted to them.
- **The cash method for the whole company** (Art. 39 Abs. 2): the default
  `tax_point: invoice_date` is the ordinary method of Art. 39 Abs. 1 and
  Art. 40 Abs. 1 Bst. a; the alternative is a whole-company election the core
  cannot express per tax code.
- **The net tax rate method** (Saldosteuersätze, Art. 37) and the flat-rate
  method for public bodies are company-level elections, so the return lists
  `half_year` with no `period_default` and `vat_schemes.json` is not shipped.
- **The shifting procedure for imports** (Art. 51): the import tax is assumed
  paid to the customs authority.
- **E-invoicing.** `einvoicing.obligation` is `none`: the MWSTG (Art. 26) fixes
  the content of an invoice, not its form, and the PGR says nothing on it. No
  mandate was found in the texts read; a statement from the Steuerverwaltung
  or the government on this could not be read, so it is a point for review.
- **Payment terms.** The ABGB sets no payment period (§ 904: due after a
  reminder when none is fixed) and the default interest is the statutory 5 %
  (§ 1000 Abs. 1, § 1333 Abs. 1), hence `legal_payment_days: 0`.
- **Other levies**, none modelled and none given a tax code: the corporate
  income tax, the minimum tax, social-security contributions, customs duty
  and excise (customs is the Swiss customs authority's under the treaty).

## Before this pack is `reviewed`

1. **The box numbering of the Liechtenstein return** against the form on the
   eMWST-Portal, with an account.
2. **Supplies and purchases across the Swiss border**, against the VAT treaty
   of 28 October 1994 and the Steuerverwaltung's guidance.
3. **The start date of the 2024 rates** from the Landesgesetzblatt entry
   (LGBl. 2023 Nr. 221).
4. **The chart**, read by someone who books Liechtenstein companies daily
   (including the Verbandspersonen and the notes Art. 1055 PGR asks for).
5. **E-invoicing**: confirm that no B2B or B2G mandate has been published.
