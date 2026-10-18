# Electronic invoicing — the file of a posted sale, and every time it was sent

One Postgres schema, `einvoicing`. It depends on the socle by foreign key,
reads a posted sale through the socle's document views, and **writes nothing
to the ledger**. This first version is the issuing side: write the electronic
invoice of a posted sale invoice or credit note in the format its country pack
declares, keep the exact file with every rule it breaks, and record each
sending of it with what came back, word for word.

The module knows no country and names no provider. Which format a company
issues in is the `einvoicing.profile` of the pack of its fiscal country, which
the socle already compiles into `country_defaults.einvoice_profile`; which
brick writes that profile is a fact about formats, in `@ekwo-ai/core`. How the
file leaves is a transport somebody plugs in, behind one TypeScript contract;
the one that ships writes it to a folder.

**Ekwo writes a file from what is booked and from its reading of the format.
It does not certify that a file is accepted by any network or authority, and
it is not tax advice.** Read [`DISCLAIMER.md`](../../DISCLAIMER.md), and have a
qualified professional check the set-up of a company and its first invoices.

| Name | What it is |
|---|---|
| module code | `einvoicing` — the key of `public.modules` |
| schema | `einvoicing` |
| capabilities | `einvoicing.read`, `einvoicing.send` — their area is the module code |
| pack section | none of its own: it reads the `einvoicing` section every pack already carries |
| posts to the ledger | no, and a test holds it to that |
| MCP tools | `einvoicing_validate`, `einvoicing_issue`, `einvoicing_status`, `einvoicing_list`, `einvoicing_fiscalise`, `einvoicing_fiscalisation_status` |
| command line | `ekwo einvoice validate`, `issue`, `status`, `list`, `fiscalise`, `fiscalisation` |
| version | 1.1.0 — fiscalisation, the chained record (`20261018015212_einvoicing_fiscalisation.sql`, which reads the socle column of `20261018014537`) |

## What it holds

Three tables, written by three functions and by nothing else — no role holds a
write privilege on them, and a trigger refuses every update and every delete
that would rewrite what was issued or what came back.

| Table | What it is |
|---|---|
| `einvoicing.issues` | One file written for one posted sale: the exact text, its SHA-256, the profile, the brick that wrote it, what the file declares it follows, and every rule of the format it breaks. `sendable` is true when that list is empty, and only then. A document whose books were completed is issued again: a second row, the first kept. |
| `einvoicing.transmissions` | One sending of one issue: the channel in two words (`self`, `service`), the service by name as free text, the reference it gave, and a state that only moves forward. |
| `einvoicing.transmission_events` | Every state a sending reached, with what the service said at that moment, verbatim, and its structured answer as it came. Appended to, never rewritten. |

## Fiscalisation: the chained record of every invoice

Many countries ask the invoicing software itself to leave, for every invoice
it issues, a record that cannot be changed, chained to the one before by a
hash, often shown on the invoice as a QR code and a sentence, and sent to the
tax authority at once or later. That is a **capability of this module**, not
a module of its own: a fiscal record is a second artefact of the same posted
sale, written by a brick, kept beside the electronic invoice, and sent to
another counter.

Whether a company has such a regime, and its rules, is the
`einvoicing.fiscalisation` block of its country pack (`packs/schema/pack.1.json`,
`$defs/fiscalisation`), compiled by the socle into
`country_defaults.einvoice_fiscalisation`: the format of the record and so
its brick, the digest and the fields it covers, the QR code, the sentence,
the modes of sending and their limits, the events. The module names no
country; the format is looked up in `FISCALISATION_FORMATS`
(`packages/core/src/einvoicing/fiscalisation.ts`), and one the registry does
not hold is refused by name, `format_without_brick`.

