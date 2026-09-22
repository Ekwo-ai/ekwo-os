/**
 * Taking over books kept somewhere else: one function per surface and one
 * function in the schema.
 *
 * A reader of `packages/formats/` turns an export into the same shape whatever
 * produced it — accounts, parties, entries, a trial balance — and the schema's
 * `import_books()` writes that shape whole or not at all, through
 * `post_entry()`. What is left in between is what this file does, and it is
 * the part only the user can settle: **which account of this company's chart
 * each account of the old one becomes**, and which journal each old journal
 * goes to. A correspondence is proposed, shown, saved by the caller and given
 * back on the next run; nothing is posted while an account has no answer.
 *
 * Adding a source is adding a reader and one line to {@link BOOK_SOURCES}.
 * There is no second command.
 */

import { createHash } from 'node:crypto';
import { readFec, type ImportedBooks, type ImportedLine } from '@ekwo-ai/fec';
import { readTrialBalance } from '@ekwo-ai/trial-balance';
import { readJournalItems } from '@ekwo-ai/journal-items';
import { readJournalReport, type DateOrder } from '@ekwo-ai/journal-report';
import { BooksError, type Backend, type Row } from './backend.js';

export type { ImportedBooks, ImportedLine } from '@ekwo-ai/fec';

/** The sources an import reads, each by one brick of `packages/formats/`. */
export const BOOK_SOURCES = ['trial-balance', 'fec', 'journal-items', 'journal-report'] as const;
export type BookSource = (typeof BOOK_SOURCES)[number];

/** What each source is, in one sentence, for a help text and a tool description. */
export const BOOK_SOURCE_DESCRIPTIONS: Record<BookSource, string> = {
  'trial-balance': 'a trial balance as CSV — account, debit, credit, or a signed balance — which becomes the opening entry of a year',
  fec: 'a fichier des écritures comptables, the eighteen-column file of the arrêté of 29 July 2013',
  'journal-items':
    'an export of journal items as CSV — one row per line of an entry, with its entry, journal, date, account, partner, debit and credit — optionally with the chart of accounts and the partners exported beside it',
  'journal-report':
    'a journal report or a general ledger detail saved as CSV — date, journal number, account code, debit, credit — optionally with the chart of accounts and the contacts exported beside it',
};

/** The journal an entry is mapped to when it is to become the opening balance rather than an entry. */
export const OPENING = '@opening';

/** The key of the journal of an entry whose source names none. */
export const NO_JOURNAL = '*';

/** One file as the caller holds it. */
export interface BookFile {
  name: string;
  content: string | Uint8Array;
}

export interface ReadBooksOptions {
  /** How bytes are decoded, where a file arrives as bytes. Never guessed. */
  encoding?: 'utf-8' | 'iso-8859-1' | 'iso-8859-15' | undefined;
  /** For `journal-report`: how a date that is not ISO is written. Never guessed. */
  date_order?: DateOrder | undefined;
}

/**
 * The correspondence between the old books and this company. Saved as JSON by
 * the caller and given back on the next run, so the second run posts what the
 * first one showed. A null is an account nobody has answered for yet.
 */
export interface ImportMapping {
  version: 1;
  source: string;
  accounts: Record<string, string | null>;
  journals: Record<string, string | null>;
}

/** Reads the files of one source into the shape `import_books()` takes. */
export function readBooks(source: BookSource, files: BookFile[], options: ReadBooksOptions = {}): ImportedBooks {
  if (files.length === 0) throw new BooksError('missing_file: an import reads at least one file.');
  const single = (): BookFile => {
    if (files.length !== 1) {
      throw new BooksError(`too_many_files: ${source} reads one file, and ${files.length} were given.`);
    }
    return files[0] as BookFile;
  };
  switch (source) {
    case 'trial-balance': {
      const encoding = options.encoding === 'iso-8859-15' ? 'iso-8859-1' : options.encoding;
      return readTrialBalance(single().content, encoding === undefined ? {} : { encoding });
    }
    case 'fec': {
      const encoding = options.encoding === 'iso-8859-1' ? 'iso-8859-15' : options.encoding;
      return readFec(single().content, encoding === undefined ? {} : { encoding });
    }
    case 'journal-items':
      return readJournalItems(
        files.map((file) => file.content),
        options.encoding === undefined ? {} : { encoding: options.encoding === 'iso-8859-15' ? 'iso-8859-1' : options.encoding },
      );
    case 'journal-report':
      return readJournalReport(files.map((file) => file.content), {
        ...(options.encoding === undefined ? {} : { encoding: options.encoding === 'iso-8859-15' ? 'iso-8859-1' : options.encoding }),
        ...(options.date_order === undefined ? {} : { dateOrder: options.date_order }),
      });
  }
}

