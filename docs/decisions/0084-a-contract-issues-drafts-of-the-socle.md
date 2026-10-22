# A contract issues drafts of the socle

> Status: accepted

## Context

A company bills most of what it sells under an agreement: a subscription, a
licence, a maintenance contract, a lease of equipment. It buys the same way.
What was agreed — the party, the term, how it renews and with how much notice,
the price of each line and how often it is invoiced — lived outside the books,
and the invoices it said were due were keyed by hand, month after month, with
the contract's number copied into the reference when somebody remembered.

The `crm` module showed the shape of a module whose rows are about contacts
rather than about the ledger. A contracts module has one more reach: what it
produces is an invoice, which is the socle's.

## Decision

**A module `contracts`, in its own schema, on the shape of `crm`.** Five
tables — `templates`, `contracts`, `schedules`, `issues`, `amendments` — and a
view, `deadlines`. Every reference is composite with `company_id`, every
function is `security invoker` and refuses by name (`contracts_<code>: …`),
and its policies go through `module_enabled()` and the module's own
capabilities: `contracts.read`, `contracts.write`, and `contracts.issue` for
turning a schedule into documents — so a member may keep the contracts
without invoicing from them.

**An issue is a draft document of the socle, written as a person writes one.**
`contracts.issue_due(company, day)` inserts into `public.documents` and
`public.document_lines`, under the socle's policies — `documents.write` is
asked, by name, before anything is written — a sales invoice on a sale, a
purchase invoice on a purchase, dated the first day of the period, to the
contract's party, in its currency, with `contract_reference` (EN 16931 BT-12)
set to the contract's number. The account of the line is resolved by the
socle from the product or the company's defaults, never by the module; the
tax is named by its code in the company's own list and read at each issue.
The module never names `entries` or `entry_lines`, and calls no
`post_module_entry()`: its manifest says `"posts": false`.

**`auto_post` asks the socle, as a person would.** A schedule that says so
has each of its documents booked by `post_document()`, which needs
`documents.post` — asked by name before the first one is written. The entry is
the socle's, built by the socle's rules, exactly as if a member had pressed
the button. Without it, the drafts wait for somebody to read them, which is
the default because AGENTS.md has an agent post nothing without the user.

**Idempotent because the socle refuses the duplicate.** The draft of a period
carries `client_ref = contracts:<schedule>:<first day>`, unique per company in
`public.documents` since the socle's idempotent creation; `contracts.issues` is
unique per schedule and first day. `issue_due()` twice for one day issues
once; two callers at once wait on the schedule's lock and the second finds
`next_on` already moved.

**A period is counted from the first one.** `contracts.step()` adds whole
periods to the first period a schedule issued, so a schedule on the 31st gives
the last day of February and the 31st of March again, rather than drifting to
the 28th for ever.

**A tacit renewal is one more term of the length of the term that ends.**
`contracts.roll_forward(company, day)` — which `issue_due()` runs first —
activates a signed contract whose start has come, expires one whose end has
passed and that does not renew, and renews a tacit one, recording each
renewal as an amendment of kind `renewal`, so the term that ends is always
read from the last renewal or from the start. Notice given is the user
terminating the contract before that day; the notice date is in
`contracts.deadlines`. How long a term lasts and how much notice is due are
the contract's words, never the module's: no country decides a default here.

**The signed file is an attachment of the socle.** The object list named the
column `document_id`, "the signed file as a document of the core, with its
checksum". In the socle a *document* is an invoice; the file with its checksum
is a row of `public.attachments`. The column is therefore `attachment_id`, on
contracts, amendments and templates alike, and a trigger checks the file is the
company's own because `attachments` has no composite key to name. The file is
filed on the other party (`entity_type = 'contact'`), which `merge_contacts()`
already moves; no value was added to the socle's list of entity types.

**Templates and amendments hold what a contract application holds.** A
template has a name, a category, a format (`html` or `docx`), the html with its
`{{variables}}` or the docx file, the variables as JSON
(`key`, `label`, `type`, `required`, `default_value`) and a template schedule.
An amendment is numbered in its contract and is a `version` of the text with
its file, an `amendment` applied as it is recorded, or a `renewal`. That is
enough for an application that keeps contract templates and signatures to
move its rows here one for one; the map is in the module's README.
Signature itself stays out of this version.

## Consequences

- An invoice issued from a contract is an ordinary document: it is posted,
  sent, paid, credited and archived by the socle's own functions, and a
  report reads it like any other.
- Deleting a draft takes its issue with it; `next_on` stays where it is, so
  the period is not issued again until somebody moves it back.
- A contract whose party, side or currency has to change once it has issued a
  document is another contract (`contracts_already_issued`).
- Indexation is data, never a formula the module runs: its due date is a
  deadline, and the new price an amendment.

## See also

- [`modules/contracts/README.md`](../../modules/contracts/README.md)
- [0051 A module has its own schema](0051-a-module-has-its-own-schema.md)
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
