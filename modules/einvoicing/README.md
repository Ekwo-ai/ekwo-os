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
| MCP tools | `einvoicing_validate`, `einvoicing_issue`, `einvoicing_status`, `einvoicing_list` |
| command line | `ekwo einvoice validate`, `issue`, `status`, `list` |

## What it holds

Three tables, written by three functions and by nothing else — no role holds a
write privilege on them, and a trigger refuses every update and every delete
that would rewrite what was issued or what came back.

| Table | What it is |
|---|---|
| `einvoicing.issues` | One file written for one posted sale: the exact text, its SHA-256, the profile, the brick that wrote it, what the file declares it follows, and every rule of the format it breaks. `sendable` is true when that list is empty, and only then. A document whose books were completed is issued again: a second row, the first kept. |
| `einvoicing.transmissions` | One sending of one issue: the channel in two words (`self`, `service`), the service by name as free text, the reference it gave, and a state that only moves forward. |
| `einvoicing.transmission_events` | Every state a sending reached, with what the service said at that moment, verbatim, and its structured answer as it came. Appended to, never rewritten. |

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
broken rule. The file kept is the CII XML. Embedding it in a PDF/A-3 needs the
visual invoice, which the books do not render.

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

- **Receiving.** An incoming file turned into a purchase draft needs the UBL
  and CII readers of the format bricks, which are being written. The seam is
  `receive()` of the transport contract; the folder transport already reads
  `<root>/inbox/`.
- **Network transports.** No Peppol access point, no national platform. They
  come beside this module, behind the same contract, with their credentials
  kept where they run.
- **The profiles without a brick**: every PINT, XRechnung, the national
  formats of platforms. Refused by name until a brick writes them.
- **PDF/A-3** for Factur-X, and any visual rendering of an invoice.
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
