# A company has a profile; its first year is a parameter

> Status: accepted

## Context

To print an invoice, a company needs a face: a trade name, a logo, a stated
capital, an activity code, a default bank account. And a first financial year
opened on 1 January by assumption is right for some countries and wrong for
others.

## Decision

**The profile is columns of `companies`.** Trade name, logo URL or storage
path (the core keeps no file), stated capital with its own currency, activity
code with its register, default bank account, document template. No second
column for the register number: `registration_number` already is it. A capital
with no currency takes the company's, in a trigger, rather than a literal.

**A sales document with no payee IBAN takes the default bank account**, in a
trigger on `documents`, so every client gets the same answer; a purchase
document never does, because the payee is somebody else.

**A company has an electronic address.** `companies.peppol_scheme` and
`peppol_identifier`, named as on `contacts`, whole or absent by check
constraint; no list of schemes in the core, since the list is revised
regularly and differs between standards.

**`document_header`** is the view a renderer reads, beside
`document_line_items` and `document_legal_mentions`; `get_document` reads it
rather than assembling its own.

**The first financial year is a parameter.**
`country_defaults.fiscal_year_default` is read by `fiscal_year_bounds()`, in
the schema because several callers ask. A pack that says nothing gets
`no_fiscal_year_default`, never a January nobody chose.

**A bank account is created from its IBAN alone.** The journal and ledger
account behind it are already chosen by the country template; the IBAN is the
fact nobody can derive and the natural key (unique on `(company_id, iban)`),
which makes creation idempotent. A company with no bank account is a `doctor`
warning, not an error.

**`create_company()` and the installer both create a company, deliberately.**
The rules — what a pack puts in a company, what dates a first year has — live
in `install_country_template()` and `fiscal_year_bounds()`, and both callers
delegate. What differs is behaviour that cannot be shared: the installer is
check-then-act and can be rerun on a half-finished project; the function
creates or raises.

## Consequences

- An invoice can be rendered from views alone.
- No country's first day of the year is assumed for another.

## See also

- `tests/company_profile.test.ts`, `tests/fiscal_year_start.test.ts`
- [0052 The installer](0052-the-installer-needs-only-node-and-a-customer-project.md)
