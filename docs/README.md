# `docs/` — the long-form reference

| File | What it is | Edited how |
|---|---|---|
| [`schema.md`](schema.md) | Every table, column, enum and function, with their comments | **Generated** by `npm run docs:schema` from `supabase/migrations/`. Do not edit by hand; it would be overwritten |
| [`schema.intro.md`](schema.intro.md) | The prose at the top of `schema.md` | By hand; it is spliced in at generation time |
| [`mapping.md`](mapping.md) | Each Ekwo table and column lined up against the EN 16931 business terms (BT-xx) and the FEC columns | By hand, when the schema or a standard changes |
| [`packs.md`](packs.md) | The country pack format file by file, how it is compiled into a seed, every rule `ekwo pack check` applies, how a pack is versioned, who may call one reviewed, and a walkthrough for adding a country in a day | By hand, when the format, the compiler or the certification policy changes |
| [`modules.md`](modules.md) | What a module is, the six rules it follows, how its migrations and its country data are applied, and how to write one in a day | By hand, when the mechanism changes |
| [`international.md`](international.md) | The plan for any country: the country pack as data, four phases, the order of countries, what is out of scope | By hand, when a phase is decided or delivered |
| [`languages.md`](languages.md) | How a label reaches a reader in their own language: what stays English, what is data, how `label_for` chooses, and what a pack owes a language it declares | By hand, when the mechanism changes |
| [`sharing.md`](sharing.md) | How a document is published behind a link a customer opens without an account: the three functions, what may be shared and the refusal each other case gets, the exact shape `shared_document()` answers with, and why there is no access code and no IP address | By hand, when the functions or the payload change |
| [`machine-access.md`](machine-access.md) | How a machine key reaches the database through the REST API: the two headers a caller sends, what the pre-request does with them, what a key may read and write, what backing a company up needs, and how `ekwo doctor` says the installation is set up for it | By hand, when the transport or what a key reaches changes |
| [`filing.md`](filing.md) | The life of a declaration in eight steps — compute, freeze, produce the file, send, record what came back, archive, settle and pay, correct — with the function behind each and, for every step, what is free and what is operated | By hand, when a step is added or the open-core line moves |
| [`firms.md`](firms.md) | An accounting firm and its clients in one installation: a client is a `companies` row and a guest with narrow rights, **what "portfolio" means** (the companies a caller may read — a firm's client portfolio, never a list anybody maintains), filing for all of them in one file, the two ways to arrange a firm and a client, and what is still missing | By hand, when a piece of the firm's workflow is delivered |
| [`load.md`](load.md) | Books at volume: the generated instance and why a copy of what the engine posted is not a fake, the six hot paths and their budgets, why the build breaks on the shape of a plan and never on a time, the format of the report, what the first run found, and what only a real Postgres can still say | By hand, when a path, a budget or the report format changes |
| [`compatibility.md`](compatibility.md) | The exports `ekwo import` reads, one line per source: the command, the export expected with its official page, the state, and what an import does not take over | By hand, when a reader is added; one of the few files allowed to name another product, to say what is read |
| [`import.md`](import.md) | Taking over books kept elsewhere: the readers and the shape they share, the correspondence and how it is proposed, what `import_books()` does in one transaction, the rehearsal, what is refused and why, and how a source is added | By hand, when a reader or the mechanism changes |
| [`company-archive.md`](company-archive.md) | How one company leaves an installation and arrives in another: the directory and its JSON Lines, the manifest, what travels and what stays behind with the reason, the conditions of an export, every refusal of an import, and how a new table says which it is | By hand, when the format or the checks change; a test refuses a table the page does not name |
| [`releasing.md`](releasing.md) | How a release is cut: the schema-version migration, the package versions and the schema floor, the changelog, the tag and the GitHub Release | By hand, when the procedure changes |
| [`demo/`](demo/README.md) | The install demo of the root README: two vhs tapes, the script that records them side by side, the GIF and the longer MP4, and what is arranged off camera | By hand; the recording is redone with `demo/render.sh` on throwaway projects, never edited |
| [`decisions/`](decisions/README.md) | One record per design decision — context, decision, consequences — with an index by subject; `decisions.md` points to it | By hand: a new decision takes the next number, a changed one is rewritten to say what holds now; `tests/decision_records.test.ts` refuses dates in headings and incident narratives |

The short version of each folder lives in that folder's own README. Start
there; come here when you need every column. Two of those folder READMEs are
worth naming: [`supabase/seed/`](../supabase/seed/README.md) says which
reference data is generated from a pack and who applies it, and
[`packages/cli/`](../packages/cli/README.md) is the installation guide,
including the four things an operator has to do on their own Supabase project
that no installer can do for them.

`mapping.md` is the contract for integrators: it is what lets someone write
a connector from another ledger, a Peppol platform or a French tax portal in
a day, without an RPC layer imitating another product.
