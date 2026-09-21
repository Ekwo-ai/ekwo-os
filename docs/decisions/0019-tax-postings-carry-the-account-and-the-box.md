# A tax posting carries the account and the box

> Status: accepted

## Context

A tax says how much; something has to say where it lands in the ledger and
where it is declared. If that is code, every country and every regime is a
release.

## Decision

**`tax_postings` carry the account and the box.** Country rules become rows.
Adding a regime is data, and the VAT return needs no country code: it sums
what the postings wrote.

**A positive `factor_percent` keeps the side of the base; a negative one flips
it.** That single rule expresses self-assessment: +100 on the recoverable
account and −100 on the payable one net to zero in the ledger while both boxes
are filled. A reverse-charge boolean that nothing reads leaves the ledger and
the return disagreeing on every intra-community purchase.

**`box_factor_percent` is separate from `factor_percent`.** A box is filled
with the sign the form expects, which has nothing to do with the ledger side.
Conflating them yields negative boxes and rejected files.

**A tax whose postings net to zero is not added to the document total.** It
follows from the postings, with no flag: on a self-assessed purchase the
supplier is owed the net amount.

**Goods, services and capital goods are separate taxes, not a guess.** Belgian
boxes 81, 82 and 83 cannot be derived from a rate and a country. Three taxes at
the same rate is the honest model.

**Taxes have `valid_from` and `valid_to`.** A rate change is a new tax code and
a closed validity, never an edit; `post_document` refuses a tax not in force on
the accounting date.

**Only percentage taxes are posted.** `amount_type = 'fixed'` exists and
`post_document` refuses it rather than guess how to spread a fixed amount over
lines.

**The core never chooses a tax for anyone.** A document line names its tax. The
core may refuse a tax that cannot apply (see
[0024](0024-a-tax-follows-the-territory-of-the-parties.md)); suggesting one is
not its role.

## Consequences

- Self-assessment, exemptions and partial deduction are all rows, and the return needs no country code.
- A tax rate change never rewrites a past document.

## See also

- [0020 One tax engine, several kinds of tax](0020-one-tax-engine-several-kinds-of-tax.md)
- [0023 Declaration boxes are data](0023-declaration-boxes-are-data.md)
- `tests/posting.test.ts`, `tests/tax_report.test.ts`
