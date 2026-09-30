# What Ekwo knows about you

**There are two Ekwos, and they are not alike.** Everything on this page
follows from telling them apart, so it is worth doing first.

| | **Ekwo OS** — the software | **Ekwo Cloud** — the hosted service |
|---|---|---|
| Where your books are | On **your** database, on a project you own and pay for | Still on your database. Ekwo Cloud links to it |
| What reaches us | **Nothing.** No telemetry, no call home, no licence check | Only what you asked it to hold, listed in §3 |
| Is an account needed | **No**, and the licence forbids requiring one | Yes — the account *is* the service |
| Does it store your data | No. It could not: we have no address and no key | **Yes, when you ask it to** — and a backup is a copy of your books |
| How it stops | Stop using it. There is nothing to close | Unlink the instance; its backups go with it, and updates stop with it |

Using Ekwo OS and never creating an account is a complete way to use Ekwo, not
a degraded one. Everything in §3 exists because somebody asked for it, on an
instance they linked on purpose. Nothing happens to an instance you have not
linked, and the screen that links one says what the service will do on it.

*Version 1.1 — <date>. This page covers the software of this repository, the
site at ekwo.ai and the hosted service at cloud.ekwo.ai, including the MCP
server at mcp.ekwo.ai. Each section says which one it is about. What changed
since version 1.0 is listed in §9.*

## 1. The software you run yourself

**Nothing reaches us.** `npx ekwo-os init` installs a schema on *your*
PostgreSQL database, on a Supabase project you create and pay for. Your ledger,
your documents, your VAT returns and your customers' names are written to your
database and stay there. There is no telemetry, no call home, no licence check
and no account required — the licence (AGPL-3.0) forbids making one a condition
of using the software, and we could not read your books if we wanted to.

Keeping it up to date is yours too: `npx ekwo migrate` brings an installation
to the current release, and nothing updates it unless you run it or link it to
Ekwo Cloud.

The command line and the local MCP server talk to your database directly. What
an AI agent does with them happens between that agent and your database. If the
agent is hosted by somebody else — Anthropic, OpenAI or another — what it sends
to its own provider is governed by that provider's terms, not by ours.

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

This section is about **Ekwo Cloud only**. None of it applies to somebody
running Ekwo OS on their own database without an account — for them, §1 is the
whole page.

An account is optional, free, and never required to use the software. Each
thing below exists because it was **asked for**: linking an instance is a
deliberate act, and an agent reads your books only after you approved it in
your browser. Nothing here touches an instance you have not linked. Linking one
shows you, on that screen, the two things the service does on it — **keep it
up to date** and **keep a monthly copy** — and each can be turned off there or
later in the settings of the instance. What the service holds is this and
nothing else:

| What | Why |
|---|---|
| Your email address | To sign you in. There is no password: a six-digit code is sent and verified |
| Your answers to three questions — the kind of work you do, your organisation, your countries, what you keep and what you want | To know who Ekwo is for. Left blank, they stay blank |
| The address of your Supabase project and its publishable key | To reach the instance you linked |
| The authorisation your Supabase organisation gave us, and the token that renews it, **encrypted** | To install the schema on the project you chose, and to keep that project up to date. It is used on that project and no other |
| The key your instance issued us, **encrypted** | To take the copies of your books. It is stored as ciphertext, never in plain text |
| The version of your instance and the outcome of each update | To know which update it needs, and whether it took |
| Your choices on the screen that linked the instance, and when you made them | To show you what is on, and to stop what you turned off |
| The copies of your books — **the bytes of your books** | See below |
| A **hash** of each agent token, never the token | To recognise an agent you allowed, without being able to replay it |
| The name and redirect address of each agent that asked for access | So you can see and revoke what is connected |
| Your support messages and our answers | To answer you |

### Updates

When a new version of Ekwo ships, Ekwo Cloud applies it to each linked
instance that has updates on. It works on the project you linked and on no
other, and it does the same steps every time:

1. It takes a copy of your books first (see below).
2. It runs the update inside a transaction and rolls it back, to see that it
   applies.
3. It runs it again, checks the trial balance to the cent inside the same
   transaction, and commits only if nothing moved.
4. It records the version and the outcome, which you see on the instance.

An update changes the structure of the database, never an amount in your
books. It cannot be undone by a script: the way back is the copy taken before
it. You can put updates on hold for an instance at any time; `npx ekwo migrate`
remains yours to run whenever you choose. An instance you have not linked
receives nothing.

### The copies hold your books

