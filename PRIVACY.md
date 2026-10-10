# What Ekwo knows about you

**Ekwo is one piece of software, and you choose where your books live.** The
same open-source schema runs everywhere; what changes is who operates the
database, and what Ekwo holds follows from that choice.

| | **Your own Supabase project** | **A project Ekwo hosts for you** |
|---|---|---|
| Where your books are | On a project you own and pay for | On a project Ekwo runs for you, in Ekwo's Supabase organisation, in the region of your continent |
| What reaches Ekwo | **Nothing**, unless you link it to an Ekwo Cloud account (§3) | Your books, kept for you, and what §3 lists |
| Is an account needed | **No** — the licence forbids requiring one | Yes: the account is how the project is reached |
| How you leave | Stop using it; there is nothing to close | Move the project to your own Supabase account, or take a `pg_dump` |

**Moving from one to the other is seamless, in both directions.** A project
Ekwo hosts is a plain Supabase project carrying the same schema: you can move
it to your own Supabase account in one step, and Ekwo keeps nothing of a
project it no longer hosts. A company started on Ekwo's trial instance moves to
a project of its own, and the move is checked by comparing both trial balances,
to the cent. A company can also be exported from one installation and imported
into another, wherever each one runs.

*Version 1.2 — 10 October 2026. This page covers the software of this
repository, the site at ekwo.ai and the hosted service at cloud.ekwo.ai,
including the MCP server at mcp.ekwo.ai. Each section says which one it is
about.*

## 1. The software on your own project

**Nothing reaches Ekwo.** `npx ekwo-os init` installs the schema on a Supabase
project you create and pay for. Your ledger, your documents, your VAT returns
and your customers' names are written to your database and stay there. There
is no telemetry, no call home, no licence check and no account required — the
licence (AGPL-3.0) forbids making one a condition of using the software.

One step is yours to take or leave: `ekwo register` announces an installation
to Ekwo. It is offered, never required, and sends the installation's
identifier, the organisation name, its country, its edition and schema
version, and the contact address you type. `ekwo unregister` clears it on your
side; write to the address in §8 to have it deleted on Ekwo's.

The command line and the local MCP server talk to your database directly. What
an AI agent does with them happens between that agent and your database. If the
agent is hosted by somebody else — Anthropic, OpenAI or another — what it sends
to its own provider is governed by that provider's terms.

## 2. The site, ekwo.ai

The pages carry **no analytics script, no tag manager and no cookie**. The site
sets nothing in your browser.

The host that serves the site counts requests from its own logs: pages
viewed, the country a request came from, the address that referred it. It is
aggregated, it is not tied to an identity, and it reaches us as counts rather
than as visits by a person. The host keeps the underlying logs under its own
terms.

**The one place the site asks you for something** is its contact form. It
collects your address and whatever else you choose to fill in — your company,
your country, who you are, your message — to reply to you and for nothing
else, on the basis of Article 6(1)(b) GDPR. It passes through the site host,
acting as our processor, is kept **twenty-four months at most**, and is never
sold. The form says all of this next to itself, in the language of the page.
To see it, correct it or have it erased, ask from your Ekwo Cloud account or
write to the address in §8.

## 3. Ekwo Cloud, the hosted service

This section is about **Ekwo Cloud**: an account, and the instances linked to
it. For somebody running Ekwo OS on their own project without an account, §1
is the whole page.

An account is free. Each thing below exists because it was **asked for**:
linking an instance is a deliberate act, a backup runs on an instance you
linked, and an agent reads your books only after you approved it in your
browser. Nothing here is turned on by default, and what Ekwo Cloud holds is
this and nothing else:

| What | Why |
|---|---|
| Your email address | To sign you in. There is no password: a six-digit code is sent and verified |
| Your answers to three questions — the kind of work you do, your organisation, your countries, what you keep and what you want | To know who Ekwo is for. Left blank, they stay blank |
| The address of your Supabase project and its publishable key | To reach the instance you linked |
| The key your instance issued us, **encrypted** | To take the backup you asked for. It is stored as ciphertext, never in plain text |
| Your backups — **the bytes of your books** | See below |
| **Your books themselves**, when Ekwo hosts your project or your company is on the trial instance | To run the project you asked Ekwo to host. On the trial instance each company is isolated by row level security: no member of one company can see another |
| A **hash** of each agent token, never the token | To recognise an agent you allowed, without being able to replay it |
| The name and redirect address of each agent that asked for access | So you can see and revoke what is connected |
| Your support messages and our answers | To answer you |

