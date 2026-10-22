# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **The package.** `readStructured()` reads a CII, UBL or Factur-X file
  exactly into the EN 16931 `ReceivedInvoice`. `readingSchema()`,
  `readingPrompt()` and `readingOf()` are the model path as data: the JSON
  schema and the words a caller sends to a vision model, and the check of its
  answer into the same `ReceivedInvoice` (`syntax: 'model'`), with what was
  not printed in `missing`, what was not of its shape in `rejected`, a
  confidence per field and per line, and the caller's extension returned
  untouched. `purchaseDraftOf()` turns either into the draft of a purchase
  document in the columns of Ekwo OS.
