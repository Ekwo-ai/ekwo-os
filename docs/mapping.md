# Mapping: Ekwo ↔ EN 16931 ↔ FEC

Each Ekwo column that has a counterpart in a standard, lined up against it. It
lets an integrator write a connector in a day instead of reading the schema
and the standards in parallel for a week.

- **EN 16931** references are business term identifiers (`BT-`) and business
  groups (`BG-`) of the European semantic standard for electronic invoicing,
  as used by Peppol BIS Billing 3.0 and Factur-X.
- **FEC** refers to the eighteen columns of the French *fichier des écritures
  comptables*, arrêté du 29 juillet 2013 (art. A. 47 A-1 du LPF). The column
  is produced by `fec_lines()`.

An empty cell means there is no counterpart, which is itself information.

## Company and period

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `companies.name` | BT-27 seller name | |
| `companies.legal_name` | BT-27 | |
| `companies.vat_number` | BT-31 seller VAT identifier | |
| `companies.registration_number` | BT-30 seller legal registration | |
| `companies.country` | BT-40 seller country | |
| `companies.peppol_scheme`, `.peppol_identifier` | BT-34 seller electronic address, with its scheme (BT-34-1) | |
| `companies.address_line1`, `.postal_code`, `.city` | BG-5 seller postal address | |
| `companies.currency_code` | BT-5 invoice currency | `Idevise` (when it differs) |

## Chart of accounts

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `accounts.code` | | `CompteNum` |
| `accounts.name` | | `CompteLib` |

## Journals

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `journals.code` | | `JournalCode` |
| `journals.name` | | `JournalLib` |

## Contacts

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `contacts.name` | BT-44 buyer name / BT-27 seller name | `CompAuxLib` |
| `contacts.vat_number` | BT-48 buyer VAT identifier | |
| `contacts.registration_number` | BT-47 buyer legal registration | |
| `contacts.auxiliary_code` | | `CompAuxNum` |
| `contacts.email` | BT-43 buyer contact email | |
| `contacts.address_line1`, `.postal_code`, `.city`, `.country` | BG-8 buyer postal address | |
| `contacts.payment_terms_days` | BT-20 payment terms | |
| `contacts.iban` | BT-84 payment account identifier | |
| `contacts.peppol_scheme`, `.peppol_identifier` | BT-49 buyer electronic address, with its scheme (BT-49-1) | |

## Taxes

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `taxes.amount` | BT-119 category rate, through the snapshot the line keeps | |
| `taxes.vat_category` | BT-118 category code, through the snapshot the line keeps | |
| `taxes.exemption_code` | BT-121 exemption reason code | |
| `taxes.legal_reference` | *(the article the tax rests on, written for a reviewer; BT-120 is `document_tax_summary.exemption_reason`)* | |

## Entries and ledger lines

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `entries.number` | | `EcritureNum` |
| `entries.entry_date` | | `EcritureDate` |
| `entries.reference` | | `PieceRef` |
| `entries.description` | | `EcritureLib` (fallback) |
| `entries.posted_at` | | `ValidDate` |
| `entries.journal_id` | | `JournalCode`, `JournalLib` |
| `entry_lines.account_id` | | `CompteNum`, `CompteLib` |
| `entry_lines.debit`, `.credit` | | `Debit`, `Credit` |
| `entry_lines.name` | | `EcritureLib` |
| `entry_lines.contact_id` | | `CompAuxNum`, `CompAuxLib` |
| `entry_lines.date_maturity` | BT-9 due date | |
| `entry_lines.matching_number` | | `EcritureLet` |
| `entry_lines.amount_currency`, `.currency_code` | | `Montantdevise`, `Idevise` |