### The backups hold your books

The daily backup exports your companies and keeps the bytes. **That is a copy
of your accounting data on our infrastructure**, with its checksum, and it is
the whole point of the feature: it is what makes it restorable into an empty
installation. It is there, and you should decide with that in mind. Unlink an
instance and its backups go with it.

### When Ekwo reads your books

**Ekwo may open your backups, and read the books of an instance you linked,
for two purposes:**

- **In your interest** — to answer a support request, to check that the
  entries recorded by you or by an agent follow the rules of your country, and
  to tell you about an error it notices. This is part of the service you asked
  for (Article 6(1)(b) GDPR).
- **To improve the service** — to find where the software, an importer or a
  country pack gets something wrong, and correct it for everybody. This rests
  on Ekwo's legitimate interest in a service that keeps correct books
  (Article 6(1)(f) GDPR), and you can object to it by writing to the address
  in §8.

Only people working for Ekwo do this, and they are bound to keep what they
read confidential. Your figures are never published, sold or handed to anyone,
and §4 still holds: your books do not train a model. You can ask what was read
and when, as §7 describes.

### What the MCP server sees

`mcp.ekwo.ai` acts **as you**, with the rights row level security gives you on
your own instance, and only after you have approved it in your browser. Its log
records that a call happened and which tool was called. **It does not record the
content of your books** — not the amounts, not the names, not the documents.

## 4. What we do not do

We do not sell anything about you. We do not run advertising, and nothing here
is shared with an advertising network. We do not build a profile of you, and we
do not use your books to train a model — ours or anyone's. There is no
third-party tracker on the site or in the application.

## 5. Who else is involved

Running the service means using three suppliers, and they see what passing
through them requires: **Supabase** (the database of the control plane, in the
European Union, and the projects Ekwo hosts, in the region of the continent you
chose), **Netlify** (serving the site and the application) and the provider
that sends the sign-in codes. Each holds data under its own terms as Ekwo's
processor, and none of them is given your books to do anything with.

## 6. How long it is kept

Your account and its profile stay until you ask for them to be deleted. A
project Ekwo hosts stays until you move it to your own Supabase account or ask
for it to be deleted; a company on the trial instance stays until it moves to a
project of its own or you ask for it to go.
Backups follow the retention shown on the instance and go when it is unlinked.
Agent tokens expire on their own — an hour for access, sixty days for renewal —
and a revoked one stops working at once. Support messages are kept so a
conversation makes sense when you come back to it.

## 7. What you can ask for

If the GDPR applies to you — it does in the European Union — you can ask for a
copy of what we hold, a correction, a deletion, or a restriction on what is
done with it, and you can object. You can ask through the support page inside
Ekwo Cloud, or by writing to the address below. We answer in a month at the
latest, and free of charge.

You can also take everything and go, and that is a property of the software
rather than a favour: your books are an ordinary PostgreSQL database with the
open schema. On your own project they are reachable with any PostgreSQL client
without asking Ekwo; a project Ekwo hosts moves to your own Supabase account in
one step. A backup taken by Ekwo Cloud restores into an installation that has
never seen the company — that restore is exercised against a real project
before every release, and the trial balance compared group by group, to the
cent.

## 8. Writing to us

- **About your data or this page**: `privacy@ekwo.ai`
- **About a security issue**: `security@ekwo.ai` — see `SECURITY.md`
- **About anything else**: the support page in Ekwo Cloud, or `support@ekwo.ai`

The controller of this data is **Ekwo**, a trade name of Karuna Co OÜ,
registered in Estonia under registry code 14510673. Estonia is in the European
Union, so the GDPR applies to this service in full, and you may complain to
your own data protection authority wherever you are.

## 9. When this page changes

The version and the date at the top move, and the change is in the changelog of
this repository like any other. This file lives in the public repository, so
what it said on any day can be read from its history.