/** sha256 of the files, in the order given: what `book_imports` keys an import on. */
export function booksChecksum(files: BookFile[]): string {
  const hash = createHash('sha256');
  for (const file of files) hash.update(typeof file.content === 'string' ? Buffer.from(file.content, 'utf8') : file.content);
  return `sha256:${hash.digest('hex')}`;
}

interface ChartAccount {
  code: string;
  name: string;
  account_type: string;
  deprecated: boolean;
}

interface CompanyJournal {
  code: string;
  journal_type: string;
}

/** How a proposed account was found, so the user knows how much to trust it. */
export type MappingBasis = 'given' | 'exact' | 'same-digits' | 'prefix' | 'none';

export interface ProposedAccount {
  source: string;
  name: string | null;
  target: string | null;
  basis: MappingBasis;
}

export interface Proposal {
  mapping: ImportMapping;
  accounts: ProposedAccount[];
  unmapped_accounts: string[];
  unmapped_journals: string[];
  /** The type of each account of the chart, by code: what says a party is a customer or a supplier. */
  account_types: Record<string, string>;
}

/** A code without the zeros it was padded with on the right: `411000` and `411` are one account. */
function unpadded(code: string): string {
  const stripped = code.replace(/0+$/, '');
  return stripped === '' ? code : stripped;
}

/**
 * The account of the chart a code of the old books most probably is, and why.
 *
 * Only what the two codes say is read, never a country: the same code; the
 * same digits once the zeros a chart pads with on the right are set aside
 * (`411` and `411000`); and else the account of the chart whose digits are the
 * longest beginning of the old code, three at least (`401ACME` to `401000`).
 * A tie is no answer. Whatever comes out is a proposal the user reads.
 */
export function proposeAccount(code: string, chart: readonly ChartAccount[]): { target: string | null; basis: MappingBasis } {
  const live = chart.filter((account) => !account.deprecated);
  if (live.some((account) => account.code === code)) return { target: code, basis: 'exact' };

  const same = live.filter((account) => unpadded(account.code) === unpadded(code));
  if (same.length === 1) return { target: (same[0] as ChartAccount).code, basis: 'same-digits' };

  let best: ChartAccount[] = [];
  let length = 2;
  for (const account of live) {
    const digits = unpadded(account.code);
    if (digits.length > length && code.startsWith(digits)) {
      best = [account];
      length = digits.length;
    } else if (digits.length === length && length > 2 && code.startsWith(digits)) {
      best.push(account);
    }
  }
  if (best.length === 1) return { target: (best[0] as ChartAccount).code, basis: 'prefix' };
  return { target: null, basis: 'none' };
}

/**
 * The correspondence for these books in this company: what the caller gave,
 * and a proposal for everything it did not.
 */
