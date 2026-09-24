# Compatibility: the exports Ekwo reads

What `ekwo import` and the MCP tool `import_books` read, one line per source.
A source is **available** only once its reader exists and is tested in this
repository; anything else is not listed. Each reader lives in
[`packages/formats/`](../packages/formats/README.md) and its README gives the
columns it reads. How an import works — the correspondence of accounts, the
rehearsal, all or nothing — is [`import.md`](import.md).

This page says what is read, and — under [Writing back](#writing-back--planned) —
what is coming. It says nothing else about the software named.

## Books

| Source | Command | Export expected | Official page | State |
|---|---|---|---|---|
| Any ledger | `ekwo import trial-balance` | A trial balance as CSV: account, debit, credit, or a signed balance | — | available |
| FEC (France) | `ekwo import fec` | The *fichier des écritures comptables*, arrêté du 29 juillet 2013 (art. A. 47 A-1 LPF) | Livre des procédures fiscales, art. A. 47 A-1 | available |
| Exact Online | `ekwo import exact-online` = `xaf` | The XML Audit File (XAF), version 3.2 or 4.0, exported under *Import/Export > Export > Audit file*; entries not yet processed are not in it. Its opening balance opens on the day the file gives | [Auditfiles in xml-formaat (XAF) exporteren](https://support.exactonline.com/community/s/article/All-All-HNO-Task-general-importexport-gen-impexp-auditt?language=nl_NL); the format: [XMLAuditfile Financieel (XAF) v 4.0.3](https://odb.belastingdienst.nl/auditfiles/xmlauditfile-financieel-xaf-v-4-0-3/), [v 3.2.1](https://odb.belastingdienst.nl/auditfiles/auditfile-financieel-xaf-v-3-2-1/) | available |
| Odoo (Accounting), 17 and 18 | `ekwo import odoo` = `journal-items` | Journal Items exported as CSV (labels or field names), and optionally the chart of accounts and the partners, each exported as CSV | [Export and import data — 17.0](https://www.odoo.com/documentation/17.0/applications/essentials/export_import_data.html), [18.0](https://www.odoo.com/documentation/18.0/applications/essentials/export_import_data.html) | available |
| Pennylane | `ekwo import pennylane` = `fec` | The FEC, exported under *Comptabilité > Saisie > Exports > Exporter le FEC*: the text file inside the ZIP it downloads, separated by tabs, in UTF-8. Account numbers are read as the file writes them, with the digit the export appends to some of them | [Exporter un FEC](https://help.pennylane.com/fr/articles/18662-exporter-un-fec) | available |
| QuickBooks Online | `ekwo import quickbooks-online` = `transaction-journal` | The Journal report with its Account # column, exported to Excel and saved as CSV; optionally the Account List, exported and saved the same way. Dates in digits are read in the order given by `--date-order` | [Print a journal entry report](https://quickbooks.intuit.com/learn-support/en-us/help-article/journal-entries/print-journal-entry-report/L1IhAG8PT_US_en_US), [Export reports to Excel](https://quickbooks.intuit.com/learn-support/en-us/help-article/report-management/export-reports-excel-quickbooks-online/L7iAoP97n_US_en_US), [Export your QuickBooks Online data](https://quickbooks.intuit.com/learn-support/en-us/help-article/list-management/export-reports-lists-data-quickbooks-online/L1xleDrLp_US_en_US) | available |
| Sage 50 (France) | `ekwo import sage-50` = `fec` | The FEC, exported under *Échanges > Exporter des écritures*, format FEC — for a closed year, *Traitements > Vérification comptable DGFIP > Export des écritures FEC*. A file that is not in UTF-8 is read with `--encoding iso-8859-15` | [Exporter un fichier FEC](https://fr-kb.sage.com/portal/app/portlets/results/viewsolution.jsp?solutionid=211010150055907) | available |
| Xero | `ekwo import xero` = `journal-report` | The Journal Report or the General Ledger Detail with its Journal ID and Account Code columns, exported to a spreadsheet and saved as CSV; optionally the chart of accounts and the contacts, exported as CSV | [General Ledger Detail report](https://central.xero.com/0/article/General-Ledger-Detail-report), [Journal report](https://central.xero.com/0/article/Journal-report), [Export or print your chart of accounts](https://central.xero.com/0/article/Export-or-print-your-chart-of-accounts), [Export contacts out of Xero](https://central.xero.com/0/article/Export-contacts-out-of-Xero) | available |

## Bank statements

| Source | Command | State |
|---|---|---|
| ISO 20022 camt.053 | `ekwo import camt.053` | available |
| CODA (Febelfin, version 2) | `ekwo import coda` | available |
| CFONB 120 | `ekwo import cfonb120` | available |

## What an import does not take over

For every source above:

- **Tax.** An imported line carries an account and an amount, not the tax
  that produced it. The history feeds the ledger, the trial balance and the
  statements, and no box of a VAT return.
- **Reconciliation marks.** They are read and not re-applied: an open item is
  matched in Ekwo, with `reconcile`.
- **Accounts the chart does not have.** Each old account is mapped to an
  account of the company's chart; none is created.
- **Documents.** Invoices and bills arrive as the entries they were posted as,
  not as documents that can be sent again.

## Adding a line

A reader in `packages/formats/`, named after the file it reads, tested against
fixtures that hold no real data; a line here; and, to be found by the name of
the software, an entry in the two lists that name them —
`packages/cli/src/commands/import.ts` and
`packages/mcp/src/tools/import-books.ts` — which are, with this page and the
README of each reader written against a named export, the only files
`scripts/check-no-competitor-names.mjs` lets name another product. The text
says what is read, and nothing else.

## Writing back — planned

Today Ekwo reads the software above from its exports and writes into none of
it. What is coming, with no date, in [Ekwo Cloud](https://cloud.ekwo.ai), the
hosted edition: connectors that read that software continuously through its
public API, and write back into it — received invoices as draft bills with
their attachment, the entries an assistant proposes as drafts, and the status
of each obligation (sent, received, filed, refused).

Nothing is ever posted or approved in the other software on the user's
behalf: whatever Ekwo writes there arrives as a draft. The readers of the
exports stay here, in the open, and so does everything they bring in.
