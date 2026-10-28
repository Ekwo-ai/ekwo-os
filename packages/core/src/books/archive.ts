/**
 * The archive of one company, read in pages.
 *
 * `export_company()` answers a whole company in one statement, which is one
 * request over the API and one clock: a large company does not fit it. Here
 * the same archive is read as many short requests (decision 0094): the
 * outline first, every table page after page, and the outline again at the
 * end. What is handed to `write` is the exact text of each data file, and the
 * manifest returned carries the checksums the database would have written —
 * so the files and the manifest are the archive `export_company()` answers,
 * byte for byte, and `import_company()` takes them as it takes that one.
 *
 * Each page is its own snapshot. If the books moved between the first outline
 * and the last — a count changed, or a table did not read the number of rows
 * its outline gave — the archive is refused, `archive_moved`, and the caller
 * reads it again. A member who may read fewer rows than a table holds is
 * refused `export_incomplete`, as `export_company()` refuses them.
 */

import { createHash, type Hash } from 'node:crypto';
import { BooksError, type Backend } from './backend.js';

export interface ArchiveTableEntry {
  name: string;
  file: string;
  rows: number;
  sha256?: string;
  values_sha256?: string;
}

export interface CompanyArchiveManifest {
  format: string;
  format_version: number;
  company: { id: string; name: string };
  tables: ArchiveTableEntry[];
  [key: string]: unknown;
}

interface ArchivePage {
  table: string;
  rows: number;
  lines: string;
  canonical: Record<string, string>;
  after: unknown;
}

export interface ReadArchiveOptions {
  /** Rows a page holds, 1 to 50000. Five thousand by default. */
  pageSize?: number;
  /** Called with the text of a data file, in order, page after page: append it to `file`. */
  write: (file: string, text: string, table: string) => Promise<void> | void;
  /** Called after each page, with the rows of its table read so far. */
  onPage?: (table: string, rowsRead: number) => Promise<void> | void;
}

export const ARCHIVE_PAGE_SIZE = 5000;

/** The archive of one company, read in pages and checked whole. Answers its manifest. */
export async function readCompanyArchive(
  backend: Backend,
  companyId: string,
  options: ReadArchiveOptions,
): Promise<CompanyArchiveManifest> {
  const pageSize = options.pageSize ?? ARCHIVE_PAGE_SIZE;
  // The act goes on the trail before anything is read, so the trail the
  // archive carries says it — and the outline it is checked against too.
  await backend.rpcVoid('note_company_export', { p_company_id: companyId });
  const before = await outlineOf(backend, companyId);

  const tables: ArchiveTableEntry[] = [];
  for (const table of before.tables) {
    const bytes = createHash('sha256');
    const values = createHash('sha256');
    let read = 0;
    let after: unknown = null;
    do {
      const page = await pageOf(backend, companyId, table.name, after, pageSize);
      if (page.lines.length > 0) await options.write(table.file, page.lines, table.name);
      digest(bytes, values, page);
      read += page.rows;
      after = page.after;
      await options.onPage?.(table.name, read);
    } while (after !== null && after !== undefined);

    if (read !== table.rows) {
      // Fewer rows than the table holds is a reader who may not see them all —
      // unless the books moved, which the outline says first.
      await assertUnmoved(backend, companyId, before);
      throw new BooksError(
        `export_incomplete: ${table.name} holds ${table.rows} rows for this company and you may read ${read} of them. An archive is whole or it is not written: ask for the reading capability you lack — or, for the table of a module, for the module to be enabled.`,
        { code: 'export_incomplete' },
      );
    }
    tables.push({ ...table, sha256: bytes.digest('hex'), values_sha256: values.digest('hex') });
  }

  await assertUnmoved(backend, companyId, before);

  return { ...before, tables };
}

/** The outline again, refused `archive_moved` when a count is not the one the reading started from. */
async function assertUnmoved(backend: Backend, companyId: string, before: CompanyArchiveManifest): Promise<void> {
  const end = await outlineOf(backend, companyId);
  const moved = end.tables.filter((t, i) => before.tables[i]?.name !== t.name || before.tables[i]?.rows !== t.rows);
  if (moved.length > 0 || end.tables.length !== before.tables.length) {
    throw new BooksError(
      `archive_moved: the books changed while they were read (${moved.map((t) => t.name).join(', ') || 'the list of tables'}). Each page is its own snapshot, so this archive is not one to keep: read it again.`,
      { code: 'archive_moved' },
    );
  }
}

async function outlineOf(backend: Backend, companyId: string): Promise<CompanyArchiveManifest> {
  const [outline] = await backend.rpc<CompanyArchiveManifest>('export_company_outline', { p_company_id: companyId });
  if (outline === undefined) throw new BooksError('export_company_outline() answered nothing');
  return outline;
}

async function pageOf(
  backend: Backend,
  companyId: string,
  table: string,
  after: unknown,
  limit: number,
): Promise<ArchivePage> {
  const [page] = await backend.rpc<ArchivePage>('export_company_page', {
    p_company_id: companyId,
    p_table: table,
    p_after: after,
    p_limit: limit,
  });
  if (page === undefined) throw new BooksError(`export_company_page() answered nothing for ${table}`);
  return page;
}

/**
 * Both checksums of a table, fed page after page: `sha256` over the lines as
 * written, `values_sha256` over the same lines with each row whose canonical
 * form differs replaced by it — which the database says, by place in the page.
 */
function digest(bytes: Hash, values: Hash, page: ArchivePage): void {
  bytes.update(page.lines, 'utf8');
  if (Object.keys(page.canonical).length === 0) {
    values.update(page.lines, 'utf8');
    return;
  }
  const lines = page.lines.split('\n');
  for (let i = 0; i < page.rows; i += 1) {
    values.update(`${page.canonical[String(i + 1)] ?? lines[i]}\n`, 'utf8');
  }
}
