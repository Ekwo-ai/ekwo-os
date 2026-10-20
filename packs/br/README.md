# Brasil

Everything Brazil adds to Ekwo, as data, **for companies under Simples
Nacional**: the five annexes of Lei Complementar nº 123, de 2006, as regimes
where one tax on turnover replaces the per-line taxes, their monthly return
(PGDAS-D) and its deadline, an original chart of accounts for micro and small
companies, a Balanço Patrimonial and a Demonstração do Resultado do
Exercício, the Mercosur Common Nomenclature (NCM) as the classification of a
line, and the sentence an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md).

**Language: `pt`**, Brazilian Portuguese, the language of the law and of the
Receita Federal's own forms. English is declared too: `i18n/en.json` is a
translation for a reader, never for a filing — see
[`i18n/README.md`](i18n/README.md).

**Status: `community`.** Nobody who files a Brazilian return has reviewed it.
`tests/golden.test.ts` replays a quarter of books, which proves the pack is
coherent, not that it is right.

Brazil is outside Directive 2006/112/EC: `BR` has `eu_vat_scope` `none` in
`supabase/seed/00_territories.sql`, with its twenty-seven federative units
(`BR-AC` … `BR-TO`, ISO 3166-2:BR) as rows of their own for the work on the
ICMS of the general regimes; no pack data names them yet. `BRL` (Brazilian
real, two decimals) is added to `00_currencies.sql`.

## Scope: Simples Nacional, and what it leaves out

| Covered | Not covered yet |
|---|---|
| A micro or small company (ME, EPP) that opted for Simples Nacional, under one annex for the whole year | Lucro Presumido and Lucro Real, with ICMS, IPI, PIS, Cofins and ISS computed per line: the core takes one tax per line, and a Brazilian line of the general regime carries several, some inside their own base and some stacked |
| Its monthly DAS on the turnover of posted sales, on a trailing window of twelve months, annualised in the first year | The MEI (microempreendedor individual), whose DAS is a fixed monthly amount — see below |

A Brazilian company under the general regimes should not use this pack as it
is: it carries no tax that such a company charges.

## The five annexes: `turnover_tax.json`

Lei Complementar nº 123, de 2006, art. 18, as amended by Lei Complementar nº
155, de 2016 (in force from 1 January 2018), computes the monthly tax of an
optant as the month's gross revenue times the effective rate

    (RBT12 × Aliq − PD) / RBT12

where RBT12 is the gross revenue of the twelve months before the period,
Aliq the nominal rate and PD the deduction of the bracket RBT12 falls in.
This is exactly decision 0080's formula. Each annex is one regime:

| Regime | Annex | Activity | 1st bracket | 6th bracket |
|---|---|---|---|---|
| `BR-SN-I` | I | Commerce (resale of goods) | 4 %, — | 19 %, 378 000.00 |
| `BR-SN-II` | II | Industry | 4.5 %, — | 30 %, 720 000.00 |
| `BR-SN-III` | III | Services not in § 5º-C, rental of movable property; § 5º-I services with Fator R ≥ 28 % | 6 %, — | 33 %, 648 000.00 |
| `BR-SN-IV` | IV | Services in § 5º-C (construction, cleaning, surveillance, law firms…), CPP paid outside the DAS | 4.5 %, — | 33 %, 828 000.00 |
| `BR-SN-V` | V | Services in § 5º-I with Fator R < 28 % | 15.5 %, — | 30.5 %, 540 000.00 |

The thresholds are the same in every annex: 180 000.00, 360 000.00,
720 000.00, 1 800 000.00, 3 600 000.00 and 4 800 000.00. Every bracket cites
its row of the annex; every figure was read on the compiled text of the law
at planalto.gov.br on 2026-10-20.