| Table | What it is |
|---|---|
| `einvoicing.fiscal_chain` | One record of one posted sale, numbered from 1 within a company and an invoicing system (`system_id`): the fields the hash covers, the exact text hashed, the hash, the hash of the record before (none for the first, which says it is the first), when it was generated with its offset, its mode of sending, the URL its QR code encodes, and its file — an issue of artefact `fiscal_record`. |
| `einvoicing.fiscal_events` | What the system records beside the invoices — a summary every so many hours where the pack asks for one, a start, a stop, a break found in the chain — numbered per company and system. |

Both are written by functions alone and refuse every update and delete
(`fiscal_record_kept`). `einvoicing.issues` and `einvoicing.transmissions`
gain an `artefact` (`einvoice`, `fiscal_record`): the rule "one sending alive
per document" holds per artefact, and only an electronic invoice that has
left writes `documents.peppol_status`.

```sql
-- One more link, and its file, in one transaction.
select einvoicing.append_fiscal_record(document, system, 'alta', format, mode,
         issuer_tax_id, series, number, issued_on, record, hash_input, hash,
         previous_hash, generated_at, verification_url,
         brick, specification, filename, media_type, content, checksum, violations);
-- The first break of a chain, walked forward then backward; no row when intact.
select * from einvoicing.verify_fiscal_chain(company, system);
select einvoicing.log_fiscal_event(company, system, 'summary', '{"records": 12}');
```

What the database checks without trusting the caller: the pack declares a
regime in that format and mode (`no_fiscalisation_regime`,
`fiscal_format_mismatch`, `fiscal_mode_not_allowed`); the record breaks no
rule (`fiscal_record_not_chainable`); its hash is the digest the pack names
of the text it came with (`fiscal_hash_mismatch`), and it holds every field
the pack says the hash covers (`fiscal_record_fields_missing`); the tail of
the chain is intact (`fiscal_chain_broken`) and is the record named as
previous — none for the first (`fiscal_chain_not_first`, `fiscal_chain_link`);
an invoice is recorded once and cancelled once (`fiscal_record_exists`,
`fiscal_nothing_to_cancel`).

**Nothing is fiscalised by a trigger.** A posted sale of a company whose pack
declares a regime and that has no record is named by the status, and the
record is made by an explicit gesture:

```sh
ekwo einvoice fiscalise <document> --system system.json   # the record, chained, and its file
ekwo einvoice fiscalise <document> --system system.json --dry-run
ekwo einvoice fiscalisation                                # chain verified, pending, missing, events
```

`system.json` describes the invoicing system as the regime asks — its name,
identifier, version, installation, producer and producer's tax number — and
is the operator's to write: none of it is invented. `EKWO_FISCAL_SYSTEM`
holds the same JSON for the MCP server, whose tools are
`einvoicing_fiscalise` and `einvoicing_fiscalisation_status`. Sending the
records is a transport, as for the electronic invoice: the record's issue is
sent with the same functions (`record_transmission`), and none ships for a
tax authority — the host brings it.

