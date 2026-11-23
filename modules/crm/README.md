# `crm` — the record of a relationship, beside the books

One Postgres schema, `crm`. A CRM is the record of a relationship, kept beside
the books on the same contacts. It holds **no contact of its own** and writes
**not one line to the ledger**.

A person is a `public.contacts` row with `is_company = false` and `parent_id`
pointing at their organisation; an organisation is a row with
`is_company = true`. Both stay `contact_type = 'other'` while they are
prospects and become `customer` the day a deal is won, so an invoice is issued
to the very row the relationship was built on. Duplicates are merged by the
socle's `merge_contacts()`, which moves every row of this schema with the rest.

The module knows nothing about who works the relationship — that is an agent's
business, outside. It holds cards, segments, pipelines, deals and activities,
and exposes them as functions an agent or a screen calls. An e-mail is enough
to start one: an activity named by an address finds or creates its contact,
then the organisation of its domain ([Cards from e-mail](#cards-from-e-mail)).

Three ways reach the same functions: SQL (below), the MCP server's `crm_*`
tools ([From an agent](#from-an-agent), and the guide
[Connecting a team of agents to the CRM through MCP](../../docs/crm-agents.md)),
and `ekwo crm` ([From the terminal](#from-the-terminal)).

| Object | What it is |
|---|---|
| `crm.cards` | One card per contact the company follows: status, priority, owner, tags, `no_outbound`, custom fields, and when anything last happened. Its first and last interaction are not stored: `crm.card_of()` computes them. |
| `crm.segments` | A tree of groups: a taxonomy branch, a target segment, a cohort, a brand. |
| `crm.segment_members` | A contact in a segment. Leaving sets `left_at` and keeps the row; joining again clears it. |
| `crm.pipelines`, `crm.stages` | A sequence of stages, each `open`, `won` or `lost`. |
| `crm.deals` | A piece of business with one contact, moving through one pipeline. Closed with its date and outcome at a `won` or `lost` stage. |
| `crm.deal_documents` | The documents a deal carries — the versions of a quote, an order, the invoices of its phases. A document belongs to one deal at most, of the same company. |
| `crm.activities` | Everything that happened: a note, an e-mail, a call, a meeting, a signal, a deal moving. The one source of a card's interactions. |
| `crm.generic_email_domains` | The e-mail domains that never name an organisation — personal mailboxes, tools that send on somebody's behalf, providers hosting many organisations. The module ships its rows (`shipped`); the installation adds rows without a company, a company adds its own. A sub-domain of a listed domain is generic too. |

| Function | What it does |
|---|---|
| `crm.upsert_card(company, contact, patch)` | Creates or changes a card. Only the fields the patch names change; an unknown key is refused, `crm_unknown_field`. |
| `crm.log_activity(company, contact, kind, …, source, source_ref)` | Writes an activity and moves the card's `last_activity_at`. The same `(source, source_ref)` twice returns the activity already kept. |
| `crm.log_activity_by_email(company, email, kind, …, source, source_ref, name)` | The same activity, named by an e-mail address: the contact is found or created by `crm.contact_from_email()`, then `crm.log_activity()` writes it. A replay writes nothing, creates nothing, and answers `replayed: true`. |
| `crm.contact_from_email(company, email, name, source)` | The contact at an address, found or created, and the organisation of its domain, found or created — never for a generic domain. Answers `contact_id`, `organisation_id`, `address`, `domain`, `generic_domain`, `contact_created`, `organisation_created`. |
| `crm.interactions_of(company, contacts[])` | For each contact, its first and last interaction and how many there were, computed from `crm.activities` — an organisation's include its people's. |
| `crm.is_generic_email_domain(company, domain)`, `crm.organisation_of_domain(company, domain)`, `crm.email_address(text)`, `crm.email_domain(text)` | The pieces the two above are made of: whether a domain is generic for a company, the organisation a domain belongs to, the address and the domain found in a text such as `Name <address>`. |
| `crm.join_segment(company, segment, contact, added_by, note)` / `crm.leave_segment(company, segment, contact)` | In and out of a segment, with the membership remembered. |
| `crm.open_deal(company, pipeline, contact, title, …)` | Opens a deal at the first `open` stage of the pipeline. |
| `crm.move_deal(company, deal, stage)` | Moves a deal; a `won` or `lost` stage closes it, and a won deal makes its party a customer. Its body is `crm.place_deal()`, which the answer to a quote uses too. |
| `crm.attach_document(company, deal, document)` / `crm.detach_document(company, document)` | A document carried by a deal, or taken off it. A document another deal carries is refused, `crm_document_in_another_deal`. |
| `crm.deal_documents_of(company, deal)` | The documents of a deal, each with its answer and its `quote_status`, as the card and the board give them. |
| `crm.deal_of_document(company, document)` | The deal a document belongs to, read from the document's side: its id, title, amount and currency, its stage (id, name, outcome), `closed_at` and `closed_outcome` — the won deal of an accepted quote too. Null when no deal carries it; a document the caller cannot read in the company is refused, `crm_unknown_document`. |
| `crm.card_of(company, contact)` | One contact as one JSON object: the contact, its organisation, its card with `first_interaction_at`, `last_interaction_at` and `interactions`, its segments, its open deals with the documents they carry, its 20 latest activities. |
| `crm.contact_vcard(company, contact)` | One contact as the text of a vCard 3.0, for an address book: name, organisation, job title, e-mail, telephone, address, profile URL, note. |
| `crm.search_cards(company, query, status, segment, stage, country, language, owner, no_outbound, active_since, inactive_since, limit)` | The cards, filtered; every filter optional. |
| `crm.segment_tree(company)` | Every segment as a tree — parent, depth, path of slugs — with how many contacts are in it now. |
| `crm.board(company, pipeline, include_closed)` | One pipeline, or all of them: the stages in order, the deals at each with the documents they carry, the totals by currency per stage and per pipeline. |
| `crm.timeline(company, contact, deal, since, kinds, limit)` | The activities of a contact or of a deal, latest first. |

```sql
-- An organisation and one of its people, both prospects.
insert into contacts (company_id, name, is_company, contact_type)
values (:company, 'Northwind Trading', true, 'other') returning id;       -- :org
insert into contacts (company_id, name, is_company, contact_type, parent_id, email)
values (:company, 'Ada Lovelace', false, 'other', :org, 'ada@example.org') returning id;  -- :ada

select crm.upsert_card(:company, :ada, '{"status": "contacted", "owner": "sales", "tags": ["event"]}');
select crm.log_activity(:company, :ada, 'email_out', 'First contact',
                        p_source => 'mailbox', p_source_ref => '<message-id@example.org>');
select crm.open_deal(:company, :sales_pipeline, :org, 'Annual subscription', 12000);
select crm.move_deal(:company, :deal, :won_stage);  -- Northwind Trading is now a customer
select crm.card_of(:company, :org);
```

## A quote moves its deal

The socle records the answer to a quote — `accepted_at`, `accepted_by`,
`declined_at`, written by `accept_document()`, `decline_document()` and
`undo_document_answer()` — and derives its status with `quote_status()`:
`draft`, `sent`, `accepted`, `declined`, `expired`, `cancelled`. The quote
carries its dated facts; **the deal carries the commercial status**
([decision 0098](../../docs/decisions/0098-a-quote-carries-its-facts-the-deal-carries-the-status.md)).

Once a deal carries a quote (`crm.attach_document()`), a trigger of this
module on the socle's `documents` moves the deal when the answer moves — in
the database, with no agent and no approval of its own:

| The quote | The deal |
|---|---|
| accepted | to the first `won` stage of its pipeline, and its party becomes a customer |
| declined | to the first `lost` stage, once no other quote of the deal is alive (neither declined, expired nor cancelled) |
| sent, expired | stays: open stages are each company's own |
| answer undone | back to the stage it was at before the answer closed it, else the last open stage of its pipeline |

A pipeline without a `won` (or `lost`) stage keeps the deal where it is, and
the fact stays on the quote. An answer recorded before the quote was
attached moves nothing. A company that has not enabled the module, a quote no
deal carries, and a database without the module: the quote carries its
facts, nothing else changes. Every move is on the deal's timeline, naming the
document.

```sql
select crm.attach_document(:company, :deal, :quote);
select accept_document(:quote, 'The buyer');   -- the deal is won, its party a customer
select undo_document_answer(:quote);           -- the deal is open again where it was
select crm.deal_of_document(:company, :quote);  -- the deal, read from the quote's side
```

A newer client on a database whose module has not received
`crm.deal_of_document()` reads it as absent: `crmDealOfDocument()` answers
`{ deal: null, available: false }`, never an error. A module's migrations
are not counted by `ekwo_schema_version()`, so the read asks for the function
itself rather than for a version (`ekwo module migrate crm` brings it).

## Cards from e-mail

An e-mail already says who it is with: an address, and in it a domain the
people of one organisation share. An agent reading a mailbox, or an import of
one, names the address and lets the module do the rest:

```sql
select crm.log_activity_by_email(:company, 'Grace Hopper <grace@harbour-logistics.example>', 'email_in',
                                 'Pricing question', p_source => 'mailbox',
                                 p_source_ref => '<message-id@example.org>', p_name => 'Grace Hopper');
-- {"contact_id": …, "organisation_id": …, "domain": "harbour-logistics.example",
--  "generic_domain": false, "contact_created": true, "organisation_created": true,
--  "replayed": false, "activity": {…}}
```

1. **The contact.** The contact of the company whose e-mail is that address,
   whatever its case — a person before an organisation, an active one before
   an archived one. None: a person is created, named by `p_name` or by the
   address, `contact_type = 'other'`.
2. **The organisation.** Unless the domain is generic: the organisation whose
   own address is at the domain (the company said so), else the organisation
   most of the people writing from it belong to, else a new organisation named
   by the domain, which the user renames. A person on file without an
   organisation gets the one of its domain; nothing else on file changes.
3. **The cards.** The person and the organisation get a card when they have
   none, with the activity's `source` as theirs. A card already there is left
   as it is.
4. **The activity**, written by `crm.log_activity()`.

**Generic domains are data.** `crm.generic_email_domains` holds the domains
that name nobody: `personal` (a mailbox anybody can open), `tool` (a service
sending on somebody's behalf), `provider` (a host of many organisations). The
module ships a list and may add rows in a later migration; it never takes one
away. An installation adds its own, as the installation (the migration runner
or the service role):

```sql
insert into crm.generic_email_domains (domain, kind, note)
values ('mail.example-isp.net', 'personal', 'Our region''s usual provider');
```

and a company adds rows for itself with `crm.write`, which no other company
reads:

```sql
insert into crm.generic_email_domains (company_id, domain, kind)
values (:company, 'coworking.example', 'provider');
```

**One de-duplication path.** The module never creates a second contact for an
address already on file, and never merges anything itself. Two contacts that
turn out to be one party — a person who wrote from a personal mailbox and from
their organisation's — are joined by the socle's `merge_contacts()`, which
proposes the pair (`suggest_duplicate_contacts()`), moves every row of this
schema, folds the two cards, and records the merge in `contact_merges`.

**Idempotent.** With a `source` and a `source_ref`, the same e-mail a second
time writes nothing and looks nothing up: the answer is the activity already
kept, with `replayed: true`. A mailbox imported twice leaves the same
contacts, organisations and cards. Two e-mails of a new domain arriving
together create one organisation: the module takes a lock per company and
domain while it decides.

**Who may.** `crm.write`, and `contacts.write` to create a contact or give a
person its organisation — refused by name without it, `crm_not_allowed`. A
text holding no address is refused, `crm_bad_email`.

**First and last interaction, computed.** An interaction is an exchange with
the contact: `email_in`, `email_out`, `call`, `meeting`, `message`. A note, a
signal, an enrichment, a task and what the module writes itself are not.
`crm.interactions_of()` computes the first, the last and how many from
`crm.activities` whenever they are read — an organisation's with its
people's — and `crm.card_of()` gives them on the card as
`first_interaction_at`, `last_interaction_at` and `interactions`. Nothing
stores them, so a merge, an activity logged late or one removed is reflected at
the next read. The card's `last_activity_at` is another fact, the latest
activity of any kind, kept by a trigger as before.

**On an older database.** A module's migrations are not counted by
`ekwo_schema_version()`, so a newer client asks for the function itself.
Where `crm.log_activity_by_email()` is absent, `crmLogActivity()` with an
`email` is refused by name, `crm_not_migrated`, and the same call with a
`contact_id` works as it always did; `crm.card_of()` simply has no
interaction fields there. `ekwo module migrate crm` brings them.

## The first pipeline

None is created for a company: a pipeline is a decision of the company, and it
is written by insertion. The one a first user usually starts with is a sales
pipeline of six stages:

```sql
insert into crm.pipelines (company_id, name, slug) values (:company, 'Sales', 'sales') returning id;

insert into crm.stages (company_id, pipeline_id, name, position, outcome) values
  (:company, :pipeline, 'Lead',      1, 'open'),
  (:company, :pipeline, 'Contacted', 2, 'open'),
  (:company, :pipeline, 'Qualified', 3, 'open'),
  (:company, :pipeline, 'Proposal',  4, 'open'),
  (:company, :pipeline, 'Won',       5, 'won'),
  (:company, :pipeline, 'Lost',      6, 'lost');
```

## From an agent

Once `public.modules` carries `crm`, the MCP server offers fifteen tools, each
a function of the schema called through `@ekwo-ai/core` — the very function
`ekwo crm` calls. The list below is the server's own — its `tools/list`, name
and title — and `tests/mcp/crm.test.ts` holds this table to it.

| Tool | Title | Function | Effect |
|---|---|---|---|
| `crm_search` | Search the cards | `crm.search_cards()` | reads |
| `crm_card` | One contact, whole | `crm.card_of()` — with the first and last interaction on the card | reads |
| `crm_contact_vcard` | One contact, as a vCard | `crm.contact_vcard()` | reads |
| `crm_segments` | The segments | `crm.segment_tree()` | reads |
| `crm_board` | A pipeline, stage by stage | `crm.board()` | reads |
| `crm_deal_of_document` | The deal a document belongs to | `crm.deal_of_document()`, as `{ deal, available }` | reads |
| `crm_timeline` | What happened | `crm.timeline()` | reads |
| `crm_upsert_card` | Write a card | `crm.upsert_card()` | adds, idempotent |
| `crm_log_activity` | Log an activity | `crm.log_activity()` by `contact_id`, or `crm.log_activity_by_email()` by `email` (and `name`), answering `resolved` | adds |
| `crm_join_segment` | Put a contact in a segment | `crm.join_segment()` | adds, idempotent |
| `crm_leave_segment` | Take a contact out of a segment | `crm.leave_segment()` | adds |
| `crm_open_deal` | Open a deal | `crm.open_deal()` | adds |
| `crm_move_deal` | Move a deal | `crm.move_deal()` | adds, idempotent |
| `crm_attach_document` | Attach a quote to a deal | `crm.attach_document()` | adds, idempotent |
| `crm_detach_document` | Take a document off its deal | `crm.detach_document()` | destroys the link |

and one prompt, `crm_morning_review`: the cards that went quiet, the deals
past their expected date, and what to suggest — written only once the user
agrees. The statuses, priorities and kinds a tool accepts are named in its
description, and those a command accepts in `ekwo crm`'s help: the core
exports the words of the five enums (`CRM_RELATIONSHIP_STATUSES`,
`CRM_PRIORITIES`, `CRM_SEGMENT_KINDS`, `CRM_STAGE_OUTCOMES`,
`CRM_ACTIVITY_KINDS`). The enum of the schema stays the source, and a test in
`tests/` holds each list equal to it. The `crm_<code>` refusals reach the model word
for word.

> **You:** We won the Northwind subscription.
> **Agent:** *(`crm_card` on Northwind Trading, then `crm_board`)* The deal
> "Annual subscription", 12000.00 at Proposal. Move it to Won? Northwind
> becomes a customer.
> **You:** Yes. *(`crm_move_deal`)* Done — Northwind Trading is a customer;
> the move is on its timeline.

## From the terminal

The same functions, as `ekwo crm`, on the company in use. A contact is named
by its id or by its name; add `--json` to any of them.

```sh
ekwo crm search --status contacted --inactive-since 2026-10-01
ekwo crm card "Ada Lovelace"
ekwo crm vcard "Ada Lovelace" --out ada.vcf      # for an address book; without --out, "Ada Lovelace.vcf"
ekwo crm card set "Ada Lovelace" --status in_discussion --owner sales --tag event --tag fair
ekwo crm segments
ekwo crm board                      # every pipeline; or: ekwo crm board <pipeline-id> --closed
ekwo crm timeline "Ada Lovelace" --kind email_out --kind call
ekwo crm log "Ada Lovelace" --kind note --subject "Asked for a quote" [--deal <deal-id>]
ekwo crm log --email "grace@harbour-logistics.example" --name "Grace Hopper" --kind email_in \
  --source mailbox --source-ref "<message-id@example.org>"   # the contact and its organisation, found or created
ekwo crm join <segment-id> "Ada Lovelace"      # leave: ekwo crm leave <segment-id> <contact>
ekwo crm deal open <pipeline-id> "Northwind Trading" --title "Annual subscription" --amount 12000 [--currency <code>]
ekwo crm deal move <deal-id> <stage-id>
ekwo crm deal attach <deal-id> <document>      # by id, number or reference; detach: ekwo crm deal detach <document>
ekwo crm deal of <document>                    # the deal it belongs to, its stage and its closing
ekwo doc accept <document> --by "The buyer"    # the deal that carries it is won
```

## Decisions worth knowing

**Every reference is composite with `company_id`.** A card, a membership, a
deal and an activity name their contact by `(contact_id, company_id)`; a deal
names its stage by `(stage_id, pipeline_id)` and its pipeline by
`(pipeline_id, company_id)`. A row of one company cannot name a contact, a
segment or a deal of another, whatever id it is handed.

**A deal won makes the party a customer, at the root of its chain.** The
contact of a deal may be a person; the row an invoice is issued to is the
organisation `commercial_entity()` walks up to. `other` becomes `customer`,
and `supplier` becomes `both`. That is a change to the socle's contact, so it
needs `contacts.write` beside `crm.write`, and is refused by name without it.

**An amount is in a currency, always named.** A deal with an amount carries a
currency code of `public.currencies`; `open_deal()` takes the company's own
when none is given. No currency is written in the module.

**A merge folds, it does not collide.** When both contacts of a merge had a
card, or were in the same segment, the two rows become one — the kept
contact's answers first, the absorbed one's filling the gaps, the tags joined,
a `no_outbound` on either side kept — in the transaction `merge_contacts()`
recorded, and in no other.

**A vCard is built here, once.** `crm.contact_vcard()` writes the vCard 3.0
an address book takes, from the socle's contact and the module's card, so a
screen, an agent and a terminal hand over the same file. The name goes whole
into `FN` and into the family-name component of `N`: where a given name ends
is a custom of each language, and the books keep one name. An organisation is
written as one (`ORG`, `X-ABShowAs:COMPANY`); a person carries their
organisation, and its address when they have none of their own. The country
is its ISO code, as the contact holds it.

**An answer moves a deal by the module's rule.** The trigger
that follows the answer to a quote is `security definer`: whoever records
the answer holds `documents.write`, and the module's rule — won, lost,
opened again — applies whatever else they hold, as a deal moving by hand
would, on the timeline with the document named.

**The functions are `security invoker`.** The policies decide every row:
`crm.read` reads, `crm.write` writes, on a company that holds the module. The
functions check the module and the capability first only to answer by name,
`crm_module_not_enabled` and `crm_not_allowed`.

## It writes no `can_disable`

Like `budgets`: turning the module off hides the rows, and turning it back on
gives them back. Nothing is deleted.

## Enabling it

```sh
ekwo module migrate crm
ekwo module enable crm --company "…"
```

Then add `crm` to the project's exposed schemas.
