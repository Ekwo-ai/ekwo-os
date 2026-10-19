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
and exposes them as functions an agent or a screen calls.

| Object | What it is |
|---|---|
| `crm.cards` | One card per contact the company follows: status, priority, owner, tags, `no_outbound`, custom fields, and when anything last happened. |
| `crm.segments` | A tree of groups: a taxonomy branch, a target segment, a cohort, a brand. |
| `crm.segment_members` | A contact in a segment. Leaving sets `left_at` and keeps the row; joining again clears it. |
| `crm.pipelines`, `crm.stages` | A sequence of stages, each `open`, `won` or `lost`. |
| `crm.deals` | A piece of business with one contact, moving through one pipeline. Closed with its date and outcome at a `won` or `lost` stage. |
| `crm.activities` | Everything that happened: a note, an e-mail, a call, a meeting, a signal, a deal moving. |

| Function | What it does |
|---|---|
| `crm.upsert_card(company, contact, patch)` | Creates or changes a card. Only the fields the patch names change; an unknown key is refused, `crm_unknown_field`. |
| `crm.log_activity(company, contact, kind, …, source, source_ref)` | Writes an activity and moves the card's `last_activity_at`. The same `(source, source_ref)` twice returns the activity already kept. |
| `crm.join_segment(company, segment, contact, added_by, note)` / `crm.leave_segment(company, segment, contact)` | In and out of a segment, with the membership remembered. |
| `crm.open_deal(company, pipeline, contact, title, …)` | Opens a deal at the first `open` stage of the pipeline. |
| `crm.move_deal(company, deal, stage)` | Moves a deal; a `won` or `lost` stage closes it, and a won deal makes its party a customer. |
| `crm.card_of(company, contact)` | One contact as one JSON object: the contact, its organisation, its card, its segments, its open deals, its 20 latest activities. |
| `crm.search_cards(company, query, status, segment, stage, country, language, owner, no_outbound, active_since, inactive_since, limit)` | The cards, filtered; every filter optional. |
| `crm.segment_tree(company)` | Every segment as a tree — parent, depth, path of slugs — with how many contacts are in it now. |
| `crm.board(company, pipeline, include_closed)` | One pipeline, or all of them: the stages in order, the deals at each, the totals by currency per stage and per pipeline. |
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

Once `public.modules` carries `crm`, the MCP server offers eleven tools, each
the function of the same name above, called through `@ekwo-ai/core`:

| Tool | Function | Writes |
|---|---|---|
| `crm_search` | `crm.search_cards()` | no |
| `crm_card` | `crm.card_of()` | no |
| `crm_segments` | `crm.segment_tree()` — every segment, in tree order, with its members now | no |
| `crm_board` | `crm.board()` — a pipeline, or all of them: stages in order, their deals, totals by currency | no |
| `crm_timeline` | `crm.timeline()` — the activities of a contact or of a deal | no |
| `crm_upsert_card` | `crm.upsert_card()` | yes |
| `crm_log_activity` | `crm.log_activity()` | yes |
| `crm_join_segment` / `crm_leave_segment` | `crm.join_segment()` / `crm.leave_segment()` | yes |
| `crm_open_deal` / `crm_move_deal` | `crm.open_deal()` / `crm.move_deal()` | yes |

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
ekwo crm card set "Ada Lovelace" --status in_discussion --owner sales --tag event --tag fair
ekwo crm segments
ekwo crm board                      # every pipeline; or: ekwo crm board <pipeline-id> --closed
ekwo crm timeline "Ada Lovelace" --kind email_out --kind call
ekwo crm log "Ada Lovelace" --kind note --subject "Asked for a quote" [--deal <deal-id>]
ekwo crm join <segment-id> "Ada Lovelace"      # leave: ekwo crm leave <segment-id> <contact>
ekwo crm deal open <pipeline-id> "Northwind Trading" --title "Annual subscription" --amount 12000 [--currency <code>]
ekwo crm deal move <deal-id> <stage-id>
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
