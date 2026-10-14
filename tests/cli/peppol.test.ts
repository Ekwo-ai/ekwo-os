/**
 * `ekwo peppol validate | lookup`: the Peppol network from a terminal, with no
 * installation and no sign-in.
 *
 * The reading and the identifiers are the brick's, tested in
 * `packages/formats/peppol-ubl`; what is asked here is what the core adds —
 * the electronic addresses of a received file checked as participants, and an
 * SML answer read off its NAPTR record — and that the command line carries
 * both to the output contract with the exit code it gives. The DNS is a
 * stand-in: no test asks the real network anything.
 */

import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { SML_ZONES, lookupPeppolParticipant, readPeppolFile, smpOfNaptr, type NaptrRecord, type NaptrResolver } from '../../packages/core/src/index.js';
import { EXIT_ERROR, EXIT_OK, EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { smlHostname } from '../../packages/formats/peppol-ubl/src/index.js';
import { repoRoot } from '../helpers/db.js';

type Row = Record<string, unknown>;

const fixtures = join(repoRoot, 'packages', 'formats', 'peppol-ubl', 'test', 'fixtures');
/** A participant of the fixtures: an enterprise number of a range nobody was issued, with check digits that pass. */
const PARTICIPANT = '0208:0999999922';
const SMP = 'https://smp.example.test';

const record = (overrides: Partial<NaptrRecord> = {}): NaptrRecord => ({
  flags: 'U',
  service: 'Meta:SMP',
  regexp: `!^.*$!${SMP}!`,
  replacement: '',
  order: 100,
  preference: 10,
  ...overrides,
});

/** A DNS that knows one name, and answers the others as a DNS does. */
function dns(known: Record<string, NaptrRecord[]>): NaptrResolver & { asked: string[] } {
  const asked: string[] = [];
  const resolve = async (hostname: string): Promise<NaptrRecord[]> => {
    asked.push(hostname);
    const records = known[hostname.toLowerCase()];
    if (records === undefined) throw Object.assign(new Error(`queryNaptr ENOTFOUND ${hostname}`), { code: 'ENOTFOUND' });
    return records;
  };
  return Object.assign(resolve, { asked });
}

let schema: Row;
let dir: string;
let standard: string;

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  dir = await mkdtemp(join(tmpdir(), 'ekwo-peppol-'));
  standard = await readFile(join(fixtures, 'invoice-standard.xml'), 'utf8');
});

afterAll(async () => {
  await rm(dir, { recursive: true, force: true });
});

async function capture(fn: () => Promise<number>): Promise<{ exitCode: number; stdout: string }> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  process.stdout.write = ((chunk: string | Uint8Array) => ((stdout += String(chunk)), true)) as typeof process.stdout.write;
  process.stderr.write = (() => true) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

/** Runs a command under --json, with the stand-in DNS, and holds the answer to the schema. */
async function ekwo(argv: string[], resolveNaptr?: NaptrResolver): Promise<OutputDocument> {
  const captured = await capture(() => run([...argv, '--json'], { resolveNaptr }));
  const document = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(captured.exitCode);
  if (document.data !== undefined) {
    const shape = ((schema['$defs'] as Record<string, Row>)['data'] ?? {})[document.command];
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape as Row, schema)).toEqual([]);
  }
  return document;
}

describe('readPeppolFile', () => {
  it('reads a received file and names no rule where none is broken', () => {
    const { invoice, violations } = readPeppolFile(standard);
    expect(violations).toEqual([]);
    expect(invoice.seller.electronicAddress).toEqual({ scheme: '0208', value: '0999999922' });
  });

  it('checks both electronic addresses as participants, check digits included', () => {
    const wrong = standard.replace('>0999999922<', '>0999999921<');
    const { violations } = readPeppolFile(wrong);
    expect(violations).toHaveLength(1);
    expect(violations[0]).toMatchObject({ code: 'invalid_electronic_address' });
    expect(violations[0]?.message).toContain('BT-34');
    expect(violations[0]?.message).toContain('check digits');
  });
});

