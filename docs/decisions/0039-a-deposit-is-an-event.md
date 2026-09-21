# A deposit is an event, written from the frozen figures

> Status: accepted

## Context

A declaration is prepared, frozen, then deposited — sometimes several times,
because an administration may refuse a file. The file must be what the
declaration says, and it must be what the administration's schema accepts.

## Decision

**A brick per format, named after the document.** A periodic return has its
own brick in `packages/formats/`, named after the document it writes, not
after a country; a second country depositing the same shape would use it.
`tax_report_templates.file_format` names the brick; null is the ordinary
answer (most forms are filed by hand on a portal).

**Its input is the freeze.** The brick takes `tax_filing_boxes`, the figures
as filed; recomputing from the ledger would drift from the filing.

**One value per grid where the form has one.** A grid given twice is a
violation, not a silent drop.

**Nothing is invented to satisfy a validator.** An absent field is an absent
element; where the schema requires one, the caller supplies it. A made-up
telephone number would travel to an administration as a fact.

**The published schema is a fixture, not a dependency.** The XSD files are
kept unmodified under the brick's `test/xsd/` with their origin; validation
runs through a development dependency, offline, and the package still depends
on nothing. **A violation is something the schema would refuse**: each one is
put back into a file and validation is shown to fail. A choice the schema
forces but does not make (the figure of a nil return) is exported and
documented as the brick's. A working system that files proves only what it
happens to do; reading the schema is what finds the rest.

**One file may carry many declarants.** Where a format lets a representative
deposit several returns in its own name, the brick writes it: the
representative block is whole or refused (completing it would send an
invented fact), identifiers use the schema's own list of issuing states, and a
sequence number tells returns apart. Whether a mandate exists is the
administration's fact; a mandate table is not modelled yet.

**A rejection is a state you send again from.** Each send is a row of
`tax_filing_deposits` with its reference, acknowledgement, the
administration's message and the file that went; the state on `tax_filings`
is the current one. `reopen_filing()` empties the filing date and reference,
and nothing is lost because the refused send is a row. A corrective is for
what an administration holds; a refused declaration is held by nobody.

**Sending is operated; what comes back is not.** Credentials, certificates and
portal sessions stay in `ee/`. The proof — deposit number, acknowledgement,
the file — lives in the company's database under the same policies as its
books, so stopping a subscription never takes the proof away. The channel is
`portal` (a person uploads) or `service` (named as text); the core keeps no
list of providers.

## Consequences

- The proof of a filing is an attachment and is read through `documents.read`;
  aligning it with `filings.read` is an open item.

## See also

- `tests/filing_deposits.test.ts`, `tests/vat_return_formats.test.ts`,
  `tests/filing_golden.test.ts`
- [0037 A filed declaration is frozen](0037-a-filed-declaration-is-frozen.md)
- [0048 Format libraries are MIT, one package per format](0048-format-libraries-are-mit-one-package-per-format.md)