export async function proposeMapping(
  backend: Backend,
  companyId: string,
  books: ImportedBooks,
  given: Partial<ImportMapping> = {},
): Promise<Proposal> {
  const [chart, journals, openingCode] = await Promise.all([
    wholeChart(backend, companyId),
    backend.select<CompanyJournal>({
      table: 'journals',
      columns: ['code', 'journal_type'],
      where: [
        { column: 'company_id', op: 'eq', value: companyId },
        { column: 'active', op: 'eq', value: true },
      ],
      order: [{ column: 'code' }],
    }),
    openingJournalCode(backend, companyId),
  ]);

  const names = new Map(books.accounts.map((account) => [account.code, account.name]));
  const codes = [...new Set([...books.accounts.map((a) => a.code), ...usedAccounts(books)])].sort();
  const accounts: ProposedAccount[] = codes.map((code) => {
    const answer = given.accounts?.[code];
    if (answer !== undefined && answer !== null) return { source: code, name: names.get(code) ?? null, target: answer, basis: 'given' };
    return { source: code, name: names.get(code) ?? null, ...proposeAccount(code, chart) };
  });

  const known = new Set(journals.map((journal) => journal.code));
  const general = journals.find((journal) => journal.journal_type === 'general')?.code ?? null;
  const journalMap: Record<string, string | null> = {};
  for (const source of [...new Set(books.entries.map((entry) => entry.journal ?? NO_JOURNAL))].sort()) {
    const answer = given.journals?.[source];
    if (answer !== undefined && answer !== null) journalMap[source] = answer;
    else if (openingCode !== null && source.toUpperCase() === openingCode) journalMap[source] = OPENING;
    else if (known.has(source.toUpperCase())) journalMap[source] = source.toUpperCase();
    else journalMap[source] = general;
  }

  // Only what these books use is kept: a saved correspondence from another
  // file does not carry answers for accounts this one never names.
  const used = new Set(usedAccounts(books));
  return {
    mapping: {
      version: 1,
      source: books.format,
      accounts: Object.fromEntries(accounts.map((account) => [account.source, account.target])),
      journals: journalMap,
    },
    accounts,
    unmapped_accounts: accounts.filter((a) => a.target === null && used.has(a.source)).map((a) => a.source),
    unmapped_journals: Object.entries(journalMap).filter(([, target]) => target === null).map(([source]) => source),
    account_types: Object.fromEntries(chart.map((account) => [account.code, account.account_type])),
  };
}

/**
 * Every account of the chart, a page at a time. A chart transcribed from a
 * regulation holds more than a thousand accounts, and a PostgREST project
 * returns a thousand rows unless asked for the next ones: a proposal made on
 * the first thousand would call an account missing that is not.
 */
async function wholeChart(backend: Backend, companyId: string): Promise<ChartAccount[]> {
  const page = 1000;
  const chart: ChartAccount[] = [];
  for (;;) {
    const last = chart[chart.length - 1]?.code;
    const rows = await backend.select<ChartAccount>({
      table: 'accounts',
      columns: ['code', 'name', 'account_type', 'deprecated'],
      where: [
        { column: 'company_id', op: 'eq', value: companyId },
        ...(last === undefined ? [] : [{ column: 'code', op: 'gt' as const, value: last }]),
      ],
      order: [{ column: 'code' }],
      limit: page,
    });
    chart.push(...rows);
    if (rows.length < page) return chart;
  }
}

/** Every account a line of these books names. */
function usedAccounts(books: ImportedBooks): string[] {
  const used = new Set<string>();
  for (const entry of books.entries) for (const line of entry.lines) used.add(line.account);
  for (const line of books.opening) used.add(line.account);
  return [...used];
}

/** The code of the journal the pack of this company opens its years on, or null. */
async function openingJournalCode(backend: Backend, companyId: string): Promise<string | null> {
  const rows = await backend.select<{ code: string }>({
    table: 'journals',
    columns: ['code'],
    where: [
      { column: 'company_id', op: 'eq', value: companyId },
      { column: 'journal_type', op: 'eq', value: 'opening' },
      { column: 'active', op: 'eq', value: true },
    ],
    order: [{ column: 'code' }],
  });
  return rows.length === 1 ? (rows[0] as { code: string }).code : null;
}

export interface ImportBooksArgs {
  company_id: string;
  source: BookSource;
  files: BookFile[];
  /** A correspondence saved from an earlier run. What it answers wins over the proposal. */
  mapping?: Partial<ImportMapping> | undefined;
  /** Show what would be written, write nothing. */
  dry_run?: boolean | undefined;
  /** Open the fiscal years the entries fall in, where the company has none. */
  open_years?: boolean | undefined;
  /** The first day of the year a trial balance opens, where the file says none. */
  opening_date?: string | undefined;
  /** Let a trial balance carry income and expense accounts: books taken over in the middle of a year. */
  allow_result_accounts?: boolean | undefined;
  /** Keep the numbers the entries had, where the country allows a number chosen by hand or the caller holds entries.import. */
  keep_numbers?: boolean | undefined;
  encoding?: ReadBooksOptions['encoding'];
  date_order?: DateOrder | undefined;
}

