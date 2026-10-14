/**
 * `ekwo peppol validate | lookup` — two questions about the Peppol network
 * that need no installation, no account and no sign-in.
 *
 *   peppol validate <file>
 *       A UBL invoice or credit note as it arrived, read and checked: what it
 *       says, and every rule it breaks — the arithmetic of EN 16931 and the
 *       electronic addresses of both parties. Nothing is booked.
 *   peppol lookup <participant> [--test]
 *       The identifier checked, then the DNS of the Service Metadata Locator
 *       asked whether it is registered, and with which Service Metadata
 *       Publisher. The production network unless --test names the
 *       acceptance one.
 *
 * Each is one function of `@ekwo-ai/core`, `readPeppolFile()` and
 * `lookupPeppolParticipant()`. The exit code follows the contract: a file
 * that breaks a rule, an identifier that is not one or a participant that is
 * not registered is a check that found something — 1; a file that is not an
 * invoice at all is a wrong call — 2.
 */

import { readFile } from 'node:fs/promises';
import {
  InvoiceFileError,
  SML_ZONES,
  lookupPeppolParticipant,
  readPeppolFile,
  type NaptrResolver,
  type ReceivedViolation,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, type ParsedArgs } from '../args.js';
import { EXIT_ERROR, EXIT_OK, setResult } from '../output.js';
import { dim, heading, line, note, pairs, warn } from '../ui.js';

export interface PeppolDeps {
  /** The DNS, when a test stands in for it. */
  resolveNaptr?: NaptrResolver | undefined;
}

export const PEPPOL_USAGE = 'usage: ekwo peppol validate <file> | ekwo peppol lookup <participant> [--test]';

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

async function validate(args: ParsedArgs): Promise<number> {
  rejectUnknownFlags(args, []);
  const path = args.positional[1];
  if (path === undefined) throw new UsageError(`missing_argument: the file to validate was not given.\n${PEPPOL_USAGE}`);
  let bytes: Uint8Array;
  try {
    bytes = new Uint8Array(await readFile(path));
  } catch (error) {
    throw new UsageError(`unreadable_file: ${path}: ${(error as Error).message}`);
  }

  let reading: ReturnType<typeof readPeppolFile>;
  try {
    reading = readPeppolFile(bytes);
  } catch (error) {
    if (error instanceof InvoiceFileError) throw new UsageError(`${error.code}: ${path}: ${error.message}`);
    throw error;
  }
  const { invoice, violations } = reading;
  const party = (p: typeof invoice.seller) => ({
    name: p.name,
    vat_id: p.vatId,
    electronic_address: p.electronicAddress === null ? null : `${text(p.electronicAddress.scheme)}:${p.electronicAddress.value}`,
  });
  setResult({
    file: path,
    kind: invoice.kind,
    customization_id: invoice.customizationId,
    number: invoice.number,
    issue_date: invoice.issueDate,
    currency: invoice.currency,
    seller: party(invoice.seller),
    buyer: party(invoice.buyer),
    payable: invoice.totals.payable,
    line_count: invoice.lines.length,
    violations,
    valid: violations.length === 0,
  });

  heading(`${invoice.kind === 'credit_note' ? 'Credit note' : 'Invoice'} ${invoice.number}, ${path}`);
  pairs([
    ['seller', `${text(invoice.seller.name)}  ${dim(text(party(invoice.seller).electronic_address))}`],
    ['buyer', `${text(invoice.buyer.name)}  ${dim(text(party(invoice.buyer).electronic_address))}`],
    ['issued', invoice.issueDate],
    ['payable', `${invoice.totals.payable} ${invoice.currency}`],
    ['lines', String(invoice.lines.length)],
  ]);
  line();
  printViolations(violations);
  return violations.length === 0 ? EXIT_OK : EXIT_ERROR;
}

function printViolations(violations: ReceivedViolation[]): void {
  if (violations.length === 0) {
    note(dim('It breaks no rule this release re-reads: the arithmetic of EN 16931 and the electronic addresses.'));
    return;
  }
  warn(`It breaks ${violations.length} rule(s):`);
  for (const violation of violations) {
    line(`  ${violation.code}${violation.line === undefined ? '' : ` (line ${violation.line})`}: ${violation.message}`);
  }
}

async function lookup(args: ParsedArgs, deps: PeppolDeps): Promise<number> {
  rejectUnknownFlags(args, ['test']);
  const participant = args.positional[1];
  if (participant === undefined) throw new UsageError(`missing_argument: the participant identifier was not given.\n${PEPPOL_USAGE}`);
  const network = boolFlag(args, 'test') ? 'test' : 'production';

  const answer = await lookupPeppolParticipant(participant, { zone: SML_ZONES[network], resolveNaptr: deps.resolveNaptr });
  setResult({
    participant: answer.participant,
    identifier: answer.check.identifier,
    valid: answer.check.valid,
    problems: answer.check.problems,
    network,
    zone: answer.zone,
    hostname: answer.hostname,
    registered: answer.registered,
    smp: answer.smp,
  });

  if (!answer.check.valid) {
    heading(`Not a Peppol participant identifier: ${answer.participant}`);
    for (const problem of answer.check.problems) line(`  ${problem.code}: ${problem.message}`);
    line();
    note(dim('The SML was not asked.'));
    return EXIT_ERROR;
  }
  heading(answer.registered === true ? `Registered on the ${network} network` : `Not registered on the ${network} network`);
  pairs([
    ['participant', text(answer.check.identifier)],
    ['asked', dim(text(answer.hostname))],
    ...(answer.smp === null ? [] : [['SMP', answer.smp] as [string, string]]),
  ]);
  return answer.registered === true ? EXIT_OK : EXIT_ERROR;
}

export async function peppolCommand(args: ParsedArgs, deps: PeppolDeps = {}): Promise<number> {
  switch (args.positional[0]) {
    case 'validate':
      return validate(args);
    case 'lookup':
      return lookup(args, deps);
    default:
      throw new UsageError(PEPPOL_USAGE);
  }
}
