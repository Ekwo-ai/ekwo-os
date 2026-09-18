# The published rules of EN 16931, for UBL

`CEN-EN16931-UBL.sch` is the Schematron of the European standard EN 16931 bound
to UBL, version **1.3.15**, exactly as **Peppol BIS Billing 3.0, release
3.0.20** ships it — which is the file a Peppol access point validates with.
Unmodified, retrieved on 18 September 2026 from

<https://github.com/OpenPEPPOL/peppol-bis-invoice-3/blob/v3.0.20/rules/sch/CEN-EN16931-UBL.sch>

SHA-256 `bdcbb7b702cce55c7f8c789bef0cb9bebf6d376140c1776e683bd6d9bc0ad331`.

It is published by CEN/TC 434 through the European Commission
(<https://github.com/ConnectingEurope/eInvoicing-EN16931>) and says so in its
first lines: *Licensed under European Union Public Licence (EUPL) version 1.2*.
It is here under that licence, as a fixture of the tests. It is not part of the
published package, which is MIT and ships `dist`, the README, the changelog and
its own licence.

It is read for two things:

- **the code lists.** `scripts/build-codelists.mjs` reads the `BR-CL-*`
  assertions and writes `src/codelists.ts`; `test/codelists.test.ts` reads them
  again and compares. Note that this is Peppol's copy and not CEN's own 1.3.15:
  Peppol updated the identifier scheme lists in it (`0245` is in, which CEN's
  1.3.15 does not have), and what the network validates with is what counts;
- **the rule identifiers.** `test/rules.test.ts` checks that every `BR-*` and
  `UBL-*` rule `src/rules.ts` names exists here, and is fatal.

It is **not executed** by the tests: it is XSLT 2.0. See the README of the
package, *What is verified, and what is not*.

The second Schematron, `PEPPOL-EN16931-UBL.sch`, is not here. Its repository
carries no licence, so it is downloaded by `scripts/play-schematron.mjs` when
the rules are played, checked against its SHA-256, and never committed.

To move to a new release: replace this file, update the tag and the two hashes
in `scripts/play-schematron.mjs`, run `npm run codelists`, play the Schematron,
and let the tests say what changed.
