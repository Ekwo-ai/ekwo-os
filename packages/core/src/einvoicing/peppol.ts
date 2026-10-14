/**
 * Two questions about the Peppol network that need no books: what does this
 * file say, and is this participant registered?
 *
 * - `readPeppolFile()` reads a UBL 2.1 invoice or credit note as it arrived,
 *   with `@ekwo-ai/peppol-ubl`, and names every rule it breaks: the arithmetic
 *   of EN 16931 the reader re-adds, and the two electronic addresses (BT-34,
 *   BT-49) checked as participant identifiers, digit by digit where their
 *   scheme publishes a check. Nothing is matched to a supplier or booked.
 * - `lookupPeppolParticipant()` checks an identifier the same way, then asks
 *   the DNS of the Service Metadata Locator (SML) under which name it is
 *   published. A NAPTR record there is a registration, and its regular
 *   expression gives the address of the Service Metadata Publisher (SMP) that
 *   holds it. No record is no registration, in that zone.
 *
 * Neither reads or writes a database, and neither sends a document: the one
 * thing that leaves is a DNS query, for a name computed from the identifier.
 * Which SML is asked is the caller's choice; there is no default zone.
 */

import {
  readUbl,
  smlHostname,
  validateParticipantId,
  type ParticipantIdCheck,
  type ReceivedIdentifier,
  type ReceivedInvoice,
  type ReceivedViolation,
} from '@ekwo-ai/peppol-ubl';

export { InvoiceFileError, SML_ZONES, type ReceivedInvoice, type ReceivedViolation } from '@ekwo-ai/peppol-ubl';

/** A received file, read: the invoice as it says it, and every rule it breaks. */
export interface PeppolFileReading {
  invoice: ReceivedInvoice;
  violations: ReceivedViolation[];
}

/** The electronic address of a party, checked as the network checks a participant. */
function addressViolation(party: 'seller' | 'buyer', address: ReceivedIdentifier | null): ReceivedViolation | null {
  if (address === null || address.scheme === null) return null;
  const check = validateParticipantId(`${address.scheme}:${address.value}`);
  if (check.valid) return null;
  const term = party === 'seller' ? 'BT-34' : 'BT-49';
  return {
    code: 'invalid_electronic_address',
    message: `The electronic address of the ${party} (${term}), ${address.scheme}:${address.value}: ${check.problems.map((p) => p.message).join(' ')}`,
  };
}

/**
 * Reads a received UBL file. Throws an {@link InvoiceFileError} where there is
 * no invoice to return — not XML, not UBL, no number, no line — and returns
 * everything else, with what does not hold in `violations`.
 */
export function readPeppolFile(input: string | Uint8Array): PeppolFileReading {
  const { invoice, violations } = readUbl(input);
  const addresses = [addressViolation('seller', invoice.seller.electronicAddress), addressViolation('buyer', invoice.buyer.electronicAddress)];
  return { invoice, violations: [...violations, ...addresses.filter((v): v is ReceivedViolation => v !== null)] };
}

// --- the SML ---------------------------------------------------------------

/** One NAPTR record, as `node:dns` returns it. */
export interface NaptrRecord {
  flags: string;
  service: string;
  regexp: string;
  replacement: string;
  order: number;
  preference: number;
}

/** Resolves the NAPTR records of a name. Throws as `node:dns` does: `ENOTFOUND`, `ENODATA`. */
export type NaptrResolver = (hostname: string) => Promise<NaptrRecord[]>;

/** The answer of the SML for one identifier. */
export interface PeppolParticipantLookup {
  /** What was given, trimmed. */
  participant: string;
  /** The identifier, checked: scheme, value, the canonical form and what is wrong with it. */
  check: ParticipantIdCheck;
  /** The DNS zone of the SML that was asked. */
  zone: string;
  /** The name asked for, or null where the identifier was not one and nothing was asked. */
  hostname: string | null;
  /** True: published in this zone. False: not. Null: not asked. */
  registered: boolean | null;
  /** The address of the SMP the record names, where there is one. */
  smp: string | null;
}

/** DNS answers that mean "no such name" or "no record of that type", as opposed to a resolver that failed. */
const NOT_PUBLISHED = new Set(['ENOTFOUND', 'ENODATA', 'NXDOMAIN']);

/**
 * The SMP address a record of service `Meta:SMP` gives: its regular
 * expression is `!^.*$!<address>!`, any delimiter, and the replacement is the
 * address. Null where the record is not of that shape.
 */
export function smpOfNaptr(record: NaptrRecord): string | null {
  if (record.service.toLowerCase() !== 'meta:smp' || record.flags.toLowerCase() !== 'u') return null;
  const delimiter = record.regexp.charAt(0);
  if (delimiter === '') return null;
  const parts = record.regexp.split(delimiter);
  const address = parts.length >= 3 ? (parts[2] as string).trim() : '';
  return address === '' ? null : address;
}

const nodeResolver: NaptrResolver = async (hostname) => {
  const dns = await import('node:dns/promises');
  return dns.resolveNaptr(hostname);
};

/**
 * Checks a participant identifier and asks one SML whether it is registered.
 *
 * An identifier that is not one is answered without a query, with its
 * problems. A resolver that fails for another reason than an absent name —
 * a timeout, a refused query — throws: that is no answer, and saying "not
 * registered" would be making one up.
 */
export async function lookupPeppolParticipant(
  participant: string,
  options: { zone: string; resolveNaptr?: NaptrResolver | undefined },
): Promise<PeppolParticipantLookup> {
  const given = String(participant ?? '').trim();
  const check = validateParticipantId(given);
  const zone = options.zone.trim().replace(/^\.+|\.+$/g, '');
  if (zone === '') throw new TypeError('an SML zone is required');
  if (!check.valid) return { participant: given, check, zone, hostname: null, registered: null, smp: null };

  const hostname = smlHostname(given, zone, 'naptr');
  let records: NaptrRecord[];
  try {
    records = await (options.resolveNaptr ?? nodeResolver)(hostname);
  } catch (error) {
    const code = (error as { code?: unknown }).code;
    if (typeof code === 'string' && NOT_PUBLISHED.has(code)) {
      return { participant: given, check, zone, hostname, registered: false, smp: null };
    }
    throw error;
  }
  const smp = [...records]
    .sort((a, b) => a.order - b.order || a.preference - b.preference)
    .map(smpOfNaptr)
    .find((address): address is string => address !== null) ?? null;
  return { participant: given, check, zone, hostname, registered: smp !== null, smp };
}
