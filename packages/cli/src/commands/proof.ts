/**
 * `ekwo proof` — the hash of a filed file, committed to a public ledger.
 *
 *   proof stamp <file> --filing <id> | --year <id> | --document <id>
 *       The sha256 of the file goes to the public OpenTimestamps calendars and
 *       the pending proof is recorded on the declaration, the financial year
 *       (its annual accounts) or the document. Only the hash leaves.
 *   proof upgrade
 *       Every pending proof of the company in use is asked about again; those
 *       a Bitcoin block now anchors are completed with the time of that block.
 *       Made to run on a schedule: with EKWO_EMAIL and EKWO_PASSWORD (or
 *       EKWO_ACCESS_TOKEN) beside SUPABASE_URL and SUPABASE_ANON_KEY, nothing
 *       is read from the disk.
 *   proof verify <file> [--ots <proof.ots>] [--out <proof.ots>]
 *       The file is hashed and its proof checked against the Bitcoin block it
 *       names. With --ots nothing of any installation is read; without it, the
 *       proof is the one the installation publishes for that hash.
 *
 * The network and the format are `@ekwo-ai/core`; the rules are the
 * database's, and a refusal is left to `output.ts` to repeat word for word.
 */

import { readFile, writeFile } from 'node:fs/promises';
import {
  checkProof,
  lookupFilingProof,
  proveFile,
  sha256,
  toHex,
  upgradeFilingProofs,
  type FilingProofSubject,
  type NetworkOptions,
  type ProofFetch,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, pairs } from '../ui.js';

export interface ProofDeps extends BooksDeps {
  /** The calendars and the block explorer, when a test stands in for them. */
  proofFetch?: ProofFetch | undefined;
}

const NETWORK_FLAGS = ['calendar', 'upgrade-calendar', 'explorer'] as const;
const STAMP_FLAGS = [...BOOKS_FLAGS, ...NETWORK_FLAGS, 'filing', 'year', 'document', 'attachment'] as const;
const UPGRADE_FLAGS = [...BOOKS_FLAGS, ...NETWORK_FLAGS] as const;
const VERIFY_FLAGS = [...BOOKS_FLAGS, 'explorer', 'ots', 'out', 'offline'] as const;

export const PROOF_USAGE =
  'usage: ekwo proof stamp <file> --filing <id> | --year <id> | --document <id> [--attachment <id> --calendar <url>…]' +
  ' | ekwo proof upgrade [--upgrade-calendar <url>… --explorer <url>]' +
  ' | ekwo proof verify <file> [--ots <proof.ots>] [--out <proof.ots>] [--explorer <url> | --offline]';

type Row = Record<string, unknown>;

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

function network(args: ParsedArgs, deps: ProofDeps): NetworkOptions {
  const calendars = stringFlags(args, 'calendar');
  const upgradeCalendars = stringFlags(args, 'upgrade-calendar');
  const explorer = stringFlag(args, 'explorer');
  return {
    fetch: deps.proofFetch ?? ((url, init) => globalThis.fetch(url, init as RequestInit | undefined)),
    ...(calendars.length === 0 ? {} : { calendars }),
    ...(upgradeCalendars.length === 0 ? {} : { upgradeCalendars }),
    ...(explorer === undefined ? {} : { explorer }),
  };
}

async function readBytes(path: string | undefined, what: string): Promise<Uint8Array> {
  if (path === undefined) throw new UsageError(`missing_argument: ${what} was not given.`);
  try {
    return new Uint8Array(await readFile(path));
  } catch (error) {
    throw new UsageError(`unreadable_file: ${path}: ${(error as Error).message}`);
  }
}

function subjectOf(args: ParsedArgs): { kind: FilingProofSubject; id: string } {
  const given = (
    [
      ['tax_filing', stringFlag(args, 'filing'), '--filing'],
      ['fiscal_year', stringFlag(args, 'year'), '--year'],
      ['document', stringFlag(args, 'document'), '--document'],
    ] as const
  ).filter(([, value]) => value !== undefined);
  if (given.length !== 1) {
    throw new UsageError(
      'missing_argument: say what the file proves, once: --filing <declaration id>, --year <financial year id> for its annual accounts, or --document <document id>.',
    );
  }
  const [kind, value, flag] = given[0] as (typeof given)[number];
  return { kind, id: uuidArg(value, flag) };
}

function printProof(proof: Row): void {
  pairs([
    ['sha256', text(proof['sha256'])],
    ['status', text(proof['status'])],
    ...(proof['anchor_chain'] === null || proof['anchor_chain'] === undefined
      ? []
      : ([
          ['anchored', `${text(proof['anchor_chain'])} block ${text(proof['anchor_height'])}`],
          ['block time', text(proof['anchor_time'])],
        ] as [string, string][])),
  ]);
}

