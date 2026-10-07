# Filing proofs

A company files a declaration, deposits its annual accounts, issues an invoice.
Months or years later somebody asks two questions: *is this the file that
went?* and *did it exist on that day?* Ekwo already keeps what was sent and
what came back ([`filing.md`](filing.md)), but it keeps them in the company's
own database, which the company can rewrite. A record that only its author
holds proves nothing to anybody else.

A **filing proof** answers both questions without asking anyone to trust the
company or the installation. The sha256 of the exact bytes of the file is
committed to a public ledger that nobody controls, and the proof of that
commitment is kept. Anybody who holds the file recomputes the hash, reads the
proof, and checks it against the ledger with software of their own choosing.

The company is the one that publishes. It decides which filing to prove and
when, and it decides whom to show the file to — an investor, a bank, a
customer, the public, or nobody. The world sees what the company chooses to
hand over, and the proof makes that choice verifiable. Only the company stamps
its own filings.

The feature is the same for every company in every country. It reads no pack
and has no national variant: a hash is a hash, and a public ledger is public
everywhere. What is proved can be any declaration, the annual accounts of any
financial year, or any document.

## What leaves, and what does not

Only the 32 bytes of the sha256 leave the machine that proves a file, and a
random nonce is appended to them before they do. The calendar sees a hash of
a hash. It learns nothing of the file, of the company, or of which file of
which company it is. The file itself, its figures and the name of the company
stay where they were.

## The method: OpenTimestamps