## Documents

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `documents` | BG-2 process control | |
| `documents.doc_type` | BT-3 invoice type code | |
| `documents.number` | BT-1 invoice number | `PieceRef` |
| `documents.supplier_reference` | BT-1 on the supplier's side | |
| `documents.contact_id` | BG-7 buyer | |
| `documents.document_date` | BT-2 issue date | `PieceDate` |
| `documents.accounting_date` | | `EcritureDate` |
| `documents.due_date` | BT-9 due date | |
| `documents.currency_code` | BT-5 | `Idevise` |
| `documents.buyer_reference` | BT-10 buyer reference | |
| `documents.project_reference` | BT-11 project reference | |
| `documents.contract_reference` | BT-12 contract reference | |
| `documents.order_reference` | BT-13 purchase order reference | |
| `documents.delivery_date` | BT-72 actual delivery date | |
| `documents.tax_point_date` | BT-7 value added tax point date | |
| `documents.delivery_address_line1`, `.delivery_postal_code`, `.delivery_city`, `.delivery_country` | BG-15 deliver-to address | |
| `documents.payment_terms` | BT-20 payment terms | |
| `documents.payment_means_code` | BT-81 payment means type code | |
| `documents.payment_reference` | BT-83 remittance information | |
| `documents.payee_iban` | BT-84 payment account identifier | |
| `documents.note` | BT-22 invoice note | |
| `documents.amount_untaxed` | BT-109 total without VAT | |
| `documents.amount_tax` | BT-110 total VAT | |
| `documents.amount_total` | BT-112 total with VAT | |
| `documents.amount_paid` | BT-113 paid amount | |
| `documents.amount_residual` | BT-115 amount due for payment | |
| `documents.reversed_document_id` | BT-25 preceding invoice reference | |

## Products

Ekwo has one table for a product and no variant of it, because variants are a
commerce feature and a variant with no distinct price, account or tax is a row that carries
nothing. Nothing here is stock: there is no `qty_available`, no valuation and
no move, and there is deliberately no counterpart to them.

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `products` | BG-31 item information | |
| `products.code` | BT-155 item seller identifier | |
| `products.name` | BT-153 item name | |
| `products.description` | BT-154 item description | |
| `products.unit_code` | BT-130 unit of measure code | |
| `products.sale_price` | BT-146 item net price | |
| `products.sale_account_id` | | `CompteNum` |
| `products.purchase_account_id` | | `CompteNum` |

## Document lines

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `document_lines` | BG-25 invoice line | |
| `document_lines.sequence` | BT-126 line identifier | |
| `document_lines.name` | BT-153 item name | |
| `document_lines.description` | BT-154 item description | |
| `document_lines.quantity` | BT-129 invoiced quantity | |
| `document_lines.unit_code` | BT-130 unit of measure code | |
| `document_lines.unit_price` | BT-146 item net price | |
| `document_lines.discount_percent` | BT-138 document level allowance percentage | |
| `document_lines.amount_untaxed` | BT-131 line net amount | |
| `document_lines.account_id` | | `CompteNum` |
| `document_lines.vat_category` | BT-151 line VAT category code | |
| `document_lines.vat_rate` | BT-152 line VAT rate | |
| `document_tax_summary` (view) | BG-23 VAT breakdown, one row per tax: two taxes of one category and rate are one group of the standard | |
| `document_tax_summary.vat_category` | BT-118 category code, as the lines carry it | |
| `document_tax_summary.tax_rate` | BT-119 category rate, as the lines carry it | |
| `document_tax_summary.base_amount` | BT-116 category taxable amount | |
| `document_tax_summary.tax_charged` | BT-117 category tax amount: what the buyer is charged, nothing where the tax is self-assessed | |
| `document_tax_summary.tax_amount` | *(the tax the return reports, which a reverse charge has and its invoice does not)* | |
| `document_tax_summary.exemption_code` | BT-121 exemption reason code | |
| `document_tax_summary.exemption_reason` | BT-120 exemption reason text | |
| `document_header` (view) | BG-2 to BG-19, everything above the lines | |
| `document_header.tax_point_date` | BT-7 value added tax point date | |
| `document_header.delivery_address_line1`, `.delivery_postal_code`, `.delivery_city`, `.delivery_country` | BG-15 deliver-to address (BT-75, BT-78, BT-77, BT-80) | |
| `document_header.seller_peppol_scheme`, `.seller_peppol_identifier` | BT-34-1, BT-34 | |
| `document_header.buyer_peppol_scheme`, `.buyer_peppol_identifier` | BT-49-1, BT-49 | |
| `document_line_items` (view) | BG-25 with BG-31 | |
| `document_line_items.seller_item_identifier` | BT-155 item seller identifier | |

### To the Peppol invoice

