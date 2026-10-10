# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **The visual PDF of a sale invoice or credit note.** `renderInvoicePdf()`
  takes the rows of `document_header`, `document_line_items`,
  `document_tax_summary` and `document_legal_mentions`, and the bytes of a
  logo, and returns `{ file, filename, title, pageCount, text }`: one sober
  layout, A4 or Letter, as many pages as the lines need, the column headings
  repeated and every page numbered. Amounts, dates, rates and country names
  are written by `Intl` in the document's language; the words of the layout
  are `ENGLISH_LABELS`, or the caller's.
- Noto Sans and Noto Sans Thai embedded, regular and bold, under the SIL Open
  Font License, as subsets; other scripts through `options.fonts`. A character
  no font has is refused (`glyph_not_covered`), text written right to left too
  (`right_to_left_text`).
- `renderFacturXPdf()` hands the rendered PDF and a CII XML to `embedFacturX`
  of `@ekwo-ai/factur-x/pdf`, passed in by the caller: a Factur-X PDF/A-3.
