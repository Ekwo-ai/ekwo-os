/**
 * The piece behind a document: the PDF of a supplier's invoice, the photograph
 * of a receipt, the file a customer was sent.
 *
 * A piece goes on its document (decision 0069), in `attachments`. Nothing here
 * stores a byte: the caller has put the file where it keeps files — a bucket of
 * its Supabase project, a folder, any address its application understands —
 * and records where, with the name, the type, the size and the checksum that
 * prove which file it is. That is the doctrine of the bank statements, whose
 * file is recorded the same way by `import_bank_statement()`, and the archive
 * of a company carries these rows and lists the files they point at.
 *
 * Recording the same file twice on one document records it once: by its
 * checksum where the caller gives one, by where it is stored otherwise. So a
 * caller that repeats itself after a dropped connection gets the first row back
 * (`replayed: true`) rather than a second copy of the same piece.
 */

import { BooksError, type Backend, type Filter } from './backend.js';
import { onlyVisible } from './shared.js';

type Row = Record<string, unknown>;

/** The columns of a piece as it is answered. */
export const ATTACHMENT = [
  'id',
  'entity_type',
  'entity_id',
  'file_name',
  'mime_type',
  'byte_size::text',
  'storage_path',
  'checksum',
  'uploaded_by',
  'created_at',
];

export interface AttachDocumentFileArgs {
  /** The document the file is the piece of. */
  document_id: string;
  /** Where the caller stored the file: a path in its storage, or any address its application opens. */
  storage_path: string;
  /** The name the file had. */
  file_name: string;
  /** Its media type, `application/pdf` for instance. */
  mime_type?: string | undefined;
  /** Its size in bytes. */
  byte_size?: number | undefined;
  /** Its SHA-256, in hexadecimal: the same file recorded again is recognised by it. */
  checksum?: string | undefined;
}

/**
 * Records a file as the piece of a document. The document must be one the
 * caller sees, and the row is written under its company with
 * `documents.write`, as the policy of `attachments` asks; a document's piece
 * may be recorded whatever its state, a posted invoice's included, since the
 * piece is what the entry was posted from.
 */
export async function attachDocumentFile(backend: Backend, args: AttachDocumentFileArgs): Promise<unknown> {
  if (args.byte_size !== undefined && (!Number.isInteger(args.byte_size) || args.byte_size < 0)) {
    throw new BooksError(`bad_value: byte_size is a whole number of bytes, got ${args.byte_size}.`);
  }
  const document = onlyVisible(
    await backend.select<Row>({
      table: 'documents',
      columns: ['id', 'company_id'],
      where: [{ column: 'id', op: 'eq', value: args.document_id }],
    }),
    `document ${args.document_id}`,
  );

  const same: Filter =
    args.checksum === undefined
      ? { column: 'storage_path', op: 'eq', value: args.storage_path }
      : { column: 'checksum', op: 'eq', value: args.checksum };
  const [before] = await backend.select<Row>({
    table: 'attachments',
    columns: ATTACHMENT,
    where: [
      { column: 'entity_type', op: 'eq', value: 'document' },
      { column: 'entity_id', op: 'eq', value: args.document_id },
      same,
    ],
    limit: 1,
  });
  if (before !== undefined) return { attachment: before, replayed: true };

  const row: Row = Object.fromEntries(
    Object.entries({
      company_id: document['company_id'],
      entity_type: 'document',
      entity_id: args.document_id,
      file_name: args.file_name,
      storage_path: args.storage_path,
      mime_type: args.mime_type,
      byte_size: args.byte_size,
      checksum: args.checksum,
    }).filter(([, value]) => value !== undefined),
  );
  const [created] = await backend.insert<Row>('attachments', [row], ATTACHMENT);
  if (created === undefined) throw new BooksError('the file could not be recorded on the document');
  return { attachment: created };
}

export interface ListDocumentFilesArgs {
  document_id: string;
}

/** The pieces recorded on a document, the first recorded first. */
export async function listDocumentFiles(backend: Backend, args: ListDocumentFilesArgs): Promise<unknown> {
  onlyVisible(
    await backend.select<Row>({
      table: 'documents',
      columns: ['id'],
      where: [{ column: 'id', op: 'eq', value: args.document_id }],
    }),
    `document ${args.document_id}`,
  );
  const attachments = await backend.select<Row>({
    table: 'attachments',
    columns: ATTACHMENT,
    where: [
      { column: 'entity_type', op: 'eq', value: 'document' },
      { column: 'entity_id', op: 'eq', value: args.document_id },
    ],
    order: [{ column: 'created_at' }],
  });
  return { document_id: args.document_id, attachments, count: attachments.length };
}
