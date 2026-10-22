# A company files under a VAT scheme, and its scheme decides its forms

> Status: accepted

## Context

A pack carried declaration forms, and a company recorded how often it files
each of them ([0036](0036-how-often-a-company-files-is-data.md)). What
nothing recorded was the fact that decides which forms a company files at
all. Most countries have several VAT schemes: a normal one with a monthly or
quarterly return; a simplified one with an annual return and payments on
account during the year; a small business exemption under which no VAT is
charged and no periodic return is filed. A company on the simplified scheme
could be handed a monthly return, and nothing refused it.

Two shapes were possible for VAT schemes: a module beside the core, or the
core itself. VAT is the core's: the return, the frozen filing and the
settlement are there, and a scheme only says which of them apply.

## Decision

**A scheme is pack data, a company states its scheme by financial year, and
the scheme governs the filing periods rather than duplicating them.**

- `tax_report.json` holds one form as an object, as before, or several as a
  list. Each form has a `role` from a closed vocabulary — `periodic`,
  `annual` — and a pack carries at most one periodic form, so
  `periodic_return_code()` and the mirror `companies.vat_period` keep one
  answer. A form that restates another one's figures names it in
  `reads_postings_of`, and each of its base and tax boxes lists the boxes of
  that form it adds up (`from`). The taxes post for one form; an annual
  return does not get a second set of postings.
- `vat_schemes.json` declares the schemes: the forms filed under each and on
  which cadences, `charges_vat`, ceilings as a closed measure, an activity, an
  amount, a currency, dates and the article that sets them, and a schedule
  of instalments as months and percentages of a box of the previous period's
  return, with a minimum base. No expression: the vocabularies are closed, as
  `applies_when` is.
- `company_vat_schemes` is the company's statement, from the first day of a
  financial year. There is no default and no guess: a company that has not
  said files exactly as before.
- `company_filing_periods` stays the one place a cadence is written. Recording
  a scheme writes the rows it implies — the scheme's default, or its one
  cadence, never a choice among several — and removes the rows of forms it
  does not file; a row the scheme does not allow is refused.
- `vat_return()` refuses by name a form the scheme does not file and a
  cadence it does not file it on, and takes the scheme's form when none is
  named. Under a scheme that charges no VAT, a sale charging VAT is refused at
  posting and the `small_business` mention is printed.
- Instalments are a plan and a record: `instalment_plan()` computes what is
  due from the frozen return of the previous period, `declaration_instalments`
  holds what was paid, a box with `reads` deducts either, and
  `upcoming_filings()` lists each instalment beside the returns.
- A ceiling is read by `vat_scheme_ceilings_crossed()`, an alert. Nothing
  moves a company from one scheme to another by itself.

## Consequences

- A country with one scheme declares one, or none, and its companies behave
  as they did.
- `upcoming_filings()` and `portfolio_upcoming_filings()` gained a column,
  `instalment`, and were dropped and created again.
- An annual return reads exactly what the periodic one would have, over the
  year: the two can never disagree about a posting.
- The corporate tax module keeps its own instalments for now. Its plan is a
  schedule of percentages of a previous year's tax, the same shape as this
  one; reading the core's would remove the second copy.
- A deadline expressed in months after the period, which an annual return
  often has, is not in the closed vocabulary of deadline rules yet; such a
  form is listed without a date.

## See also

- `supabase/migrations/20261022110000_a_company_files_under_a_vat_scheme.sql`
- `supabase/migrations/20261022110100_the_return_reads_the_vat_scheme.sql`
- `tests/vat_schemes.test.ts`
- `docs/filing.md` — Schemes and instalments
- [0036](0036-how-often-a-company-files-is-data.md) — Filing cadence is data, counted in months
- [0080](0080-a-tax-on-turnover-replaces-vat.md) — A regime where one tax on turnover replaces VAT