[`@ekwo-ai/peppol-ubl`](../packages/formats/peppol-ubl/) reads one row of
`document_header`, the rows of `document_line_items` and the rows of
`document_tax_summary`, under the column names above, and nothing else: no
join to a table and no option is needed for a posted sale to come out with no
rule broken. Dates are selected `::text`. What the views do not say yet, and
the brick therefore reports rather than writes: the net price of a line keyed
with its tax in it (BT-146, BR-26), document and line allowances and charges,
and a reason for a supply outside the scope of the tax where the pack gives it
no code (BR-O-10).

### To the Factur-X invoice object

[`@ekwo-ai/factur-x`](../packages/formats/factur-x/) takes a plain
invoice object and emits EN 16931 CII XML. It lives in this repository under
`packages/formats/`, but `@ekwo-ai/core` does not depend on it: a format is
something you add on top of the ledger, not something the ledger needs. The
mapping is therefore written here and asserted in `tests/mcp/products.test.ts`
without the library.

Read `document_line_items` and build one line per row:

| Factur-X line field | Ekwo | EN 16931 |
|---|---|---|
| `name` | `item_name` | BT-153 |
| `description` | `item_description` | BT-154 |
| `sellerItemId` | `seller_item_identifier` — the product code, null on a free-text line | BT-155 |
| `quantity` | `quantity` | BT-129 |
| `unitCode` | `unit_code` | BT-130 |
| `unitPrice` | `unit_price` | BT-146 |
| `vatRate` | `vat_rate` | BT-152 |
| `vatCategory` | `vat_category` | BT-151 |

The header comes from `documents` and `companies` as the Documents table
above says: `number` → `number` (BT-1), `document_date` → `issueDate` (BT-2),
`due_date` → `dueDate` (BT-9), `buyer_reference` → `buyerReference` (BT-10),
`order_reference` → `orderReference` (BT-13), `payee_iban` → `payment.iban`
(BT-84).

## Payments, matching, bank

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `reconciliations.matched_at` | | `DateLet` |
| `reconciliations.matching_number` | | `EcritureLet` |

## Analytics and attachments

| Ekwo | EN 16931 | FEC |
|---|---|---|
| `attachments` | BG-24 additional supporting documents | |

## Deliberately absent

| What | Why not |
|---|---|
| A line type telling invoice lines from ledger lines | Documents and entries are two tables, so a line never has to say which one it belongs to. |
| A product catalogue with variants | A catalogue is an application concern, not an accounting one. |
| Analytic columns created at runtime | A schema that alters itself cannot be migrated or secured. |
| Per-company defaults stored as JSON | A plain column per company default is simpler and joinable. |
| An XML-RPC or JSON-RPC endpoint | Supabase exposes the schema as REST with an OpenAPI description. |

## Producing a FEC

`fec_lines(company_id, from, to)` returns the eighteen columns: the opening
balances of the financial year first, then its movements in chronological
order. `generateFec()` in `@ekwo-ai/fec` turns them into the file, and
`checkFec()` applies the file-level rules — mandatory fields, one side per
line, each entry balancing — before you hand it over.

The opening lines are computed from the ledger and never posted, one per
balance-sheet account, plus one for the result of a year that has not been
closed yet. They appear only when the period is exactly a financial year. The
sources below are those of a movement line; an opening line takes its journal
from `country_defaults.opening_journal_code`, its account and amount from the
cumulative balance of the day before the year opens, and its label from
`country_defaults.opening_entry_label`.

| FEC column | Source |
|---|---|
| `JournalCode`, `JournalLib` | `journals.code`, `journals.name` |
| `EcritureNum` | `entries.number` |
| `EcritureDate` | `entries.entry_date` |
| `CompteNum`, `CompteLib` | `accounts.code`, `accounts.name` |
| `CompAuxNum`, `CompAuxLib` | `contacts.auxiliary_code`, `contacts.name` |
| `PieceRef` | `documents.number`, else `documents.supplier_reference`, else `entries.reference` |
| `PieceDate` | `documents.document_date`, else `entries.entry_date` |
| `EcritureLib` | `entry_lines.name`, else `entries.description`, else `accounts.name` |
| `Debit`, `Credit` | `entry_lines.debit`, `entry_lines.credit` |
| `EcritureLet` | `entry_lines.matching_number` |
| `DateLet` | latest `reconciliations.matched_at` on that line |
| `ValidDate` | `entries.posted_at` |
| `Montantdevise`, `Idevise` | `entry_lines.amount_currency`, `entry_lines.currency_code`, when the currency differs from the company's |