- **Window.** `months: 12`, `includes_period: false` (art. 18, § 1º: the
  twelve months *before* the period), `short: annualise`. In the first year
  of activity the Receita Federal's *Perguntas e Respostas* (question 5.4.1,
  "rule until 2026") proportionalises RBT12: the first month's own revenue
  times twelve, then the average of the previous months times twelve — what
  the core's `annualise` does. The core counts the months from the first
  month of the company's first financial year in Ekwo, so a company that
  opened its CNPJ before its first year in Ekwo needs its earlier revenue
  booked, or its first periods are annualised when the law would not.
- **Form and deadline.** `BR-PGDAS-D`, monthly, transmitted and paid by the
  20th of the following month (art. 18, § 15-A, II; Resolução CGSN nº 140,
  de 2018, art. 40, as the *Perguntas e Respostas*, questions 6.4 and 6.8,
  state it). When the 20th is not a banking day the deadline moves to the
  next one; the core's `day_of_month_after_period` does not move it.
- **What it replaces.** `vat` and `sales_tax`: a line carrying a tax of
  either kind is refused under the regime. The DAS gathers IRPJ, IPI, CSLL,
  Cofins, PIS/Pasep, CPP, ICMS and ISS in one payment (art. 13).
- **Where it posts.** `post_turnover_tax()` debits `6.1.1 Simples Nacional
  (DAS)` and credits `2.1.4.01 Simples Nacional a recolher`, the
  `tax_payable` role; the DRE shows it among the deductions from gross
  revenue (Law 6.404/1976, art. 187, I).

**The Fator R** decides between annex III and annex V for the services of
art. 18, § 5º-I: payroll of the twelve previous months over gross revenue of
the same months, at or above 28 % → annex III (§ 5º-J), below → annex V
(§ 5º-M). It is a fact about the company that changes month by month; the
pack carries no rule for it, and the company declares the annex it is under,
by whole financial years (decision 0080). A company whose Fator R crosses
28 % within a year cannot move from one annex to the other in Ekwo yet.

### The MEI is not in this pack

Art. 18-A lets the microempreendedor individual (gross revenue up to
81 000.00 in the previous year) pay the Simples Nacional "em valores fixos
mensais, independentemente da receita bruta": a fixed monthly sum made of a
social security contribution set on the minimum wage plus a fixed ICMS and
ISS amount (art. 18-A, § 3º, V). The brick of decision 0080 computes a rate
on turnover; a fixed amount whatever the turnover is not a rate, and faking
it with a negative deduction would print a wrong effective rate and a wrong
tax in any month without revenue. It is left out until the core can say a
fixed amount per period.

## The golden quarter and its DAS, computed by hand

`golden/` is a services company under annex III that opened on 1 January
2026: fourteen documents (eight sales including an export of services and a
partial cancellation, five purchases including a service bought abroad, one
supplier credit note) and five payments, one on account. The golden format
replays documents and payments and has no place to declare a regime or post
a DAS, so the statements and the trial balance under `golden/` are those of
the documents alone. The DAS of each month, computed by hand and confirmed
against `turnover_tax_return()` on the same documents under `BR-SN-III`:

| Month | Revenue of the month | Window | RBT12 | Bracket | Effective rate | DAS |
|---|---|---|---|---|---|---|
| 2026-01 | 15 000.00 | first month: its own revenue × 12 | 180 000.00 | 1st (up to 180 000.00, inclusive) | 6 % | **900.00** |
| 2026-02 | 18 500.00 (12 000.00 + 7 500.00 − 1 000.00) | January × 12 | 180 000.00 | 1st | 6 % | **1 110.00** |
| 2026-03 | 14 000.00 | (15 000.00 + 18 500.00) / 2 × 12 | 201 000.00 | 2nd | (201 000 × 11.2 % − 9 360) / 201 000 = 6.5433 % | **916.06** |

Posted with `post_turnover_tax()`, the quarter adds 2 926.06 debit on
`6.1.1` and credit on `2.1.4.01`, and the DRE's net profit becomes
37 600.00 − 2 926.06 = 34 673.94. The February export of services (S3) is in
the revenue and in the window, as the law wants it; the reduction of the DAS
it earns is not computed — see below.

