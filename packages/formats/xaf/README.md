# `@ekwo-ai/xaf`

Reads an **XML Audit File Financial** — the *XML Auditfile Financieel*, XAF,
the file an accounting package hands over when an auditor or a tax authority
asks for the books of a year — into plain objects, in TypeScript, with no
dependencies. Versions **3.2** and **4.0** are read, each recognised by the
namespace of its schema.

```ts
import { readXaf } from '@ekwo-ai/xaf';

const books = readXaf(bytes); // a string, or the bytes of the file

books.version;     // '4.0'
books.currency;    // 'EUR', from header/curCode
books.entries;     // [{ journal: 'VK', number: '2025001', date: '2025-01-15', lines: […] }, …]
books.opening;     // the obLine of the opening balance
books.openingDate; // opBalDate (3.2), or the first day of the year (4.0)
books.violations;  // a transaction that does not balance, totals the lines disagree with
```

## What is read

| Part of the books | Where it sits in the file |
|---|---|
| currency | `header/curCode` |
| accounts | `company/generalLedger/ledgerAccount`: `accID`, `accDesc`, `accTp` (`B`, `P`, `M`, kept as written) |
| parties | `company/customersSuppliers/customerSupplier`: `custSupID`, `custSupName`, `eMail`, `taxRegIdent`, `commerceNr`, the country of its first address |
| opening balance | `company/openingBalance/obLine`: `accID`, `amnt`, `amntTp`; its date `opBalDate` in 3.2, `header/startDate` in 4.0, which has none |
| entries | `company/transactions/journal` (`jrnID`, `desc`) `/transaction` (`nr`, `desc`, `trDt`) |
| lines | `trLine`: `accID`, `desc`, `amnt` and `amntTp` (`D` or `C`), `custSupID`, `docRef` (the first one is the entry's reference), `currency/curCode` and `curAmnt`, and in 3.2 `matchKeyID` |

- An amount is an `xsd:decimal`; its side is `amntTp`. A negative amount is
  the other side.
- The file states its own totals — `linesCount`, `totalDebit`, `totalCredit` —
  for the opening balance and for the transactions, and each is held against
  what the lines add up to. A file that disagrees with itself, or a transaction
  that does not balance, comes back as written, with a violation.
- The encoding is the one the XML declaration names — UTF-8 or ISO-8859-1 —
  and UTF-8 when it names none, as XML provides. A caller who names another
  is refused rather than obeyed.
- The XML is read by a strict reader of its own: no DOCTYPE, no entity beyond
  the five XML predefines, bounds on size, depth and element count.

What is not read: the sub-ledgers of version 3.2 (`subledgers`,
`obSubledgers`), which restate by party what the lines already say; the VAT
codes and the tax amounts of a line; the periods; the history of changes.

## What it returns

The shape declared in [`src/types.ts`](./src/types.ts), which is, field for
field, the shape every reader of an accounting export in this repository
declares for itself, plus the `version` of the file and the `openingDate` of
its opening balance. Amounts are decimal strings, never negative. What is not
an audit file is thrown as a `BooksFileError` with a `code`.

It knows no chart of accounts: in [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os)
the correspondence is made by `ekwo import xaf <file>`.

## Sources

The format was read on 24 September 2026 from the schemas the Dutch tax
administration publishes on its developer portal — `XmlAuditfileFinancieel3.2.xsd`
and `XmlAuditfileFinancieel4.0.xsd`, kept under [`test/xsd/`](./test/xsd/README.md)
with where each came from — and from the pages of that portal:
[Auditfile Financieel (XAF) v 3.2.1](https://odb.belastingdienst.nl/auditfiles/auditfile-financieel-xaf-v-3-2-1/),
[XMLAuditfile Financieel (XAF) v 4.0.3](https://odb.belastingdienst.nl/auditfiles/xmlauditfile-financieel-xaf-v-4-0-3/),
[Achtergrond informatie XAF4.0](https://odb.belastingdienst.nl/auditfiles/achtergrond-informatie-xaf4-0/).

It was written against the audit file **Exact Online** exports, as its help
centre describes it on the same day:
[Auditfiles in xml-formaat (XAF) exporteren](https://support.exactonline.com/community/s/article/All-All-HNO-Task-general-importexport-gen-impexp-auditt?language=nl_NL)
— *Import/Export > Export > Audit file*; entries not yet processed are not in
the file. `ekwo import exact-online <file>` is the same as `ekwo import xaf`.

The fixtures under `test/fixtures/`, one per version, are written by hand, hold
no real data, and are validated against the schema of their version by
`test/schema.test.ts`.

MIT.
