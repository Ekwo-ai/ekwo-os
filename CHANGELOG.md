# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project
adheres to [Semantic Versioning](https://semver.org/).

Migrations are additive. A published migration is never edited: a database
somewhere has already run it.

## [Unreleased]

## [0.4.1] — 2026-09-18

### Changed

- **The command line is published as `ekwo-os`, and the command it installs is
  still `ekwo`.** `0.4.0` was the first release sent to npm, and the registry
  took fourteen packages of fifteen: it refuses the unscoped name `ekwo` as too
  close to two packages that already exist, a judgement it never passes on a
  scoped name. The CLI takes the name of the repository instead. `npx ekwo-os
  init` is what the README, the package READMEs, `SECURITY.md`, the help of the
  CLI and the two messages of `@ekwo-ai/mcp` that tell somebody which command
  to run now say; `bin` is unchanged, so `npm install -g ekwo-os` puts `ekwo`
  on the path and every example that starts with `ekwo ` stands. Nothing of
  the schema moves: `ekwo_schema_version()` answers `0.4.0`, the floor of the
  three packages stays there, and an installation at `0.4.0` has nothing to
  migrate. Every workspace moves to `0.4.1` together, because a release is one
  number. [`docs/releasing.md`](docs/releasing.md) says what publishing asks of
  an account with two-factor authentication, which the first run found out.

## [0.4.0] — 2026-09-18

### Added

- **A company leaves an installation with its books, and arrives in another one
  alive.** Several companies in one installation is the normal case — a firm
  and its clients — and `pg_dump` takes all of them or none, so the company
  whose owner changes accountant could be handed its ledger by nothing in this
  repository. `export_company(company)` writes one company out: entries,
  documents, pieces, third parties, the bank and its matchings, the
  declarations with the figures they were frozen with and the deposits that
  prove they went, the settings, the chart, the counters, the rows of the
  modules, the audit trail. `import_company(archive, owner)` takes it into
  another installation, where it keeps its identifiers, its numbers, its locks
  and its trail. `ekwo company export <company> --out <dir>` and
  `ekwo company import <dir>` are the same two acts from a shell, under the
  output contract. The format — a directory, JSON Lines per table, decimals as
  strings, a manifest with the versions needed and a sha256 per file that
  `shasum` checks without Ekwo — is [`docs/company-archive.md`](docs/company-archive.md).

  **What belongs to a company is read from the catalogue, not from a list**: a
  table that carries `company_id`, or that a foreign key leads from to
  `companies`. `company_archive_registry` says of each one `exported`, or
  `excluded` with the reason — members, invitations, keys and shared links stay
  where they were issued — and a table that says neither stops every export, by
  name, at run time as well as in the test. A module answers for its own tables
  through `<schema>.archive_tables()`; `assets` and `budgets` do.

  **Leaving needs `company.export`, which `owner` and `client` hold**, because a
  right to leave that only the firm can exercise is not a right of the client.
  The export runs as its caller under row level security — `service_role` and
  the owner of the database are refused, and the CLI steps down to
  `authenticated` for the member it acts for — and it is whole or it is not
  written: every table is counted a second time by a definer function that
  answers a number, and a member who may read fewer rows than there are is told
  which table. The readers are stable, so an archive is one snapshot; the act
  is recorded on the audit trail.

  **Arriving is one call, by the installer or an administrator of the
  installation, and the archive is not trusted.** Rows are inserted rather than
  replayed through `post_entry()`, which would renumber them — with the user
  triggers of the filled tables off for the transaction, foreign keys on — and
  the result is checked before anything stays: every row is of the company that
  arrived, no reference reaches into a company that was already here, entries
  balance and agree with their lines, matched amounts agree with the matchings,
  no counter is behind a number already used. A company already here is
  refused, which is what a second run meets.

  `tests/company_archive.test.ts` is the proof, on every pack that files: two
  companies furnished alike in one installation, one exported as its owner and
  imported elsewhere — trial balance, general ledger, the return and
  `filing_drift()` equal to the cent, the declaration still frozen with its
  proof, the locks and the closed year refusing what they refused, the next
  document numbered as it would have been, and not one identifier of the other
  company anywhere in the archive. `tests/company_archive_refusals.test.ts`
  offers the archives that lie, and each is refused whole.
  Not carried, and written: the bytes of the attachments, which the manifest
  lists. `docs/decisions.md` has the rest of what is missing.

- **`@ekwo-ai/coda` and `@ekwo-ai/cfonb120` — the two formats of fixed
  positions the packs already named.** The Belgian pack says its banks send
  CODA and the French one CFONB 120, and both were held as owed. Two MIT bricks
  with no dependency read them, from the published lay-outs — Febelfin's
  standard 2.6/2.8, the CFONB brochure of 2004 and its SEPA addendum of 2010 —
  and return **the fields `@ekwo-ai/camt053` returns, under the same names**,
  so `import_bank_statement()` takes what they read with nothing in between.
  Amounts are decimal strings: CODA's three decimals, CFONB's sign written over
  the last digit and its number of decimals read from the record; nothing is
  rounded. Refused by name, thrown: a record that is not 128 or 120 characters
  (nothing is padded), an unknown record, a record out of place or of another
  account, an encoding that is not the one said — ISO-8859-1 is an option,
  never a guess, and EBCDIC is refused. Returned as written and reported: a
  balance that does not follow, a CODA trailer whose count or totals disagree
  with the file, a Belgian structured communication that fails its modulo 97. A
  CODA total is split into its details only when they add up to it, as a
  camt.053 batch is. CFONB 120 carries no country, so its account is returned
  as an IBAN only when the caller names one (`ibanCountry`). The MCP tool
  `import_bank_statement` takes `coda` and `cfonb120`. **What is not
  guaranteed is written down and asserted as it is**: the same day from a CODA
  and from a camt.053 is recognised only when the bank writes the same
  reference in both — which Febelfin's standard does not promise — and a
  CFONB 120, which gives a movement no bank reference, is always imported
  beside the camt.053 of the same month. No file from a real bank was read.
  MT940 is left for a user with files: its counterparty lives in a field whose
  lay-out is each bank's own.

- **`import_bank_statement()` — a statement is imported once.** The way in to
  `bank_statements` and `bank_transactions`, which the reconciliation has read
  since it existed and only a test had written. It takes what a format reader
  returned, as jsonb, and writes those two tables and **nothing else**: no
  entry, no payment, no matching. A statement line becomes a payment when
  `settle_from_statement()` says what it pays.

  **Replaying a file creates nothing, and it is the database that refuses.**
  Every imported line carries `bank_transactions.import_key`, unique per bank
  account. With a bank reference the key is the reference (with the position in
  a split batch, the date and the amount); without one it is everything the
  statement says about the line **and which occurrence it is** among the lines
  of the file that say the same — so two tenants paying the same rent with the
  same words on the same day are two lines, and the same file replayed is still
  two.

  **A statement that overlaps an earlier one imports what is new and proves all
  of it.** A line exists once; a statement *lists* lines, in the new
  `bank_statement_lines`, whether it brought them or found them, and
  `balance_end_computed` is over the list. The month that arrives after its
  first fortnight adds the second fortnight and still closes on its balance.

  **Refused by name, with nothing written, and the whole file or none of it**:
  an account the company does not have — never created on the fly
  (`unknown_bank_account`); opening plus booked lines that is not the closing
  balance, **recomputed in the database** and not taken from the reader's flag
  (`unbalanced_statement`); no balances; a booked line in another currency or
  finer than the column; the same statement with other balances
  (`statement_conflict`). **Signalled, never refused**: an opening balance that
  is not the previous closing one, and a hole in the bank's numbering — in the
  result, and at any time in the `bank_statement_continuity` view, where
  importing the missing month closes the gap without anybody touching a row.

  `security invoker`: row level security is the wall, and an explicit
  `bank.write` check in front of it says why. Tested as a person — a `viewer`, a
  `client` and a member who lost `bank.write` alone are refused, the owner of
  another company learns only that there is no such company, and two companies
  holding the same account do not see each other's lines. The checksum of the
  file is kept on the statement; with a `storage_path` the file is a row in
  `attachments`.

  The MCP server gains **`import_bank_statement`** — `format`, required and
  never guessed, and the file as text — which reads with `@ekwo-ai/camt053`,
  refuses a hostile file before the database hears of it, and returns what was
  imported, what was already known and what is missing. No CLI command yet.

  `tests/camt053.test.ts` walks every pack that names `camt.053`: the golden
  year, an invented statement valid against the published schema, the brick,
  the import **as the owner under row level security**, and `auto_settle()`
  finding the invoice from the reference the statement carries — paid, the line
  reconciled, the bank fee left alone, and a second import undoing none of it.
  `tests/bank_statement_formats.test.ts` is the ledger of what the packs name
  and nothing reads: seven formats, each owed by name.
- **A posted invoice is sendable from the three views, with nothing told to the
  brick.** The end-to-end test of `@ekwo-ai/peppol-ubl` had listed what the core
  did not say; three migrations say it, and that test now writes an invoice with
  no rule broken from three reads and no option.

  **A line keeps the category and the rate it was posted with**
  (`20260918141107`). `document_lines.vat_category` and `.vat_rate` were
  published as BT-151 and BT-152 and never written. They are now derived from
  the tax while the document is a draft — following the tax when it moves, and
  taking the draft's totals with it — and frozen when it is posted:
  `document_line_tax_frozen` refuses a change by name. `document_tax_summary`
  groups on what the lines carry instead of reading the tax, so a pack upgrade
  that changes a rate restates no invoice already sent — neither its lines, nor
  its breakdown, nor its totals, which a corrected description used to recompute
  at the rate of the day. Lines already posted take the tax as it stands, once;
  no figure moves, and a line an application had stamped keeps its stamp.
  **An application that wrote these two columns itself should stop**: on a
  draft it is overwritten, on a posted document it is refused.

  **A company has an electronic address** (`20260918141342`):
  `companies.peppol_scheme` and `.peppol_identifier`, BT-34, the pair
  `contacts` has for BT-49 — a scheme and a value, whole or absent, no list of
  schemes in the core, written under `company.write`. The comments of
  `country_defaults.party_scheme` and `.vat_scheme` said "ISO 6523" and now say
  what the packs put there: a code of the Electronic Address Scheme list, a
  default to propose, and not the scheme of a registration number.

  **The views carry what the schema knew** (`20260918141605`), appended:
  `document_header.tax_point_date`, `delivery_address_line1`,
  `delivery_postal_code`, `delivery_city`, `delivery_country`,
  `seller_peppol_scheme`, `seller_peppol_identifier`, `buyer_peppol_scheme`,
  `buyer_peppol_identifier`; `document_tax_summary.exemption_code` (BT-121),
  `exemption_reason` (BT-120) and `legal_reference`. The reason is the sentence
  the pack prints on such an invoice, in the language of the document — not the
  pack's legal reference, which is written for a reviewer.
  `legal_mention_treatments()` is the one place that says which treatments a
  mention covers.

  **The United Kingdom pack is unchanged, and its invoices pass.** BR-E-10,
  BR-G-10 and BR-AE-10 ask for a code or a text; the VATEX list names articles
  of the EU directive and "export outside the EU", neither of which is British
  law, so the pack rightly codes none — and the text it always had now reaches
  the file. `docs/decisions.md` has the argument and what is still open.

  `@ekwo-ai/peppol-ubl` reads the electronic addresses from the header and no
  longer joins a silent line to its tax. Its 100 fixtures and the recorded
  Schematron verdicts are unchanged to the byte. `docs/mapping.md` has the new
  columns against their business terms.

- **`@ekwo-ai/camt053` — the first brick that reads.** The core has carried
  `bank_accounts`, `bank_statements` and `bank_transactions` since the first
  release, six packs name `camt.053` as a statement their banks send, and the
  reconciliation settles statement lines — and nothing could read a statement.
  This brick does: an ISO 20022 *Bank To Customer Statement* into statements
  and lines, MIT, no dependency, no database, no country.

  **The shape it returns is declared in the brick**: an account that is an IBAN
  *or* `Othr/Id` with its scheme (ISO 20022 offers the choice, and half the
  world has no IBAN), opening and closing balances, and per line the booking
  and value dates, a signed amount as a **decimal string**, the counterparty,
  the structured communication and the free one **kept apart**, the bank's own
  reference, the end-to-end identifier and the bank transaction code. A batch
  becomes one line per transaction only where the transactions add up to the
  entry exactly; otherwise it stays one line and says why.

  **Opening plus booked entries is the closing balance, or the file says so** —
  `balance_mismatch`, with the difference, and nothing corrected. The schema
  accepts a statement that does not add up, and a test shows it doing so.

  **A statement is hostile input.** The brick carries its own XML reader: any
  DOCTYPE is refused unread, so there is no entity to expand and nothing that
  opens a file; size is bounded before reading, depth and count while reading,
  without recursion; UTF-8 is decoded fatally. Billion laughs, XXE, a hundred
  thousand nested elements and a 33 MiB file are each refused by name.

  **Proved against the source, and the README says where the proof stops.** The
  thirteen schemas ISO publishes for versions 02 to 14 are fixtures, unmodified.
  One invented statement is written in all thirteen versions; each file is
  held against its schema, and all thirteen read to the same objects. Fetching
  the schemas refuted the draft the same hour: `BIC` became `BICFI` in version
  03 and not 04, version 14 exists since March 2026, and version 01 is another
  message under the same name — refused rather than half read. **Not
  verified**: a single file from a real bank, any banking community's usage
  guideline, and who the counterparty of a reversal is. camt.052 and camt.054
  are refused by name.
- **`npm run release:publish` — what a release publishes is read from the
  workspaces.** The list was a column of `npm publish` lines in
  `docs/releasing.md`, and a brick was once in the repository and not in the
  column. `scripts/publish.mjs` publishes whatever is a workspace and is not
  `private`, after every package of this repository it depends on; it says what
  it would do by default, and `--for-real` refuses a dirty tree, a HEAD no tag
  names and a session nobody logged in to, and skips a version the registry
  already holds. A test keeps the order honest and refuses a range on one of
  our own packages that the repository no longer satisfies.

- **The command line keeps books: `contact`, `invoice`, `post`, `payment`,
  `match`, `doc`.** A person in a terminal could install Ekwo and could not
  write an invoice, and an agent with a shell had to be given an MCP server
  first. `ekwo contact add`, `invoice new`, `invoice line add`, `post`,
  `payment record`, `match <transaction> <document>`, `doc list --unpaid` and
  `doc show` run as the person signed in, on the company in use, and **each is
  one function the MCP server calls too**.

  **Those functions moved to `@ekwo-ai/core`** (`src/books`): the `Backend`
  interface, the column lists, the amount formatting, contacts, documents and
  their lines, posting, payments and matching. The server keeps its zod inputs
  and re-exports the functions under the names they had; the command line
  brings a `Backend` of its own, over `fetch`. **The CLI computes no amount** —
  a test reads `packages/cli/src/commands/` and refuses the means to — and a
  refusal of the database is exit code 3, word for word, now proved through a
  shipped verb on a locked period.

  **`--ref`: a creation happens once.** Migration `…143417` adds `client_ref`
  to `contacts`, `documents` and `payments`, unique per company where given. The
  same reference a second time returns the first row (`replayed: true`), and
  finishes what a dropped connection cut in two — a draft without its lines, a
  payment never booked. The lookup is a convenience; the index is the
  guarantee. The MCP tools take `client_ref` too.

  **`--dry-run`: the database rehearses.** `rehearse_post_document()` calls
  `post_document()` for real inside a block it rolls back: the entry it shows
  is the one that would be written, under the number it would take, no counter
  burnt and no audit row left, and it refuses what posting refuses in the same
  words. `post_document` of the MCP server takes `dry_run`. No other verb has
  one: for no other does the database know how.

  **`--stdin`** reads one JSON object with the MCP tool's fields, and refuses
  one nobody defined. **`--line`** is named fields (`name=…,price=…,tax=…`);
  the free-text form `"Audit 1 500 EUR@21"` was arbitrated out — a rate is not
  a tax, and `1 500` is one number or two.

  `record_payment` gains `document_id`: the contact and the direction are read
  off what is open on the document, and the matching is offered to it alone.
  `list_documents` gains `unpaid`.

- **`@ekwo-ai/peppol-ubl` — the invoice the packs already promised.** Four packs
  declare `peppol-bis-3` as the structured invoice their country expects, the
  core carries what EN 16931 needs to write one, and nothing wrote it:
  `factur-x` writes the CII syntax of the standard, not the UBL one Peppol
  carries. This brick does — a sales invoice or credit note as UBL 2.1 in the
  profile Peppol BIS Billing 3.0, MIT, no dependency, from `document_header`,
  `document_line_items` and `document_tax_summary` as they are.

  **The figures are the books' figures.** Nothing is recomputed and no figure
  passes through a `number`: a total that does not add up is written as posted
  and reported as `BR-CO-15`, not corrected. 112 published rules are re-read
  and named by the identifier they are published under, so what the brick says
  of a file and what a validator on the network says of it are the same
  sentence; what would not be UBL at all is refused before a file exists.

  **Proved against the sources, and the README says where the proof stops.** The
  OASIS schemas validate every file in the test suite. The code lists are
  generated from the Schematron Peppol ships and compared with it code for code.
  The Schematron itself is XSLT 2.0 and is not run by the suite: it was played
  out of tree — release 3.0.20, `scripts/play-schematron.mjs` — against 100
  committed files, its verdicts are committed, and the suite holds the brick to
  them byte for byte and rule for rule. National rules and warnings are not
  re-read; the README lists what is not, by name.

  `tests/peppol_ubl.test.ts` walks every pack that declares the profile: the
  golden year, through `post_document()`, into the file, **read back to the
  cent** — totals, VAT by rate, lines against the ledger. Writing the file is
  free; sending it takes an access point, and stays in `ee/`.

  Playing the published rules refuted the first draft nine times, and the
  end-to-end test refuted it twice more. `docs/decisions.md` has the list, with
  what the same test found the core and the packs do not say yet.

- **Books at volume: the plans are read, and the build breaks on their shape.**
  Every test booked a handful of documents — fifteen at most — and Postgres
  plans fifteen rows the same way whatever the indexes are, so 173 indexes had
  been declared and never once seen used. `tests/load/` builds an instance of
  five companies of 10 000 documents over five financial years, runs `analyze`,
  and reads the plan of six hot paths — the ledger of an account, the trial
  balance, the aged balance, the tax return of a period, the entries file of a
  year, `suggest_contacts()` over a month of statement — as the owner and as a
  signed-in member. **A sequential scan of a large table inside one of them
  fails the build and names the statement.** Times go into a report, next to a
  budget, and into no assertion: a time on a shared runner is noise. The plans
  inside plpgsql bodies are read with `auto_explain` and nested statements.

  The books are **the golden year the engine really posted, copied**
  (`scripts/load/books.mjs`): posting 10 000 documents through
  `post_document()` takes over a minute before the first plan is read, and
  invented ledger rows prove nothing. Deterministic from a seed, no real data,
  and no country — the pack is `EKWO_LOAD_PACK`. 100 000 documents a company is
  `EKWO_LOAD_DOCUMENTS=100000`, outside the CI. The same generator and the same
  six definitions are wired into `scripts/e2e-supabase.mjs` behind
  `EKWO_E2E_LOAD_DOCUMENTS`, for times on a real Postgres over SQL and over
  PostgREST — written, and like the rest of that script not yet run.
  [`docs/load.md`](docs/load.md) has the method, the report format and what is
  still unknown.

  What it found: no hot path walks a large table, and two things no plan would
  ever have shown — both under *Fixed* below.

- **`docs/firms.md` — an accounting firm and its clients, on one page**, and
  what *portfolio* means in `portfolio_upcoming_filings()` and
  `portfolio_filings_touched_since()`: a firm's client portfolio, which here is
  the companies the caller holds `filings.read` on, worked out at each call and
  never a list anybody maintains. The page gathers what was delivered in pieces
  — a client is a `companies` row and a guest with the `client` preset, the
  firm files for all of them in one file, the two ways to arrange a firm and a
  client — and what is missing, in the order it matters. The MCP tools say the
  same in their descriptions, which is where a model reads it.

- **The portfolio: every company somebody keeps, read at once.**
  `upcoming_filings()` and `filings_touched_since()` take a company, and a firm
  that keeps forty does not ask forty times.
  `portfolio_upcoming_filings(from, to)` and
  `portfolio_filings_touched_since(from, to)` walk **the companies the caller
  holds `filings.read` on, and no other**. There is no firm in the schema and no
  list of clients: the portfolio is what the caller may read, so the accountant
  of two companies gets two, the person who runs one gets one, and nobody had to
  be called anything. Both are `security invoker` — row level security does the
  sorting, as it does for the two functions they are built on — and the
  capability is tested in the open on the list of companies, because
  `companies` is readable by people `tax_filings` is closed to.

  **Every company of the portfolio is in every answer.** A row without a date
  says why in `reason`: `no_deadline_rule` where the pack names no day for the
  form, `nothing_due` where nothing of the company falls in the window,
  `no_form` where the installation carries no return for it. On the other
  reading, a company nothing moved in is a row with no filing and `filed` says
  how many declarations were examined. A company left out cannot be told from a
  company that was never looked at, and over forty of them that is the
  difference that matters.

  **The window is on the day a return is due**, not on the period as
  `upcoming_filings()` reads it; an undated period is listed while the month
  after it overlaps the window, which is the only place the closed vocabulary
  of rules ever puts a date. The administrator of the instance, who creates
  companies and keeps none of their books, has an empty portfolio: that is what
  `tax_filings` already said, and it is now tested. The MCP server gains both
  readings as tools. `tests/filing_portfolio.test.ts` proves all of it as the
  people concerned, across three packs picked by what they declare about their
  deadline.

- **`ekwo login`, `logout`, `use` and `whoami` — the command line learns who
  it is.** Every command took a connection string, which is right for an
  installer and untenable for twenty commands a day, and a connection string is
  nobody: it is the owner of the database. The commands that keep books act as
  **a person**, through the instance's API and under row level security — the
  route the MCP server takes, to the same functions. `login` asks the instance
  for a session and keeps it in the user's configuration directory
  (`~/.config/ekwo`, `0600`), **never in a repository**: a directory with a
  `.git` above it is refused before anything is sent. The password is sent once
  and written nowhere. An access token that lapsed is renewed ahead of time, and
  again when the instance answers 401 anyway; the rotated refresh token is on
  disk before the call is retried, and a session that cannot be renewed is
  `session_expired`, not a loop. `--profile` and `EKWO_PROFILE` hold one
  instance, one person and one company each. **The environment comes first and
  touches no file** — the variables the MCP server reads — and is taken whole: a
  token there with no instance beside it is a wrong call, never sent to a
  profile's host.

  **Every answer names the company it was rendered for.** Under `--json` a
  command that acts as a person carries a `context` — profile, instance,
  company, `null` when none is in use — on success and on a refusal alike.
  `ekwo use` checks the company against the instance as the user, so one they
  cannot see is `unknown_company` and is not named back to them. `whoami` works
  nothing out: the companies are what the policies let through, the
  capabilities are `member_capabilities()`, the version is
  `ekwo_schema_version()`.

  **A `service_role` key is refused at five doors**, with the sentence the MCP
  server uses: `isServiceRoleKey()` and the refusal **moved to `@ekwo-ai/core`**,
  and the MCP server re-exports them under the names they had. **A refusal that
  arrives over PostgREST is still exit code 3**: the SQLSTATE travels in the
  error body and is read as a driver's is, which closes the gap the output
  contract wrote down. The CLI gains no dependency — the three auth requests and
  the two PostgREST ones are written on `fetch`. `init`, `migrate` and the other
  commands that connect as the owner of the database now say so when they
  connect.

  *Changed:* an unknown or ambiguous company in `ekwo pack upgrade` is exit
  code 2 where it was 1 — it shares its matching with `ekwo use`, and a company
  named wrong is a wrong call. The help no longer says "never writes a secret
  to disk"; it says what is kept, where, and what never is.

- **`@ekwo-ai/vat-consignment` 0.3.0 — a firm files for its clients, in one
  file.** `generateVatConsignments()` writes as many returns as it is given and
  the `Representative` who files them. Read in the schema and not assumed:
  `VATDeclaration` repeats, `VATDeclarationsNbr` counts them, and the
  representative block is optional with **every field inside it required** — so
  a representative is named entirely or refused, never completed and never
  dropped. Returns are numbered by position, two under one number are refused,
  and a violation says which return it is in. `ISSUERS` is the schema's list of
  issuing states (Greece is `EL` in it), compared with the schema file code for
  code. `generateVatConsignment()` is unchanged: a consignment of one. Not
  checked, and written: whether the representative holds a mandate — a fact of
  the administration's records, not of the file.

- **A `client` preset: the person whose company it is, in the installation of
  whoever keeps their books.** Several companies inside one instance has been
  the normal case since the first day — a firm and its clients — and the client
  had no preset to sit on: `viewer` hands nothing over, `accountant` drafts
  invoices. `client` holds what `viewer` holds, the ledger included because the
  books are theirs, plus one new capability.

  **`documents.deposit` — the capability that was missing.** Handing a receipt
  over is an insert into `attachments`, and the only policy that admitted one
  tested `documents.write`, which also creates and changes draft documents.
  There was no way to say *may give us the piece* without saying *may write the
  invoice*. The new capability admits an INSERT and nothing else, on the company
  itself (`entity_type = 'company'`) and nowhere else — `attachments` is
  polymorphic, and a depositor who could name any row could pin a file of their
  own beside the receipt of a filed declaration — and signed:
  `attachments.uploaded_by` now defaults to the caller and a deposit is refused
  unless it says the caller. Filing the piece, moving it onto the document it
  becomes and deleting it stay `documents.write`. A second SELECT policy lets a
  depositor read back their own deposits, so `insert … returning` answers for a
  member or a key that holds `documents.deposit` and not `documents.read`.
  `owner` and `accountant` hold it too; `viewer` does not.

  `invite_member()` takes the preset as it takes the others, `assets` and
  `budgets` give it their `.read`, and `MemberRole`, the MCP `invite_member`
  tool and the README name it. `tests/client_preset.test.ts` proves it as that
  person, under row level security, and is written against the catalogue: every
  table `authenticated` may write is updated, deleted from and inserted into,
  every volatile function it may execute is called on a real target, and the
  whole database is fingerprinted before and after. A function nobody
  classified fails the test, so the next one is tried the day it lands.

- **The CLI answers a program as well as a person.** Every `ekwo` command takes
  `--json` and then writes one JSON document to the standard output, of one
  published shape ([`packages/cli/schema/output.1.json`](packages/cli/schema/output.1.json)),
  with the prose on the standard error. Exit codes tell four things apart: `0`
  done, `1` it failed or a check found something, `2` the command was called
  wrong, and **`3` the database refused** — a locked period, a capability the
  caller does not hold, a policy, a constraint. A refusal is printed as the
  database wrote it and named in a field of its own (`error.name`:
  `period_locked`). No command waits on a question off a terminal or under
  `--json`; the prompts themselves now refuse to. `ekwo module list` prints an
  aligned table. This is the first card of the epic that brings the MCP
  server's verbs to the command line, and it adds none of them.

- **A first country walks the whole chain.** Belgium computes its return, freezes
  it, writes the file Intervat takes, and settles it — every step proved by
  `tests/filing_golden.test.ts`, which now prints `be: freezes, writes a file,
  settles` and **refuses a checkout where no country does all three**.

  The Belgian pack names the two accounts a declaration is settled on: `451900`
  for what it owes and `411900` for what it is owed back, in both charts, in four
  languages. They are apart from `451000` and `411000` on purpose — the taxes
  themselves post there, and a period cannot be cleared into an account it is
  still posting on. The PCMN fixes `411` and `451` and leaves what is beneath
  them to the company, so these are sub-accounts of the pack's and not of the
  law's. They are named after what they hold rather than after the *compte
  courant* the administration abolished in favour of the provisions account.

- **The proof, pack by pack.** `tests/filing_golden.test.ts` replays the golden
  year of every pack that declares a form, computes the return, **freezes it**,
  writes the file and reads it back to the cent where a brick exists, and posts
  the settlement where the pack names an account — then checks the tax accounts
  of the period are back to zero. How far each pack got is the assertion, and the
  run prints it: today six packs freeze, one writes its file, three settle. A
  pack that cannot walk the chain cannot say that it files.

  `ekwo pack list` prints the same five answers per pack — the form, its cadence,
  whether the deadline is in the pack, the file it is deposited as, the account
  it settles to — and **prints every "no"**: a listing that showed only what
  works would be a brochure. `filingReadiness()` is read by both, so the listing
  and the test cannot disagree.

  [`docs/filing.md`](docs/filing.md) is the cycle in one page: compute, freeze,
  produce the file, send, record what came back, archive, settle and pay,
  correct — with the function behind each step and, for every one of them, what
  is free and what is operated.

- **A deposit, and what came back.** Filing was one act with one date, which is
  the happy path and was all the schema could describe. A declaration is refused
  — a malformed file, a certificate that expired mid-session, a figure the
  administration disputes — and then it is **sent again**, which nothing could
  say: `file_filing()` refused anything that was not a draft, so a rejected
  declaration was a dead end whose only exit was a corrective. A corrective
  replaces a declaration that was *accepted*; one that was never received has
  nothing to correct.

  `tax_filing_deposits` holds one row per send: the channel, the service where
  there was one, the reference, the outcome, **the administration's own words**,
  and the two files — what was sent and the receipt, named apart from each other
  rather than left as two attachments nobody can tell apart. `file_filing()`
  writes the row and accepts a rejected declaration; `record_filing_outcome()`
  answers on the send it answers; `reopen_filing()` takes a rejected declaration
  back to draft so its figures can be worked out again, and refuses to do that to
  an accepted one.

  **The open-core counterpart of D6**: sending stays in `ee/` — credentials, a
  certificate, a portal session, somebody answerable when a return is late — and
  everything that comes back is here, in your database, under your own policies.
  A company that stops paying for the transmission keeps every proof that it
  filed. The channel is two words, `portal` or `service`, and a service's name is
  free text: the core records what was used and holds no list of what may be,
  which is what keeps it uncoupled from any provider.

- **The file of a periodic VAT return, which existed for no country.** Seven
  bricks wrote legal files and not one of them wrote the declaration a company
  files every month: the four statement bricks carry recapitulative listings,
  `xbrl-cbso` the annual accounts. **`@ekwo-ai/vat-consignment`** is the first —
  the XML Intervat takes for the Belgian monthly or quarterly return, zero
  dependencies, MIT like every brick.

  Its input is `tax_filing_boxes`: the figures **as they were frozen at filing**,
  never a recomputation. A test posts a late invoice into a filed quarter and
  checks that the file does not move while `filing_drift()` reports the
  difference — which is the whole reason D1 froze anything.

  It writes two-digit grids, omits a grid at zero, writes amounts with a point,
  and **writes nothing for a field it was not given**: a telephone number
  invented to satisfy a validator reaches an administration as a telephone
  number. Three things come back as violations instead of breaking the file — a
  box that is not a grid of this form, an amount that is not one, and **the same
  grid twice**, which is the one thing this format cannot hold: it gives every
  grid a single value, so a form that prints a base and a tax on one line (the
  French CA3, line 08) has no representation in it.

  `tax_report_templates.file_format` is how a form says which brick writes it —
  named after the format, never after the country — and the Belgian pack names
  this one. Null stays the ordinary answer: a form nobody can write is still one
  a company files by hand on a portal. The guard that would refuse a pack naming
  a format nobody can write is owed here and to `bank_statement_formats` alike,
  and is one guard over the three rather than three.

- **What moved after it went.** A declaration leaves and its period stays open —
  a late supplier invoice, an adjustment, a correction, all legitimate. What was
  not legitimate is that nobody was told. `filings_touched_since()` lists the
  declarations the ledger disturbed after they were filed: how many entries
  carrying a declaration box landed in the period, when the last one did, and how
  many of the frozen figures now disagree. An entry that moves no figure is still
  listed; one that concerns nothing on the form is not, and neither is the
  declaration's own settlement.

  **A corrective now settles the difference.** `filing_tax_movements()` nets the
  period against what an earlier settlement already carried, so the corrective's
  entry books what changed and not the quarter all over again — the gap D4 named
  and left open.

  **`lock_filed_period()`** carries the tax lock to the end of a declared period,
  forward only, for a company that does want it shut. It is a function of its own
  rather than a flag on filing, and the test is what settled that: `post_entry()`
  checks the tax lock for every entry, so locking at the moment of filing would
  lock the declaration's own settlement out of its period for ever. It refuses
  while the period still has tax accounts to clear, and says so.

  What a country does with a correction — a replacement return, an adjustment on
  the next period, a threshold below which nothing is filed — is pack data nobody
  has read the texts for yet, and is not invented here.

- **What a declaration owes.** An accepted return left the books untouched: the
  collected and the deductible stayed where the postings put them, and what was
  owed to the administration was a subtraction nobody had made. `settle_filing()`
  clears every tax account the period moved — the same window and the same
  tax-point rule the return read — and carries the net to the account **the pack
  names**, `tax_payable`, or `tax_receivable` where the period ends in a credit
  and the chart keeps the two apart. One entry per declaration, through
  `post_entry()`, linked by a column with a unique index: replaying is refused by
  the database.

  A credit is not settled until the company says what happens to it — carried to
  the next declaration, or claimed back — because both are ordinary and the
  choice is not the schema's. `filing_tax_movements()` shows what will be
  cleared before anything is posted. And the debt is then an open item like any
  other: name the administration as its contact, give the entry the reference the
  payment will quote, and `auto_settle()` matches the payment to it — which is
  what B4 was built for.

  Three packs name the accounts: France 445510 and 445670, Luxembourg 461412 and
  421612, the United Kingdom its 2210 control account for both signs. Belgium and
  Estonia name none, because their charts post the taxes themselves on the
  account the role would want and a separate control account is a change to those
  charts rather than to this code; the United States files no periodic VAT return
  at all. Where no pack names one, settling refuses and says which role to set.

- **A box of a filed declaration is a number *and* a kind.** `tax_filing_boxes`
  was keyed on the box alone, which is right on a form that prints a base and a
  tax on separate lines and wrong on the French CA3, where line 08 carries both:
  preparing that declaration failed on a unique constraint. The key is now
  `(filing, box, kind)`, and `filing_drift()` answers on it too — "08 moved" is
  half an answer on a form where 08 is two figures.

- **When a declaration is due.** The schema knew how *often* a company files —
  one cadence per form — and never *when*. The date is a rule of the country, so
  it goes where country rules go: `deadline` on the form in `tax_report.json`,
  a closed vocabulary of two shapes — a fixed day of the month that follows, or
  the last day of it — either able to add `plus_days`, with the text that sets
  it. `filing_deadline()` works it out, `upcoming_filings()` lists what is due
  between two dates, period by period, with the declaration already prepared or
  filed against each.

  Four packs declare one: Belgium and Estonia the twentieth of the month that
  follows, California the last day of it, the United Kingdom the last day plus
  the seven days HMRC grants a return filed online. **France declares none on
  purpose** — its dates are assigned from the taxpayer's identification number,
  which is not a rule about a period — and `filing_deadline()` answers null
  rather than a day that would be wrong for most filers. Luxembourg declares
  none because nobody has read the text yet, which is the same answer for a
  different reason and is written down as such.

- **A declaration that was filed is a row, not a report.** `vat_return()`
  recomputes from the ledger every time it is asked, which is right for
  preparing a return and wrong for having filed one: post an entry into a
  period declared three months ago and the same function answers different
  figures than the administration holds, with **nothing saying which were the
  ones sent**. `tax_filings` and `tax_filing_boxes` keep them, box by box,
  frozen by a trigger from the moment the declaration goes.

  The boxes are rows and not a JSON document: a box is already an object of
  this schema, and a filed return has to be queryable the way everything else
  is — summed, compared period to period, joined to the form it belongs to.

  `prepare_filing()` computes and keeps; called again on a draft it refreshes,
  and on a declaration that has gone it refuses and names what is needed
  instead. `file_filing()`, `record_filing_outcome()` and `supersede_filing()`
  are the transitions, functions rather than updates for the reason posting is
  one. A corrective never overwrites: the old filing becomes `superseded` and
  the new one points at it, because what was sent was sent.

  **A period where nothing happened is filed nil**, not refused — an obligation
  in most countries, and the first version of this got it wrong by counting the
  boxes instead of asking whether the figures had been computed.

  `filing_drift()` falls out of the freeze for nothing and is the most useful
  health check here: box by box, what the ledger says today against what was
  filed. Empty is the answer everybody wants; anything else is a corrective to
  file or an entry in the wrong period.

  Filing has its own capability. `entries.read` was not enough and
  `company.write` too much: an administration receives something in the
  company's name, and that is exactly the act a company keeps for one person
  while several keep the books.

- **What the money pays.** The other half of a statement line: `open_items()`
  lists what is still owed in the shape a search needs, `suggest_matches()`
  answers what a line could settle — with the evidence and, as before, how many
  candidates that same evidence produced — and `settle_from_statement()` is the
  act: it books the payment, posts it and matches it against the items named.

  **A statement line does not become an entry, it becomes a payment.** The
  ledger already knows what a payment is; `post_payment()` books it and
  `reconcile()` matches it, and nothing in this file writes an `entries` or an
  `entry_lines` row of its own.

  `auto_settle()` walks a period and applies **only what one piece of evidence
  identifies**: a reference that matches, or an exact amount with exactly one
  candidate. Everything else comes back with the reason it was left, which is
  the report a bookkeeper actually reads. Two of those reasons are deliberate
  refusals rather than missing features. **A combination is never applied**:
  `suggest_combination()` finds the subset of a counterparty's open items that
  adds up, oldest first and deterministic, and offers it — because a sum that
  reaches the right total from the wrong invoices leaves nothing behind to
  notice. **A partial payment is never applied**: a deposit, a discount, a short
  payment and an error wear the same face, and the ledger cannot tell them
  apart. And a transfer between two accounts of the same company is named as
  what it is and left alone.

  With `p_apply` false it changes nothing and says what it would do.

- **Who the money came from, and a memory of how we knew.** A statement line
  carries a name the bank wrote, an account, a free-text description and an
  amount; none of them is a contact. `contact_patterns` records the **motif** —
  four kinds, closed: the counterparty's account, a spelling of the name, a word
  of the description with its exclusions, a band of amounts — and
  `suggest_contacts()` answers with every contact a line could be, the score,
  the evidence in a sentence, and **how many contacts that same evidence
  reached**. One is a recognition; two is a coincidence with a name on it.
  Nothing here chooses a contact: the core still proposes and a person decides.

  `confirm_contact()` is the only thing that learns, because a decision
  somebody stands behind is the only thing worth learning from: the account and
  the name as that bank writes them become motifs, and every motif that had
  named somebody else is charged a use without a success — being wrong costs
  confidence, or every motif converges on certainty and the oldest mistake
  wins. Confidence is the two counters and nothing else, `(success + 1) /
  (usage + 2)`, so a motif nobody has used yet is worth half and says so.

  What is deliberately absent is a list of legal forms to ignore. `sarl`,
  `bvba`, `gmbh` are country data and would be literals in the core; the count
  of what the evidence reaches does the same work better, because a word
  carried by thirty suppliers identifies none of them — including the words such
  a list would have forgotten. That is the 16 April 2026 incident of the
  production this design comes from, where five characters of a name made
  `SARL` equal to `SASU`, kept as a test rather than as a comment.

  The five numbers this runs on — how much of a name has to agree, how far two
  amounts may sit apart, how far a payment may sit from its document, how long
  a word has to be — are `matching_settings`, per company, and their shipped
  answers live in `matching_policy_of()` and nowhere else. **A tolerance is
  counted in units of the currency's own smallest denomination**, never in
  cents: a quarter of the world's currencies has none.

- **A tax follows the territory of the parties.** `applies_when` on a tax takes
  `seller_in`, `buyer_in` and `supply_in`, each naming one territory of
  `territories`, and every key present has to hold — a closed vocabulary of
  three equalities, with no operator and no negation. Where a party is comes
  from four new columns, all of them foreign keys into the same table:
  `companies.territory_code`, `contacts.territory_code`,
  `documents.supply_territory_code` and the three on a tax; a null resolves,
  down a ladder that is written down — the seller and the buyer by the kind of
  document, the supply from the document's own column, then
  `delivery_country` (BG-15), then the buyer. A condition is satisfied by the
  territory named and by everything inside it, so a tax of a country reaches a
  territory under it and not the other way round. `post_document()` raises
  `tax_territory_mismatch` or `no_party_territory` and books nothing; it still
  chooses no tax for anybody. `ekwo pack check` refuses a territory the table
  does not carry, on `applies_when` and on `jurisdiction` alike, refuses a
  `seller_in` outside the pack's own country, and judges a tax's VAT regime on
  the territory it applies in — which is what makes `eu_vat_scope = 'goods'`
  mean something and Northern Ireland expressible. `packs/us/` says where each
  of its eleven codes applies and no figure of its golden year moved.
  `supabase/seed/00_territories.sql` gains four American states. Closes two
  notes of `docs/international.md`, one from the United Kingdom and one from the
  United States, that had proposed the same fix from opposite sides.

- **A box of a declaration may be a rate of another box, and a form may be
  printed in the order it is printed in.** A computed box was a list of boxes to
  add and a list to subtract, which is every European return and no sales tax
  return: CDTFA-401-A works its taxable total out on line 12 and then says
  *multiply line 12 by 0.06*. A box now takes `rate`, a percentage, with
  `rate_of`, the one box it applies to — two named fields, no expression
  language, and the same closed vocabulary as before. `packs/us` states lines
  13, 14 and 15 that way and the four `tax` postings that used to fill them from
  an apportionment of the combined rate have lost their boxes; not one figure of
  its golden year moved. Line 16 stays summed from the ledger, because a
  district tax is owed on the sales made in that district and not on the
  period's whole taxable total.

  With it, `sequence` stops meaning two things. `print_sequence` is optional on
  a box and says where the administration prints it; `sequence` stays where the
  pack declares it; and the order the totals are worked out in is the boxes each
  one names, which is what `evaluate_totals()` has resolved since it became the
  one evaluator. The rule in `ekwo pack check` that refused a total naming a
  total declared after it is gone — three packs had paid for it — and a cycle is
  refused by name instead, at check time and, at runtime, as `formula_cycle`.
  `vat_return()` answers `print_sequence` beside `sequence`, and
  `packs/us/tax_report.json` prints in the order CDTFA does.

- **A pack's claims about the arithmetic of its own form are read.**
  `report_arithmetic` in `packs/<cc>/golden/expectations.json` was declared in
  `tests/helpers/packs.ts` and compared to nothing. A test now holds every claim
  against the form the pack carries, so a box that adds the wrong boxes — or is
  a rate of the wrong one — is caught by the sentence the instructions write,
  and not only by a golden figure that would have agreed with it.

- **A vocabulary for a tax that is not a value added tax.** The first pack of a
  country with no VAT — sales tax and use tax, nothing recoverable at any stage
  — returned five gaps of vocabulary, and four of them close here. `tax_treatment`
  gains **`self_assessed`**: a tax a buyer owes directly to an administration
  under that administration's own law, and computes and declares themselves.
  California's use tax was booked as `domestic_reverse_charge` with a
  `legal_reference` that said in a sentence it was not one — there is no exempt
  supply behind it, no supplier relieved of anything, and nothing recovered at
  the other end. **`vat_category` is no longer required outside the common
  system of VAT** unless the pack declares an e-invoicing profile: BT-151 is a
  term of an invoice governed by EN 16931, and a country whose sellers issue no
  such invoice has no category of anybody's to record. The border is the one
  ST38-1 drew for the reason code, one field over, and the column being free is
  not the column being unchecked — a category a pack does name is still held to
  its treatment, its reason and its rate. **The register entry that publishes a
  country's exemption reason codes now says so**, with `"reason_codes": true`,
  instead of being whichever entry of kind `standard` came first: `standard`
  means "a technical norm or code list", so citing FRS 102 or the FASB
  Codification silently authorised a reason code on any tax of the pack. No pack
  ever carried one, in either pack the trap was live in. And **a tax can say
  what it depends on**: `conditions`, a closed vocabulary of five words —
  `buyer_certificate`, `buyer_status`, `transport_evidence`, `seller_threshold`,
  `supply_nature` — for an exemption whose answer is not in the books. There is
  no value beside any of them: no threshold amount, no certificate number, no
  operator and no expression, because the figure is in the article the tax
  already cites. Five codes of `packs/us/` now say which question they answer.
  What is still nowhere, and is recorded as such in `docs/international.md`, is
  the evidence itself — no place on a contact for a certificate and its
  validity, no place anywhere for a rolling total per territory.

- **A cadence per declaration, and a ledger line that names its posting.** A
  company files several declarations and each has a cadence of its own — the
  recapitulative statement of intra-Community supplies is monthly in France from
  the first euro, monthly in Belgium above a threshold counting goods alone
  whatever the return's cadence, on separately chosen cadences for goods and
  services in Luxembourg, and filed with the return in Estonia — and
  `companies.vat_period` held one, named after the return. `company_filing_periods`
  now holds one row per form; `vat_return()` reads the cadence of the form it was
  asked for, and `ec_sales_list()` gains the same guard for the statement the
  caller names, refusing nothing when it names none. `companies.vat_period` is
  kept because it is published, and is now derived: a mirror of the row for the
  country's periodic return, held in step by two triggers so the fact is decided
  in one place. The proposal moved with it — a pack proposes on the **form**, in
  `tax_report.json`'s `period_default`, judged against the law rather than
  against the number of cadences the form accepts. That closes the British gap:
  `packs/gb` proposes `quarter` on a form filed on three cadences (Value Added
  Tax Regulations 1995, reg. 25(1)), and re-reading the others on the same rule
  moved Belgium and France to `month` — each country's code makes the monthly
  return the rule and the quarterly one an authorisation granted on turnover —
  while Luxembourg proposes nothing, because there the cadence follows turnover.
  Beside it, `entry_lines.posting_type` says which tax posting wrote a line, so a
  `base` line and a `tax_on_base` line of the same tax on the same account are
  no longer indistinguishable; existing lines were filled only where a tax and a
  declaration box name one posting type and no other, and left null otherwise.
  `ekwo init` asks once per declaration and takes `--filing-period
  <report_code>=<cadence>` as well as `--vat-period`; `ekwo status` lists every
  cadence. All five packs bump — be **1.9.0**, fr **1.10.0**, lu **1.4.0**, ee
  **1.5.0**, gb **0.4.0** — and no golden figure changes, because a cadence
  computes nothing. Three notes in
  [`docs/international.md`](docs/international.md) are closed and two opened: a
  pack declares one form where a country files several, and one cadence per form
  is one too few where a country splits a statement by what is supplied.
- **The United States, the first country with no value added tax.**
  [`packs/us/`](packs/us/) **0.1.0**, `community`: a chart of 234 accounts
  written against Regulation S-X because the United States prescribes none, the
  balance sheet of rule 5-02 and the income statement of rule 5-03 caption by
  caption, eleven sales and use taxes across three states, the thirty-nine boxes
  of California's CDTFA-401-A, the usual lives of a fixed asset under the FASB
  Codification, and a golden year of fifteen documents on a 52-week fiscal year
  ending the last Saturday of June. Twenty texts in the register, every one of
  them opened.

  The United Kingdom was the first pack outside the Union and still levied a VAT.
  This one has none: the tax is levied by the states and by thousands of
  districts under them, **the buyer never gets a cent of it back** — every tax of
  this pack is `recoverable: false` and a purchase tax is a `tax_on_base`
  posting at the full amount, so an 8,000 dollar purchase costs 8,580 — there is
  **no national return**, and there is no legal chart of accounts. Three states
  were chosen for what each shows: California, whose form prints the state, the
  county, the local and the district share of one rate on four separate lines;
  New York, which adds the local share into one combined rate against a
  jurisdiction code and files a form this pack does not carry; and Oregon, which
  levies no sales tax at all, which is a territory a pack can now state.
  California's use tax is the buyer charging themselves and paying the State
  directly, which the pack books as a `tax_on_base` posting and three `tax`
  postings with a negative factor and a positive box factor.

  Fourteen things the core could not say precisely are in
  [`docs/international.md`](docs/international.md) under "From the United
  States", and none of them was patched for this pack's sake. The first is the
  one to read: **a box of a declaration form can be a rate applied to another
  box**, which four lines of CDTFA-401-A are and which a `total` — a list to add
  and a list to subtract — cannot express. Then: a tax cannot be conditioned on
  the territory of the parties, so a pack offers a Californian company New York's
  codes; there is no treatment for a tax a buyer assesses on themselves outside
  the common system, and none for a supply outside the taxing territory but
  inside the country; an EN 16931 category is still required where no invoice
  carries one; a register entry of kind `standard` is silently read as the list
  BT-121 codes come from; an exemption that turns on a certificate the buyer
  signed or on a threshold the seller crossed cannot be recorded;
  `fiscal_year_default` offers four opening months where the law offers twelve
  and then a 52-53-week year; a form filed in whole dollars over a ledger kept
  in cents cannot say so; the close cannot send other comprehensive income
  anywhere but the result; a fixed asset carries one depreciation plan and an
  American asset has two, one for the books and one for the return. One was
  confirmed rather than found: `sequence` on a box is print order and evaluation
  order at once, for the third time.

  Two of the gaps this pack was written against were closed by the cadence
  change above, days before it landed, and the pack is rebased onto both. It
  proposes `quarter` in its form's `period_default`, because section 6452(a) of
  the California code makes the return quarterly for everybody and section
  6455(a) lets the Department direct otherwise — regulation 25(1) of the British
  VAT Regulations in another language — and `company_filing_periods` is where an
  American company's several cadences will be recorded once a pack can declare
  more than one form. The third, that a pack declares one form where a country
  files several, is that change's own note and not a new finding; what the
  United States adds to it is the shape of the missing form, which here is the
  **same** declaration fifty times over, under fifty bodies of law and in fifty
  territories, so the list of forms a pack will one day declare has to carry the
  territory each belongs to.

  Two things outside `packs/us/` moved with it, each in a commit of its own.
  `supabase/seed/00_territories.sql` gains a `US` row: `ekwo pack check` reads
  that table to decide whether the VATEX list reaches a pack, and a country with
  no row is held to the Union's, so an American exempt sale would have been
  refused for naming no code from a list that does not bind it. That makes a
  third place a pack of a third country is written, and
  [`docs/packs.md`](docs/packs.md) now says so in the walkthrough. And one
  assertion of `tests/pack_install.test.ts` was an unnamed country: it grouped
  every posting of every pack by country and by form with `order by 1`, and
  compared the result to a list it sorted by country **and** by form — which
  every pack until the sixth happened to satisfy. Both sides are now sorted by
  the same comparator, which removes an assumption rather than adding a case.

- **A price that already holds its tax.** `taxes.price_include` had been a
  column since the tax engine landed and was read by nothing: a line carrying
  such a tax was booked with the tax added *on top* of the price the customer
  had already paid, so a till roll of 5 493,92 became an invoice of 6 592,70.
  The engine now takes the tax out of the **gross of the tax group** — rounded
  once, at the decimals of the document's currency, as EN 16931 BR-CO-14
  requires and as VAT Notice 700 §§ 17.5 and 17.6 allow a retailer to do
  invoice by invoice — subtracts it so that `base + tax` is the price that was
  quoted to the unit, and shares that base back over the lines in proportion to
  their gross with the remainder on the last, which is the technique
  `post_document` already used for a non-deductible share. A discount applies
  to the gross, before the conversion. The line keeps the gross it was quoted
  at and a snapshot of the flag, frozen when the document is posted so a pack
  upgrade cannot rewrite an invoice that has been sent; `document_line_items`
  publishes both beside the base and `shared_document()` carries them into the
  payload behind a link, so a customer opening a retail invoice is no longer
  shown a gross unit price beside a net line amount with nothing saying which is
  which. Three refusals answer by name: a fixed-amount tax has no rate to divide by, a line
  whose price includes a tax has to name one, and a tax group cannot be half
  inclusive. `packs/gb/` bumps to **0.2.0**, on top of the 0.1.1 below — the
  same retail tax, its legal reference no longer describing a gap, and a golden
  document of three counter sales quoted gross, one of them after a discount,
  whose shares only add up because the last line takes the remainder. The four other packs do not move
  and their golden files are unchanged to the byte. The note in
  [`docs/international.md`](docs/international.md) is closed, the arithmetic is
  in [`docs/decisions.md`](docs/decisions.md), and two narrower gaps opened
  beside it: the choice HMRC gives a retailer between two rounding units, and
  BT-146, the net unit price, which nothing publishes where the price was quoted
  with the tax in it.

- **A tax posting names every box the form prints its amount in.** A tax still
  carries one `base` posting per kind of document — one taxable amount, one
  definition — and a second place the form shows it is still a `total` where
  that place is a sum. Where it is not, the posting names the boxes itself:
  `box` in `taxes.json` takes a string or a list of strings, `tax_postings` and
  `tax_posting_templates` carry `declaration_boxes text[]` beside the
  `declaration_box` it starts at, and `vat_return()` sums a line into every box
  its posting names. `ekwo pack check` refuses an empty list, a box named twice
  by one posting, and a box the form declares a total. Two forms that could not
  be written down before now can: form KMD reports an intra-Community
  acquisition in boxes 1, 6 and 6.1 at once, and the British VAT Return reports
  a service received from a supplier established abroad in box 6 and box 7.
  Nine `hidden` boxes that existed only to work around this are gone —
  `packs/ee` 1.4.0 loses six and `packs/gb` 0.3.0 loses three, and both move
  their `schema_min` to this migration — and not one figure of either golden
  scenario moved. A `hidden` box now means one thing: an intermediate total the
  form works out and does not print.

- **The United Kingdom, `packs/gb/`, and the first country outside the Union.**
  Every pack before it could lean on the VAT Directive, on the
  intra-Community mechanism and on the European code lists, and nobody knew how
  much of the format silently assumed them. This one carries an original chart
  of 190 accounts blocked onto the statutory formats, 25 taxes with the
  standard rate back to 1994 — 17.5 %, 15 % from 1 December 2008, 17.5 % again
  from 1 January 2010, 20 % from 4 January 2011, and the temporary hospitality
  rates beside them — the nine boxes of the VAT Return as they stand since
  1 January 2021, the balance sheet and the profit and loss account of the
  small companies regime (S.I. 2008/409, Schedule 1, Format 1), the usual lives
  of a fixed asset under FRS 102, and a golden year of fourteen documents on a
  year to 31 March. No tax is intra-Community on either side: what replaced
  them is postponed VAT accounting, the construction reverse charge of s. 55A
  and the reverse charge on services received from abroad of s. 8. Certification
  is `community`, 32 texts are in the register with every URL opened, and
  Northern Ireland, Making Tax Digital submission and the VAT schemes are out of
  scope and say so.
  Seven gaps in the core are written up in
  [`docs/international.md`](docs/international.md) and none of them was patched
  for the pack's sake — the first two were closed afterwards, on their own, and
  are under Fixed below:
  an exemption outside the Union has no VATEX code and one is required; `G` and
  `VATEX-EU-G` describe the Union's border and not a third country's; one
  taxable amount is printed in two boxes that are siblings rather than nested;
  `price_include` is declared and never computed, which is what a British retail
  price needs; a rounding rule belongs to a country where HMRC gives one to each
  kind of trader; a tax cannot depend on a territory, so the `territories` table
  can say what `XI` is and a pack still cannot carry its taxes, which is why
  Northern Ireland is absent; and a pack may propose a filing cadence only where
  its form accepts one, where the British law gives a default its form does not
  show.
- **Ten assertions of the test suite were an unnamed country.** Adding the
  first pack that is written in English, closes straight into retained earnings,
  files a nine-box return, sorts after Luxembourg by name and is not a Member
  State found ten places where `tests/` assumed something every pack until then
  happened to satisfy — a hard-coded list of two module seed files, a form with
  more than twenty boxes, a closing style out of two of the three the schema
  defines, a pack with at least one other language, a country `is_eu_member()`
  answers yes about, and the rest. None of them spelled a country code, so
  `npm run check:no-country-literals` never saw them. Each now reads the pack,
  the schema or the query it is asserting about, and no country was added to any
  list; the membership one became a stronger claim than it replaces, because a
  pack whose treatments are intra-Community has to be inside the common system
  and one whose treatments are not has to be outside it. The table is in
  [`docs/international.md`](docs/international.md).

- **The document rules of a country cite the article behind them.** How an
  invoice is numbered, the payment term the law sets in the absence of an
  agreement, when the tax falls due and which structured invoice is
  obligatory all arrived in the database as a word — `gapless_per_year`, `30`,
  `invoice_date`, `peppol-bis-3` — and a word looks the same whether somebody
  read the decree or guessed. `documents.references` now carries a
  `legal_reference` and a `source` per rule, three and not one because they are
  three articles of two or three different texts in every country the packs
  cover; `einvoicing.legal_reference`, which the format has accepted since the
  section existed and all four packs write, stopped being dropped by the
  compiler. Eight nullable columns on `country_defaults` hold the four pairs,
  beside the rule each belongs to. `ekwo pack check` refuses a declared rule
  that cites no article on a `reviewed` pack and warns about one on any other,
  and refuses a key the pack's register does not carry.
- **The core can say where the common system of VAT applies, and under which
  two letters.** `ec_sales_list()` shipped with two holes `docs/international.md`
  recorded: it could not tell a Member State from a third country — its only
  check was that the customer was not in the company's own — and it read a
  customer's VAT country off their ISO code, so a Greek customer recorded
  without a prefix was listed under `GR`, which every one of the four
  administrations refuses. Both are answered by `territories`, a reference
  table of the framework beside `currencies`: 49 rows seeded by
  `supabase/seed/00_territories.sql` — the 27 Member States with the day each
  became bound, the United Kingdom with the day it stopped being, Northern
  Ireland, and the territories articles 6 and 7 of Directive 2006/112/EC take
  out of the common system or put into it — each carrying the text it comes
  from. `territory_of()`, `is_eu_member(code, on)`, `eu_vat_scope_of(code, on)`
  and `vat_prefix_of()` read it; nothing branches on a code and adding a State
  is a row.
  The statement asks it **as at the entry date of the line**, so a period in
  2020 still reports supplies to the United Kingdom and one in 2021 does not,
  and a supply the system does not reach comes back as
  `vat_country_outside_the_union` instead of being filed. Northern Ireland is a
  row of its own with a parent and an `eu_vat_scope` of `goods`, not a flag on
  the United Kingdom: goods supplied there belong on the statement and services
  do not, which is `vat_country_outside_the_union_for_this_supply`. The columns
  are named for VAT rather than for membership because the two dates differ —
  the United Kingdom left the Union on 31 January 2020 and the common system on
  31 December 2020 — and the row says so. `vat_prefix` holds a difference and
  never a copy (`EL` for Greece, `FR` for Monaco, `GB` for the Isle of Man),
  which also fixed a defect no Belgian or French filer could have seen: the
  company's own country was compared raw, so a Greek company would never have
  caught a domestic supply listed as an intra-Community one. A database with
  the table and without the seed is refused by name, `no_territories`, rather
  than reporting every customer in the world as outside the Union. The four
  format bricks receive a prefix already resolved and did not change.
- **`intracom_triangular`.** The middle supply of a triangular arrangement —
  B's sale to C, relieved by article 141 of Directive 2006/112/EC and
  reverse-charged to C by article 197 — had no word in `tax_treatment`, so it
  was declared as ordinary goods although all four recapitulative statements
  print it as a category of its own. The value costs nothing else:
  `ec_sales_list()` derives the nature by taking `intracom_` off the treatment
  and returns `triangular` unchanged, and the four bricks, published before the
  value existed, already write `T` on the Belgian listing, the `TVA_LICT` form
  of the Luxembourg envelope and the `kolmnurktehing` column of the Estonian
  form VD — while the French DES says by name that a supply of goods belongs on
  another file. On the invoice it resolves to the **reverse-charge** mention
  and not to the intra-Union one: the supply is not exempt under article 138,
  it takes place where the goods arrive, and article 226(11a) requires the
  sentence saying the customer owes the tax. Its EN 16931 category is `K` with
  `VATEX-EU-IC`, not `AE`, which the guidance reserves for a reverse charge
  within one Member State. **No pack declares such a tax**: the path is proved
  on a fixture rather than on a country, because an invented tax in `packs/` is
  a rule nobody can review.

- **A conflict marker cannot be committed.** `npm run check:no-conflict-markers`
  reads every file git tracks and refuses the four lines a merge leaves behind:
  the opening marker, the separator, the closing marker and the fourth one
  naming the common ancestor that the `diff3` and `zdiff3` styles write. It
  runs in the CI's *hygiene* job. Two `|||||||` lines had sat in this file for
  a day: they cost nothing at runtime, which is why nothing noticed — no test
  reads the changelog and no build parses it — and prose is where a conflict is
  most likely, because a changelog and a design note are what every branch
  appends to. Only tracked files are read, so a marker in a working copy is a
  merge somebody is in the middle of rather than a fault, and the separator is
  matched whole so a Markdown heading underlined with `=` is not caught.
  `tests/conflict_markers.test.ts` builds a throwaway git repository, puts the
  four markers in a file it tracks and reads the refusal back, so the guard is
  itself run against something faulty rather than only against a clean tree.

### Changed

- **`status`, `doctor`, `pack status` and `pack upgrade --json` put their report
  under `data`.** They printed it bare; the document around it is what lets a
  caller read any command the same way. `pack --json` was accepted by
  `pack build`, `check` and `list` and ignored: they answer now.
- **Wrong arguments to `ekwo init` end on 2, not 1**, as does a missing
  `--email` for `ekwo register` and `ekwo module` or `ekwo pack` with no
  subcommand, whose usage now goes to the standard error.
- **`socleCode()` moved from `@ekwo-ai/mcp` to `@ekwo-ai/core`**, with
  `isRefusalState()`, so the CLI and the MCP server read a refusal in one
  place. The MCP server still exports it. `ekwo` now depends on
  `@ekwo-ai/core`; outside this repository its one dependency is still the
  Postgres driver.

- **`auto_settle()` no longer stops on a line it cannot book.** A refusal from
  `settle_from_statement()` — an open item naming nobody, for instance — used to
  propagate out of the pass, rolling back everything it had already settled and
  reporting nothing at all. It is now caught, reported against the line it
  belongs to in the database's own words, and the walk goes on. A pass over a
  month of statements is exactly where one line must not be able to silence the
  other forty.

### Fixed

- **Row level security cost nine to forty-five times the query it guarded —
  found by `tests/load/`.** Every table of a company carried `using
  (has_capability(company_id, '…'))`, and `has_capability()` being `stable` was
  read, here and on the roadmap, as "evaluated once per query". It is not what
  the word means: Postgres may assume the answer holds within a statement, and
  does not remember it. With a column as its argument the function ran once per
  row visited — 359 000 times for one trial balance over 10 000 documents,
  3 266 ms as a member against 72 ms as the owner, **on identical plans**, which
  is why no plan would ever have shown it. `20260918141627` adds
  `companies_with_capability(capability)`, which lists the companies the caller
  may do a thing in by asking `has_capability()` about each — one definition of
  who may do what, not two — and rewrites the fifty-two policies of that shape
  to `company_id = any ((select companies_with_capability('…'))::uuid[])`, a
  sub-select Postgres evaluates once per statement. The same trial balance as a
  member: 18 ms. `tests/capabilities.test.ts` and `tests/api_keys.test.ts`
  compare the two functions over every preset, every capability, a grant, a
  revoke and a machine key; `tests/rls.test.ts` refuses a new policy of the old
  shape; `tests/load/` bounds how often a hot path asks.

- **`suggest_contacts()` scored every contact of the company for every
  statement line.** For each of them it entered `significant_words()` — a SQL
  function Postgres cannot inline — and intersected arrays up to three times,
  to conclude for all but a handful that the names share no word. A month of
  statement against 500 contacts: 3.5 s. `20260918143352` stores the words of a
  name in `contacts.name_words`, a generated column, and sets those contacts
  aside with one array operator before anything is scored: 0.24 s, and the 974
  suggestions of that month identical to the last character. No GIN index: it
  was tried, the planner used it, and it bought a tenth.

- **Two `SECURITY DEFINER` functions checked nobody — found by the sweep
  above.** `catch_up_journal_sequence()` trusted that `post_entry()` had checked
  its caller, and was executable on its own: anybody signed in, member of the
  company or not, could advance the counter of a journal they knew the id of to
  any number of the right shape, which is a hole in a numbering the law of
  several countries forbids holes in. It now asks what `next_entry_number()`
  asks — the installer, or `entries.post` on the company of the journal.
  `touch_api_key()`, only ever meant to be called by `use_api_key()`, held the
  default EXECUTE of the schema and stamped `last_used_at` on any key: it is
  revoked from `authenticated`, and the definer that calls it still can.
  Migration `20260918114322`.

- **`@ekwo-ai/vat-consignment` 0.2.0 — the schema was read, and it disagreed four
  times.** The first version was written from a production filing, and its
  README said the XSD had not been read. It now validates every shape of file it
  writes against `NewTVA-in_v0_9.xsd` in its own tests (`xmllint-wasm`, a
  development dependency: no network, no system tool, and the package still
  ships with none), and reading it found:

  - `Data` is **required, with at least one `Amount`** — a nil return wrote
    neither and was invalid. It now says the one thing it has to say, that
    nothing is owed, on grid 71;
  - `ClientListingNihil` is **required** — it was left out unless asked for. It
    is always written, `NO` by default: the absence of a claim;
  - every amount is a **`PositiveAmount_Type`** — a negative figure went straight
    into the file. It is now the violation `negative_amount`, because this form
    keeps what reduces a figure on a grid of its own;
  - the grids are a **closed enumeration** — any two digits were accepted. `GRIDS`
    is the schema's list, compared with the schema file number for number.

  Also new: `replacedDeclaration`, which writes `ReplacedVATDeclaration` so a
  corrective says what it replaces, and two fields left out with a violation
  rather than written invalid — a reference over fourteen characters, a
  telephone number over twenty digits.

- **The tax point stopped being a word nobody read, and three packs stopped
  declaring a derogation as if it were their principle.**
  `country_defaults.tax_point_rule` held one of three words, no function read
  it, and `post_document()` dated a tax by the day the entry was booked on — a
  different question. Belgium, Luxembourg and the United Kingdom all declared
  `invoice_date` where the law puts the fait générateur at the supply and lets
  an invoice displace it (art. 16 and 22 against art. 17 and 22bis, art. 21
  against art. 24 par. 1er, VATA 1994 s. 6(2)–(3) against s. 6(4)–(5)), and
  Estonia declared `delivery_date` where KMS § 11 lg 1 keeps whichever of a
  supply and a payment came first. The vocabulary gains `invoice_if_issued` and
  `earliest_of_delivery_or_payment`, each text was read before the word was
  chosen, and `tax_point_of()` is the column's only reader.
  `documents.tax_point_date` — EN 16931's BT-7, which the table lacked, and
  which a document may state for itself — and `entry_lines.tax_point_date`
  carry the answer; `post_document()` and `settle_cash_basis_tax()` write them
  and `vat_return()` files a figure by the day its tax fell due rather than the
  day its entry was booked. Null keeps the entry's date, so no ledger and no
  golden scenario moves. France was read and left as it stands: goods on the
  supply, services on `taxes.cash_basis`, which is CGI art. 269 exactly.
- **A chart, a statement and a statement line can be traced to the text they
  come from.** `source_key` on `chart_templates`, `statement_templates` and
  `statement_line_templates`, compiled from the pack like the register added it
  to the taxes and the declaration boxes in 0.3.0. Until now a `legal_reference`
  reached the database with no way to open the law behind it.
- **`supabase/migrations/README.md` lists every migration again.** Twenty-one
  rows were missing, the whole tail of the 0.3.0 cycle and two older ones; the
  table is the only index of what the schema is made of.
- **A format library runs its own tests again.** Each package under
  `packages/formats/` is MIT, depends on nothing here, and is meant to be read
  and run outside this repository — but `npm test` in one of their directories
  found the root vitest configuration, whose patterns are written from the
  repository root and match nothing from inside a package. Vitest exited
  non-zero having run no test at all, which is how the `prepublishOnly` of
  `@ekwo-ai/factur-x` and `@ekwo-ai/xbrl-cbso` came to refuse both of them:
  `npm publish` on either would have failed on the way out. Every brick now
  carries a three-line vitest configuration of its own, and
  `tests/formats.test.ts` refuses a brick without one.

- **An exemption reason code was demanded of a country the list does not
  reach.** `ekwo pack check` required BT-121 as soon as a tax's `vat_category`
  was `E`, `G`, `O`, `AE` or `K`, and checked it against the VATEX list of
  EN 16931 — which is the Union's list: its own codes name articles of
  Directive 2006/112/EC and its national codes belong to Member States that
  publish them. A country outside the common system of VAT has no code there
  and no administration with any reason to publish one, so the first pack of
  such a country had to invent `VATEX-GB-SCH9` and borrow three Union codes to
  get past the check. The last column of the correspondence table now applies
  only where the Union's VAT applies: there, an `exemption_code` stays null,
  the article goes in `legal_reference`, a `VATEX-*` code is refused by name,
  and the five `intracom_*` treatments are refused outright. A reason code from
  some other published list is accepted where the pack's register declares that
  list with `kind: standard` — the field provided for, the content left to
  whoever publishes one. The EN 16931 categories are untouched, because
  UNCL5305 is a UN/CEFACT list; the description of `G` was corrected with it,
  from the Union's border to the border of whoever levies the tax, which is
  what UNCL5305 says and what makes a British export `G`. Which side of the
  line a pack is on is read from `territories` — the `eu_vat_scope` of its
  country at the manifest's `released_at` — and no country is written into the
  code: `pack check` has no database, so it parses
  `supabase/seed/00_territories.sql`, the file the database is seeded from, and
  a test holds its answer against `eu_vat_scope_of()` for every territory on
  every date the table carries. A country the table has no row for is held to
  the table as published, because a missing row is silence and not a no. No
  migration, no schema change: the rule is in the CLI and the two gaps it
  closes are marked closed in `docs/international.md`.
- **`packs/gb/` 0.1.1** drops `VATEX-GB-SCH9` and the three Union codes it had
  borrowed from seven taxes, keeps every `legal_reference` — Schedule 9 to the
  Value Added Tax Act 1994, s. 30(6) for the export, s. 55A for the
  construction reverse charge — and loses the two review points its README
  opened on. Nothing is computed from an exemption reason code, so the golden
  expectations are byte for byte what they were.

- **A VAT category came back padded with a space.** `taxes.vat_category`,
  `tax_templates.vat_category` and `document_lines.vat_category` were
  `char(2)`, and `char(n)` pads to width on write; every category of EN 16931
  but `AE` is one character, so the database answered `S `, `K `, `E `, and had
  done since the columns were created. `document_line_items` and
  `document_tax_summary` published that as BT-151, and `shared_document()`
  reads both views — so a renderer writing it straight into an invoice emitted
  one that fails validation, a reader comparing it to `'S'` found nothing, and
  the padded code reached whoever held the link to a shared document. The three
  columns are now `text`, under a check constraint that accepts one or two
  capitals, so the column refuses what it used to manufacture; the existing
  values are trimmed by the conversion and a column holding nothing but padding
  becomes the null it always meant. The two views were dropped and recreated
  unchanged but for existing, with the same columns in the same order, the same
  `security_invoker`, the same comments and the same grants. No pack moved: a
  pack never wrote the space, the column added it, so every golden figure and
  every compiled seed is identical.

- **A document was reprinted in a language it was never sent in.** The language
  of an invoice was re-derived on every read — the customer's, else the
  company's, else the one the country pack declares — so a customer who
  switched language rewrote every invoice ever addressed to them, legal
  mentions included. That is wrong on the one part of a document a country
  actually legislates. `documents.language` records it: filled from that same
  chain when the document is created, kept in step while it is a draft, and
  frozen the moment it is posted, which is what `document_lines.vat_category`
  and `vat_rate` already are and for the same reason. A posted document that
  somebody tries to move refuses by name, `document_language_frozen`; the
  documents already in the database were filled from the chain once, in the
  migration, which is the best that can be said of a document already sent.
  `preferred_languages(language, company)` is the chain from a starting point
  the caller names, and `preferred_languages(company)` is now one line on top
  of it that supplies the signed-in reader's preference — so the reader of a
  shared link, who has no session at all, reaches the published chain instead
  of a second copy of it written inside `shared_document()`.
  `document_legal_mentions` answers in the document's language and publishes
  which one it used; `document_header` carries it too. `anon` gains nothing:
  the overload is granted to `authenticated` and `service_role`, and the public
  door is still one `security definer` function. No pack moved — every golden
  figure and every compiled seed is identical.

### Security

- **An entry is posted by `post_entry()`, and a document by `post_document()`.**
  The guards below froze what is posted and left the way in alone. A member
  holding `entries.post` could `update entries set state = 'posted', number =
  'HAND/1'` on a balanced draft: a number chosen by hand where the law forbids
  a hole in the sequence, no `posted_at`, no financial year, no line required,
  the period asked the weaker question — then frozen for good. A document could
  be flipped to `posted` on a posted entry that was not its own.
  `20260918171946` holds the transition to what the functions produce, read on
  the row and in the counter: `entry_posted_by_hand` unless the entry has an
  instant it was posted at, no year but its own, a line, an open period and —
  where numbering is gapless and the caller does not hold `entries.import` —
  the number its journal's counter has just delivered;
  `document_posted_by_hand` unless the entry was built for this document, on
  its day, and gave it its number. Judged on facts and not on a flag, because a
  session can set a flag. `post_entry()`, its seven callers, the modules, the
  rehearsal and the import are unchanged.

- **A posted entry is immutable, in an open period too.** The schema said so
  everywhere — the audit trail records the posting and not the lines "because a
  posted entry is immutable" — and enforced it in a locked period only. In an
  open one a member holding `entries.write` could delete the lines of a posted
  entry, delete the entry, or set it back to `draft`, and no trace was kept.
  `20260918161538` closes it like the document below: once an entry has left
  `draft` it is not deleted, its state does not change, and nothing moves but
  `matching_number` and `matched_amount` on its lines, which is what the
  matching writes. `entry_posted`, SQLSTATE `55006`, nobody exempt; nobody
  inserts an entry that is already posted either (`entry_born_posted`): one
  arrives only with a company loaded by `import_company()`.
  Every path that writes an entry was read first — they all insert a draft and
  call `post_entry()`, and where the schema undoes one it already does so by a
  mirror naming it in `reversed_entry_id` — so no function had to change to
  keep working. **A posted entry is undone by a reversal**; the path is tested
  as the accountant, and `reverse_entry()` is the function still missing.

- **A posted document is immutable, by the database.** It was by convention. A
  member holding `documents.write` — the `accountant` preset — could, in an open
  period, rewrite any column of any line of an issued invoice, add a line or
  delete one and watch its totals follow while the ledger kept the old figure;
  rewrite its totals, number, dates, customer and currency; unhook it from its
  entry; send it back to `draft` and post it a second time; mark it `cancelled`
  with nothing reversed; or delete it. The period locks only ever guarded the
  ledger.

  `20260918161204` closes it in the shape `tax_filing_boxes_are_frozen` has:
  once the state has left `draft` nothing moves but a closed list —
  `amount_paid` (to the figure the matching gives and no other,
  `document_amount_paid()`: judged by value, not by path), `payment_state`,
  `sent_at`, `peppol_status`, `peppol_message_id` — no line is added, changed
  or removed, the state does not change, the row is not deleted, and a document
  holds the entry it produced. Refused by name — `document_posted`,
  `document_posted_without_entry`, `document_amount_paid_is_derived`,
  `document_payment_state_is_derived`, `document_born_posted` — with SQLSTATE
  `55006`, so `ekwo` exits 3 and the MCP server explains it. A column added
  later is frozen the day it is added, and the test — every column of the
  catalogue, from an accountant, the owner and a machine key — tries it that
  day. Nobody is exempt and no function had to change for it:
  `post_document()`, the matching, a pack upgrade and the closing of a year
  pass for what they write and when. The guards are `security definer`: asked
  under the caller's row level security, "is the company still there?" was
  answered *no row* to a machine key, and that let a key delete what an owner
  could not.

  **Nobody inserts a document that is already posted** (`document_born_posted`),
  the installer and an administrator of the instance included: one arrives that
  way only with a company loaded by `import_company()`, which switches the
  guards off by name for the time of the load — they are back on afterwards,
  after a failure too, and what arrived is frozen like the rest, with the line
  it was posted with even where the tax has moved since. A document becomes
  posted only with an entry that is itself posted, and the totals of a posted
  document are no longer recomputed from its lines. **An issued invoice is
  corrected by a credit note** naming it in `reversed_document_id`, posted by
  `post_document()` and matched against it; the path is tested as the
  accountant. **An application that edited a posted document in place will now
  be refused**, and a migration that must restate posted rows has to disable
  the guard by name in its own file. `document_line_tax_frozen` is folded into
  `document_posted`. Found on the way and not closed here: a machine key cannot
  write a document line at all. `docs/decisions.md` has what went through, the
  closed list with its reasons, and the exemption that was written and then
  withdrawn.

- **A session nobody prepared is not the installer.** `is_installer()` answered
  NULL — not false — on a connection where `ekwo.installing` had never been
  set, and a guard written `if not is_installer() and not has_capability(…)`
  does not raise on NULL. The caller with neither a session nor a key, which is
  what `service_role` is through PostgREST, walked through `create_company()`,
  the journal counters, the API keys and the module switches. A person was
  never affected: a session carries a `sub` and `has_capability()` answers it.
  The function now says false. The harness had always set the variable, so no
  test could see it; `tests/fresh_session.test.ts` reloads the database into an
  instance where nothing was set and asks every argument-less boolean helper
  the same question.

## [0.3.0] — 2026-09-15

### Added

- **The sources of a pack become a register somebody can open.**
  `legal_reference` said which article a rule claimed and never where to read
  it, and `certification.sources` was a list of bare titles: a reviewer holding
  *Arrêté royal n° 20, tableau A* had a citation and a search engine. It is now
  a register — a key, a title, the official publisher, an absolute `https` URL
  and the day somebody opened it, out of a closed vocabulary of six kinds
  (`law`, `regulation`, `form`, `standard`, `portal`, `guidance`) — and every
  tax, box, chart, statement, statement line, legal mention and fixed-asset
  rule names a key beside the article it already carried. The article stays on
  the rule and the link stays in the register, so a publisher that reorganises
  its site is one line of a pack to change. No pack copies a word of the law:
  a quotation ages without anybody noticing.
  The four packs carry 53 texts between them, every URL opened on 15 September
  2026, and 462 rules point at one — including all 110 taxes and all 243 boxes.
  `ekwo pack check` refuses a duplicate key, a key the register does not
  carry, an entry that is not shaped like one, a non-`community` pack whose
  register is empty, and — on a `reviewed` pack — a tax or a box that names no
  source, which is the substance of a review; a `maintained` pack is warned
  instead. The bare string is still read so that a pack written before this
  compiles, and is warned about as deprecated.
  `ekwo pack check --links` opens every URL and names the ones that went
  quiet. It is opt-in, the CI never runs it, and it never changes the exit
  code: Légifrance refuses a request with no browser behind it, and a gate on
  that would fail a contributor's pull request for something nobody in it did.
  The register compiles into `country_packs.sources`, the key travels with the
  rule in `tax_templates.source_key` and `tax_report_box_templates.source_key`,
  and the MCP tool `describe_pack` returns all of it, so an application can
  answer "where do these rules come from" without reading a pack. The
  walkthrough in `docs/packs.md` now starts at step 0: open the consolidated
  text, the decree, the form with its notice and the filing portal, and write
  them down before a line of JSON.
  No figure moved. The three golden expectation files of every pack are
  byte-for-byte what they were.

- **A treatment for a service bought from a supplier who is not established
  here, and a check that a tax's three code lists agree.**
  `tax_treatment` gains `foreign_services_received`: the general
  business-to-business rule of articles 44 and 196 of Directive 2006/112/EC,
  which the vocabulary had no word for — `intracom_acquisition_services`
  covers a supplier in another Member State and `import` is goods declared to
  customs, so the Estonian pack had been declaring such a tax as an import and
  saying so in its own legal reference. The name is about establishment rather
  than about the border, which is why it is not `import_services`. It resolves
  to the reverse-charge mention on an invoice, and `EE-P-VS-24` now carries
  it.
  `ekwo pack check` gains the correspondence between `treatment`, the EN 16931
  category (BT-118, BT-151) and the VATEX reason (BT-121), transcribed from
  UNCL5305, from the Commission's *Technical guidance for tax codes in
  EN 16931* version 1 and from the pairings the VATEX list publishes on its
  own codes. Neither of those two columns is read by the ledger or by the
  declaration, so nothing had ever compared them to anything: a pack could
  declare an export at the standard rate and the whole suite passed. Twenty
  taxes across the four packs were corrected — the intra-Community supplies
  and acquisitions carried the reverse-charge pair where the supplier's
  invoice carries `K` and `VATEX-EU-IC`, and the imports of goods claimed a
  standard rate no supplier had levied. `docs/packs.md` carries the table and
  the two decisions behind it.

- **A document can be sent to the person it is addressed to, behind a link they
  open without an account.**
  `document_shares` holds a link onto one sales document; `share_document()`
  creates one and returns its token once; `revoke_share()` stops it, for good;
  and `shared_document(token)` — the one function `anon` may execute that is not
  a policy helper — returns that document as jsonb: the header, the lines, the
  VAT breakdown, the totals, the legal mentions in the document's own language,
  the seller's identity and payment details, and what is still owed today with
  the date of the last payment, so a link a customer keeps stays worth opening
  after they have paid.
  The token is the whole secret: 32 bytes as 43 base64url characters, stored
  only as a sha256, returned by the call that creates it and by nothing else.
  It is drawn from two `gen_random_uuid()` rather than `gen_random_bytes(32)`,
  because `pgcrypto` is not available under PGlite and an invariant that cannot
  be tested is an invariant nobody is keeping.
  `anon` holds no privilege on `document_shares` or on any view: the invariant
  of `20260911210131` is kept, not bent. An unknown token, a withdrawn link, an
  expired link and a document that may no longer be shared all answer with the
  same null, so the function is an oracle for nothing. Sales documents only —
  a purchase invoice is a third party's own document — never a draft, never a
  cancelled one.
  A new capability, `documents.share`, on the owner and accountant presets;
  `instance.public_base_url`, nullable and with no default, which the returned
  `url` is built on; `share_document`, `revoke_share` and `list_shares` as MCP
  tools, and `shared_document` deliberately not one; and the count of live
  links per company in `ekwo status`. [`docs/sharing.md`](docs/sharing.md) is
  the reference and `docs/decisions.md` carries the reasoning.

- **The recapitulative statement of intra-Community supplies, as one function
  of the core and four format bricks.**
  Every Member State asks a seller the same question — to whom, in another
  Member State, did you supply goods and services without charging VAT, and for
  how much — and then wants the answer in a file of its own shape. Nothing here
  could answer it: the boxes of the return hold the totals and not the
  customers, and a listing per customer cannot be read back out of them.
  **`ec_sales_list(company, from, to)`** returns one line per customer VAT
  number and per nature of supply, summed from the posted ledger in the
  company's currency with credit notes deducted. The nature comes from the
  treatment of the tax with its `intracom_` prefix removed, so the day that
  vocabulary gains the triangular operation all four forms print, the function
  returns it without a line changing. A supply that cannot be declared — a
  customer with no VAT number, a number that is not in another Member State —
  comes back with the reason in `issue` rather than being dropped, because a
  file that balances against nothing is worse than a file with a hole in it.
  It is exposed as an MCP tool beside `vat_return`, and the prompt that prepares
  a return now asks for it.
  **It refuses no period**, where `vat_return()` refuses one the company does
  not file on. `companies.vat_period` records how often the *return* is filed,
  and the statement has its own cadence in three of the four countries read
  while writing this — that gap, and four more, are written down in
  `docs/international.md` rather than patched.
  **The files are four MIT bricks**, each written only from a specification
  that could be read and each citing it: `@ekwo-ai/intra-consignment` for the
  Belgian listing of Intervat, `@ekwo-ai/des` for the French déclaration
  européenne de services, `@ekwo-ai/ecdf` for the Luxembourg interface file and
  its four statement forms, `@ekwo-ai/vd` for the Estonian form VD. They agree
  on almost nothing — one line per nature against one line per customer, a
  country field apart from the number against the two joined, cents against
  whole euros — which is what organising by format and never by country is for.
  The French état récapitulatif TVA on goods is **not** among them: its XML is
  the INSTAT envelope, whose habilitation number and statistical fields a set of
  books does not hold, and `packages/formats/des/README.md` says so with the
  documents a successor would start from.
  Each pack's golden scenario gained the supply of services it was missing, and
  the Belgian one a credit note on an intra-Community supply — the document that
  proves the listing and the return do not read alike, since Belgium reports
  that credit note positively in a box of its own and the statement deducts it
  from the customer.

- **A company opens on the part of its chart it actually works with.**
  A country pack is a transcription of the regulation — 120 accounts in
  Estonia, 353 in Belgium, 394 in France, 1 026 in Luxembourg — and a company
  uses a fraction of it: two production installations measured on a full year
  of books used 60 accounts out of roughly 300 and 126 out of roughly 300.
  Nothing about the packs changes; a second question is added beside the chart.
  **`accounts_in_use(company, from, to)`** (migration `20260914143915`) returns
  the accounts a company is working with: those carrying a line of a posted
  entry — in the period when one is given, ever when none is — those its
  configuration points at by foreign key (the role defaults, a contact
  override, a journal, a tax posting, the transition account of a cash-basis
  tax, a bank account, a product), those a module it has enabled holds, and
  those somebody pinned; minus the deprecated ones. A configuration reference
  is not dated; only the movement is.
  **`accounts.pinned`** is the column an operator edits to add an account the
  rules cannot know about, or to keep one that has stopped being referenced.
  `install_country_template()` now pins what it wires — eleven accounts on
  Belgium, Estonia and Luxembourg, fifteen on France: the roles of the country
  model, the accounts of its financial journals and the accounts its taxes
  post to. A country model names about a dozen accounts whatever the size of
  its chart. Pinning is display and never a restriction: any account of the
  chart that is not deprecated may still be booked on.
  **The socle still ignores its modules.** It does not name `assets` or
  `budgets`: it asks each module the company has enabled for
  `<schema>.accounts_in_use(uuid)`, the convention `disable_module()` already
  reads for `can_disable`. A module that references no account writes no such
  function.
  **`list_accounts` starts from that set**, says which scope it answered with,
  and takes `include_all` for the whole chart, `include_deprecated` for the
  whole chart with the retired accounts, and `in_use_from` / `in_use_to` to
  narrow the movements to a period. **`pin_accounts`** pins or unpins by code.
  The `ekwo://companies/{id}/chart` resource is unchanged and still carries
  everything.

- **How often a company files its VAT return is data, and the return reads it.**
  `vat_return()` takes two dates, which is right, but nothing held how often
  the company files at all, so a quarterly filer could be handed a July return
  and nothing said so. Three columns, each where the answer belongs:
  **`tax_report_templates.periods`** is what the form accepts — a list, because
  one set of boxes may be filed on more than one cadence;
  **`companies.vat_period`** is what this company files, nullable and with no
  default; **`country_defaults.vat_period_default`** is what the pack proposes.
  The vocabulary is an enum, `month | quarter | year`, and
  `month_or_quarter` — never a cadence anybody files on — is read as the two it
  names, so a pack written before the list keeps working.
  **`vat_return()` refuses a period the company does not file on**, by name,
  and only when the refusal is certain: the form offers the recorded cadence,
  the dates are themselves a whole cadence of that form, and the two differ. A
  fortnight, a half-year and the annual form a quarterly filer also files go
  through, because the function is a control query as often as a filing.
  **`ekwo init` asks** when the country's form offers several and the pack
  proposes none, `--vat-period` answers outside a terminal, and a company that
  has not decided is recorded as not having decided. **`ekwo status` prints
  it.** **Estonia is the only pack here that proposes a cadence** — the
  taxable period is the calendar month for everybody, käibemaksuseadus § 27
  lõige 1. Belgium, France and Luxembourg all make it follow turnover, so each
  cites the article that says so on its form and leaves the proposal empty.
  Migration `20260914163943`; packs `be` 1.6.0, `fr` 1.7.0, `lu` 1.1.0,
  `ee` 1.1.0 — one bump each, covering this and the `seed_sequence` field the
  Estonian pack added to the three manifests without bumping them.

- **Luxembourg, as `packs/lu/`.** The third country pack, and the first
  contributed from published sources rather than from books somebody keeps.
  It carries the **plan comptable normalisé** of the *règlement grand-ducal du
  12 septembre 2019* whole — **1 026 accounts, 747 of them postable**, the
  depth the regulation prescribes, because Luxembourg publishes no abridged
  chart: what it abridges for a small company is the presentation.
  **35 taxes**: the four rates of article 39 — 17 %, 14 %, 8 %, 3 % — with the
  **temporary 2023 rates beside them**, 16 %, 13 % and 7 %, each with its own
  validity, so a document dated in 2023 books at the rate of its own year and
  lands in the boxes the form keeps for it. Intra-Union supplies and
  acquisitions of goods and of services, export, exemption under article 44 and
  the domestic reverse charge on both sides.
  **The eCDF periodic VAT return**, `LU-VAT-PERIODIC`, with the **156 numbered
  fields** of its four sections and the totals its own validation rules state.
  The monthly form and the quarterly form carry the same numbering, so one
  definition covers both.
  **The two abridged schemes of annual accounts**, `LU-ECDF-BS-ABR` and
  `LU-ECDF-PL-ABR`, whose **line codes are the eCDF field identifiers** — `203`,
  `651` — so a future filing brick maps a line to a field without a table in
  between. All 747 postable accounts reach exactly one line, by the State's own
  *tableau de passage*, transcribed account by account.
  **French, German and English**, all three complete, and the German and the
  English are the versions the State itself publishes on the eCDF forms rather
  than a translation made here.
  A golden year of ten documents and three payments, `certification.status`
  **`community`**, and a pack README that ends on the ten points a Luxembourg
  reviewer should look at first. Out of scope in v1 and said so: the XML of an
  eCDF deposit, the FAIA audit file, the annual VAT return, the franchise and
  group regimes, and corporate income tax.
- **Estonia, as `packs/ee/`, a pack written from the outside in.**
  **`packs/ee/`** carries an original chart of 120 accounts, 29 taxes, form KMD
  and the two statements of the annual report, and it compiles to
  `supabase/seed/11_pack_ee.sql`. Nothing in the core changed for it: no
  migration, no function, no column, and `tests/golden.test.ts` replayed its
  fourteen documents without knowing that Estonia exists.
  **The rate history is in the pack, because a code is a rate at a date.** The
  standard rate is there three times — 20 % to the end of 2023, 22 % to 30 June
  2025, 24 % since — so a document dated in 2024 books at the rate of 2024 and
  a credit note correcting it lands in the box today's form keeps for it. The
  24 % carries no end date: the reversion to 22 % in 2029 was enacted and then
  repealed with the Act that carried it.
  **The chart is written, not copied.** Estonia prescribes none, so this one
  follows the convention Estonian practice shares — four digits, four classes,
  equity inside class 2 — and is blocked so that each range of codes maps onto
  one line of the statutory balance sheet or income statement.
  **Form KMD nests, and the pack says how it handled that.** A tax reports its
  base to one box; the form asks for the same amount in a box, in the memo box
  inside it, and sometimes in a third. The pack posts to the innermost box and
  rebuilds every printed parent as a total, which takes six boxes the form does
  not print, all marked `hidden`. `packs/ee/README.md` lists them.
  **Status `community`**, and it stays there until an Estonian accountant has
  read it and put their name in the manifest. Every rate, box and mention cites
  its article; six things the core could not express are recorded in
  [`docs/international.md`](docs/international.md) with a proposed fix, and none
  of them was patched into the core for one country.
- **A pack declares the number its compiled seed carries, and a published
  number never changes.**
  It was the pack's rank in the alphabetical list of slugs, so inserting a
  country in the middle of the alphabet renamed the seed of every country after
  it — a release renaming a file that installations already hold. **`seed_sequence`
  is now a required field of the manifest**: Belgium 10, France 11, Luxembourg
  12, Estonia 13, and nothing sorts anything. `ekwo pack check` refuses a pack
  that declares no number and `ekwo pack build` refuses two packs claiming one.
  The three published seeds keep their names; each gains one changed line, the
  checksum of a manifest that now carries the field.

- **`ekwo doctor` compares the database to an inventory of what the release
  defines.**
  The check knew how to say that a table had no policy; it could not say that a
  table was gone. **`packages/cli/assets/expected-objects.json`** is now the
  list of everything a release defines — tables and their columns, views,
  functions with their signature, policies, triggers and types, per schema —
  and it is **generated from the migrations** by
  `scripts/generate-expected-objects.mjs`, exactly as `docs/schema.md` is, never
  kept by hand. It ships inside the package, so `npx ekwo doctor` carries it,
  and two CI jobs hold it there: one regenerates it and fails on a difference,
  one diffs the shipped copy against the repository's.
  **Missing, extra and a policy are three different answers.** Missing means the
  installation is behind or damaged, and fails. Extra means the operator added
  their own object, and is reported as information. A policy missing *or* added
  on a table of this schema fails either way round, because row level security
  is the security model. A column whose type has moved is reported as changed.
  `ekwo doctor` still exits `1` on a problem and `0` on everything else, so it
  stays usable as a deployment gate.
  **A module is required of a database that carries it**, and a module whose
  migrations never ran is named and skipped. **A database older than the CLI is
  compared anyway**, and the report says which version each side is at.
  `--json` carries the whole comparison, section by section. `npm run inventory`
  regenerates the file in a checkout.

- **A golden year of books per country pack, and a legal source on every tax
  and every box.**
  A pack could describe a country but could not be wrong in a way anyone would
  notice: a tax that posts to the wrong grid and a grid that expects the wrong
  postings agree with each other, the seed compiles and the return is wrong.
  **`packs/<cc>/golden/`** is the second opinion — `scenario.json`, ten
  documents at least of one financial year with the payments that settle some
  of them, and beside it three generated files holding what the engine makes of
  them to the cent: `vat_return.json` period by period, `statements.json` line
  by line, `trial_balance.json` account by account.
  **One runner, and no country inside it.** `tests/golden.test.ts` reads
  `packs/`, installs a company on each pack from what that pack's own scenario
  declares, replays it through `post_document`, `post_payment` and `reconcile`,
  and compares. What it demands of a scenario it demands of the pack: a tax due
  on collection is required of a scenario whose pack has one, and of no other.
  `UPDATE_GOLDEN=1 npm test -- tests/golden.test.ts` rewrites the three
  expectation files and never the scenario.
  **A pack without a golden is refused** — by `readPack`, so by `ekwo pack
  check` and by the CI. A pack that cannot have one says why in its manifest,
  under `"golden": { "exempt": "…" }`, and the commands print the sentence.
  `packs/generic` is the only exemption here: a framework has no chart, no
  journal, no tax and no currency, so no company can be installed on it.
  **`legal_reference` is now required on every tax and on every box of a
  declaration**, and the thirty-one Belgian grids and twenty-two French lines
  carry theirs. A golden proves internal coherence and never legal truth, which
  is exactly why the source and `certification.status` have to carry the rest.
  **`.github/CODEOWNERS`** names an owner per pack.
  The first run found two things in the French pack, reported rather than
  patched away: line 01 of the CA3 can come out negative when a quarter's
  credit notes exceed its sales, and line 08 does not tie to itself on an
  intra-Union acquisition, whose base goes to line 03 and whose tax goes to
  line 08. Both are in [`docs/decisions.md`](docs/decisions.md).
  Belgium moves to 1.5.1, France to 1.6.1 and the generic framework to 1.1.1:
  a legal source is a patch.

- **An end-to-end test: the same release installed two ways, and a whole
  financial year played out.**
  `npx ekwo init` and `supabase db push` + `psql -f` have always been
  documented as interchangeable, and nothing checked it. `tests/e2e/` now
  installs the release both ways into two databases and compares the migration
  history, every column of every table, the body of every function and every
  row of every table the seeds write, rendered and sorted. The second path
  imports nothing from the CLI, so what is compared is two installers rather
  than one installer twice.
  **It found one difference, in the documentation rather than the code.** The
  by-hand instructions in the README named two seed files of the four
  `config.toml` lists, so an installation made that way came up with a chart of
  accounts and no generic financial statements, and nothing failed until
  somebody asked for a balance sheet. The README is corrected and a test reads
  it: every seed file the installer applies must be named there. On every byte
  of reference data, the two paths agree.
  **Then the year.** A company installed from the frozen 1.0.0 seeds is brought
  to this release, its pack upgraded through `ekwo pack upgrade`, and carried
  through the opening balance, a sale, a purchase, the VAT return, both
  financial statements, the close, the re-opening and the close again — once
  per country the frozen seeds carry, naming none of them: the accounts, the
  journals, the tax, the declaration form and the schemes all come out of the
  pack. Every figure is compared to one the test works out itself from
  `sum(debit) - sum(credit)` and the pack's own rows, including the rule engine
  that puts an account on a line and the evaluator the forms and the statements
  share. Closing is what makes a balance sheet balance, and both sides of that
  are asserted: out by exactly the result before, nil after.
  **`npm run e2e:supabase`** does the same against a real Supabase project,
  through the published binary, a GoTrue sign-in and PostgREST — the four
  things PGlite is not. It installs at the previous tag, migrates, upgrades the
  pack, signs in, books, files and closes, and prints a pass/fail table. It is
  run by hand before a release is tagged, never by the CI, and it refuses a
  database that already holds an `instance` row.

- **The country pack is documented end to end, and an installation says what it
  leaves for its operator to do.**
  [`docs/packs.md`](docs/packs.md) now describes the format file by file, the
  compiler and the three kinds of seed it writes, the checksum that makes a seed
  stale when any file of its pack moves, **every rule `ekwo pack check`
  applies** grouped by what it guards — manifest, chart, roles, closing style,
  taxes, declaration form, statements and their fact keys, legal mentions,
  languages, golden scenario, module sections — and what it deliberately does
  not refuse. The certification policy says who may set `community`,
  `maintained` and `reviewed`, what a reviewer puts their name to, and what
  `.github/CODEOWNERS` is and is not. "Adding a country in a day" is a ten-step
  walkthrough a contributor can follow from `cp -r packs/be packs/xx` to the
  pull request.
  [`CONTRIBUTING.md`](CONTRIBUTING.md) states the seven invariants of a country
  pack: data never code, no country literal in the core, an account resolved by
  its role, a legal reference on every tax and every box, a golden scenario or a
  written reason there is none, a review that is a named professional, and
  nothing ever deleted from a pack.
  [`supabase/seed/README.md`](supabase/seed/README.md) says what each seed file
  holds, which five are generated and must not be edited, the order they are
  applied in and who applies each, with the counts corrected against the packs
  as they stand.
  [`docs/international.md`](docs/international.md) records phase 0 as delivered,
  item by item, without moving the roadmap.
  **And `ekwo init` prints, at the end of a successful installation, the four
  things it cannot do for you**: turn off self sign-up on your Supabase project,
  keep two administrators, keep the `service_role` key off machines that do not
  need it, and read [`DISCLAIMER.md`](DISCLAIMER.md) before filing anything.
  Three of the four are settings of a project rather than rows in a database, so
  no connection string reaches them and `ekwo doctor` does not pretend to check
  them. The installation guide carries the same four in the same words, and a
  test reads both.
  The installation guide also gains what a script hits before it hits anything
  else: **`ekwo init` refuses to pick a country, a chart of accounts or a
  language for you** outside a terminal, and names the flag; the four reference
  seeds are named, in the order they are applied; and the catalogue check of
  `ekwo doctor` says what it does **not** cover — constraints, indexes and
  function bodies. **Where table access comes from is written down**: it was a
  known gap when this guide was written, and the entry above closed it in the
  same release, so the section says what the schema grants and keeps the
  history that explains the symptom — an installation nobody has migrated,
  whose `public` schema was recreated without the project's default
  privileges, is one the doctor calls healthy and PostgREST answers
  `permission denied for table companies` on.
  Two examples in that guide were broken and are corrected: the non-interactive
  `ekwo init` one-liner and the scratch-project procedure both omitted
  `--chart` and `--language`, which the Belgian pack has made mandatory since it
  gained a second chart of accounts.

### Changed

- **A test may book in a country. It may not expect one.**
  Eleven test files named `BE`, `FR` and `LU` by hand: six loops over a literal
  pair of pack slugs, and tables keyed by country for the statements, the
  declaration forms, the charts, the exchange accounts, the closing parameters
  and the fixed-asset rules. Adding Luxembourg meant editing most of them, and
  until they were edited the pack was checked by nothing.
  Every one of those now walks `listPacks()` through the new
  `tests/helpers/packs.ts` and takes its expectation from the pack itself — a
  role of the manifest, an account of a chart, a box of the form. A test that
  needs the pack with a particular property asks for that property
  (`packWhere('taxes on collection', …)`) instead of naming the country that
  has it. The set of certification statuses comes from the published schema
  rather than a literal pair.
  A claim only one pack can make — a fact key of a national filing taxonomy —
  moves to **`packs/<cc>/golden/expectations.json`**, beside the golden and
  outside the pack checksum, read by one generic runner. Adding a country now
  touches the pack folder and its `golden/`, and nothing under `tests/`.
  `scripts/check-no-country-literals-in-tests.mjs` runs in the CI and keeps it
  that way; `docs/packs.md` describes the two places a pack is written.

- **A base is written once, and printed as often as the form likes.**
  A tax carries one `base` posting per kind of document, so a taxable amount
  has one definition and reaches one box — and a national form that prints that
  base a second time gets a computed `total`, not a second posting. The rule
  was enforced by `ekwo pack check` and written down nowhere. `docs/packs.md`
  now carries it where the postings are defined and again in the walkthrough,
  with the Luxembourg return as the worked example: box `472` adds the rate
  bases of section II instead of being posted to, and the Estonian `6.1` / `6`
  / `1` nesting is the same shape three deep. Documentation only: no pack and
  no function changed.

- **The code and the type of an account stop moving once it is in use.**
  Every reference to an account inside a company is a foreign key on
  `accounts(id)`, so renumbering one appeared to break nothing. The rules do
  not follow the key: a financial statement maps an account to a line by its
  code, and the eighteen account types are what put an account on one side of
  the balance sheet or in the income statement. Moving `700000` to `701000`
  moved a year of bookkeeping to another line of a statement somebody had
  already filed, and the `accounts_write` policy had nothing to say about it.
  A trigger (migration `20260914144731`) now refuses a change of `code`
  (`account_code_frozen`) or of `account_type` (`account_type_frozen`) on an
  account that carries a ledger line, is named by a tax posting, or plays one
  of the company's roles. The label, the translations, the notes, the parent,
  `reconcilable`, `deprecated` and `pinned` stay free, and deprecating remains
  the way to retire an account that was wrong.
  One consequence is deliberate: `pack_upgrade(…, apply => true)` now fails by
  name rather than moving a used account between statements. That difference
  was already a `review`, which is the rule that exists for a person to look.

- **`tax_report_templates.period` is now `periods`, a list, with no default.**
  The column defaulted to `month_or_quarter`, so a pack that had never
  considered its own cadence filed on Belgium's and France's, silently, in a
  column a reader would take for data. There is no default now, and
  `ekwo pack check` refuses a form that names none. `tax_report.json` accepts
  either the list or the single word it used to take.

- **The real-project end-to-end run times every step.** `npm run e2e:supabase`
  printed a pass/fail table; it now prints how long each step took and the
  total beside it. Over a pooler and a hosted PostgREST what matters about a
  release is not the total but which step holds it — a migration set that
  doubled, a first query waiting on a cold project, a close that got slower as
  the ledger grew — and a number that moved between two releases is a question
  worth asking before the tag, not after.

### Fixed

- **`ekwo pack check` refuses a sign on a statement line computed from other
  lines.** `sign: -1` is how a scheme prints a credit balance as a positive
  figure, and `financial_statement()` applies it when it sums the line from the
  ledger. A total is worked out from lines that already read that way, and the
  evaluator then multiplied the total by the total's own sign as well — so a
  scheme that flipped a credit line and flipped the subtotal above it got the
  figure back the way it started, silently. It cost the Luxembourg pack a wrong
  set of golden figures, caught by somebody reading them. The two are refused
  together, the explicit `1` included; `minus` is how a total subtracts. The
  evaluator is unchanged and no pack combined the two, so no golden figure
  moved.

- **`ekwo pack upgrade` left a company on the old version when the release
  changed nothing the difference compares.**
  The command asked for the difference first and returned early when it was
  empty, saying the company was already at the version this installation holds.
  Those are two different claims: a patch release — a legal source added to a
  tax, a box renamed — moves the pack version and touches no natural key, so
  the difference is empty and `company_packs` went on recording the old
  version for ever, with `ekwo pack status` calling the company behind every
  time. `pack_upgrade()` already handled an empty difference by recording the
  version, so the early return is gone rather than corrected. Found by the
  end-to-end run against a real project, upgrading an installation made at
  v0.2.0: Belgium moved 1.5.0 to 1.5.1 and the company stayed on 1.5.0.

- **`ekwo status` and `ekwo doctor` reported an ordinary installation as ahead
  of the CLI.**
  `ekwo migrate` applies the modules' migrations beside the socle's and records
  them in the same history, which is what it is meant to do. The other two
  computed their gap against the socle alone, read those versions as history
  they had no file for, and told the operator to upgrade a CLI that was already
  current. All three now build the same set.

- **`docs/schema.md` no longer reorders its overloads on its own.** The
  function table was ordered by name alone, and two functions of the same name
  were left in whatever order the rows came off `pg_proc` — so rewriting one of
  them could move the pair in a document nobody had edited. It now orders by
  name and `oid`, and the two `resolve_line_account` entries swapped places
  once, for good.

### Security

- **The schema grants its own rights, and the anonymous role holds none on any
  table.**
  Until now not one migration gave `anon` or `authenticated` a privilege on a
  table. A Supabase project carries default privileges on `public` that hand
  `all` on every new table, sequence and function to the three API roles, so
  everything worked — and `anon`, the role behind the publishable key any
  visitor holds, had INSERT, UPDATE and DELETE on every table of the ledger
  with row level security as the only thing in the way.
  **Migration `20260914151207` declares the privileges by name**, table by
  table and view by view, with one migration each for the `assets` and
  `budgets` modules. `authenticated` may attempt exactly the verbs the policies
  of that table are prepared to judge: the four on the twenty-six a policy
  `for all` governs, SELECT alone on the twenty-four a country pack or a
  `security definer` function writes, and SELECT alone on `audit_log`, which
  is append-only by trigger for everyone including its owner. `anon` gets
  nothing on any table, view or sequence, and keeps the ten policy helpers it
  already had. `service_role` gets what a person gets. The twenty-nine trigger
  bodies stop being callable at all.
  **No wildcard, and no `alter default privileges` as the mechanism** — that
  is the hidden dependency being removed. The project's defaults are taken
  back and stopped; Ekwo's own EXECUTE default from `20260911210131` goes with
  them. From here, **a migration that creates a table, a view or a function
  grants it in the same file**.
  **`anon` could read every table of the `assets` and `budgets` modules**,
  whose opening migrations carried `grant select on all tables … to anon`.
  Row level security answered every such read with an empty set, so nothing
  leaked; the surface is closed now.
  **`ekwo pack upgrade` could not have worked through PostgREST.**
  `pack_upgrade()` writes its own audit line and was `security invoker`, so it
  called `audit_record()` — closed to `authenticated` since `20260914103412` —
  as the caller. On a real project the upgrade committed and the trail did
  not. `20260914152840` makes the function `security definer`, like its peers,
  and the capability test it already carried is unchanged.
  **What enforces it**: the `grants` section of
  `packages/cli/assets/expected-objects.json` — the inventory that already
  carries the objects a release defines, because a privilege and the object it
  sits on ship in the same migration — generated by `npm run inventory` and
  refused by the CI when it drifts; `tests/grants.test.ts`, which compares the catalogue to it,
  checks the doctrine against `pg_policy`, and books a whole country pack's
  golden year on a database whose roles start with nothing at all; and
  `ekwo doctor`, which reports a missing grant or an extra one to `anon` as a
  problem and a wider grant to `authenticated` as a warning.
  **The test harness stopped supplying privileges.** The Supabase shim and
  `freshDatabase` used to grant the three roles everything, which made the
  whole suite pass against privileges no installation was guaranteed to have.
  Every test file is now also a test of the grants.
  **The installation guide says the new answer and keeps the old symptom.**
  `packages/cli/README.md` described where table access comes from as a known
  gap; it now says that the schema grants its own rights, what that means for
  an application that reads a table without signing a user in, and why an
  installation nobody has migrated can still answer `permission denied for
  table companies`.

## [0.2.0] — 2026-09-14

The first published release. `0.1.0` below was the first schema and was never
tagged; nothing outside this repository had run it. From `v0.2.0` on, a
published migration is never edited — the rule is enforced on every push and
against the latest tag, and a mistake is corrected by a new migration, always.

### Added

- **An append-only audit trail, and the first pack upgrade.**
  The ledger was already immutable — an entry is posted once and corrected by a
  reversal — but everything *around* it was not: the chart of accounts, the
  journals, the taxes and the accounts they post to, the bank accounts, the
  contacts, the products, the financial years, the members and their roles, the
  pack version a company holds. Those decide how every future entry is booked,
  and nothing recorded that one of them had moved.
  **`audit_log`** records who (`auth.uid()`, and the machine key where one was
  presented), what (the table, the natural key, the row before and after as
  `jsonb`, the operation), when, and the company the change belongs to. Beside
  the ordinary edits it records the acts: a document posted or cancelled, an
  entry posted or reversed, a payment booked, matched or unmatched, a financial
  year closed or reopened, a pack upgraded. The ledger itself is not audited: a
  posted entry is immutable and is corrected by a reversal, so what is recorded
  is the act of posting and never the lines.
  **Append-only is a trigger, not a policy.** Policies do not apply to the table
  owner and `service_role` carries BYPASSRLS, so an audit trail defended only by
  row level security is one the operator can quietly rewrite. Nothing updates a
  row and nothing deletes one, except `purge_audit_log(date)` — `service_role`
  only, no default retention, and it writes its own row saying how many it
  dropped. Members of a company read its trail and nobody else sees anything.
  `api_keys.key_hash` and `company_invitations.token_hash` are never copied into
  it.
  **`ekwo pack status`** shows what each company copied against what the
  installation holds, and changes nothing. **`ekwo pack upgrade <company>`**
  moves it: the difference is computed by natural key and every difference falls
  into one of three rules — an addition is copied in, a closed validity is
  applied, and everything else is listed and left exactly where it was until
  `--apply`. A row the company holds and the pack does not is never applied at
  all: nothing is removed from a company's books by an upgrade. The recorded
  version moves only when nothing is left waiting. The rules live in the schema,
  `pack_upgrade_diff()` and `pack_upgrade()`, so an application or an assistant
  asking the same question gets the same answer.
  **The upgrade is tested from the published 1.0.0**, not from a fixture: the
  four hand-written seeds kept since the pack format replaced them are replayed,
  a company is installed from them, this release's packs land on top, and the
  test asserts that nothing is silent.
  **Versioning the socle.** Each of `ekwo`, `@ekwo-ai/core` and `@ekwo-ai/mcp`
  declares a `schema_min`, in `package.json` and as a constant, the way a country
  pack declares one in its manifest; the MCP server asks `ekwo_schema_version()`
  before it offers a tool and refuses an older database by name; `ekwo migrate`
  recommends a snapshot before it applies anything, because migrations move
  forward only and there is no `down`.
  **`read_audit_log`** is the MCP tool for it — filters on table, natural key,
  user, act, operation and date range — and there is no tool that writes it.
- **An amount is rounded at the decimals of its currency, by the method of its
  country.** `currencies.decimal_places` and `country_defaults.rounding_method`
  were filled by every pack and read by nothing: every rounding in the schema
  was `round(x, 2)`, fifty-one times, in eighteen functions, a view and a
  generated column. Two decimals is right for the euro and wrong for the yen,
  which has none, and for the dinar, which has three.
  **`round_amount(amount, rounding_of(company, currency))` is the one path.**
  `money_rounding` is the pair the two columns answer, `round_amount` the
  arithmetic and the only function that names a rounding method — half up, half
  even, down, up, all on the absolute value, so a credit note is its invoice
  with the sign flipped — and `rounding_of` the only reader of the two columns.
  A currency, a company or a country it cannot resolve is refused by name.
  Every ledger-affecting rounding of the socle and of the `assets` and
  `budgets` modules goes through it, including `post_document`, `post_payment`,
  `reconcile`, `settle_cash_basis_tax`, `close_fiscal_year`, `vat_return`,
  `financial_statement`, `fec_lines` and the depreciation schedule.
  A function that handles two currencies resolves two: a document is stated in
  its own and the ledger keeps the company's.
  **`document_lines.amount_untaxed` is now written by a trigger** rather than
  generated, because a generated column may not look up the currency of its
  document. It is still derived and still cannot be keyed in.
  **The tolerances are fractions of a unit**, through `currency_unit()`, where
  they used to be fractions of a cent.
  **`evaluate_totals` takes the rounding as an argument** and its three-argument
  form is gone; it is immutable and looks nothing up.
  **CI refuses a new one.** `npm run check:rounding` reads every migration
  written since, and a test asks the catalogue whether any live function, view
  or generated column still rounds to a number written down.
  What is not done, and is named in `docs/decisions.md`: the monetary columns
  are still `numeric(16, 2)`, so a currency with more than two decimals is
  rounded right and stored short.

- **Every label a user reads, in every language the country pack publishes.**
  The schema was bilingual in shape and monolingual in fact: `name_i18n` sat on
  the chart of accounts, the declaration boxes and the statement lines, and all
  four language files of Belgium and France were empty. A Belgian company
  keeping its books in Dutch was handed a chart of accounts, a set of journals
  and a VAT return in French.
  **Belgium now ships in Dutch, German and English, and France in English.**
  354 accounts across both Belgian charts, 394 French ones, the journals, the
  taxes, the boxes of the periodic return, the lines of the annual accounts,
  the sentences an invoice must print and the fixed-asset categories — complete,
  from the official wording where a country publishes one. Sources are cited in
  `packs/<cc>/i18n/README.md`.
  `journal_templates`, `journals`, `tax_templates`, `taxes` and
  `country_defaults` gain `name_i18n`, which is what was missing for a company
  to read its journals and its VAT codes in its own language;
  `install_country_template()` copies them through `label_for()` the way it
  already copied the accounts.
  **A pack declares its languages** — `languages` in the manifest — and the
  declaration is a promise: `ekwo pack check` fails, naming every missing key,
  if a declared language stops covering the pack. A language file that is not
  declared may be partial and falls back, which is how a language is
  contributed one section at a time. A label under a code the pack does not
  carry is refused either way.
  **One file per language.** A translation now lives only in
  `i18n/<lang>.json`: the inline `text_i18n` of a legal mention and the
  `name_i18n` of an asset category moved there, so a contributor edits one file
  and a reviewer reads one file.
  `country_defaults.languages` records what a pack publishes, `ekwo init` lists
  those languages with nothing pre-selected rather than guessing, `ekwo pack
  list` shows them, and the demo company says which language it keeps its books
  in. [`docs/languages.md`](docs/languages.md) is the mechanism end to end.
- **The FEC carries its opening balances, and an unclosed year carries its
  result.** `fec_lines()` returned the movements of a period and nothing else,
  so the file of a financial year could not rebuild the balance sheet it
  belongs to. It now prepends the *à-nouveaux*: one line per account that
  carries forward, at the balance of the day before the year opens, on the
  journal `country_defaults.opening_journal_code` names and as one balanced
  entry. They are **computed from `trial_balance()` and never posted** — every
  report here reads the ledger from the beginning, so an opening entry would
  count each carried balance twice — and a balance-sheet account is one whose
  `account_type` carries forward, never a code prefix.
  **A year the meeting has not closed yet still carries its result**: the
  accounts that do not carry forward are the mirror image of the balance-sheet
  ones, so what is left over goes on one more line, on the balance-sheet
  account the close would have used — France's 120 or 129 under
  `result_accounts`, retained earnings under the other two styles, because an
  appropriation account is inside the income statement and the closing entry
  empties it. A pack that names none gets `no_result_account`; a first set of
  books with nothing to carry is asked for nothing at all. The export is never
  refused for a year that is merely open.
  **And the entries a close writes leave the file of the year they close**:
  kept, they show the result twice and the income statement read from the file
  is nil. So the file of a closed year is byte for byte the file of the same
  year still open, and the result reaches the balance sheet in the opening
  lines of the year that follows. `financial_statement()` keeps the
  appropriation entry, which is part of a statutory income statement, and
  `docs/decisions.md` says why the two readers differ.
  The wording of those lines is `defaults.opening_entry_label` in the pack —
  France says *À-nouveaux* — with a neutral English fallback, because the
  format fixes eighteen columns and no wording. An extract that is not a whole
  financial year gets no opening lines. Same signature, same eighteen columns:
  `@ekwo-ai/fec` and the `generate_fec` tool need no change.

- **Modules: one Postgres schema each, and the ledger only through a
  function.** The socle stays in `public` and knows nothing about what is built
  beside it. `public.modules` is the registry — a table, written by the last
  statement of a module's own first migration, never a plugin list in code —
  and `company_modules` says which company has enabled which, written only by
  `enable_module()` and `disable_module()` because the table has no write
  policy at all. `module_enabled(company, code)` is the one call a module's row
  level security policies make, and it joins the eight helpers `anon` may
  execute: what it gives a stranger is the word `is_company_member` already
  gives them.
  **`post_module_entry()` is how a module reaches the ledger**: it hands over a
  company, a date, a tag and its lines as data, and the socle builds the draft
  and calls `post_entry()`. `entries.module_code` and `entries.module_ref`
  carry the tag, and a unique index on `(company_id, module_code, module_ref)`
  is what makes a module idempotent — the database refuses the second posting
  rather than the module remembering to look. No `entry_kind` value per module.
  Nine guards hold the rest: row level security on every module table, every
  company table's policies through `module_enabled()`, `company_id` on every
  table that is not reference data, no function of a module schema executable
  by PUBLIC or `anon`, no country, currency or language literal under
  `modules/**`, no write to `entries` or `entry_lines` and no direct
  `post_entry()`, a manifest that validates against `modules/schema/module.1.json`,
  migration timestamps that sort after every socle migration and are unique
  across the repository, and a module held to what its manifest says about
  posting.
  `ekwo module list|migrate|enable|disable`; `ekwo migrate` applies the modules
  by default and `--no-modules` leaves them out, which is what to pass before
  `supabase db push`. Module migrations share the socle's history with the
  module in the recorded `name` (`assets/assets`). The MCP server registers a
  module's tools under the prefix its manifest declares, reading
  `public.modules` for what is installed, and turns PostgREST's profile error
  into the sentence that names the setting — because exposing a schema is the
  one thing no migration can do.

- **`assets` — fixed assets, their depreciation and their disposal.** Straight
  line and declining balance, with the country's prorata convention, its
  declining cap and its switch back to the straight line as pack data in
  `packs/<cc>/assets.json`; the usual durations of a kind of asset as
  `assets.category_templates`, each one naming what it comes from. Every amount
  is rounded to the cent and the last line takes the remainder, so a schedule
  sums to exactly `cost − residual_value` — asserted on every asset of every
  test. `run_depreciation` books one entry per period through
  `post_module_entry()` and is a no-op the second time; a closed financial year
  refuses it, because `post_entry()` asserts the period. `dispose_asset` follows
  the country's own mechanism: `net_result` puts the difference on one account
  (Belgium 763/663), `gross` books the net book value as a charge and the
  proceeds as an income in full (France 675/775) — the enum names the mechanism
  and never a country, as `closing_style` does. `units_of_production` is in the
  enum and refused by name. Four nullable `country_defaults` columns, none with
  a default, carry the accounts each style needs; both packs move to 1.4.0.

- **`budgets` — what was planned, against what was booked.** The module that
  proves the mechanism holds for one that is not `assets`: no country data, no
  pack section, no seed, and not one line written to the ledger. A budget per
  financial year, its lines per account and period, and
  `budgets.variance(company, budget, from, to)` against posted entries of kind
  `normal`. The sign is the one a business says out loud — an income and a cost
  are both positive — and it comes from `accounts.internal_group`. It writes no
  `can_disable()`, which is the other half of that convention: turning it off
  takes nothing away.
- **A role is a preset, a capability is what a policy tests, and a company has
  a face.** `capabilities` holds twenty codes — `documents.post`,
  `payments.write`, `settings.write`, `members.manage`, `year_end.close` and
  the rest — `role_capabilities` says what `owner`, `accountant` and `viewer`
  each hold, and `company_members.capabilities_granted` /
  `capabilities_revoked` adjust one member in both directions, a revoke
  winning over a grant and over the preset. **Every policy in the schema now
  calls `has_capability()`**, and `can_write_company()` is rewritten on top of
  it rather than left beside it; the three roles do exactly what they did
  before. Posting a document, posting an entry and closing a year are guarded
  by triggers on the transition, because what changes there is a state and not
  a row. A module adds its codes to the same table, with `area` set to its own
  code.
  **A guard written two days earlier had never fired**: the counters behind
  `next_entry_number()` and `next_matching_number()` checked
  `not can_write_company(...)`, which was NULL for a stranger and therefore
  never raised — so any signed-in user could burn numbers in any journal of
  the installation. It raises now.

- **Invitations.** `invite_member()` returns a token once and stores only its
  sha256; `accept_invitation()` requires `auth.email()` to match the address
  invited, is single use and expires; `revoke_invitation()` withdraws one.
  `company_members.user_id` still has no foreign key to `auth.users`, which is
  what lets a membership exist before the person signs up. MCP tools
  `invite_member`, `list_invitations` and `revoke_invitation`; accepting is
  the invitee's own act and has no tool.

- **User preferences, and one way to choose a label.** `user_preferences` —
  preferred company, language, timezone, `date_display_format`,
  `number_display_format` (named so that neither is confused with
  `country_defaults.number_format`, which is a numbering pattern), theme —
  nullable everywhere and with no default anywhere, because null means "take
  the company's answer, then the pack's". `label_for(name, name_i18n,
  languages)` replaces the resolution that was written out wherever it was
  needed, `preferred_languages(company)` builds the chain, and
  `install_country_template()` is republished on it. MCP tools
  `get_preferences` and `set_preferences`.

- **A company profile an invoice can be printed from.** Trade name, logo URL
  or storage path, stated capital with its own currency, activity code and the
  register it belongs to, default bank account, document template. A capital
  with no currency takes the company's own; a sales document with no payee
  IBAN takes the default bank account, and a purchase document never does.
  **`document_header`** is the third view beside `document_line_items` and
  `document_legal_mentions`, and `get_document` reads it instead of assembling
  the same thing itself. MCP tools `update_company_profile` and
  `create_company`. No `registry_reference`: `registration_number` already is
  the number the commercial register holds.

- **Numbering reads the country pack.** `next_entry_number()` builds the
  number from `country_defaults.number_format` — `{CODE}`, `{YYYY}`, `{YY}`,
  `{MM}` and a `{N…}` counter padded to its own width — through
  `format_number()`, which refuses a token it does not know. **No fallback
  literal**: a pack that declares nothing gets `no_number_format` naming
  `documents.number_format`. The counter follows the pattern: a year in it
  restarts with the year, and a pattern with none keeps one series. `post_entry()`
  reads `numbering_gapless` and refuses a number chosen by hand where the law
  forbids a hole — unless the caller holds **`entries.import`**, a capability
  in no preset, for taking over books that already have numbers; a duplicate
  is refused either way, and `catch_up_journal_sequence()` advances the
  counter to an imported number so the next automatic one continues the
  series. Belgium and France declare the pattern the engine used to
  hard-code, so no number changes.

- **Keys for machines.** `api_keys` — one company, an explicit list of
  capabilities, an expiry, a sha256 at rest — with `create_api_key()` (which
  refuses a capability the issuer does not hold), `use_api_key()` presenting a
  key for one transaction, `touch_api_key()`, `current_api_key()` and
  `revoke_api_key()`. `has_capability()` answers for a key where there is no
  member answer. A key is not a session, and the README says what that costs.
  MCP tools `create_api_key`, `list_api_keys` and `revoke_api_key`.

- **The first financial year is a parameter.** `fiscal_year_bounds()` opens it
  on the month `country_defaults.fiscal_year_default` declares and closes it a
  day before the same day a year later; a pack that says nothing gets
  `no_fiscal_year_default` rather than January. `ekwo init` gains
  `--fiscal-year-start`, and `create_company()` does the same work for a
  client. `ekwo init --iban` now also points the company at the account it
  creates, so the first invoice carries an IBAN.

- **The format libraries live here now, under `packages/formats/`, one MIT
  package per format and never one per country.** `@ekwo-ai/xbrl-cbso` and
  `@ekwo-ai/factur-x` came in by subtree with their history; the French FEC
  left `@ekwo-ai/core` for **`@ekwo-ai/fec`**, which `@ekwo-ai/core` and
  `@ekwo-ai/core/fec` re-export, deprecated, for one version. A brick imports
  nothing from the core and declares the row shapes it reads in its own types;
  `tests/formats.test.ts` fails if one loses its MIT `LICENSE`, imports the
  core or another brick, or takes a runtime dependency its format does not
  need. The CLI's published dependency list is unchanged — `pdf-lib` belongs to
  Factur-X alone.
  **The core stops asserting its fact keys and starts verifying them**: the
  fifty-three `xbrl` keys of the Belgian schemes are resolved against the NBB
  taxonomy the brick carries, and each one has to land on the very line code
  that wrote it. A statement that carries keys now names the taxonomy they were
  written against — `"taxonomy": "nbb-cbso:26.0"`, checked by `ekwo pack check`
  — and the Belgian pack moves to 1.3.1. No migration: the taxonomy never
  enters Postgres.
  **And the test the split into two repositories made impossible now exists**:
  the demo books are closed, presented on the three NBB schemes by
  `financial_statement()`, filed through `generateCbsoXbrl({ lines })`, checked
  against the arithmetic of the Filing application, and compared byte for byte
  with a committed golden instance.

- **VAT falls due when the cash moves, and the exchange difference when it
  settles.** A tax marked `cash_basis` is booked by `post_document` on the
  transition account its pack names and on **no declaration box**, and so is
  the base it is computed on: a cash-basis return reports the base collected,
  and a base declared a month before its tax is a return that does not tie
  out. `settle_cash_basis_tax()`, called by `reconcile()` and by
  `unreconcile()`, moves the settled share — pro rata, cumulative, the last
  payment carrying the remainder — to the account and the box it is declared
  on, dated on the day the settlement completes, on the miscellaneous journal.
  A cash-basis tax that names no transition account, that splits its tax over
  two postings or that also carries a non-deductible share is refused at
  posting and by `ekwo pack check`. `vat_return()` needed no change.
  **The French pack gains the six services taxes that fall due on collection**
  (CGI art. 269-2-c, and art. 271-I-2 on the purchase side) and the two
  accounts they wait on, `445870` and `445860`; the goods taxes are unchanged
  and are also the option for the debits. Belgium is unchanged: its regime has
  no general cash-basis option in the socle.
  **The ledger converts**, which it did not: a document in a foreign currency
  booked its foreign figures as if they were the company's, and
  `entry_lines.amount_currency` was written by nothing. `post_document` and
  `post_payment` now book the company's currency at the rate the document or
  the payment carries — `payments.exchange_rate` is new — and a matching
  between two lines in the same foreign currency is worked out in that
  currency, the difference realised on `country_defaults.fx_gain_code` /
  `fx_loss_code` so the third-party account goes to nil. Both packs name those
  accounts and move to 1.2.0. `reconciliations` gains `fx_entry_id` and
  `tax_transfer_entry_id`, which the MCP server returns. Revaluation of open
  items and cash accounting as a ledger stay out of scope. Migration
  `20260912112132`.
- **What a country requires on a document is data.** Twelve columns on
  `country_defaults` — `numbering_gapless`, `number_format`,
  `legal_payment_days`, `late_payment_reference`, `tax_point_rule`,
  `einvoice_profile`, `einvoice_mandatory_from`, `party_scheme`, `vat_scheme`,
  `bank_statement_formats`, `payment_formats`, `fiscal_year_default` — and
  `legal_mention_templates`, the sentences a country puts on an invoice with a
  closed vocabulary of nine conditions and a validity of their own. The
  `document_legal_mentions` view decides which of them apply to one document,
  from its country, its date and the treatments of the taxes on its lines;
  `document_line_items` gained `tax_treatment`, `tax_exemption_code` (BT-121)
  and `tax_cash_basis`. `pack.json` compiles its `documents`, `einvoicing` and
  `bank` sections at last, and `ekwo pack check` enforces their vocabularies —
  the nine conditions, the three tax points, the bank formats by name, four
  digits for an ISO 6523 scheme, a number pattern with exactly one counter,
  and a legal reference on every mention. `get_document` returns the
  applicable mentions and the country's payment and e-invoicing rules;
  `ekwo status` prints the e-invoicing profile of each pack. Belgium and
  France move to 1.2.0. **No function was added**: two views read the data and
  the numbering engine is untouched. Migration `20260912111751`.
- **A country has charts of accounts, not one chart.** `chart_templates` lists
  what a country offers, `account_templates.chart_code` says which one an
  account belongs to — the natural key is now `(country, chart_code, code)` —
  and `company_packs.chart_code` records which one a company copied. The
  journals, the taxes and the declaration form stay common to the charts of a
  country: an association files the same VAT return as a company. `pack.json`
  declares `charts`, exactly one of them the default, and `ekwo pack check`
  refuses a pack whose role codes and tax posting accounts are not in every
  chart it ships. `ekwo init --chart <code>` picks one, an interactive install
  asks only when there are several, and `ekwo status` prints the chart each
  company keeps its books on. Belgium ships a second chart, the PCMN as the
  associations title of the Code des sociétés et des associations applies it,
  marked `community` on the chart entry. Migration `20260912095825`.
- **Financial statements are data.** `statement_templates`,
  `statement_line_templates` and `statement_line_rules`, filled by the packs;
  `financial_statement(company, code, from, to)` returns the whole frame, nil
  lines included, in the order the scheme prints it. A line is summed from the
  ledger through rules — by code range, code prefix, account type or one code
  — or computed from other lines through plus and minus lists, with no
  expression language, as for a declaration form. Belgium gets the NBB
  abbreviated balance sheet, income statement and allocation section; France
  the 2050-2051 balance sheet and the 2052-2053 income statement of the 2026
  liasse; `packs/generic/` a country-less framework by account type that fits
  any chart, including one with no legal codes. `unmapped_accounts()` names
  what a scheme would silently leave out, and `ekwo pack check` refuses a
  chart with an account that reaches no line of any of its statements — which
  is what makes a balance sheet balance. Two MCP tools, `list_statements` and
  `financial_statement`, and `get_company` now says which pack and which chart
  a company sits on. An income statement leaves out the entries
  `close_fiscal_year()` marks `kind = 'closing'`, so a closed year still
  reports what it earned; a balance sheet keeps them, because that entry is
  what carries the result onto the line it shows. Migrations `20260912100412`
  and `20260912104719`.
- **One evaluator for both reports.** `evaluate_totals(values, formulas,
  keep_zero)` is the single place a plus/minus formula is worked out;
  `vat_return()` was rewritten onto it rather than have the calculation exist
  twice. It also gains what the statements needed: totals evaluated in the
  order they depend on each other rather than in the order the form declares
  them, and a cycle that raises `formula_cycle` instead of quietly reading
  zero. No pack changes answer.
- **An appropriation entry is not a closing entry.** `entries.kind` gains
  `appropriation`, which `close_fiscal_year()` puts on the entry that moves
  the result into the appropriation accounts; the entry that empties the
  income statement keeps `closing`. Under one name the two cancelled out and
  the Belgian "Affectations et prélèvements" section read nil the moment a
  year was closed. An allocation section now leaves out the closing entry and
  keeps the appropriation, an income statement leaves out both, and a balance
  sheet keeps both. `reopen_fiscal_year()` undoes both. Migrations
  `20260912105720` and `20260912105721`.

- **One tax engine, several kinds of tax.** `tax_kind`
  (`vat`/`gst`/`sales_tax`/`withholding`/`other`), `recoverable`,
  `jurisdiction`, `price_include` and `cash_basis` on `taxes` and
  `tax_templates`; `rounding_method` and `cash_rounding_unit` on
  `country_defaults`. All of them were already words in the pack format,
  marked deferred, and the compiler dropped them; they now reach the database.
  Every default is today's behaviour, so no existing tax changes by a cent.
- **`tax_on_base`, a posting that books non-deductible VAT on the account of
  the line.** A Belgian company car at 21 % with the deduction capped at 50 %
  books 1 000 on the vehicle, 105 on the deductible VAT account, 105 more on
  the vehicle and 1 210 to the supplier; Belgian grid 83 reports 1 105,
  because the form asks for the base plus the non-deductible VAT. The posting
  carries no account, exactly like `base`, and is split across the accounts of
  the lines it taxes in proportion to their bases.
- **Belgium and France gain the taxes that needed it**, both packs moving to
  `1.1.0`: `BE-P-21-50-I` and `BE-P-21-50-S` (vehicles and their running
  costs, art. 45 § 2 CTVA), `BE-P-21-ND` (frais de réception, art. 45 § 3),
  and `FR-P-20-CARB` (fuel at 20 % with the 80 % deduction of CGI art. 298,
  4, 1°).

- **No currency and no language written into the code either.** The MCP tools
  that create a product, a document or a bank account fell back to `'EUR'`
  when the caller named no currency; they read the company's own now, and
  refuse with `not_found` on a company they cannot see. `bootstrap()` took
  `'EUR'` and `'fr'` the same way and now takes the pack's, or says which flag
  to pass. A currency and a language are what a country decides, so a literal
  one is a country in the code wearing another hat — a guard test refuses both
  in `packages/*/src`.

- **No default country, anywhere.** `ekwo init` used to label the country
  question with `PCMN` and `PCG` written in the CLI and to preselect Belgium.
  The list and the labels now come from `country_packs`, sorted by name, so
  installing a pack is what adds a choice; there is no preselected value,
  because the one question whose wrong answer is a chart of accounts has no
  right default. Non-interactively, `--country` is required and the refusal
  names the packs installed. The currency and the language come from the pack
  and are asked for when it carries none, instead of falling back to `EUR`
  and `fr` written in code.

- **Five country literals removed from published migrations.** The Belgian
  frame VI inside `vat_return()` in `20260911121000`, and the backfills that
  named `'BE'` and `'FR'` in `20260911183000` (cash account), `20260912074712`
  (default language) and `20260912080311` (report code). The first three
  values are pack data and the compiled seeds upsert them; the fourth needed
  no backfill at all, since a null `report_code` on a posting means "the
  periodic return of the country" and `vat_return()` reads it that way. Those
  files were edited rather than overridden, once, because no installation
  anywhere had run them — the rule and its exception are written down in
  `supabase/migrations/README.md`. Three tests now keep it that way: no
  function in `public`, no file under `supabase/migrations/`, and no source
  file of the CLI, the MCP server or the core may hold a country code.

- **Declaration boxes are data, and `vat_return()` holds no country.**
  Migration `20260912090407` adds `tax_report_templates` — one declaration form
  of one country — and `tax_report_box_templates` — one box, with `plus_boxes`,
  `minus_boxes` and `floor_zero` where it is a total. `ekwo pack build`
  compiles `packs/<cc>/tax_report.json` and the `tax_report_boxes` labels of
  `i18n/` into them, so the Belgian 71/72 and the French CA3 totals (01, 16,
  23, 25, 28) are pack data. `vat_return(company, from, to, report_code)`
  evaluates the totals in the `sequence` the form declares and returns, beside
  the four columns it always did, the `name` of each box, its `sequence`,
  `hidden` and `report_code`; the three-argument call is unchanged. The last
  `fiscal_country = 'BE'` leaves the core, and a test keeps it out: no function
  in `public` may hold a country code in its source. `ekwo pack check` refuses
  a formula that names a box the form does not carry, a bare reference that
  could mean two boxes, a total that names itself or a total computed after it,
  a formula on a box that is summed from the ledger, a box declared twice, and
  a tax that posts to a box the form does not declare.

- **Opening balances and a year-end close that is a parameter, not a branch**
  (migration `20260912094412`). `opening_balance(company, year, lines)` takes
  the trial balance of whatever kept the books before and posts it as the
  opening entry of a year, on the opening journal, dated on its first day;
  balance-sheet accounts only, unless the caller says it is taking books over
  mid-year. `close_fiscal_year(year)` moves the result out of the income
  statement the way `country_defaults.closing_style` says — straight to
  retained earnings, into a current-year result account on the balance sheet,
  or through an appropriation account of the income statement — zeroes every
  income and expense account, and closes the year. `reopen_fiscal_year(year)`
  reverses what it wrote, never deletes it, and is refused once a later year
  is closed or booked into. Belgium's 693/793 to 140/141 and France's 120/129
  are values in `packs/be` and `packs/fr`, and a test asserts that no function
  of this change holds a country code or an account code. The close writes no
  *à-nouveaux*: every report here reads the ledger from the beginning, so an
  opening entry on top of it would count each balance twice —
  `docs/decisions.md` carries the reasoning and what reversing it would cost.
  `fiscal_years.is_closed` is no longer an ordinary column: a trigger refuses
  the transition to anyone but those two functions, and `entries.kind`
  (`normal | opening | closing`) says what an entry is for so a statement of a
  closed year can leave the year-end entries out without a heuristic — written
  by those three functions, refused to everyone else by a trigger, and carried
  by a reversal from what it undoes. **None of the five new
  `country_defaults` columns carries a default**: a default closing style is
  one country's mechanism handed to every country that has not spoken, so a
  pack that says nothing is refused by name — `no_closing_defaults`,
  `no_opening_journal` — and `ekwo pack check` catches the same gaps before a
  seed is written. Three MCP tools —
  `opening_balance`, `close_fiscal_year`, `reopen_fiscal_year` — and
  `ekwo status` now says how many financial years are open.

- `DISCLAIMER.md`: software, not advice; the books are yours; what a pack
  and a review are and are not; estimates are estimates.

- `MANIFESTO.md`: why Ekwo exists — financial autonomy for every business,
  accounting as a commons, a network rather than a vendor — and a "Ways to
  help" section in `CONTRIBUTING.md` for accountants, translators and
  people who run it.

- **Ekwo maintains a pack; only an accountant reviews one.** The certification
  scale had a value `ekwo` that read as "certified by Ekwo", which is a claim
  nobody here can make: writing a pack and proving it internally coherent is
  not a professional reading it against the law. `pack_certification` gains
  `maintained` (migration `20260912081014`), Belgium and France become
  `maintained` rather than `ekwo`, and migration `20260912081015` moves any row
  that held the old value and empties `certified_by`, which said "Ekwo AI".
  `ekwo` stays in the enum — a published column never loses a value — and is
  deprecated: nothing writes it and the pack schema refuses it. `ekwo init`,
  `ekwo status` and the header of every generated seed print the same
  sentence, from one place in the CLI: "maintained by Ekwo — not yet reviewed
  by an accountant", "reviewed by X on Y", "community pack — not reviewed".

- **Two columns Canada will need, added before Canada.** Migration
  `20260912080311`: `report_code` on `tax_posting_templates` and
  `tax_postings`, backfilled to `BE-VAT-PERIODIC` and `FR-CA3` and written by
  the compiler from `tax_report.json` (a posting may override it with
  `"report"`); and `region` on `companies` and `contacts`, ISO 3166-2 without
  the country prefix. A box number is unique only inside one form, and a
  Canadian company files two returns at once; Canadian tax follows the
  buyer's province, not the seller's. Adding either with the pack would mean
  migrating tables that by then hold years of postings. Nothing reads `region`
  yet — the rules that turn it into a suggested tax are phase 1 — which is
  said out loud in the migration rather than left to be discovered.

- **An installation knows which country pack it holds, and each company
  knows which one it copied.** Migration `20260912074712` adds `country_packs`
  — version, release date, sha256 of the pack files, certification status and
  who signed it — written by the generated seed; and `company_packs`, written
  by `install_country_template`, backfilled at `1.0.0` for companies that
  already exist. `ekwo status` prints both and warns when a company is behind
  the pack the instance holds; `ekwo init` prints the certification status
  before anything is booked, in as many words when a pack is a community one.

  **The generated seeds upsert**, on the template tables and on nothing that
  belongs to a company. Until now they said `on conflict do nothing`, so an
  instance installed last month received no pack correction at all — not even
  for a company created afterwards, since a company copies the templates at
  install time. Applying a seed twice still changes nothing; applying a
  corrected pack now corrects the template and leaves every company alone,
  which is a test.

  Labels can be translated: `account_templates.name_i18n` and `accounts.name_i18n`
  (jsonb, from `packs/<cc>/i18n/`), `companies.language`,
  `country_defaults.language_default`, and
  `install_country_template(company, country, language)` — a third argument,
  defaulting to the company's own language — which copies
  `coalesce(name_i18n->>language, name)` into `accounts.name` and keeps the
  whole object beside it. `ekwo init --language nl` chooses it. The
  two-argument form is dropped rather than overloaded: an overload with a
  default argument makes `install_country_template(company, 'BE')` ambiguous,
  and Postgres refuses the call that works today.

  `accounts.statement_hint` and `account_templates.statement_hint` are added
  in the same migration; `financial_statement()` reads them in a later release.

- **Country packs, and the compiler that turns one into a seed.** A country
  now lives in `packs/<cc>/`: `pack.json` (manifest, defaults, roles,
  journals), `accounts.csv` (the chart, in the CSV subset every accounting
  tool exchanges), `taxes.json` (taxes and their postings), plus
  `tax_report.json`, `statements.json` and `i18n/`, which this release
  validates and does not yet compile. `packs/schema/pack.1.json` is the
  published JSON Schema (draft 2020-12) for all of them, and it has no field
  through which a pack could execute anything — a test asserts that.

  `ekwo pack build <cc>|--all` compiles a pack into
  `supabase/seed/<n>_pack_<cc>.sql`, which is committed; `ekwo pack check
  --all` recompiles in memory and refuses a stale seed, and the CI's *hygiene*
  job runs it. The SQL is a build artefact like `docs/schema.md`, and
  `supabase db push` and `psql -f` still install a country without this CLI
  ever running. The CLI gained no dependency: the schema validator is a
  hundred and eighty lines of the subset the pack schema uses.

  Belgium and France were extracted from the four seeds that held them, with
  no change of content: `10_pack_be.sql` and `11_pack_fr.sql` replace
  `10_chart_be.sql`, `11_chart_fr.sql`, `20_taxes_be.sql` and
  `21_taxes_fr.sql`, which move to `tests/fixtures/seeds-before-packs/` where
  a test loads the old four into one database and the new two into another and
  compares every row of `account_templates` (353 + 392), `journal_templates`
  (12), `tax_templates` (36), `tax_posting_templates` (128) and
  `country_defaults` (2).

- `docs/international.md`: the plan for making the core usable in any
  country — the country pack as data, four phases, the order of countries.

- **`products`, in the core rather than in a module beside it.** Migration
  `20260911195054`: a code unique in the company (EN 16931 BT-155), a name
  (BT-153), a description (BT-154), `service` or `goods`, a unit from UN/ECE
  recommendation 20, a sale and a purchase price, the account and the tax each
  side books to, and `active`. Row level security by company, in the same
  migration. `document_lines` gains `product_id` — nullable for ever, because
  free text is how most invoices are written — and `description`; the unit
  stays on the `unit_code` that shipped in the first release.

  A product **pre-fills a line and never constrains it**: the line keeps its
  own text, price, unit, account and tax, so a catalogue edited next month
  cannot change what an invoice said last month. The account resolution gains
  its product step — the line, the product, the company default, the country
  model — and the `document_line_items` view puts BT-153, BT-154 and BT-155
  side by side for a Factur-X or Peppol document.

  The MCP server gains `search_products`, `create_product` and
  `update_product`, and a line of `create_document` or `update_document_lines`
  takes `product_id` or `product_code`. `@ekwo-ai/core` carries `Product`,
  `ProductKind` and the short list of unit codes. The demo company carries
  four products and three invoices written from them.
- **A bank account at install time, and a tool to add one later.**
  `ekwo init` asks for the IBAN of the main account — optional, with `--iban`,
  `--bic` and `--bank-name` for the non-interactive form — and creates the
  `bank_accounts` row wired to the bank journal and to the ledger account the
  country model put behind it. Running `init` again with the same IBAN finds
  it rather than creating a second. The MCP server gains `create_bank_account`
  and `list_bank_accounts`, `record_payment` documents its `bank_account_id`,
  and the `no_bank_account` refusal now names the tool that fixes it.
  `ekwo doctor` warns — never fails — about a company with no bank account.
- **The write path has a test under row level security.** Every test in this
  repository ran as the table owner, which is exempt, so the two bugs above
  were invisible: an accountant now posts a document and matches a payment
  under `set role authenticated`, and both counters are exercised.
- **`npx @ekwo-ai/mcp`** — `packages/mcp`, the Model Context Protocol server.
  Tools over stdio: read the companies, the chart of accounts, the
  contacts, the documents and the bank lines; create a contact, a draft
  invoice and its lines; post it; record a payment and match it against the
  open invoices; pull the trial balance, the general ledger, the aged balance,
  the VAT return and the French FEC; lock a period. Plus the chart of accounts
  and the taxes as MCP resources, and two prompts — `close_month` and
  `prepare_vat_return`.

  It acts **as the user**: `SUPABASE_URL` and `SUPABASE_ANON_KEY` with an
  address and a password (or an access token), and row level security decides
  everything else. A `service_role` key is refused at startup. The
  self-hosted route, `EKWO_DB_URL`, requires `EKWO_ACT_AS_USER_ID` and sets
  the JWT claims and the `authenticated` role on every query, so the policies
  bind there too. Every ledger write goes through the schema's own functions;
  nothing in the server writes an `entries` row, and no tool unposts an entry.
- **`post_payment(payment_id)`** — migration `20260911173000`. Money in or out
  becomes a balanced entry: the bank side from the payment's bank account or
  its journal, the third-party side resolved by role the way `post_document`
  resolves it. It matches nothing, deliberately: which invoices a payment
  settles is `reconcile`'s decision. Without it, every client would have had
  to assemble the two ledger lines itself.
- **`npx ekwo init`** — `packages/cli`, published as `ekwo`. One command turns
  a Supabase project the customer already owns into a set of books: it applies
  the migrations, seeds the currencies, the chart of accounts and the VAT
  codes, creates the first administrator in the customer's own Supabase Auth,
  then runs the six steps of the installation sequence — `init_instance()`,
  `claim_instance_admin()`, the company, `company_members` as owner,
  `install_country_template()` and the first financial year. Every step checks
  before it acts, so running it twice creates nothing twice. Node 20 is the
  only requirement: no Supabase CLI, no Docker.
- **`ekwo migrate`, `ekwo status`, `ekwo doctor`, `ekwo demo`.** `migrate`
  shows the gap before closing it and re-applies the idempotent reference
  seeds; `status` reports the schema version installed against available, the
  pending migrations, the instance, its administrators and its companies;
  `doctor` checks what the schema cannot enforce on its own — row level
  security on every table, a policy on every protected table, no pending
  migration, no membership pointing at a deleted user, statements that tie to
  their lines, posted entries that balance; `demo` loads the sample company on
  explicit request.
- **`ekwo register` / `ekwo unregister`.** The registration question is asked
  once, at the end of `init`, and the default answer is no. Saying yes writes
  the address on the instance row through `register_instance()` and POSTs six
  fields — instance id, organisation, country, edition, schema version,
  contact address — to `EKWO_REGISTRY_URL`. A failed POST is a soft message:
  the local record stands and `ekwo register` retries.
- **A migration history compatible with the Supabase CLI.** The runner writes
  `supabase_migrations.schema_migrations` with the same columns and the same
  `version` the Supabase CLI uses, so `supabase db push` and `ekwo migrate`
  are interchangeable in both directions. Each file is applied in one
  transaction with its history row, so a migration that fails halfway leaves
  nothing behind and the next run resumes at it.
- **The schema travels with the package.** `supabase/migrations` and
  `supabase/seed` are copied into `dist/assets` at build time, and a test pins
  that copy to the repository byte for byte. `ee/` is never included.
- **`.env.example`**, documenting `EKWO_DB_URL`, `SUPABASE_URL`,
  `SUPABASE_SERVICE_ROLE_KEY` and `EKWO_REGISTRY_URL`. The CLI never writes a
  secret to disk; `ekwo.json`, the one file it writes, holds the project URL,
  the country and the schema version.
- **A test suite for the installer**, covering the migration runner
  (idempotence, Supabase-compatible history, resuming after a failure halfway),
  the full non-interactive installation against a shimmed Supabase Auth, the
  status and doctor checks, and registration with the endpoint mocked and with
  it unreachable.

### Changed

- `docs/schema.md` gains a section per module schema, generated the same way
  the socle's is. `docs/modules.md` is how to write one; `docs/decisions.md`
  carries the reasoning. `supabase/config.toml` says in a comment which line
  exposes a module schema, and leaves it out by default. `ekwo migrate` applies
  the modules this release carries unless `--no-modules` is passed.

- **The postings of one side of a tax share out the amount of the group**, the
  last taking the remainder, instead of each rounding on its own. No tax had
  more than one posting per side before, so nothing that exists moves; two
  halves of 0,63 now come out as 0,32 and 0,31 rather than 0,32 twice, which
  would have been refused as `document_total_mismatch`.
- **`document_tax_summary.tax_charged` counts `tax_on_base` postings**, so the
  supplier of a partially deductible purchase is owed the whole invoice.
- **The two constraints on a posting's account become one**,
  `tax_postings_account_by_type` (and its twin on the templates): a `tax`
  posting needs an account, every other type must have none. A value added to
  the enum later has to come back to it rather than slip through.
- **`list_taxes` and the `ekwo://companies/{id}/taxes` resource expose the new
  columns**, and the postings carry their `report_code`.

- **The repository is `Ekwo-ai/ekwo-os`**, and every link, `homepage`,
  `repository` field and clone line in the documentation and in the six
  package manifests points there.

- **Eighty-five foreign keys had no index on the side that needs one.**
  Postgres indexes the referenced side of a foreign key, because that side is
  a primary key, and nothing on the referencing side — so every delete of a
  parent scans its children, and most joins an accounting core writes are on
  exactly those columns. Migration `20260913104232` creates 71 of them across
  the socle and the two module migrations `20260913104233` and
  `20260913104234` cover `assets` and `budgets`. Where a table has a
  single-column key and a composite one leading with the same column, the
  composite serves both and is the one created. On the demo company nothing
  was slow, which is why it survived forty-nine migrations; on four years of
  books it is the difference between a report and a timeout.

- **The additive-migrations rule runs on every push, not only on a pull
  request.** The job was gated on `pull_request` and everything went straight
  to `main`, so it never looked. It now compares a push to `main` against the
  previous commit and against the latest tag — the released set — and a pull
  request against its base branch. The README of a migrations directory is
  documentation, so it is out of the glob.

- **`docs/schema.md` is checked to be the output of the generator.** It is
  built from the migrations, the generator is deterministic, and the build
  fails when the committed file is not what `npm run docs:schema` produces. A
  hand-written line in a generated file is a lie that outlives the person who
  wrote it.

### Removed

- **`@ekwo-ai/core/fec` and the FEC re-exports of `@ekwo-ai/core` are gone.**
  The release that moved the format to `@ekwo-ai/fec` kept them alive for one
  version, and this is the next one: import `generateFec`, `checkFec`,
  `fecFileName`, `fromQueryRow`, `formatFecDate`, `formatFecAmount` and
  `FEC_COLUMNS` from `@ekwo-ai/fec`. The core still depends on it, because
  `EkwoClient.generateFec()` writes the file it has just fetched.

### Fixed

- **A `jsonb` argument crossed the direct-Postgres route as a Postgres array.**
  PostgREST posts the arguments of a function as JSON, so a `jsonb` parameter
  receives a real array there; a driver handed a JavaScript array builds an
  array *literal* instead, and `node-postgres` turns an array of objects into
  `{"[object Object]"}`. The SQL backend now stringifies an object or array
  argument and casts the placeholder to `jsonb`, so the two routes agree
  rather than agreeing by accident on one driver. Found while adding
  `opening_balance`, which is the first function to take one.

- `record_payment` (MCP) asked for a journal even when `bank_account_id` was
  given, although the account carries its journal. It now takes the journal
  from the account. Found on the first run against a real Supabase project.

- **`--db-region` built a pooler hostname and called it the answer.** The
  region does not determine the generation prefix: a project created in
  `eu-west-3` answers on `aws-1-eu-west-3.pooler.supabase.com` and returns
  "Tenant or user not found" on `aws-0-`, which reads like a wrong password
  rather than a wrong host. `--project-ref` with `--db-password` and
  `--db-region` now tries both generations on the session port, keeps the one
  that answers and prints it. Without `--db-region` nothing is derived at all:
  the CLI asks for the connection string the dashboard prints under Connect →
  Session pooler, because the direct host `db.<ref>.supabase.co` is IPv6-only
  on any recent project and deriving it silently produces a hang.
- **Three columns of `country_defaults` had no reader.**
  `sales_account_code`, `purchase_account_code` and `currency_code` were
  declared from the first release and consumed by nothing — the state the
  naming policy forbids. They are consumed now rather than deleted: migration
  `20260911193853` adds `companies.default_sales_account_id` and
  `default_purchase_account_id`, `install_country_template` wires them from
  the country model, and a document line that names no account is resolved by
  trigger — the line, then the company default, then the country model.
  `ekwo init` offers `country_defaults.currency_code` as the currency of the
  company, which has to happen before the insert: `companies.currency_code` is
  `not null default 'EUR'` and is never empty afterwards.

- **A freshly installed company refused its first payment.**
  `country_defaults.bank_account_code` was declared from the first release and
  read by nothing, so `install_country_template` left
  `journals.default_account_id` null on every journal and `post_payment()`
  found no bank side — the demo seed wired it by hand, which was the symptom.
  Migration `20260911183000` adds `cash_account_code` to the country model and
  points the bank and cash journals at their account (`550000` / `570000` in
  the PCMN, `512000` / `530000` in the PCG). A company that already chose a
  default account keeps it.
- **Nobody but the database owner could post an entry.** `next_entry_number()`
  and `next_matching_number()` write `journal_sequences` and
  `matching_sequences`, which carry a select policy and no other, and both ran
  as the caller — so posting a document or drawing a matching letter failed
  for every signed-in user with "new row violates row-level security policy".
  It went unnoticed because the tests and the installer both run as the owner.
  Migration `20260911173100` makes the two functions `security definer` and
  has each check that the caller may write the company it is counting for.
- Re-applying the tax seeds — a second `ekwo init` or `supabase db push` on
  the same project — failed on `tax_posting_templates`, which had no natural
  key to conflict on. Migration `20260911160000` adds it and the seeds use it;
  a test now applies every reference seed twice. Found on the first real
  installation.

- **`aged_balance` reported any group it did not know as receivable.** The
  function tested `p_group = 'payable'` twice and fell through to the
  receivable ageing on everything else, so `'supplier'`, `'creditors'`,
  `'Payable'` or a typo returned a full, plausible, wrong report — the one
  failure mode a report must not have, because nothing about it looks like an
  error. Migration `20260913104014` names the two groups and refuses anything
  else.

- **A cash-basis tax whose posting named no declaration box never settled.**
  `post_document()` writes `box_amount` only for a posting that names a box,
  and `settle_cash_basis_tax()` looks for lines that have one, so the amount
  landed on the transition account and stayed there — silently, for as long as
  nobody reconciled that account. Migration `20260913103355` refuses the
  combination where it is created, in the pack compiler and in the schema,
  rather than at the moment it would have gone wrong.

- **Seven columns defaulted to `'EUR'` and one to `'fr'`.** A company,
  document, payment, product, bank account or statement created without a
  currency got euros instead of an error — the country literals in another
  hat. Migration `20260913102758` drops the defaults; the value now comes from
  the pack of the fiscal country or from the row above, and a pack that says
  nothing is refused by name instead of assuming Europe.

- **A negative half was rounded three different ways by three packages.**
  `@ekwo-ai/factur-x`, `@ekwo-ai/xbrl-cbso` and `@ekwo-ai/mcp` each reached
  for `Math.round` or `toFixed`, which disagree on `-0.005`. Each carries the
  same half-up-on-the-absolute-value rounding now, which is what the schema
  does, so a credit note is its invoice with the sign flipped in the export as
  well as in the ledger.

- **A connection that could not declare itself the installer carried on.**
  `connect()` swallowed the failure of `set_config('ekwo.installing', …)`, and
  the run then failed five guards later with a message about a capability the
  operator cannot have. It closes the connection and raises where it happened.

### Security

- **A machine key could do anything, because it has no session.** Eleven
  functions and triggers were written as `if auth.uid() is not null and not
  has_capability(…) then raise`, which checks a signed-in caller and exempts a
  caller with no session. That was the installer, until `20260913085932` added
  API keys — a key is deliberately not a session, `auth.uid()` stays null, and
  every one of those guards stood aside. A key issued with `["entries.read"]`
  could post an entry, close a financial year, invite a member, create a
  company and issue itself a second key carrying every capability of the
  installation. Migration `20260913102115` names the exemption instead of
  inferring it: `is_installer()` is true only when the migration runner set
  `ekwo.installing` on its own connection, and false outright when there is a
  session or a key presenting itself. A caller reaching the database through
  PostgREST cannot set it.
- **`is_company_owner()` and `can_write_company()` answered NULL to a
  stranger, and `not NULL` never raises.** Inside a policy that is harmless;
  inside a `security definer` function it is the opposite, and the stranger
  walked past the exception into the body. `enable_module()` and
  `disable_module()` did exactly that, on a table with no write policy at all,
  so the function was the only door and the door was open. Migration
  `20260913101536` makes both helpers answer false rather than null.
- **`EKWO_ACCESS_TOKEN` was the second door for a `service_role` key.** The
  MCP server refused one in `SUPABASE_ANON_KEY` and not in the access token,
  which goes into the `Authorization` header — where PostgREST reads the role
  — so a key pasted there bypassed every policy while the anon key beside it
  made the configuration look right. It is refused in both slots now, by name.
- **A test now fails if any function of `public` is executable by PUBLIC.**
  The finding below was a README rule and a revoke in one migration; it is a
  test in `tests/hardening.test.ts`, which reads `proacl` — a null one counts,
  being the built-in default — so the next migration that forgets the revoke
  fails in CI rather than on a live project.
- **A function created after `20260911210131` was open again.** That migration
  changed the default privileges so that "a function added tomorrow starts
  closed", and PostgreSQL does not work that way: `alter default privileges …
  revoke execute on functions from public` does not delete the built-in world
  default, it is merged with it, so the next function created came out with
  `=X` — EXECUTE for PUBLIC, which on Supabase is an anonymous RPC endpoint.
  `install_country_template` was that function, for the length of one commit.
  Migration `20260912074712` repeats the revoke from PUBLIC (never from
  `anon`, which holds explicit grants on the eight policy helpers), and
  `supabase/migrations/README.md` makes it a rule for every migration that
  adds a function. `tests/hardening.test.ts` pins the list of functions
  `anon` may execute and is what caught it.
- The anonymous role could execute every function of the schema (Postgres
  grants EXECUTE to PUBLIC; Supabase exposes `public` functions as RPC). It
  now executes only the eight helpers the policies evaluate, and the default
  privileges keep it that way for functions added later. Migration
  `20260911210131`.
- `instance_admins` was readable by any signed-in user, member or not; a
  Supabase project accepts self sign-up by default. Administrators are now
  visible to members of a company, to administrators, and to oneself.
- README: a Security section that says to turn off public sign-ups on the
  project, and why an installation should keep two administrators.

## [0.1.0] — 2026-09-11

### Added

- **The instance.** `instance`, a singleton row written by the installer:
  a locally generated `instance_id`, the organisation, its country, the
  edition (`community` or `cloud`), the schema version and the install date.
  `contact_email` and `registered_at` are an opt-in, empty by default, read by
  nothing, and reversible through `unregister_instance()`. There is no
  `tenant_id` anywhere in the schema: the instance is the tenant.
- **An instance-level role.** `instance_admins`, keyed on the customer's own
  `auth.users`, says who may create companies and invite members; an
  administrator still cannot read a ledger they were not invited to.
  `init_instance()`, `claim_instance_admin()`, `register_instance()`,
  `unregister_instance()`, `is_instance_admin()` and `is_any_company_member()`
  come with it. Reading the `instance` row is for a member of at least one
  company or an administrator, and writing it is for an administrator.
- **Schema.** Thirty further tables across companies and membership, fiscal
  years, chart of accounts, journals, contacts, taxes and tax postings,
  journal entries and lines, documents and document lines, payments,
  reconciliations, bank accounts, statements and transactions, currencies and
  rates, analytic axes and values, and polymorphic attachments. Row level
  security on every one of them, driven by `company_members` and three roles:
  owner, accountant, viewer.
- **`account_type` with eighteen values**, grouped by a prefix that derives
  the balance-sheet group, so the aged balance, reconcilability and the
  statement mapping are computable instead of pattern-matched on codes.
- **`post_document(id)`**: base lines, tax lines built from `tax_postings`,
  and a third-party counterpart that balances by construction. A credit note
  flips the side rather than negating the amount; a self-assessed tax is
  booked on both sides and still fills both declaration boxes.
- **Numbering** per journal and per year, `CODE/YYYY/NNNN`, backed by a
  counter row rather than a lock on the journal.
- **Period locks**: `lock_date` and `tax_lock_date` on the company, closed
  fiscal years, enforced by triggers on entries and lines. Matching stays
  possible after a lock.
- **Bilateral matching**: `reconcile()` and `unreconcile()`, with a shared
  letter (`A0001`) and a residual maintained on each line. Matching a
  third-party line moves `documents.amount_paid`, and `amount_residual` and
  `payment_state` follow: what a document has been settled by is derived, not
  keyed in.
- **Reports**: `trial_balance`, `general_ledger`, `aged_balance`,
  `vat_return`, `fec_lines`. All of them filter posted entries in the `WHERE`
  clause, so a draft line cannot leak into a balance.
- **Country templates**: `account_templates`, `journal_templates`,
  `tax_templates`, `tax_posting_templates` and `country_defaults`, installed
  into a company by `install_country_template(company, country)`.
- **Seeds**: the Belgian PCMN (353 accounts) and the French PCG (392
  accounts), 19 Belgian and 17 French taxes with their ledger accounts and
  declaration boxes, eleven currencies, and a fictional demo company.
- **`@ekwo-ai/core`**: types of the schema, a thin client over the accounting
  functions, and the French FEC generator with its file-level checks.
- **Tests**: 166 of them, running every migration and seed against Postgres in
  WebAssembly, covering posting, credit notes, self-assessment, matching,
  period locks, reports, row level security, the instance singleton and its
  roles, and a golden FEC export.

[Unreleased]: https://github.com/Ekwo-ai/ekwo-os/compare/v0.4.1...HEAD
[0.4.1]: https://github.com/Ekwo-ai/ekwo-os/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/Ekwo-ai/ekwo-os/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/Ekwo-ai/ekwo-os/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/Ekwo-ai/ekwo-os/releases/tag/v0.2.0