[OpenTimestamps](https://opentimestamps.org) is an open protocol for dating a
hash against Bitcoin. Public calendars, run by several independent operators,
collect hashes, combine them in a merkle tree, and commit the root of that
tree to a Bitcoin transaction about once per block interval. The proof is a
small file (`.ots`) that holds the path from the hash to the merkle root of a
block.

- **Cost.** None. The calendars are free and need no account; one Bitcoin
  transaction serves every hash submitted in that round.
- **Delay.** A proof is *pending* as soon as a calendar answers, and
  *complete* once the round is in a block: usually a few hours.
- **Verification.** A complete proof needs no calendar and no Ekwo
  installation, only a Bitcoin block header, which any node or block explorer
  provides. The reference client (`ots verify`) and any other implementation
  of the format read the same file.
- **What it proves.** That the file existed no later than the time of the
  block. Not who made it, and not that its content is true.

Each hash is submitted to the four public calendars the reference client uses,
and the proof keeps every answer, so a proof does not depend on any one
operator staying online.

## In the database

| Object | What it is |
|---|---|
| `filing_proofs` | One row per hash and per method. The subject (a declaration, a financial year for its annual accounts, or a document), the stored attachment whose bytes were hashed where it is kept, `sha256`, `values_sha256`, the method, the status (`pending`, `complete`), the proof bytes, the calendars, and the anchor: chain, block height, block time, block hash |
| `record_filing_proof(subject_kind, subject_id, sha256, method, proof_base64, calendars, attachment_id, values_sha256)` | Records a proof a client just obtained. The company is the subject's. The same bytes recorded twice by the same method return the existing row |
| `upgrade_filing_proof(proof_id, proof_base64, anchor_chain, anchor_height, anchor_time, anchor_reference)` | Replaces the bytes of a pending proof with the longer proof a calendar returned. With an anchor, the proof becomes complete and is frozen |
| `tax_filing_values_sha256(filing_id)` | The figures of a declaration in canonical form: one `canonical_json()` line for `{report_code, period_start, period_end}`, then one per box `{box, kind, amount}` in box then kind order, hashed with sha256. Recorded with every proof of a declaration, so the figures can be matched without the file |
| `filing_proof(sha256)` | The public door, callable without signing in |

Recording and upgrading need the capability `filings.prove`, held by the
`owner` and `accountant` presets. Reading the proofs of a company needs
`filings.read`. Nobody writes the table directly: the two functions are the
only way in. A complete proof does not move.

A company that leaves an installation takes its proofs with it
([`company-archive.md`](company-archive.md)). A proof is checked against the
public ledger and not against the installation, so it means the same thing in
any installation.

## The public door

`filing_proof(sha256)` answers one row per proof recorded for that hash:

| Column | |
|---|---|
| `sha256` | The hash asked about, in lower case |
| `method` | `opentimestamps` |
| `status` | `pending` or `complete` |
| `anchor_chain`, `anchor_height`, `anchor_time`, `anchor_reference` | `bitcoin`, the block height, the time in the block header, the block hash. Null while pending |
| `recorded_at`, `completed_at` | When the proof was recorded and when it was anchored |
| `proof_base64` | The `.ots` file, base64 |

It answers nothing about who proved the file or what it is about: no company,
no subject, no identifier of any row. A malformed hash and a hash nobody proved
get the same empty answer. Like `shared_document()`
([`sharing.md`](sharing.md)), it is a `security definer` function and the only
thing the anonymous role reaches here; the table stays closed to it.

Over the REST API, with the project's publishable key and no session:

```sh
curl -s "$SUPABASE_URL/rest/v1/rpc/filing_proof" \
  -H "apikey: $SUPABASE_ANON_KEY" -H "Content-Type: application/json" \
  -d "{\"p_sha256\": \"$(shasum -a 256 accounts.xml | cut -d' ' -f1)\"}"
```

## From the command line

```sh
ekwo proof stamp accounts.xml --year <financial year id>
ekwo proof stamp return.xml --filing <declaration id> --attachment <attachment id>
ekwo proof stamp invoice.pdf --document <document id>

ekwo proof upgrade                      # complete what a block now anchors

ekwo proof verify accounts.xml --out accounts.xml.ots
ekwo proof verify accounts.xml --ots accounts.xml.ots   # no installation read
```

`proof upgrade` is made to run on a schedule, every few hours, as a person or
a CI job: with `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `EKWO_EMAIL` with
`EKWO_PASSWORD` (or `EKWO_ACCESS_TOKEN`) in the environment, nothing is read
from the disk. It asks only the calendars it trusts, by default the four the
reference client trusts (`--upgrade-calendar` replaces them). It dates a
complete proof with the block time read from an Esplora block explorer
(`--explorer`, `https://blockstream.info/api` by default). It refuses a proof
whose path does not end in the merkle root of the block it names.

`proof verify` checks that the proof is about the file and that each Bitcoin
anchor matches its block. `--offline` skips the explorer. `--out` writes the
`.ots` file, which `ots verify` and any other implementation read.

## In code

`@ekwo-ai/core` exports what the command line uses, for any other surface: a
scheduled function, the MCP server, an application.

- `proveFile(backend, { subject_kind, subject_id, bytes }, { fetch })` hashes
  the file, submits it, and records the pending proof.
- `upgradeFilingProofs(backend, companyId, { fetch })` completes what a block
  now anchors.
- `lookupFilingProof(backend, sha256)` reads the public door.
- `checkProof(bytes, ots, { fetch })` checks a file against a proof.
- Lower down: `stampDigest`, `upgradeProof`, `bitcoinBlockAt`, `readOts`,
  `writeOts`.

The network is reached only through the `fetch` the caller hands in. The
format is written to the reference implementation's layout; the tests compare
the bytes with a layout assembled by hand.

## What a proof is worth

A proof shows that a file existed no later than a given time and has not
changed since. In many legal systems an electronic timestamp is admissible as
evidence. Some give a legal presumption of accuracy only to a timestamp issued
by a qualified trust service provider, for example under the eIDAS regulation
(Article 41). A timestamp from such a provider under RFC 3161 would be a third
method beside the two below. The `method` column is where it would go.

A proof does not show that the figures are right, that the file was accepted
by an administration, or who produced it. The deposit and its acknowledgement
remain the record of the filing ([`filing.md`](filing.md)).

## A second layer: Ethereum Attestation Service

OpenTimestamps proves **when**. It says nothing about **who**: anybody can
timestamp any file. The [Ethereum Attestation Service](https://attest.org)
(EAS) is an open protocol for signed, public statements. An address attests a
structured record under a registered *schema*. The record is readable by
anyone through an explorer or a contract call, and other services can reuse
it. The column `filing_proofs.method` already accepts `eas`. Nothing writes it
yet: this section evaluates it.

### What an attestation would say

One schema, registered once, the same for every country:

```
bytes32 fileSha256, bytes32 valuesSha256, string filingType,
string period, string entityScheme, string entityId, string jurisdiction
```

- `filingType` is the form code of the pack (`tax_filings.report_code`),
  `annual_accounts`, or the document type.
- `entityScheme` and `entityId` are the identifier of the company in a scheme
  anybody can resolve, such as a Legal Entity Identifier or the registry
  number the pack names.
- `jurisdiction` is the company's own country code, read from the company row.
- No figure and no name: the hashes carry the content.

### Who attests

| Attester | What it proves | Cost of keys |
|---|---|---|
| An address the company controls | The company itself published these hashes. This is the strong form | The company keeps a key, in a wallet or a signing service, and links the address to its identity: on its website, in its registry entry, or through a second attestation |
| The operator of the installation | An installation observed that this company published these hashes | One operational key per installation; weaker, because the operator vouches for the company |

### Onchain or offchain

- **Offchain attestations** are EIP-712 signatures of the same record. They
  cost nothing, can be verified by anybody who has the signed object, and can
  be published anywhere. In `filing_proofs` the signed object is the `proof`,
  the attestation uid is `anchor_reference`, and `anchor_chain` is the chain
  whose EAS contract the signature names. Dating it costs nothing more: the
  same file already has an OpenTimestamps proof.
- **Onchain attestations** write the record in the EAS contract of a chain.
  On a layer-2 network such as Base or Optimism, where EAS is deployed at a
  fixed system address, one attestation is a transaction of roughly 150 000
  to 250 000 gas. At the fee levels those networks have shown since blob data
  became available (EIP-4844), that is a fraction of a cent to a few cents,
  mostly the layer-1 data fee. Registering the schema is one transaction of
  the same order, once. Ethereum mainnet costs two to three orders of
  magnitude more and brings nothing here. These figures move with the market
  and are to be measured on the chosen network before anything is written
  onchain.

### How it would plug in

1. An attestation is recorded with `record_filing_proof(…, 'eas', …)`, with
   the signed attestation as its proof bytes. For an onchain attestation, it
   is completed with `upgrade_filing_proof(…, anchor_chain, anchor_height,
   anchor_time, anchor_reference)`, where `anchor_height` is the block number
   and `anchor_reference` the attestation uid.
2. The unique key is `(company_id, sha256, method)`, so one file carries one
   OpenTimestamps proof and one EAS attestation side by side, and
   `filing_proof(sha256)` returns both.
3. The key that signs never reaches the database or this repository, for the
   same reason the credentials of a filing do not
   ([`cloud-services.md`](cloud-services.md)). Signing is the client's act:
   the company's own wallet, or a signing service it chose.

### Recommendation

Keep OpenTimestamps as the default: free, keyless, verifiable offline. Add EAS
**offchain** attestations when a company wants to publish its filings under
its own identity, for example on a public company page. That costs nothing
beyond the key the company holds. Write **onchain** only when a company asks
for discoverability through public explorers, on a layer-2 network, and
measure the fee first. Neither needs a migration: both fit the columns that
exist.

## See also

- `supabase/migrations/20261007192418_a_filing_is_proved_by_its_hash.sql`
- `packages/core/src/proofs/`, `packages/cli/src/commands/proof.ts`
- `tests/filing_proofs.test.ts`, `tests/opentimestamps.test.ts`
- [0066 A filing is proved by its hash](decisions/0066-a-filing-is-proved-by-its-hash.md)