describe('lookupPeppolParticipant', () => {
  it('asks the name the SML publishes the identifier under, and reads the SMP off the record', async () => {
    const hostname = smlHostname(PARTICIPANT, SML_ZONES.test, 'naptr');
    const resolver = dns({ [hostname.toLowerCase()]: [record()] });
    const answer = await lookupPeppolParticipant(`iso6523-actorid-upis::${PARTICIPANT}`, { zone: SML_ZONES.test, resolveNaptr: resolver });
    expect(resolver.asked).toEqual([hostname]);
    expect(answer).toMatchObject({ registered: true, smp: SMP, hostname, zone: SML_ZONES.test });
    expect(answer.check.identifier).toBe(PARTICIPANT);
  });

  it('says not registered where the name does not exist, and asks nothing for an identifier that is not one', async () => {
    const resolver = dns({});
    expect(await lookupPeppolParticipant(PARTICIPANT, { zone: SML_ZONES.production, resolveNaptr: resolver })).toMatchObject({
      registered: false,
      smp: null,
    });
    const wrong = await lookupPeppolParticipant('0208:0999999921', { zone: SML_ZONES.production, resolveNaptr: resolver });
    expect(wrong).toMatchObject({ registered: null, hostname: null });
    expect(wrong.check.problems.map((p) => p.code)).toEqual(['invalid_check_digits']);
    expect(resolver.asked).toHaveLength(1);
  });

  it('does not turn a resolver that failed into an answer', async () => {
    const failing: NaptrResolver = async () => {
      throw Object.assign(new Error('queryNaptr ETIMEOUT'), { code: 'ETIMEOUT' });
    };
    await expect(lookupPeppolParticipant(PARTICIPANT, { zone: SML_ZONES.production, resolveNaptr: failing })).rejects.toThrow('ETIMEOUT');
  });

  it('reads only a record of service Meta:SMP with flag U, whatever its delimiter', () => {
    expect(smpOfNaptr(record({ regexp: `#^.*$#${SMP}#` }))).toBe(SMP);
    expect(smpOfNaptr(record({ service: 'Meta:Other' }))).toBeNull();
    expect(smpOfNaptr(record({ flags: 'S' }))).toBeNull();
    expect(smpOfNaptr(record({ regexp: '' }))).toBeNull();
  });
});

describe('ekwo peppol', () => {
  it('validate: a file that breaks no rule ends on 0', async () => {
    const path = join(dir, 'standard.xml');
    await writeFile(path, standard);
    const document = await ekwo(['peppol', 'validate', path]);
    expect(document.command).toBe('peppol validate');
    expect(document.exitCode).toBe(EXIT_OK);
    expect(document.data).toMatchObject({ valid: true, violations: [], seller: { electronic_address: PARTICIPANT } });
  });

  it('validate: a file that breaks one ends on 1, the rule named', async () => {
    const path = join(dir, 'wrong-address.xml');
    await writeFile(path, standard.replace('>0999999922<', '>0999999921<'));
    const document = await ekwo(['peppol', 'validate', path]);
    expect(document.exitCode).toBe(EXIT_ERROR);
    expect(document.data).toMatchObject({ valid: false, violations: [{ code: 'invalid_electronic_address' }] });
  });

  it('validate: a file that is not an invoice is a wrong call, by its name', async () => {
    const path = join(dir, 'not-an-invoice.xml');
    await writeFile(path, '<?xml version="1.0" encoding="UTF-8"?><Order xmlns="urn:example"/>');
    const document = await ekwo(['peppol', 'validate', path]);
    expect(document.exitCode).toBe(EXIT_USAGE);
    expect(document.error?.message).toMatch(/^not_an_invoice: /);
  });

  it('lookup: registered ends on 0, with the SMP; --test asks the acceptance network', async () => {
    const hostname = smlHostname(PARTICIPANT, SML_ZONES.test, 'naptr');
    const document = await ekwo(['peppol', 'lookup', PARTICIPANT, '--test'], dns({ [hostname.toLowerCase()]: [record()] }));
    expect(document.command).toBe('peppol lookup');
    expect(document.exitCode).toBe(EXIT_OK);
    expect(document.data).toMatchObject({ network: 'test', zone: SML_ZONES.test, hostname, registered: true, smp: SMP });
  });

  it('lookup: not registered, or not an identifier, ends on 1', async () => {
    const absent = await ekwo(['peppol', 'lookup', PARTICIPANT], dns({}));
    expect(absent.exitCode).toBe(EXIT_ERROR);
    expect(absent.data).toMatchObject({ network: 'production', zone: SML_ZONES.production, registered: false });
    const malformed = await ekwo(['peppol', 'lookup', '0999999922'], dns({}));
    expect(malformed.exitCode).toBe(EXIT_ERROR);
    expect(malformed.data).toMatchObject({ valid: false, registered: null, problems: [{ code: 'malformed' }] });
  });

  it('answers a verb it does not know with its usage', async () => {
    const document = await ekwo(['peppol', 'send', PARTICIPANT]);
    expect(document.exitCode).toBe(EXIT_USAGE);
    expect(document.error?.message).toContain('ekwo peppol validate <file>');
  });
});