/**
 * Reads the files, settles the correspondence and hands the books to
 * `import_books()`. With `dry_run` the database rehearses the import and rolls
 * it back; without, it posts all of it or nothing.
 *
 * Refused before the database is asked: books whose reader found something
 * that does not add up, an account or a journal with no answer, a currency the
 * file names that is not the company's.
 */
export async function importBooks(backend: Backend, args: ImportBooksArgs): Promise<Record<string, unknown>> {
  const books = readBooks(args.source, args.files, { encoding: args.encoding, date_order: args.date_order });
  const proposal = await proposeMapping(backend, args.company_id, books, args.mapping ?? {});
  const read = {
    accounts: books.accounts.length,
    contacts: books.contacts.length,
    entries: books.entries.length,
    lines: books.entries.reduce((sum, entry) => sum + entry.lines.length, 0),
    opening_lines: books.opening.length,
  };
  const answer = {
    dry_run: args.dry_run === true,
    source: args.source,
    read,
    mapping: proposal.mapping,
    accounts: proposal.accounts,
    unmapped_accounts: proposal.unmapped_accounts,
    unmapped_journals: proposal.unmapped_journals,
    violations: books.violations,
  };

  const company = await backend.select<{ currency_code: string | null }>({
    table: 'companies',
    columns: ['currency_code'],
    where: [{ column: 'id', op: 'eq', value: args.company_id }],
  });
  const currency = company[0]?.currency_code ?? null;
  if (company[0] === undefined) throw new BooksError(`not_found: company ${args.company_id}. Either it does not exist, or you are not a member of it.`);

  const blocking: string[] = [];
  if (books.currency !== null && currency !== null && books.currency.toUpperCase() !== currency) {
    blocking.push(`import_currency_mismatch: the files are in ${books.currency} and the company keeps its books in ${currency}`);
  }
  if (books.violations.length > 0) {
    blocking.push(
      `import_violations: the files do not add up in ${books.violations.length} place${books.violations.length === 1 ? '' : 's'}; ` +
        books.violations.slice(0, 5).map((v) => `${v.row === null ? '' : `row ${v.row}: `}${v.message}`).join('; '),
    );
  }
  if (proposal.unmapped_accounts.length > 0) {
    blocking.push(`import_unmapped_accounts: no account of the chart answers for ${proposal.unmapped_accounts.join(', ')}. Say which in the correspondence`);
  }
  if (proposal.unmapped_journals.length > 0) {
    blocking.push(`import_unmapped_journals: no journal answers for ${proposal.unmapped_journals.join(', ')}. Say which in the correspondence`);
  }
  if (blocking.length > 0) {
    if (args.dry_run === true) {
      return { ...answer, result: null, refusals: blocking, note: 'Nothing was written, and nothing would be: the refusals above come first. Fill the correspondence and run it again.' };
    }
    throw new BooksError(blocking.join('\n'), {
      hint: 'Nothing was imported. Run the same import with dry_run to see the correspondence proposed, save it, answer what is missing, and give it back.',
    });
  }

  const payload = buildPayload(books, proposal.mapping, proposal.account_types, currency, args);
  payload['checksum'] = booksChecksum(args.files);
  payload['file_names'] = args.files.map((file) => file.name);

  const [result] = await backend.rpc<Row>('import_books', {
    p_company_id: args.company_id,
    p_books: payload,
    p_dry_run: args.dry_run === true,
    p_open_years: args.open_years === true,
    p_allow_result_accounts: args.allow_result_accounts === true,
  });
  const written = (result?.['import_books'] ?? result) as Row | undefined;
  return {
    ...answer,
    result: written ?? null,
    refusals: [],
    note:
      args.dry_run === true
        ? 'Nothing was written. The database ran the import and took it back, so the numbers are the ones it would take now and a refusal would have been the real one. Keep the correspondence and run it again without dry_run.'
        : 'Every entry is posted through post_entry() and numbered by the journal it went to; the numbers the old books used are kept as each entry\'s reference. Imported lines carry no tax, so they feed no box of a VAT return. The same files again are refused.',
  };
}

