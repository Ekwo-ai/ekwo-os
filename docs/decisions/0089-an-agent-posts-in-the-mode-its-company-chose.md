# An agent posts in the mode its company chose

> Status: accepted

## Context

An agent keeps books through the MCP server, which acts as the person who
connected it ([0053](0053-the-mcp-server-acts-as-the-user.md)), or through a
machine key, which writes as the person who issued it
([0064](0064-a-key-writes-as-its-issuer.md)). Either way it holds
`documents.post` as soon as that person does, and `post_document` took a
document id and nothing else. "Ask the user before posting" was a sentence in
the description of the tool: a model may follow it, and nothing checked that it
did. A posted entry is not edited; it is corrected by a credit note.

A person keeps control of the books by setting the rules and the rights. What
was missing is the choice, company by company, of how far an agent goes within
them.

## Decision

**A company chooses a posting mode for its agents**, `companies.posting_mode`:

- `review`, the default — every document an agent proposes is approved by a
  person before the agent may post it;
- `autopilot` — the agent posts directly, within the rules and the rights it
  holds, and every posting is recorded on the audit trail as an agent's.

**The database enforces it**, so the command line, the REST API and the MCP
server answer the same way. A trigger on the posting itself
(`documents_posting_mode`, beside `documents_assert_may_post`) holds every path
that sets a document to posted.

**An agent is a transaction that says so, or a key.** `agent_call()` is true
when a machine key is presented, and when the MCP server marked the
transaction — the setting `ekwo.agent` on a direct connection, the header
`X-Ekwo-Agent` through PostgREST; the server marks every one it opens. A person
signed in — in the web application, on the command line — posts as before:
posting is their approval. The database cannot tell a person from a program
using that person's own session without the mark, and does not pretend to: a
program that wants the protection connects as an agent.

**An approval is an act on the audit trail, bound to a version of the draft.**
`approve_document(document)` writes `document_approved` on `audit_log`, with
`document_version()` — a digest of the document and its lines as they stand,
every column but `updated_at`. In review, an agent's posting is refused
(`approval_required`) unless the trail holds an approval of the version being
posted, written since the document last went back to draft. A change to the
draft after its approval — a line, a price, a date — voids it. No table is
added: the trail is append-only, written by functions only, and is where an
auditor looks.

**Only a person approves, and only a person chooses the mode.**
`approve_document()` refuses an agent and a key (`approval_by_a_person`) and
asks `documents.post`. `companies.posting_mode` is written by whoever may write
the company, and a trigger refuses the change in an agent's transaction
(`posting_mode_by_a_person`): a key holding `company.write` does not switch its
own company to autopilot.

**Every posting by an agent is on the trail**, in both modes:
`document_posted_by_agent`, with the mode, and in review the version and the
approval it rests on (`approved_by`, `approved_at`), beside the
`document_posted` the state change already writes.

**A rehearsal is not held to it.** `rehearse_post_document()` posts and rolls
back; showing a person the entry is how they decide to approve it.

## Consequences

- An installation upgraded to this release is in review for every company: an
  agent that posted directly is refused until a person approves, or switches
  the company to autopilot (`ekwo company posting-mode autopilot`).
- The approval lives where an application can show it: the rows of
  `audit_log` with `action = 'document_approved'` and the document's id.
- The rule holds every posting of a document, including the ones a function
  makes on the agent's behalf. In review, an agent's `cancel_document` that
  issues a credit note, and a contract schedule with `auto_post` issued by an
  agent, are refused the same way: the credit note or the invoice was never
  approved. The person cancels, or issues, or approves the drafts.
- What is held today is the posting of a document. A manual entry, a payment
  and a matching are not covered by the mode yet; they remain bounded by the
  capabilities of the key or the person.

## See also

- `supabase/migrations/20261023174709_an_agent_posts_in_the_mode_its_company_chose.sql`
- `tests/posting_mode.test.ts`
- [0017 An append-only audit trail](0017-an-append-only-audit-trail.md)
- [0053 The MCP server acts as the user](0053-the-mcp-server-acts-as-the-user.md)
- [0064 A key writes as the person who issued it](0064-a-key-writes-as-its-issuer.md)
