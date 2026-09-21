# `modules/` — one Postgres schema each, beside the socle

The socle is `public`: companies, accounts, taxes, entries, documents, the
reports. What is built beside it lives here, one folder and one schema per
module.

| Module | Schema | Posts to the ledger | Country data |
|---|---|---|---|
| [`assets`](assets/) | `assets` | yes, through `post_module_entry()` | `packs/<cc>/assets.json` |
| [`budgets`](budgets/) | `budgets` | no | none |

`schema/module.1.json` is the published shape of a `module.json`, and
`ekwo module list` refuses one that does not match it.

## The rules, in one screen

1. **One schema, and the socle is not it.** A module depends on `public` by
   foreign key; the socle has no hook, no callback and no idea it exists.
2. **The ledger only through `post_module_entry()`.** The words `entries` and
   `entry_lines` never appear in a write statement here, and a test over every
   file of this folder refuses one that does. Reading the ledger is allowed.
3. **Row level security on every table**, through `module_enabled()` where the
   table carries a `company_id`.
4. **A module does its own grants.** `public` gets them from Supabase; a schema
   a migration created gets nothing.
5. **A country is data.** No module names one. What Belgium decides is in
   `packs/be/<section>.json` and compiles into `supabase/seed/modules/<code>/`.
6. **The registry is a table.** The last statement of a module's first
   migration writes its row into `public.modules`.

Migrations live in `<code>/supabase/migrations/`, share the socle's history
with the module in the recorded `name`, and their timestamps sort after the
socle migration the manifest declares it needs, `requires_socle_min`. Tests live in `<code>/tests/` and the root `npm test` runs
them.

The full version, and how to write a module in a day, is
[`docs/modules.md`](../docs/modules.md). Why it is shaped this way is in
[decision 0051](../docs/decisions/0051-a-module-has-its-own-schema.md).

## Planned modules

Two modules are decided and neither is written. They are recorded here because
the public site names them, and nothing should be on that page that is not in
this repository — and because the shape of each is the part worth agreeing on
before anybody writes it. Both follow the rules above: a schema of their own,
and `post_entry()` as the only way anything of theirs reaches the ledger.

No date is attached to either. What is written here is what they are, not when.

### `carbon` — sustainability accounting on the same ledger

A tonne of CO₂ accounted for as strictly as a euro, which is what
[`MANIFESTO.md`](../MANIFESTO.md) commits to.

Two methods, and they complement rather than compete. **Spend-based** reads the
entries that are already there: an emission factor per account, or per line of
a purchase, applied to amounts the books already hold. **Activity-based** reads
physical quantities — kilowatt-hours, litres, kilometres — recorded against the
same documents. A business starts with the first because it costs nothing to
begin, and replaces it line by line with the second where the numbers matter.

The scopes are the GHG Protocol's, 1, 2 and 3. The emission factors are
**data, not code**: loaded the way a country pack is, versioned, with the
publisher and the day it was read on every one of them, from public bases such
as ADEME's Base Empreinte, DEFRA and Exiobase. The reporting side is aligned on
what a small company is actually asked for — VSME, and ESRS E1 under the CSRD —
rather than on a format of our own.

Every tonne points at the entry and the document that justify it, which is the
whole reason for putting it on this ledger rather than in a spreadsheet beside
it: the audit trail is the one the money already uses.

### `crypto` — digital assets

Not one more bank account. A token is not a currency and not a stock: it needs
its own inventory, its own cost basis and its own revaluation.

Wallets and venues, acquisition lots, fair value at the close, and realised
gains by the method the country allows — first in first out, or average cost —
which is a rule of a country and therefore pack data rather than a setting. The
exports platforms hand over are read by format libraries under
[`packages/formats/`](../packages/formats/), like every other file this project
reads, so a new venue is a package and not a fork.

The reporting obligations are the reason the module is dated to now rather than
to some later tidy-up: MiCA, and the exchange of information DAC8 sets up.

### `sign` — electronic signature, in the open

A document to be signed, its signatories, the invitation each of them was sent
and where each of them stands. Beside it the **trail of proof**, written at the
moment somebody signs — who, when, and what: the fingerprint of the document
they saw, the identity they presented, the timestamp. That trail is the whole
value of a signature after the fact, and it is the part a business must not
have to ask a supplier for.

**Which level a deed requires is a rule of a country**, so it is pack data and
not code: simple, advanced and qualified in the sense of eIDAS are three words
a country's law attaches to acts, and no two countries attach them to the same
ones. The module reads that the way every other country rule is read.

Its own schema, joined to the documents of the socle — a quote that was
accepted, a contract, the minutes of a meeting — and reaching the ledger only
where a signed act has a consequence in it, through `post_entry()` like
everything else.

What needs a qualified trust provider — the qualified signature itself, the
qualified timestamp — is a provider you choose, behind one interface, the way
the bank connection and the invoicing network already are. The socle never
knows which one.
