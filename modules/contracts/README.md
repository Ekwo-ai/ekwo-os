# `contracts` — what a company agreed, and the invoices it says are due

One Postgres schema, `contracts`. A contract is an agreement with one party of
the books — a customer when the company sells, a supplier when it buys — and
the module keeps what was agreed: its kind, its dates, how it renews and with
how much notice, its value, the signed file. Its **schedules** are the lines it
invoices, each at its own rhythm, and `contracts.issue_due()` turns every
period that has come into **one draft document of the socle**: a sales invoice
on a sale, a purchase invoice on a purchase, `contract_reference` (EN 16931
BT-12) set to the contract's number.

The module **never writes the ledger itself** (`"posts": false`). A draft it
issues is an ordinary document: read, posted, sent, paid and credited by the
socle's own functions. A schedule with `auto_post` asks the socle's
`post_document()` to book its documents, as a member with `documents.post`
would. Why it is shaped this way is
[decision 0084](../../docs/decisions/0084-a-contract-issues-drafts-of-the-socle.md).

It knows no country, no currency and no language: the currency of a contract
is the company's unless another is named, a tax is named by its code in the
company's own list, and the account of a line is resolved by the socle.

| Object | What it is |
|---|---|
| `contracts.contracts` | One agreement: party, `number` (unique in the company), `name`, `kind`, `direction` (`sale` / `purchase`), `state`, `signed_on`, `starts_on`, `ends_on` (null: open-ended), `renews_on`, `renewal` (`none` / `tacit`), `notice_days`, `currency_code`, `total_value`, the signed file (`attachment_id`), `notes`, `analysis`, `attributes`. |
| `contracts.schedules` | A line it invoices: product or name, quantity, unit (UN/ECE Rec. 20), unit price, tax by code, `frequency` (`weekly`, `monthly`, `quarterly`, `yearly`), `next_on`, `until`, `indexation` (as data), `auto_post`. |
| `contracts.issues` | Which document a schedule issued for which period. One per schedule and first day. |
| `contracts.amendments` | The history of a contract, numbered from 1: a `version` of the text with its file, an `amendment` — what changes, from when, signed when, with the signed file — or a tacit `renewal`. |
| `contracts.templates` | What a contract starts from: clauses as `html` with `{{variables}}` or as a `docx` file, the variables, a category, a template schedule. |
| `contracts.deadlines` | A view: the notice date, the renewal, the end, the next issue and the indexation due, of every signed or active contract. |

A contract's state moves forward only — `draft → sent → negotiation → signed →
active → expired | terminated | cancelled` — and the last three are final. A
running contract is terminated, not cancelled; an unsigned one is cancelled.

| Function | What it does |
|---|---|
| `contracts.upsert_contract(company, number, patch)` | Creates the contract of that number or changes it, field by field. A new one needs `contact_id`, `name`, `kind` and `direction`. Once it has issued, its party, side and currency stay (`contracts_already_issued`). |
| `contracts.upsert_schedule(company, contract, schedule, patch)` | Adds a schedule (`schedule` null) or changes one. From a product (`product_code`), the product's name, unit, price and tax for the side of the contract pre-fill it. |
| `contracts.issue_due(company, day)` | Every period whose first day is on or before `day`, one draft each; `next_on` moved on. Renewals and expiries first. Idempotent per schedule and period. |
| `contracts.roll_forward(company, day)` | Signed contracts whose start has come become active; ended ones expire, or renew tacitly for the length of the term that ends. |
| `contracts.amend(company, contract, summary, effective_on, changes, kind, signed_on, attachment)` | Records an amendment and applies its changes — contract fields by name, schedule fields under `"schedules": {"<id>": {…}}` — or a version with its file. |
| `contracts.from_template(company, template, contact, number, direction, kind, starts_on, values, name)` | A draft contract of a template, its schedule copied, the clauses answered with the values in place. A required variable left empty is refused, `contracts_missing_variable`. |
| `contracts.card_of(company, contract)` | One contract as one JSON object: the contract, its party, its file, its schedules, its history, its latest documents and its deadlines. |
| `contracts.list_contracts(company, state, direction, contact, query, limit)` | The contracts, each with its nearest deadline. |
| `contracts.list_templates(company, include_inactive)` | The templates, by category and name. |

```sql
select contracts.upsert_contract(:company, 'CTR-0001', '{
  "contact_id": "…", "name": "Hosting", "kind": "subscription", "direction": "sale",
  "state": "signed", "starts_on": "2027-01-01", "ends_on": "2027-12-31",
  "renewal": "tacit", "notice_days": 90}');

select contracts.upsert_schedule(:company, :contract, null, '{
  "name": "Hosting", "quantity": "2", "unit_price": "500", "tax_code": "<a code of the company>",
  "frequency": "monthly", "next_on": "2027-01-01"}');

