/**
 * What is in the box, and what is not yet.
 *
 * Every tile carries `proof`: a path in this repository that is the reason the
 * tile says what it says. `tests/` checks that each path exists, which is a
 * weak test of a strong rule — the rule is that nobody adds a tile here
 * without being able to point at the thing. A tile is `shipped` only when that
 * path is a function, a module, a brick or a command that exists today;
 * anything else is `planned`, and anything that is neither is simply absent.
 *
 * `planned` is deliberately quiet on the page. It is where this is going, said
 * once, with no date attached to any of it — a roadmap with dates on a home
 * page is a promise somebody else has to keep.
 */

export type Status = 'shipped' | 'planned';

/**
 * The four families the grid reads in.
 *
 * They are the positioning line taken seriously: accounting is the core that
 * ships, finance is what ships around it, and the last two are where the
 * ledger is going. A family with nothing but `planned` in it says so on the
 * page rather than being quietly dropped.
 */
export type Family = 'accounting' | 'finance' | 'sustainability' | 'digital' | 'documents';

export interface Capability {
  /** Lucide icon name, rendered from the inline set in `pages/icons.tsx`. */
  icon: string;
  title: string;
  body: string;
  status: Status;
  family: Family;
  /** The path in this repository that proves the tile. Checked by a test. */
  proof: string;
}

/** The grid: what a business actually keeps books with. */
export const CAPABILITIES: Capability[] = [
  {
    icon: 'fileText',
    title: 'Sales and invoices',
    family: 'accounting',
    body: 'Draft, number and post an invoice or a credit note under the numbering rule the country prescribes.',
    status: 'shipped',
    proof: 'supabase/migrations/20260911120900_post_document.sql',
  },
  {
    icon: 'shoppingCart',
    title: 'Purchases and suppliers',
    family: 'accounting',
    body: 'The same documents the other way round, with the tax recovered — or not — as the country says.',
    status: 'shipped',
    proof: 'supabase/migrations/20260911120500_documents.sql',
  },
  {
    icon: 'landmark',
    title: 'Bank and reconciliation',
    family: 'finance',
    body: 'Import a statement, match a payment against what it settles, and let the reference do it for you.',
    status: 'shipped',
    proof: 'supabase/migrations/20260918150931_a_statement_is_imported_once.sql',
  },
  {
    icon: 'fileText',
    title: 'VAT, from the box to the filing',
    family: 'accounting',
    body: 'The return is computed from the books, frozen box by box, filed, and settled to the account the pack names.',
    status: 'shipped',
    proof: 'docs/filing.md',
  },
  {
    icon: 'bookCheck',
    title: 'Year-end close',
    family: 'accounting',
    body: 'Opening balances, closing the year into the accounts the country uses, and opening it again when you must.',
    status: 'shipped',
    proof: 'supabase/migrations/20260912094412_opening_and_closing.sql',
  },
  {
    icon: 'chartColumn',
    title: 'Reports and statements',
    family: 'accounting',
    body: 'Trial balance, general ledger, aged balance, and the statutory statements of the country — one call each.',
    status: 'shipped',
    proof: 'supabase/migrations/20260912100412_financial_statements.sql',
  },
  {
    icon: 'send',
    title: 'Electronic invoicing',
    family: 'accounting',
    body: 'Write and validate a Peppol BIS 3 or Factur-X invoice, with the sentences the country puts on it.',
    status: 'shipped',
    proof: 'packages/formats/peppol-ubl',
  },
  {
    icon: 'boxes',
    title: 'Fixed assets',
    family: 'finance',
    body: 'Depreciation schedules and disposals, on the durations and conventions the country pack declares.',
    status: 'shipped',
    proof: 'modules/assets',
  },
  {
    icon: 'target',
    title: 'Budgets',
    family: 'finance',
    body: 'A budget per year and per account, and the variance against what the books actually hold.',
    status: 'shipped',
    proof: 'modules/budgets',
  },
  {
    icon: 'building',
    title: 'Many companies, one installation',
    family: 'finance',
    body: 'A firm keeps forty clients in six countries as forty rows, each with its own chart, locks and pack.',
    status: 'shipped',
    proof: 'docs/firms.md',
  },
  {
    icon: 'packageOpen',
    title: 'Leave whenever you like',
    family: 'finance',
    body: 'A company exports whole — books, declarations and the proof they were filed — and imports into another installation.',
    status: 'shipped',
    proof: 'docs/company-archive.md',
  },
  {
    icon: 'terminal',
    title: 'A command line, and an API',
    family: 'accounting',
    body: 'Every operation from a terminal or a script, with JSON output and exit codes a program can read.',
    status: 'shipped',
    proof: 'packages/cli',
  },
  {
    icon: 'plug',
    title: 'A server for agents',
    family: 'accounting',
    body: 'The same operations exposed over the Model Context Protocol, under the rights of the person the agent acts for.',
    status: 'shipped',
    proof: 'packages/mcp',
  },
];

