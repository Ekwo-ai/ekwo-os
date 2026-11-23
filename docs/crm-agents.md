# Connecting a team of agents to the CRM through MCP

This page is for whoever sets up several AI agents to work the relationships of
one company — one reads the mailbox, one prepares the morning review, one
follows the pipeline — and for the agents themselves. It says how each agent
reaches the `crm` module through the MCP server, who it acts as, which tools
it uses, and what keeps several agents from writing over each other.

The module is described in [`modules/crm/README.md`](../modules/crm/README.md):
its objects, its functions and the list of its tools. The first session of an
agent with the books is [`agents.md`](agents.md); the server itself,
[`packages/mcp/README.md`](../packages/mcp/README.md).

## What the team shares, and what it does not

Every agent works on **the same rows**: the company's contacts in the books,
the module's cards, segments, deals and activities. There is no copy per
agent, no queue between them and no list of agents in the database. What
keeps the work coherent is in the schema:

- **One contact per address.** An activity named by an e-mail finds the contact
  already on file at that address before it creates one, and the organisation
  of its domain before it creates one (`crm_log_activity` with `email`). Two
  agents reading the same thread find the same contact.
- **One activity per message.** An activity read from elsewhere carries its
  `source` and `source_ref` — the mailbox and the message identifier. The same
  pair twice writes nothing and answers the activity already kept, whichever
  agent logs it first.
- **One card per contact.** `crm_upsert_card` changes only the fields its patch
  names; an agent that sets a priority does not erase the owner another set.
- **Dates nobody types.** A card's first and last interaction are computed from
  the activities whenever they are read (`crm_card`), so no agent keeps them
  up to date and none can get them wrong.
- **One way to join two contacts.** Two rows that turn out to be one party are
  joined by the socle's merge — proposed by `suggest_duplicate_contacts`,
  confirmed by a person, carried out by `merge_contacts`. No agent merges by
  logging or by creating; the team proposes, the user decides.

## Who each agent acts as

The MCP server acts as **a person**, never with the `service_role` key — it
refuses to start with one. Give each agent its own identity, so that the audit
trail says which one did what and each holds only what its work needs:

1. **Invite one member per agent** into the company (`invite_member()`, or the
   invitation screen of the application), with the narrowest role that fits —
   `viewer` for an agent that only reads, `accountant` for one that writes —
   and the capabilities it does not need revoked on its membership.
2. **Start one MCP server per agent**, signed in as that member. Locally, over
   stdio:

   ```json
   {
     "mcpServers": {
       "ekwo-crm-mailbox": {
         "command": "npx",
         "args": ["-y", "@ekwo-ai/mcp@latest"],
         "env": {
           "SUPABASE_URL": "https://YOURREF.supabase.co",
           "SUPABASE_ANON_KEY": "the anon (publishable) key",
           "EKWO_EMAIL": "the address of the mailbox agent's member",
           "EKWO_PASSWORD": "its password"
         }
       }
     }
   }
   ```

   With an Ekwo Cloud account, each agent adds the hosted connector
   `https://mcp.ekwo.ai/mcp` instead, approved in the browser by the person
   whose access it uses; leaving *write* unticked on the approval screen gives
   a reader.
3. **Name the agent in what it writes.** `actor` on an activity and `owner` on
   a card are handles, free text: `mailbox-agent`, `review-agent`,
   `sales-desk`. The module keeps no list of them; they are how a person
   reading a timeline knows who did what.

What each kind of agent needs:

| Agent | Reads | Writes | Capabilities |
|---|---|---|---|
| Mailbox reader | `crm_search`, `crm_card` | `crm_log_activity` with `email`, `source`, `source_ref` | `crm.read`, `crm.write`, `contacts.write` (to create the contacts of new addresses) |
| Morning reviewer | `crm_search`, `crm_board`, `crm_timeline`, the prompt `crm_morning_review` | nothing until the user agrees, then `crm_upsert_card`, `crm_log_activity` | `crm.read`; `crm.write` once it may write |
| Pipeline follower | `crm_board`, `crm_card`, `crm_deal_of_document` | `crm_open_deal`, `crm_move_deal`, `crm_attach_document` | `crm.read`, `crm.write`; `contacts.write` to win a deal, which makes its party a customer |
| Segment keeper | `crm_segments`, `crm_search` | `crm_join_segment`, `crm_leave_segment`, `crm_upsert_card` | `crm.read`, `crm.write` |

A refusal names what is missing — `crm_not_allowed: … needs contacts.write`,
`crm_module_not_enabled` — and an agent hands that sentence to the user
rather than working round it.

## The mailbox agent, step by step

The agent that reads a mailbox is the one that fills the CRM. For each
message:

1. **Log it by address.** `crm_log_activity` with `email` — the counterpart's
   address, or `Name <address>` as the header carries it — `name` when the
   header gives one, `kind` `email_in` or `email_out`, `occurred_at` the date
   of the message, `subject`, `source` the mailbox and `source_ref` the
   message identifier. The answer's `resolved` says what happened: the
   contact and its organisation, whether either was created, whether the
   domain was generic, whether the message was already kept (`replayed`).
2. **Leave generic domains alone.** An address at a personal mailbox, a tool or
   a provider gives a contact and no organisation. If the user says which
   organisation the person belongs to, that is a change to the contact, made
   with the user, not a guess.
3. **Report what it created.** New contacts and organisations are named after
   the address and the domain; the user renames them, or merges them with a
   contact already on file that the agent could not recognise.
4. **Run again without fear.** Read the mailbox from the start, or the last
   week again: every message already kept answers `replayed: true`, and no
   contact, organisation or card is created twice.

A domain that names nobody and is not on the module's list — a regional
provider, the company's coworking space — is added once, as data: by the
installation for every company, or by the company for itself
(`crm.generic_email_domains`, described in the module's README). An agent
proposes it; a person adds it.

## A session of the team

> **Mailbox agent:** *(`crm_log_activity`, email `Grace Hopper <grace@harbour-logistics.example>`, source `mailbox`, source_ref the message-id)*
> A new contact, Grace Hopper, and a new organisation, harbour-logistics.example.
>
> **Morning reviewer:** *(`crm_morning_review`, then `crm_card` on harbour-logistics.example)*
> One new organisation since yesterday: harbour-logistics.example, first
> interaction this morning, one e-mail in, asking for prices. Rename it, give it
> an owner, and open a deal in Sales?
>
> **You:** Call it Harbour Logistics, owner sales-desk, and open the deal.
>
> **Pipeline follower:** *(`crm_upsert_card`, then `crm_open_deal`)* Done: Harbour
> Logistics is followed by sales-desk, and "First order" is open at Lead.

The renaming of the organisation is a change to the contact in the books,
made by the user in the application, or by a tool of the books they ask an
agent to use.

## What no agent does

- **Invent an exchange.** An activity is something that happened, logged from
  the message, the call or what the user said.
- **Merge, delete or create a second contact to avoid one.** Duplicates go to
  the user through `suggest_duplicate_contacts`; the merge is theirs.
- **Approach a contact marked `no_outbound`.** An answer to them is still an
  answer; a first message is not.
- **Change a status, an owner or `no_outbound` the user did not mention.**
  Read `crm_card` first, propose, then write.
- **Hold the `service_role` key.** Each agent is a member, with its own
  identity and its own capabilities.