**The QR code on the invoice.** Once a sale has its record, its PDF —
`ekwo doc pdf`, `render_invoice_pdf`, `renderDocumentPdf()` — carries the QR
code of the regime: the verification URL of its last `alta` record, at the
smallest size and with the quiet zone the pack gives, its label above and,
under it, the sentence the pack names for the record's mode, drawn by
[`@ekwo-ai/invoice-pdf`](../../packages/formats/invoice-pdf/README.md#a-fiscal-qr-code).
Before the record there is no URL, and the PDF says so in `fiscal_qr`
rather than printing a code of its own making.

## The states of a sending

```
prepared ──▶ submitted ──▶ accepted_by_access_point ──▶ delivered
    │             │                   │
    ▼             └────────┬──────────┘
  failed                   ▼
                        rejected
```

**A 2xx is not a delivery.** `submitted` says a transport took the file and
gave it a reference, nothing more. `accepted_by_access_point` is the service
that carries it having validated it; `delivered` is the receiving side having
it. `failed` is a file that never left — the transport could not hand it over
— and `rejected` is a refusal somebody on the way wrote down, kept in their
words. The last three close the sending. A rejected or failed document is not
a dead end: fix the books, issue again, and send — a second row, the first one
kept with its refusal. The model is the socle's `tax_filing_deposits`.

The database refuses, by name:

| Refusal | When |
|---|---|
| `document_not_a_sale`, `document_not_posted` | Only a posted sale invoice or sale credit note is issued. |
| `no_einvoicing_profile` | The company's pack declares no profile. |
| `einvoice_profile_mismatch` | A file written in another profile than the pack's. |
| `einvoice_checksum_mismatch` | A checksum that is not the SHA-256 of the text. |
| `einvoice_not_sendable` | A file that breaks a rule. The rules are repeated in the message, verbatim. |
| `einvoice_superseded` | An older issue of a document issued again since. |
| `einvoice_already_sent` | A document with a sending on its way, or delivered. |
| `transmission_state_backwards`, `transmission_closed`, `transmission_already_left` | A state that would move backwards, a closed sending that would move at all, a sending that has left and would have "failed". |
| `transmission_reference_differs`, `transmission_reference_missing` | A reference changed once given; a state past `submitted` without one. |

And the TypeScript side, before anything is recorded: `format_without_brick`
when the pack declares a profile no brick of this release writes. Nothing is
then written in the nearest format that exists — a file in another profile is
a file the network refuses after it has left.

## The functions

```sql
-- Keep the file a brick wrote for a posted sale. The same file twice is one issue.
select einvoicing.record_issue(document, profile, brick, specification,
                               filename, media_type, content, checksum, violations);

-- A sending begins, as prepared: the channel, and the service by name where one is used.
select einvoicing.record_transmission(issue, 'service', 'The access point');

-- What came back: a state, a reference, the service's words, its structured answer.
select einvoicing.record_transmission_outcome(transmission, 'rejected', null,
                                              'the words of the refusal', '{"code": "…"}');
```

Each one needs `einvoicing.send` (and `record_issue` also `documents.read`) on
a company that holds the module. Writing the file is not in SQL: it is the
bricks of `packages/formats/`, run by `@ekwo-ai/core` —
`validateEinvoice()`, `issueEinvoice()`, `einvoiceStatus()`,
`listEinvoiceTransmissions()` — which the MCP server and the command line both
call.

## Formats

| Profile, as a pack declares it | Brick | Syntax |
|---|---|---|
| `peppol-bis-3` | `@ekwo-ai/peppol-ubl` | UBL 2.1, Peppol BIS Billing 3.0 |
| `factur-x-en16931` | `@ekwo-ai/factur-x` | UN/CEFACT CII D16B, EN 16931 profile |

Every other profile a pack declares is refused by name until its brick exists.
Adding one is an entry in `EINVOICE_FORMATS` (`packages/core/src/einvoicing/formats.ts`)
and a brick, nothing else; no country is named on the way.

The Factur-X brick computes its own totals from numbers and fills in what it
is not given. The adapter holds it to the books: everything it would default —
a delivery date, an exemption sentence, a payment means — is given from the
books or reported as a broken rule, and every total and every VAT group it
would write is compared with what was posted; a difference of a cent is a
broken rule. The file kept is the CII XML. The PDF/A-3 that carries it is
rendered on demand, from the same books, by `ekwo doc pdf --factur-x` and
`render_invoice_pdf`, and is not kept here.

## Transports

A transport is four questions, in `packages/core/src/einvoicing/transport.ts`:

```ts
interface EinvoiceTransport {
  readonly channel: 'self' | 'service';
  readonly service: string | null;              // free text; required for `service`
  send(file, metadata): Promise<Submission>;    // a reference — not a delivery
  status(reference): Promise<TransmissionOutcome>;
  receive(): Promise<ReceivedFile[]>;           // the seam for the receiving side
  lookup(address): Promise<Reachability>;       // null where it cannot tell
}
```

**No credential crosses it**, and none is ever written to the database: a
transport is built by whoever operates it, with what it needs, outside the
books. The books record the channel, the service's name and what it answered.
A transport that throws `TransportError` — or anything else — records a
`failed` sending with the message of the error, verbatim.

**The one that ships is a folder**, `directoryTransport(root)`:

```
<root>/outbox/<file>                         written once, never overwritten
<root>/outbox/<file>.accepted_by_access_point
<root>/outbox/<file>.delivered               a receipt: its text is the message,
<root>/outbox/<file>.rejected                kept word for word
<root>/inbox/<file>                          what arrived, read by receive()
```

No network and no account. Whatever carries the files further — a script that
uploads them to a portal, the client of an access point, a person — reads the
folder and answers by leaving a receipt beside the file; `status` reads the
furthest one. The file name carries twelve characters of the checksum and
eight of the sending's identifier, so two issues of one document never meet,
and a file sent again after a refusal is a new file beside the refused one —
the old receipt is never read as the answer to the new sending.

**Plugging another one** is writing those four functions in a package of its
own, or in the service that operates it, and handing the object to
`issueEinvoice()` and `einvoiceStatus()`. The MCP server and the command line
use the folder (`EKWO_EINVOICE_DIRECTORY`, `--to <directory>`); a network
transport is given to them the same way.

## Using it

```sh
ekwo module enable einvoicing --company "…"

ekwo einvoice validate <document>              # the file and the rules it breaks; records nothing
ekwo einvoice issue <document>                 # keep it
ekwo einvoice issue <document> --send --to ./einvoices
ekwo einvoice status <document> --refresh --to ./einvoices
ekwo einvoice list
```

`validate` and `issue` end on exit code 1 when the file breaks a rule, like a
check that found something; a refusal of the database is 3, with its name.
Through MCP, the same four verbs are `einvoicing_validate`,
`einvoicing_issue`, `einvoicing_status` and `einvoicing_list`.

## `documents.peppol_status` and `peppol_message_id`

The socle carries these two columns on every document, on the closed list of
what may still move after posting, and `unpost_document()` reads them to refuse
taking back to draft a document that has left. Nothing filled them until now.
The module's tables are the record; once a sending has left — `submitted` or
further, with a reference — `record_transmission_outcome()` writes its state
and reference there too, so the socle knows the number is in somebody else's
hands. Nothing else of a posted document is touched. The names say Peppol and a
profile that travels elsewhere writes them too: renaming them is the socle's
to do.

## What it does not do yet

- **Sending fiscal records to an authority.** The chain is kept and the file
  of each record is an issue ready to send; the transport of the authority
  (its envelope, certificate and flow control) is the host's.
- **Unposting a fiscalised document.** `unpost_document()` reads the socle's
  two columns, which a fiscal record does not write; a record is cancelled by
  an `anulacion`, and the document by a credit note.

- **Receiving.** An incoming file turned into a purchase draft needs the UBL
  and CII readers of the format bricks, which are being written. The seam is
  `receive()` of the transport contract; the folder transport already reads
  `<root>/inbox/`.
- **Network transports.** No Peppol access point, no national platform. They
  come beside this module, behind the same contract, with their credentials
  kept where they run.
- **The profiles without a brick**: every PINT, XRechnung, the national
  formats of platforms. Refused by name until a brick writes them.
- **Keeping a PDF/A-3** for Factur-X. The visual invoice is rendered by
  [`@ekwo-ai/invoice-pdf`](../../packages/formats/invoice-pdf/README.md), and
  `ekwo doc pdf --factur-x` (`render_invoice_pdf` with `factur_x`) embeds the
  CII in it; what this module keeps is still the XML alone, not the PDF.
- **Lookup** of a recipient on a network: the folder cannot tell, and says so.

## What an accountant should check

- The company's identity in the books — its legal name, VAT or registration
  number and electronic address — and each customer's electronic address.
  Most broken rules are a field the books do not hold, and are fixed there,
  never in the file.
- That the profile of the pack is the one the company is held to. The pack's
  status says how far it has been reviewed; no status means certified.
- The first files, opened and read, before anything is sent through a
  network.