/** The books, translated into this company's codes, in the shape `import_books()` takes. */
function buildPayload(
  books: ImportedBooks,
  mapping: ImportMapping,
  accountTypes: Record<string, string>,
  currency: string | null,
  args: ImportBooksArgs,
): Record<string, unknown> {
  const account = (code: string): string => mapping.accounts[code] as string;
  // What a party is follows from where its lines are booked: on a receivable
  // it is a customer, on a payable a supplier, on both it is both.
  const roles = new Map<string, Set<string>>();
  const line = (source: ImportedLine): Row => {
    if (source.contact !== null) {
      const seen = roles.get(source.contact) ?? new Set<string>();
      const type = accountTypes[account(source.account)];
      if (type === 'asset_receivable') seen.add('customer');
      if (type === 'liability_payable') seen.add('supplier');
      roles.set(source.contact, seen);
    }
    const foreign = source.currency !== null && source.amountCurrency !== null && source.currency.toUpperCase() !== currency;
    return {
      account_code: account(source.account),
      contact_key: source.contact,
      label: source.label,
      debit: source.debit,
      credit: source.credit,
      currency_code: foreign ? (source.currency as string).toUpperCase() : null,
      amount_currency: foreign ? source.amountCurrency : null,
      date_maturity: source.dueDate,
    };
  };

  const entries: Row[] = [];
  const openingLines: Row[] = [];
  let openingDate: string | null = null;
  for (const entry of books.entries) {
    const journal = mapping.journals[entry.journal ?? NO_JOURNAL] as string;
    if (journal === OPENING) {
      if (openingDate !== null && openingDate !== entry.date) {
        throw new BooksError(
          `import_opening_dates: the entries mapped to the opening are dated ${openingDate} and ${entry.date}; an opening balance has one date, the first day of a year`,
        );
      }
      openingDate = entry.date;
      openingLines.push(...entry.lines.map(line));
      continue;
    }
    entries.push({
      journal_code: journal,
      date: entry.date,
      number: args.keep_numbers === true ? entry.number : null,
      reference: entry.reference ?? entry.number,
      description: entry.description,
      lines: entry.lines.map(line),
    });
  }
  if (books.opening.length > 0) {
    if (openingLines.length > 0) {
      throw new BooksError('import_two_openings: these books carry a trial balance and entries mapped to the opening; one opening per import');
    }
    if (args.opening_date === undefined) {
      throw new BooksError('missing_opening_date: a trial balance says nothing of the day it opens. Give the first day of the fiscal year it opens (opening_date).');
    }
    openingDate = args.opening_date;
    openingLines.push(...books.opening.map(line));
  } else if (args.opening_date !== undefined && openingDate === null) {
    throw new BooksError('unexpected_opening_date: an opening date was given and these books carry no balance to open');
  }

  const typeOf = (key: string): string => {
    const seen = roles.get(key) ?? new Set<string>();
    return seen.size === 2 ? 'both' : seen.size === 1 ? ([...seen][0] as string) : 'other';
  };
  const contacts = books.contacts
    .filter((contact) => roles.has(contact.code))
    .map((contact) => ({
      key: contact.code,
      name: contact.name,
      auxiliary_code: contact.code === contact.name ? null : contact.code,
      contact_type: typeOf(contact.code),
      vat_number: contact.vatNumber,
      registration_number: contact.registrationNumber,
      email: contact.email,
      country: contact.country,
    }));
  // A party named on a line that the files list nowhere else is still a party.
  for (const key of roles.keys()) {
    if (!contacts.some((contact) => contact.key === key)) {
      contacts.push({ key, name: key, auxiliary_code: null, contact_type: typeOf(key), vat_number: null, registration_number: null, email: null, country: null });
    }
  }

  return {
    source: books.format,
    contacts,
    entries,
    opening: openingDate === null ? null : { date: openingDate, lines: openingLines },
  };
}