Ekwo Cloud keeps copies of the companies of each linked instance: **a monthly
copy, twelve kept, on the free plan**, and a daily copy, thirty kept, as well
on the paid plan. A copy is also taken before each update. **That is a copy of
your accounting data on our infrastructure**, with its checksum, and it is the
whole point of the feature: it is what makes it restorable into an empty
installation. We do not read it, and no part of the service opens it to look
inside — but it is there, and you should decide with that in mind. Unlink an
instance and its copies go with it.

For what those copies contain, Ekwo acts on your behalf and on your
instructions, as a processor within the meaning of Article 28 GDPR: the names,
addresses and bank details in your books are those of your customers,
suppliers and staff, and you remain responsible for them. The terms that govern
this are in `DPA.md`, and they are part of what you accept when you link an
instance.

### What the MCP server sees

`mcp.ekwo.ai` acts **as you**, with the rights row level security gives you on
your own instance, and only after you have approved it in your browser. Its log
records that a call happened and which tool was called. **It does not record the
content of your books** — not the amounts, not the names, not the documents.

## 4. What we do not do

We do not sell anything about you. We do not run advertising, and nothing here
is shared with an advertising network. We do not build a profile of you, and we
do not use your books to train a model — ours or anyone's. We do not use the
copies of your books for any purpose of our own: not for statistics, not for
product research, not in anonymised form. There is no third-party tracker on
the site or in the application.

## 5. Who else is involved

Running the service means using three suppliers, and they see what passing
through them requires: **Supabase** (the database of the control plane and the
storage where the copies of your books are kept, in the European Union),
**Netlify** (serving the site and the application, and running the functions
that take copies and apply updates — your books pass through those functions
in transit and are not stored there) and **Mailjet**, which sends the sign-in
codes and receives your email address only. Each holds data under its own terms
as our processor, and none of them is given your books to do anything with.
The list, with where each one keeps data, is in Annex 3 of `DPA.md`.

## 6. How long it is kept

Your account and its profile stay until you ask for them to be deleted.
Copies of your books: twelve monthly copies, and thirty daily copies as well on
the paid plan, each replaced as a newer one is taken; all of them go when the
instance is unlinked. Keeping your books for the years the law of your country
requires is done on your database, not in these copies. The authorisation of
your Supabase organisation is deleted when you unlink the last instance it
served, and you can also withdraw it from Supabase directly. Agent tokens
expire on their own — an hour for access, sixty days for renewal — and a
revoked one stops working at once. Support messages are kept so a conversation
makes sense when you come back to it.

## 7. What you can ask for

If the GDPR applies to you — it does in the European Union — you can ask for a
copy of what we hold, a correction, a deletion, or a restriction on what is
done with it, and you can object. You can ask through the support page inside
Ekwo Cloud, or by writing to the address below. We answer in a month at the
latest, and free of charge.

You can also take everything and go, and that is a property of the software
rather than a favour: the database is **yours**, on a project you own, so your
ledger and your documents are reachable with any PostgreSQL client without
asking us. A copy taken by Ekwo Cloud restores into an installation that has
never seen the company — that restore is exercised against a real project
before every release, and the trial balance compared group by group, to the
cent.

## 8. Writing to us

- **About your data or this page**: `privacy@ekwo.ai`
- **About a security issue**: `security@ekwo.ai` — see `SECURITY.md`
- **About anything else**: the support page in Ekwo Cloud, or `support@ekwo.ai`

The controller of the data on this page — your account, your answers, what
the service records about your instance — is **Ekwo (Karuna Co OÜ)**, a private
limited company registered in Estonia under registry code 14510673 — the same
entity named in `README.md`, `CLA.md` and the manifesto, and the same one the
site already gives as controller beside its contact form. For the content of
your books, you are the controller and Ekwo is your processor, under `DPA.md`.
Estonia is in the European Union, so the GDPR applies to this service in full,
and you may complain to your own data protection authority wherever you are.

## 9. When this page changes

The version and the date at the top move, and the change is in the changelog of
this repository like any other. This file lives in the public repository, so
what it said on any day can be read from its history.

**Version 1.1** added: the updates Ekwo Cloud applies to a linked instance and
how to put them on hold; the monthly copy on the free plan and the copy taken
before each update; the authorisation of your Supabase organisation, which the
service held since version 1.0 and this page did not list; the version and
update outcome of each instance; the choices made on the linking screen; that
Ekwo is your processor for the content of your books, under `DPA.md`; and that
the copies are never used for a purpose of Ekwo's own.
