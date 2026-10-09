# Received documents

Files written by hand, as a supplier's system would send them, to test the
reader on what the writer of this package never produces: allowances and
charges, several payment means, an embedded PDF, a link to an external
document, a credit note with its due date in the payment means and its project
as a document of type 50, a prefixed root element.

Everything is invented. The Belgian enterprise numbers are in the `0999` range,
in which none has been issued, with check digits that pass; the GLNs start with
`02`, the prefix GS1 reserves for numbers used inside one company and never
assigned to one; the IBANs name bank codes that do not exist; the domains end
in `.example.test`. The embedded PDF is a one-page file drawn for the test.

`test/read.test.ts` validates each against the OASIS UBL 2.1 schemas under
`test/xsd/` before it reads it, so a fixture that is not UBL fails as a fixture
rather than passing as a reading.