## The documents carry no tax: `taxes.json`

An optant charges no tax on its invoices and recovers none on its purchases
(art. 23). Two zero-rate codes of kind `other` exist so that every line
carries a code the engine books without tax: `BR-SN-VENDA` (sales, at home
or abroad) and `BR-SN-COMPRA` (purchases). They are not an exemption and do
not say the operation is outside ICMS or ISS: they say its tax is in the
month's DAS. Their `treatment` is `not_subject`, the closest word the
vocabulary has for "no tax on this line". A line may also carry no code at
all.

They exist for one more reason, written here for the core: a pack whose
`taxes.json` is an empty list compiles into a seed with an empty `values`
clause, which Postgres refuses — the compiler of `packages/cli` assumes at
least one tax.

There is no `tax_report.json`: Simples Nacional has no periodic VAT return,
and the regime's own form is declared in `turnover_tax.json`.

## Chart of accounts

Brazil imposes no numbered chart on micro and small companies: the Civil
Code (arts. 1.179 and 1.183) asks for uniform bookkeeping and allows a
numbering of the company's own, Lei Complementar nº 123, art. 27, allows
simplified bookkeeping to an optant, and the Conselho Federal de
Contabilidade's standards for micro and small entities set the content of
the statements, not a numbering. This chart is original: 189 accounts on
four dotted levels (`1.1.2.01`), each group reaching one line of the
Balanço Patrimonial or of the DRE in the order of Law 6.404/1976, arts. 178
and 187:

- `1` Ativo — `1.1` circulante (disponível, clientes, outros créditos,
  estoques, despesas antecipadas, contas transitórias), `1.2` não circulante
  (realizável a longo prazo, investimentos, imobilizado, intangível);
- `2` Passivo — `2.1` circulante (fornecedores, obrigações trabalhistas,
  sociais e tributárias, empréstimos, outras), `2.2` não circulante;
- `3` Patrimônio líquido — capital, reservas, lucros ou prejuízos
  acumulados, resultado do exercício;
- `4` Receitas — `4.1` receita bruta by activity (goods, manufactured goods,
  services, rental, exports), `4.2` deductions (returns, cancellations,
  unconditional discounts), `4.3` finance income, `4.4` other income;
- `5` Custos — cost of goods and of services sold;
- `6` Despesas — `6.1.1` Simples Nacional (DAS), staff, administrative,
  selling, finance and other expenses.