select * from contracts.issue_due(:company, current_date);   -- the drafts that are due
select * from contracts.deadlines where company_id = :company order by due_on;
```

## Capabilities

| Capability | Viewer, client | Accountant | Owner |
|---|---|---|---|
| `contracts.read` | yes | yes | yes |
| `contracts.write` | — | yes | yes |
| `contracts.issue` | — | yes | yes |

`issue_due()` needs `contracts.issue` and `contracts.write` (it moves
`next_on`), and the socle's `documents.write` — `documents.post` too for a
schedule with `auto_post` — each refused by name before anything is written.
`contracts.issues` is written under `contracts.issue` alone.

## What an accountant should check

- **The tax of each schedule.** It is a code of the company's own list,
  chosen by whoever wrote the schedule, read at every issue. A contract whose
  supply changes treatment is amended; nothing here picks a tax.
- **The date of a document.** A draft is dated the first day of the period
  it covers: invoicing in advance. A company that invoices in arrears sets
  `next_on` to the day it invoices.
- **Notice dates.** `contracts.deadlines` computes the last day notice can be
  given as `notice_days` before the next term, or before the day after the
  end where the contract does not renew. It is a reading of the figures
  recorded, not of the contract's text: counsel reads the clause.
- **Tacit renewal.** A contract renews for the length of the term that ends,
  measured in years, months and days from the last renewal or from the start.
  A clause that renews for another length is an amendment of `ends_on` when
  the time comes.
- **Indexation.** The index, the formula and the base are kept as data and
  never computed: the due date is a deadline, the new price an amendment.

## From an agent

Once `public.modules` carries `contracts`, the MCP server offers eight tools,
each a function above called through `@ekwo-ai/core`; `ekwo contracts …` calls
the same ones.

| Tool | Command | Function | Writes |
|---|---|---|---|
| `contracts_list` | `ekwo contracts list [--templates]` | `list_contracts()`, `list_templates()` | no |
| `contracts_card` | `ekwo contracts card <contract>` | `card_of()` | no |
| `contracts_deadlines` | `ekwo contracts deadlines` | the view `deadlines` | no |
| `contracts_upsert` | `ekwo contracts set <number>` | `upsert_contract()` | yes |
| `contracts_schedule` | `ekwo contracts schedule <contract>` | `upsert_schedule()` | yes |
| `contracts_issue_due` | `ekwo contracts issue [--on <date>]` | `issue_due()` | yes: drafts of the socle |
| `contracts_amend` | `ekwo contracts amend <contract>` | `amend()` | yes |
| `contracts_from_template` | `ekwo contracts from-template <template> <contact>` | `from_template()` | yes |

An agent shows what is due before issuing it, and the drafts before anything
is posted: [AGENTS.md](../../AGENTS.md).

## A signature request, later

Signature is not in this version. When it comes, it attaches the way an
electronic invoice leaves the `einvoicing` module: **a transport the host
brings**, with no provider named in the core.

- A request names a contract, or one of its amendments, and the file to sign
  — an attachment of the socle, whose checksum is the fingerprint of what is
  signed.
- Its signers are people of the party and of the company, each with an order
  and a state; the module records what the transport reports (sent, signed,
  declined, expired) and when, and never reaches a provider itself.
- The signed file comes back as a new attachment with its own checksum, and
  is written as the `attachment_id` of the contract (or of the amendment) with
  its `signed_on`; the contract moves to `signed`.
- Which level of signature a deed requires is a rule of a country, and so pack
  data — the planned `sign` module of [`modules/README.md`](../README.md).

## Moving an application that keeps contract templates and signatures

The module is the ground such an application can move onto. Its rows move as
below; nothing here assumes the move has been made.

| Its table | Here | How |
|---|---|---|
| `contract_templates` (`name`, `description`, `category`, `variables`, `is_active`, `created_by`, `created_at`) | `contracts.templates` | 1:1 — `is_active` → `active`; `variables` keeps its shape, `[{key, label, type, required, default_value}]`. |
| `contract_templates.template_format`, `html_content` | `contracts.templates.format`, `html` | 1:1 — `html` or `docx`. |
| `contract_templates.file_path` | `contracts.templates.attachment_id` | Changes shape — the file becomes a row of `public.attachments` (`storage_path`, `checksum`), and the template names it. |
| `contract_templates.company_id` null (a template for every company) | `contracts.templates` of each company | Changes shape — a template belongs to a company here; a shared one is copied into each company that uses it. |
| `documents` (`name`, `file_path`, `file_size`, `mime_type`, `sha256_hash`, `uploaded_by`) of category `contracts` | `public.attachments` (`file_name`, `storage_path`, `byte_size`, `mime_type`, `checksum`, `uploaded_by`), named by a `contracts.contracts` row | Changes shape — the file is an attachment of the socle, filed on the party; the contract itself (party, dates, value) is a new row, which the file alone does not carry. |
| `document_versions` (`version_number`, `file_path`, `file_size`, `change_summary`, `created_by`) | `contracts.amendments` of kind `version` (`number`, `attachment_id`, `summary`, `created_by`) | 1:1 for each version, its file an attachment. |
| `signature_requests`, `signature_request_signers` | — | Stays there until the signature request above exists here; then moves as a request and its signers, the access token never copied. |
| `documents` of the other categories, board members, mandates, shareholders, meetings, attendance, annotations, its audit log | — | Stays there: governance, the board and the shareholders are not contracts. |

## Not in this version

- Signature, above.
- A contract with several parties: one party per contract, as an invoice has
  one buyer.
- Usage measured by the module: a `usage` contract's quantity is what the
  schedule says; metered quantities are written into the draft before it is
  posted.
- Proration of a first or last period: a period runs from one `next_on` to the
  next, cut only by the contract's end.