/**
 * The two modules that are decided and not written.
 *
 * They get cards of their own rather than a line in the grid, because they are
 * the half of the positioning line that is a direction: the shape of each is
 * settled — a Postgres schema of its own, reaching the ledger through
 * `post_entry()` and never behind its back, like `assets` and `budgets` — and
 * neither exists. `modules/README.md` is where that is written down, and is
 * what the card links to. The word on the pill is the whole claim: read the
 * card with the pill covered and it must still not sound like something a
 * reader could install today.
 */
export const PLANNED_MODULES: Capability[] = [
  {
    icon: 'leaf',
    title: 'Carbon, on the same ledger as money',
    body:
      'A tonne of CO₂ accounted for as strictly as a euro: emission factors loaded as ' +
      'versioned, sourced data the way a country pack is, from the purchases already booked ' +
      'or from physical quantities, each tonne tied to the entry that justifies it.',
    status: 'planned',
    family: 'sustainability',
    proof: 'modules/README.md',
  },
  {
    icon: 'penLine',
    title: 'Signing, in the open',
    body:
      'A document, its signatories and where each of them stands, with the trail of proof ' +
      'written as somebody signs. Which level of signature a deed needs is the law of a ' +
      'country, so it is pack data; the qualified part is a trust provider you choose, the ' +
      'way the bank and the network already are.',
    status: 'planned',
    family: 'documents',
    proof: 'modules/README.md',
  },
  {
    icon: 'coins',
    title: 'Digital assets, as their own thing',
    body:
      'Not one more bank account: wallets and venues, acquisition lots, fair value at the ' +
      'close, realised gains by the method the country allows — with the exchange exports ' +
      'read by format libraries, like every other file.',
    status: 'planned',
    family: 'digital',
    proof: 'modules/README.md',
  },
];

/** The automation section: what happens without somebody typing it. */
export const AUTOMATION: Capability[] = [
  {
    icon: 'send',
    title: 'Electronic invoices, written and checked',
    family: 'accounting',
    body: 'A brick writes the Peppol BIS 3 or Factur-X file and validates it against the standard. Sending and receiving over the network is the operated edition — the file itself is yours either way.',
    status: 'shipped',
    proof: 'packages/formats/peppol-ubl',
  },
  {
    icon: 'download',
    title: 'Statements in, matched',
    family: 'finance',
    body: 'camt.053, CODA and CFONB 120 import once however often you replay the file; a payment finds the invoice it settles by its reference.',
    status: 'shipped',
    proof: 'packages/formats/camt053',
  },
  {
    icon: 'activity',
    title: 'Every report is one call away',
    family: 'accounting',
    body: 'Trial balance, aged balance, the VAT return and what is due when — for a person, a script or an agent, through the same functions.',
    status: 'shipped',
    proof: 'supabase/migrations/20260911121000_reporting.sql',
  },
  {
    icon: 'scanLine',
    title: 'From a PDF to a draft',
    body:
      'Your model reads the supplier invoice and calls the same tools a person would: the ' +
      'contact, then the draft with its lines, accounts and taxes. The database works out the ' +
      'totals, and nothing is booked until somebody posts it. Ekwo carries no reader of its ' +
      'own and does not need one.',
    status: 'shipped',
    family: 'accounting',
    proof: 'packages/mcp/src/tools/write.ts',
  },
];
