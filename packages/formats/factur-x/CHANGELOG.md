# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Reading a received invoice.** `readCii()` reads a CII D16B
  `CrossIndustryInvoice` of any profile — MINIMUM, BASIC WL, BASIC, EN 16931,
  EXTENDED, ZUGFeRD 2.x spellings included — and says which profile it
  declares. `readFacturX()` of `@ekwo-ai/factur-x/pdf` reads it out of the
  PDF. The result is the `ReceivedInvoice` that `readUbl()` of
  `@ekwo-ai/peppol-ubl` returns, from byte-for-byte copies of the same files:
  figures as the decimal text the file wrote, the EN 16931 arithmetic reported
  in `violations`, an `InvoiceFileError` with a code for what is not an
  invoice.
- `extractFacturX()` also finds `xrechnung.xml`, the name ZUGFeRD gives the
  XML of its XRECHNUNG profile.

## [0.2.0] — 2026-09-14

Released with Ekwo OS `v0.2.0`, the first tagged release of the repository this
package lives in.

### Fixed
- **A negative half was rounded the wrong way.** The totals used
  `Math.round((v + EPSILON) * 100) / 100`, which goes towards positive infinity
  and turns `-0.005` into `-0.00` — so a credit note was not its invoice with
  the sign flipped, and the cent was found by whoever filed the return. The new
  `roundCurrency` rounds half up on the absolute value, which is symmetric by
  construction, and is the same file in the three packages that hold a copy.

## [0.1.0] — 2026-09-11

### Added
- `generateCiiXml`: EN 16931 CII XML for the MINIMUM, BASIC WL, BASIC, EN 16931 and
  EXTENDED Factur-X profiles, with VAT breakdown rules, credit notes and prepayments.
- `computeTotals`, VAT category and unit-code helpers.
- `@ekwo-ai/factur-x/pdf`: `embedFacturX` (PDF/A-3 attachment + XMP) and `extractFacturX`.
