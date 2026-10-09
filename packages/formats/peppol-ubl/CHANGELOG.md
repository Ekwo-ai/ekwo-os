# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Reading a received invoice.** `readUbl()` reads a UBL 2.1 `Invoice` or
  `CreditNote`, bare or in the envelope of an access point, into a
  `ReceivedInvoice`: parties with their schemes, dates, references, lines, VAT
  breakdown, totals, payment means and the documents attached, an embedded PDF
  as bytes. Figures stay the decimal text the file wrote; the arithmetic of
  EN 16931 (BR-CO-10 to BR-CO-17) is reported in `violations`, never
  corrected. A file that is not an invoice throws an `InvoiceFileError` with a
  code, read by a strict XML reader of the package's own (no DOCTYPE, size,
  depth and element limits). `@ekwo-ai/factur-x` returns the same shape from
  CII.
- **Participant identifiers.** `validateParticipantId()` checks a Peppol
  participant identifier — scheme of the EAS list Peppol delivers to, numeric
  or symbolic spelling, and the check digits of seven schemes whose rule is
  published. `smlHostname()` computes the DNS name of a participant on an SML,
  for the CNAME and the NAPTR lookups, without any network call.
- **The first version.** A sales invoice or credit note as Peppol BIS Billing
  3.0 (UBL 2.1), from a posted document as three row shapes — header, lines,
  VAT breakdown — with the figures written as they were posted and never
  recomputed, on exact decimals.
- **112 published rules re-read and named by their identifier**, EN 16931 and
  Peppol, as `violations` beside a file that is always valid UBL 2.1.
- **Code lists generated** from the EN 16931 Schematron Peppol ships
  (`scripts/build-codelists.mjs`) and compared with it code for code.
- **Proof against the sources**: the OASIS schemas in the test suite, and the
  published Schematron played out of tree against 100 committed files
  (`scripts/play-schematron.mjs`), its verdicts recorded and held to on every
  run. The README says what that proves and what it does not.

### Changed
- **The electronic addresses are read from the header** —
  `seller_peppol_scheme`, `seller_peppol_identifier`, `buyer_peppol_scheme`,
  `buyer_peppol_identifier` — where `sellerEndpoint` and `buyerEndpoint` are not
  given. They are still never derived from another identifier.
- **A line is no longer joined to its tax by `tax_id`.** The category and the
  rate of a line are the line's: Ekwo OS now writes them when the document is
  posted, and a join read the tax of today into an invoice already sent. A line
  that says neither is reported (BR-CO-04, UBL-SR-48). `tax_id` is no longer a
  declared column of the rows.
- No field of the rows is marked *not in the view today* but the net price of a
  line keyed with its tax in it. Same input, same file: the 100 fixtures and
  their recorded verdicts are unchanged.
