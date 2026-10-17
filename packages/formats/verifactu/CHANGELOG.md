# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- First version: the VERI*FACTU invoicing record of a posted sale, *de alta*
  and *de anulación* (`RegistroAlta`, `RegistroAnulacion`, schema version
  1.0), its chained SHA-256 fingerprint, the URL of the QR code in both
  modes, and every rule of the AEAT the record breaks by its error code.
