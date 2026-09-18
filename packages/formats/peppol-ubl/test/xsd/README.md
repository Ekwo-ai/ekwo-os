# The published schemas

Fixtures of `test/schema.test.ts` and of `tests/peppol_ubl.test.ts` at the root
of the repository, and nothing else: the package ships none of them (`files` in
`package.json` lists `dist`, the README, the changelog and the licence) and
reads none of them at runtime.

They are the UBL 2.1 schemas OASIS publishes, unmodified, retrieved on
18 September 2026 from the OASIS Standard of 4 November 2013:

| Files | From |
|---|---|
| `maindoc/UBL-Invoice-2.1.xsd`, `maindoc/UBL-CreditNote-2.1.xsd` | `xsdrt/maindoc/` of <https://docs.oasis-open.org/ubl/os-UBL-2.1/UBL-2.1.zip> |
| `common/*.xsd`, all fourteen | `xsdrt/common/` of the same archive |

`xsdrt` is the *runtime* set: the same schemas as `xsd/` with the annotations
left out, which is a quarter of the size and validates identically — OASIS
publishes both for that reason. The two directories are laid out as in the
archive because the schemas import each other by relative path
(`../common/…`), and they are not edited to do otherwise.

Each file carries its own notice: *Copyright © OASIS Open 2013. All Rights
Reserved*, under the OASIS IPR policy, which allows copying and distribution of
the unmodified files.

UBL 2.1 is what Peppol BIS Billing 3.0 is bound to, and it does not change. If
a later profile moves to another version of UBL, that is another format.
