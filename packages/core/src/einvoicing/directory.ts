/**
 * The transport that ships: a folder.
 *
 * It writes the file into `<root>/outbox/` and says where. No network, no
 * credential, no account anywhere — which is what makes it the default, the
 * one a self-hosted installation can use on the first day, and the one the
 * tests run end to end. Whatever carries the files further — a script that
 * uploads them to a portal, the client of an access point, a person — reads
 * the folder, and may answer through it:
 *
 *     <root>/outbox/<file>                       written once, never overwritten
 *     <root>/outbox/<file>.accepted_by_access_point
 *     <root>/outbox/<file>.delivered             a receipt: its text is the
 *     <root>/outbox/<file>.rejected              message, kept word for word
 *     <root>/inbox/<file>                        what arrived, read by receive()
 *
 * The channel is `self`: the company takes the file where it goes, through a
 * program of its own. A folder cannot tell whether an address is reachable,
 * and `lookup()` says exactly that.
 *
 * A file name carries the first twelve characters of the file's checksum, so
 * two issues of one document never meet in the folder, and writing the same
 * file twice is the same file — the second write finds it and checks it is
 * byte for byte the one it would have written.
 */

import { mkdir, readFile, readdir, stat, writeFile } from 'node:fs/promises';
import { basename, extname, join } from 'node:path';
import {
  TransportError,
  type EinvoiceFile,
  type EinvoiceTransport,
  type ReceivedFile,
  type Reachability,
  type SendMetadata,
  type Submission,
  type TransmissionOutcome,
} from './transport.js';

/** The answers a carrier may leave beside a file, in the order they are read: the furthest first. */
const RECEIPTS = ['delivered', 'rejected', 'accepted_by_access_point'] as const;

const OUTBOX = 'outbox';
const INBOX = 'inbox';

/** The media type of a file that arrived, from its name. Nothing is guessed beyond the extension. */
function mediaTypeOf(name: string): string {
  return extname(name).toLowerCase() === '.xml' ? 'application/xml' : 'application/octet-stream';
}

/** `invoice-INV-1.xml` and a checksum → `invoice-INV-1.0f343b093112.xml`. */
export function directoryFilename(file: Pick<EinvoiceFile, 'filename' | 'checksum'>): string {
  const safe = basename(file.filename).replace(/[^A-Za-z0-9._-]+/g, '-');
  const extension = extname(safe);
  const stem = extension === '' ? safe : safe.slice(0, -extension.length);
  return `${stem === '' ? 'einvoice' : stem}.${file.checksum.slice(0, 12)}${extension}`;
}

/** A reference this transport gave, and nothing else: `outbox/<one file name>`. */
function outboxPath(root: string, reference: string): string {
  const name = reference.startsWith(`${OUTBOX}/`) ? reference.slice(OUTBOX.length + 1) : '';
  if (name === '' || name !== basename(name) || name.startsWith('.')) {
    throw new TransportError(`unknown_reference: ${reference} is not a file this directory wrote`);
  }
  return join(root, OUTBOX, name);
}

async function exists(path: string): Promise<boolean> {
  return (await stat(path).catch(() => undefined)) !== undefined;
}

export interface DirectoryTransportOptions {
  /** Recorded as the service's name. A folder is the company's own act, so none by default. */
  service?: string | null;
}

/** The folder transport, rooted at `root`. The folders are created on first use. */
export function directoryTransport(root: string, options: DirectoryTransportOptions = {}): EinvoiceTransport {
  return {
    channel: 'self',
    service: options.service ?? null,

    async send(file: EinvoiceFile, _metadata: SendMetadata): Promise<Submission> {
      const name = directoryFilename(file);
      const path = join(root, OUTBOX, name);
      try {
        await mkdir(join(root, OUTBOX), { recursive: true });
        await writeFile(path, file.content, { encoding: 'utf8', flag: 'wx' });
      } catch (error) {
        const code = (error as NodeJS.ErrnoException).code;
        if (code !== 'EEXIST') {
          throw new TransportError(`directory_unwritable: ${(error as Error).message}`);
        }
        // Written already: the same file, or a refusal. Never overwritten.
        const there = await readFile(path, 'utf8');
        if (there !== file.content) {
          throw new TransportError(
            `directory_conflict: ${path} already holds another file under this name, and it is not overwritten`,
          );
        }
      }
      return { reference: `${OUTBOX}/${name}`, state: 'submitted', message: null };
    },

    async status(reference: string): Promise<TransmissionOutcome> {
      const path = outboxPath(root, reference);
      for (const state of RECEIPTS) {
        const receipt = `${path}.${state}`;
        if (await exists(receipt)) {
          const text = await readFile(receipt, 'utf8');
          return { state, message: text === '' ? null : text };
        }
      }
      // No receipt: the file is where it was written, or whatever carries the
      // files took it and has said nothing yet. Either way it was handed over.
      return { state: 'submitted', message: null };
    },

    async receive(): Promise<ReceivedFile[]> {
      const dir = join(root, INBOX);
      const names = (await readdir(dir).catch(() => [] as string[])).filter((name) => !name.startsWith('.')).sort();
      const out: ReceivedFile[] = [];
      for (const name of names) {
        const path = join(dir, name);
        const info = await stat(path);
        if (!info.isFile()) continue;
        out.push({
          reference: `${INBOX}/${name}`,
          filename: name,
          mediaType: mediaTypeOf(name),
          content: await readFile(path, 'utf8'),
          receivedAt: info.mtime.toISOString(),
        });
      }
      return out;
    },

    async lookup(): Promise<Reachability> {
      return { reachable: null, message: 'a directory cannot tell whether an address is reachable' };
    },
  };
}
