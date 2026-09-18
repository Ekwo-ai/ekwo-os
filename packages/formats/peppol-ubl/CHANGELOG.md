# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
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
