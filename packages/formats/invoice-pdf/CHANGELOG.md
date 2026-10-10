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
- **PDF/A-3b, measured with veraPDF.** The rendered PDF carries an XMP
  packet declaring PDF/A-3b and mirroring its information dictionary; a PNG
  logo's alpha channel is flattened on white, and a CMYK JPEG is refused.
  veraPDF 1.30.3 finds no failed rule of PDF/A-3b in the examples, the
  Factur-X one included (146 rules passed); `npm run verapdf` repeats the run
  where veraPDF is installed. The trailer identifier, which a negative number
  could write with a minus sign, is always hexadecimal digits.
- **A theme**, `options.theme`: an accent colour, a typeface (Noto Sans or the
  caller's) and the side of the logo; `DEFAULT_THEME` is sober. The layout
  takes from two earlier renderers the shaded panels of the parties, the band
  of column headings, the framed payment block beside the totals, and the
  logo on either side.
- The figures printed — totals, tax per rate, amount due — are tested equal
  to those of the CII embedded beside them, read back out of the PDF, on an
  invoice under two rates and on a credit note; the business terms of
  EN 16931 the rows hold are tested present on the page.
- `examples/invoice-english-factur-x.pdf`.