async function stamp(args: ParsedArgs, deps: ProofDeps): Promise<number> {
  rejectUnknownFlags(args, STAMP_FLAGS);
  const bytes = await readBytes(args.positional[1], 'the file to prove');
  const subject = subjectOf(args);
  const attachment = stringFlag(args, 'attachment');
  const { backend, company } = await openBooks(args, deps);

  const result = await proveFile(
    backend,
    {
      subject_kind: subject.kind,
      subject_id: subject.id,
      bytes,
      ...(attachment === undefined ? {} : { attachment_id: uuidArg(attachment, '--attachment') }),
    },
    network(args, deps),
  );
  setResult(result);

  const proof = result['proof'] as Row;
  heading(result['already_proved'] === true ? `Already proved, in ${company.name}` : `Submitted, in ${company.name}`);
  printProof(proof);
  line();
  note(dim('Only the sha256 of the file left this machine. The proof is pending until a calendar commits it to a Bitcoin block, usually within a few hours: run `ekwo proof upgrade`.'));
  return 0;
}

async function upgrade(args: ParsedArgs, deps: ProofDeps): Promise<number> {
  rejectUnknownFlags(args, UPGRADE_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const report = await upgradeFilingProofs(backend, company.id, network(args, deps));
  setResult(report);

  heading(`Proofs of ${company.name}`);
  pairs([
    ['checked', String(report.checked)],
    ['anchored now', String(report.completed.length)],
    ['still pending', String(report.pending.length)],
  ]);
  for (const proof of report.completed) {
    line();
    printProof(proof);
  }
  return 0;
}

async function verify(args: ParsedArgs, deps: ProofDeps): Promise<number> {
  rejectUnknownFlags(args, VERIFY_FLAGS);
  const bytes = await readBytes(args.positional[1], 'the file to verify');
  const digest = toHex(sha256(bytes));
  const offline = boolFlag(args, 'offline');
  const explorer = stringFlag(args, 'explorer');
  if (offline && explorer !== undefined) throw new UsageError('conflicting_flags: --offline asks no explorer, and --explorer names one.');

  let ots: Uint8Array | undefined;
  let published: Row | undefined;
  const otsPath = stringFlag(args, 'ots');
  if (otsPath !== undefined) {
    ots = await readBytes(otsPath, 'the proof');
  } else {
    const { backend } = await openBooks(args, deps);
    const found = (await lookupFilingProof(backend, digest)).find((p) => p.method === 'opentimestamps');
    if (found !== undefined) {
      published = { ...found };
      delete published['proof_base64'];
      ots = new Uint8Array(Buffer.from(found.proof_base64, 'base64'));
    }
  }

  if (ots === undefined) {
    setResult({ sha256: digest, proved: false, published: null, check: null });
    heading('Not proved');
    note(`No proof is published for sha256 ${digest}.`);
    return 1;
  }

  const fetch = deps.proofFetch ?? ((url: string, init?: Parameters<ProofFetch>[1]) => globalThis.fetch(url, init as RequestInit | undefined));
  const check = await checkProof(
    bytes,
    ots,
    offline ? undefined : { fetch, ...(explorer === undefined ? {} : { explorer }) },
  );
  const outPath = stringFlag(args, 'out');
  if (outPath !== undefined) await writeFile(outPath, ots);

  const proved = check.matches_file && check.bitcoin.length > 0;
  setResult({ sha256: digest, proved, published: published ?? null, check, ...(outPath === undefined ? {} : { written: outPath }) });

  heading(proved ? 'Proved' : check.matches_file ? 'Pending' : 'Not this file');
  pairs([
    ['sha256', digest],
    ['proof is about this file', check.matches_file ? 'yes' : 'no'],
    ...check.bitcoin.map(
      (b): [string, string] => ['bitcoin block', `${String(b.height)}${b.time === undefined ? ' (not checked)' : `, ${b.time}`}`],
    ),
    ...(check.pending.length === 0 ? [] : ([['waiting on', check.pending.join(', ')]] as [string, string][])),
  ]);
  if (outPath !== undefined) note(dim(`The proof is written to ${outPath}; any OpenTimestamps verifier reads it.`));
  return check.matches_file ? 0 : 1;
}

export async function proofCommand(args: ParsedArgs, deps: ProofDeps = {}): Promise<number> {
  const [action] = args.positional;
  if (action === 'stamp') return stamp(args, deps);
  if (action === 'upgrade') return upgrade(args, deps);
  if (action === 'verify') return verify(args, deps);
  throw new UsageError(PROOF_USAGE);
}