The turnover the regime reads is what sale invoices and credit notes put on
the `income` accounts: `4.1` and `4.2`, so a return or a cancellation lowers
the revenue of its own month (art. 3º, § 1º: "não incluídas as vendas
canceladas e os descontos incondicionais concedidos"). Only customer and
supplier accounts, `2.1.4.01` (the DAS payable, `tax_payable`) and
`1.1.3.03` (taxes recoverable, `tax_receivable`) are reconcilable.

## The statements

`BR-BP` (Balanço Patrimonial) and `BR-DRE` (Demonstração do Resultado do
Exercício), framework `BR-ME-EPP`, follow the groups of Law 6.404/1976,
art. 178, and the discrimination of art. 187, which the Civil Code
(arts. 1.188 and 1.189) refers to. IRPJ and CSLL are inside the DAS, so the
DRE has no income tax line. `result_in_progress` is `alone`: line `3.5`
takes the result of the year and nothing else.

## The NCM: `classifications`

`pack.json` declares `ncm`, the Mercosur Common Nomenclature, as the
classification a line or a product holds in its attributes (decision 0078),
with the pattern `^([0-9]{8}|00)$`: eight digits since Ajuste SINIEF 22/13
(1 August 2014), `00` for a service item or an item without a product. The
pattern catches a typing error; the code's meaning stays the seller's.

## The electronic tax document (NF-e, NFS-e)

Every sale of goods is covered by an NF-e and every service subject to ISS
by an NFS-e, which the municipalities authorise in the national standard
from 1 January 2026 (Lei Complementar nº 214, de 2025, art. 62, § 1º). The
document exists only once the administration's authorising system has
received, validated and authorised it (art. 62, II): a clearance regime.
Ekwo does not generate, sign or transmit an NF-e or an NFS-e, and the
`fiscalisation.clearance` brick needs a `format` a piece of
`packages/formats` writes, which does not exist for Brazil; so `einvoicing`
declares no profile, no date and no `fiscalisation`, and the invoice carries
the sentence `dfe_not_issued`. The document number of the pack is the
ledger's own reference (`numbering: free`); the number the law controls is
the one of the authorised document.

## What this pack does not say yet, and why

- **The general regimes** (Lucro Presumido, Lucro Real): several taxes per
  line, ICMS inside its own base, IPI on top of it, ICMS-ST — out of scope,
  see above.
- **The MEI**: a fixed monthly amount, which the brick cannot express.
- **The reduction of the DAS on exports** (art. 18, § 14): the shares of
  Cofins, PIS/Pasep, IPI, ICMS and ISS are taken out of the effective rate
  for export revenue. The core applies one effective rate to the whole
  turnover, so the DAS of a month with exports is overstated by those
  shares. Likewise the revenue subject to ICMS-ST, monophasic PIS/Cofins or
  ISS withheld by the customer, which the PGDAS-D splits out.
- **Several activities in one company** (an annex I shop that also
  provides annex III services): the PGDAS-D applies each annex to its own
  revenue; decision 0080 puts a company under one regime at a time.
- **The cash-basis option** (art. 18, § 3º): an optant may tax the revenue
  *received* in the month rather than earned; the core reads posted
  invoices.
- **The ceilings**: above 3 600 000.00 of RBT12 (the *sublimite*), ICMS and
  ISS leave the DAS and are paid under the general rules; above
  4 800 000.00 the company leaves the regime (art. 3º, II, and § 9º-A). The
  sixth bracket is left open because the format needs one open bracket.
- **Taxes outside the DAS** (art. 13, § 1º): ICMS-ST and the rate
  differential on interstate purchases, ISS withheld, IOF, the taxes on
  imported services, the CPP of annex IV. They have no code here.
- **The tax reform**: Lei Complementar nº 214, de 2025, replaces PIS, Cofins,
  ICMS and ISS by CBS and IBS from 2027 onwards and amends LC 123; the
  *Perguntas e Respostas* already marks its rules "until 2026". The
  brackets here are dated from 2018-01-01 with no end, and must be reread
  when the amended annexes are published.
- **Payment deadline on a non-banking day**: moved to the next banking day
  by the law, not by the core.

## Sources

Every value cites its text in `certification.sources`: Lei Complementar nº
123, de 2006 (compiled text, planalto.gov.br); the *Perguntas e Respostas do
Simples Nacional* of the Comitê Gestor (Receita Federal, updated
9 October 2026); the Portal do Simples Nacional (the filing portal); the
Civil Code and Law 6.404/1976 (planalto.gov.br); Lei Complementar nº 214, de
2025; the Goiás Secretaria da Economia on Ajuste SINIEF 22/13; the national
NFS-e portal. The text of Resolução CGSN nº 140, de 2018, is cited through
the *Perguntas e Respostas*, which names its articles: the Receita
Federal's normative database did not render it to a reader this session.

## For a reviewer

The first things to read against practice: the window and its annualisation
for a company that opened its CNPJ before its first year in Ekwo; whether
`6.1.1` among the deductions from gross revenue is how a Brazilian
accountant presents the DAS; the choice of `not_subject` for the two
carrier codes; the chart's numbering against the Plano de Contas Referencial
of the SPED ECD a firm may have to map to; and the list of what the DAS
leaves out, which decides how far a real optant can rely on the figure
`turnover_tax_return()` gives.
