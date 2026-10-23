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
was missing is the choice of how far an agent goes within them — for the
company, and for one session of one agent.

Coding agents settled the same question: a default mode in the settings, a
flag the person passes to one session to skip the questions
(`--dangerously-skip-permissions`), and a setting that forbids the flag
(`disableBypassPermissionsMode`). The owner chose that model (23/10/2026).

## Decision

**One setting of the company, `companies.agent_posting`**, a column beside
its profile — read by `get_company`, written by `update_company_profile`,
`ekwo company agent-posting` and, in Ekwo Cloud, its Settings page:

- `review`, the default — a document an agent proposes is posted once a
  person approved the draft as it stands; a session may opt into autopilot;
- `autopilot` — agents post directly, within the rights of the person they act
  for;
- `review_only` — review, and no session may opt into autopilot.

No table is added: the company row is where its settings are, and its writes
are already guarded (`company.write`) and audited.

**The session's choice travels with the mark of the agent.** An agent is a
transaction presenting a machine key, or one the MCP server marked — the
setting `ekwo.agent` on a direct connection, the header `X-Ekwo-Agent` through
PostgREST: `agent_call()`. The value of the mark is the session's choice:
`autopilot`, `review`, or anything else for none. `ekwo-mcp --autopilot` or
`--review`, or `EKWO_AGENT_POSTING`, sets it for a local server; a host of the
HTTP transport passes it as `agent` of the connection. `ekwo.agent_session` /
`X-Ekwo-Agent-Session` names the session. `agent_posting_mode(company)` is what
a posting meets: the session's choice where it made one, the setting otherwise
— `review` in a `review_only` company, and `autopilot_forbidden` when the
session asked for autopilot there.

**A machine key's choice is fixed when it is issued** (owner, 23/10/2026), not
made by the program at each call. `api_keys.posting_mode` is `review`, the
default — a session without the flag: the company's setting decides — or
`autopilot`, the flag given for good. A request made with a key ignores the
mark. `create_api_key(…, p_posting_mode)` issues a key in autopilot only to a
person who may change `agent_posting` (`company.write`), never in a
`review_only` company (`autopilot_forbidden`, as for the use of such a key),
and to an agent only from a session that already posts in autopilot there — a
key is not a way for an agent to loosen what a person chose for it. Nothing
writes the column afterwards: a key wanted in another mode is issued again.
One column on the existing table, shown by `list_api_keys` and `ekwo key
list`.

A person signed in — in the web application, on the command line — posts as
before: posting is their approval. The database cannot tell a person from a
program using that person's own session without the mark, and does not pretend
to: a program that wants the protection connects as an agent.

**The database enforces it**, so the command line, the REST API and the MCP
server answer the same way. A trigger on the posting itself
(`documents_posting_mode`, beside `documents_assert_may_post`) holds every path
that sets a document to posted: `autopilot_forbidden` by name, and in review
`approval_required` unless the trail holds an approval of the version being
posted, written since the document last went back to draft.

**An approval is an act on the audit trail, bound to a version of the draft.**
`approve_document(document)` writes `document_approved` on `audit_log`, with
`document_version()` — a digest of the document and its lines as they stand,
every column but `updated_at`. A change to the draft after its approval — a
line, a price, a date — voids it.

**Only a person approves, and only a person loosens the setting.**
`approve_document()` refuses an agent and a key (`approval_by_a_person`) and
asks `documents.post`. `agent_posting` is written with `company.write`; in an
agent's transaction a trigger refuses a change that loosens it
(`agent_posting_by_a_person`) — an agent may make it stricter when the person
asks, and a key holding `company.write` does not switch its own company to
autopilot. Autopilot for one session is the person's choice too: they start
the session with it.

**Every posting by an agent is on the trail**, in every mode:
`document_posted_by_agent`, with the mode it met, the company's setting, the
session, the key (the row's `api_key_id`), and in review the version and the
approval it rests on (`approved_by`, `approved_at`), beside the
`document_posted` the state change already writes.

**It is said where it is decided.** The MCP server says at start-up and in
`status` whether its session runs in review or in autopilot, and in which
companies autopilot is refused; the descriptions of `post_document` and
`cancel_document` say it too.

**A rehearsal is not held to it.** `rehearse_post_document()` posts and rolls
back; showing a person the entry is how they decide to approve it.

## Consequences

- An installation upgraded to this release is in review for every company: an
  agent that posted directly is refused until a person approves, sets the
  company to autopilot, or starts the session with `--autopilot`.
- The approval lives where an application can show it: the rows of
  `audit_log` with `action = 'document_approved'` and the document's id.
- The rule holds every posting of a document, including the ones a function
  makes on the agent's behalf. In review, an agent's `cancel_document` that
  issues a credit note, and a contract schedule with `auto_post` issued by an
  agent, are refused the same way: the credit note or the invoice was never
  approved. The person cancels, or issues, or approves the drafts.
- A key's program chooses autopilot for itself with a header, the way a
  session does; a company that wants none of it is `review_only`.
- What is held today is the posting of a document. A manual entry, a payment
  and a matching are not covered by the mode yet; they remain bounded by the
  capabilities of the key or the person.

## See also

- `supabase/migrations/20261023174709_an_agent_posts_in_the_mode_its_company_chose.sql`
- `tests/agent_posting.test.ts`
- [0017 An append-only audit trail](0017-an-append-only-audit-trail.md)
- [0053 The MCP server acts as the user](0053-the-mcp-server-acts-as-the-user.md)
- [0064 A key writes as the person who issued it](0064-a-key-writes-as-its-issuer.md)
