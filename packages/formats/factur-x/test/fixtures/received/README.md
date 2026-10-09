# Received documents

Files written by hand, as a supplier's system would send them, to test the
CII reader on what the writer of this package never produces:

- `invoice-with-pdf.xml` — EN 16931: allowances and charges, several payment
  means, an embedded PDF, a link to an external document, a project. It is
  the invoice of `peppol-ubl/test/fixtures/received/invoice-with-pdf.xml`
  written in CII, and `test/read.test.ts` holds the two readers to the same
  result for it.
- `credit-note-basic.xml` — BASIC: a credit note (type 381) with its preceding
  invoice, a tax point date, an IBAN written in groups, a seller addressed by
  SIRET and a buyer by VAT number.
- `invoice-minimum.xml` — MINIMUM: no line, the totals only.

Everything is invented. The Belgian enterprise numbers are in the `0999`
range, in which none has been issued; the GLNs start with `02`, the prefix GS1
reserves for numbers used inside one company; the French, Dutch and
Luxembourg numbers are runs of nines; the IBANs name bank codes that do not
exist; the domains end in `.example.test`. The embedded PDF is the one-page
file of the Peppol brick's fixture.

No CII schema is held in this repository, so these files are not validated
against one; they follow the element order of the CII D16B schema all the
same.
