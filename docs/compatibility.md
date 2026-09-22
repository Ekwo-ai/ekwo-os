# Compatibility: the exports Ekwo reads

What `ekwo import` and the MCP tool `import_books` read, one line per source.
A source is **available** only once its reader exists and is tested in this
repository; anything else is not listed. Each reader lives in
[`packages/formats/`](../packages/formats/README.md) and its README gives the
columns it reads. How an import works — the correspondence of accounts, the
rehearsal, all or nothing — is [`import.md`](import.md).

This page says what is read. It says nothing else about the software named.

## Books

| Source | Command | Export expected | Official page | State |
|---|---|---|---|---|
| Any ledger | `ekwo import trial-balance` | A trial balance as CSV: account, debit, credit, or a signed balance | — | available |
| FEC (France) | `ekwo import fec` | The *fichier des écritures comptables*, arrêté du 29 juillet 2013 (art. A. 47 A-1 LPF) | Livre des procédures fiscales, art. A. 47 A-1 | available |
| Odoo (Accounting), 17 and 18 | `ekwo import odoo` = `journal-items` | Journal Items exported as CSV (labels or field names), and optionally the chart of accounts and the partners, each exported as CSV | [Export and import data — 17.0](https://www.odoo.com/documentation/17.0/applications/essentials/export_import_data.html), [18.0](https://www.odoo.com/documentation/18.0/applications/essentials/export_import_data.html) | available |
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
two reader READMEs above, the only files `scripts/check-no-competitor-names.mjs`
lets name another product. The text says what is read, and nothing else.
