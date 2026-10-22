# Usage figures

`usage_figures()` tells whoever runs an installation for somebody else — a
host keeping an instance alive, an operator linked to a company by a key —
whether the books are in use, without reading them. It is a function of the
schema; it sends nothing anywhere. Whoever calls it gets the answer, and only
for the companies they are on.

```sql
select * from ekwo.usage_figures();
```

```sh
curl -X POST "https://YOURREF.supabase.co/rest/v1/rpc/usage_figures" \
  -H "apikey: <the publishable key>" \
  -H "X-Ekwo-Api-Key: <the secret of a key of the company>"
```

## What it returns

One row per company and per figure:

| Column | What it is |
|---|---|
| `company_id` | The company counted. |
| `figure` | The name of the figure, from the list below. |
| `count` | How many rows it counts. |
| `last_created_at` | When the most recent of them was created; null when there is none, or when the table keeps no creation date. |

The last time anything was written in a company is the greatest
`last_created_at` of its rows.

No name, no amount, no label, no number of a document and no identifier other
than the company's own is returned. That is the whole of the promise, and
`tests/usage_figures.test.ts` holds it.

## The list

Always returned, with `0` when the company has none:

| Figure | Counts |
|---|---|
| `members` | People on the company (`company_members`). |
| `invitations` | Invitations sent, whatever became of them. |
| `contacts` | Customers and suppliers. |
| `products` | Products and services. |
| `fiscal_years` | Fiscal years opened. |
| `bank_accounts` | Bank accounts. |
| `bank_statements` | Bank statements, imported or keyed. |
| `payments` | Payments recorded. |
| `book_imports` | Imports of books kept elsewhere. |
| `tax_filings` | Declarations prepared. |
| `vat_schemes` | VAT schemes the company said it is on (`company_vat_schemes`), one per change. |
| `declaration_instalments` | Payments on account of a declaration recorded. |
| `attachments` | Files attached to a document or an entry. |

Returned for each group that has at least one row:

| Figure | Counts |
|---|---|
| `documents.<doc_type>.<state>` | Documents of that type in that state — `documents.sale_invoice.posted`, `documents.purchase_invoice.draft`. |
| `entries.<state>` | Entries in that state — `entries.posted`, `entries.draft`. |

For each module enabled on the company:

| Figure | Counts |
|---|---|
| `modules.<code>` | `1`; `last_created_at` is when it was enabled. |
| `<code>.<table>` | Rows of each table of the module's schema that carries `company_id` — `crm.deals`, `budgets.lines`. |

A module installed later is counted the same way, without a change here.

## What it leaves out

What the country pack lays down when a company is created — accounts, taxes,
tax postings, journals, declaration boxes — is the same for every company of a
country and says nothing about whether anybody keeps books there. It is not
counted. Nor is the audit trail, which counts what the other figures already
count.

## Who may call it

A member of the company, signed in, and the holder of a key of that company,
whatever the key's capabilities: what it learns is less than what any of them
already lets it read. Anybody else gets no rows, and an anonymous caller is
refused. The headers are those of [`machine-access.md`](machine-access.md);
decision [0093](decisions/0093-a-company-is-counted-never-read.md).
