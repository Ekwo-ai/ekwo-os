/**
 * Where on the DNS a Peppol participant is looked up.
 *
 * A sender finds the access point of a receiver in two steps: the Service
 * Metadata Locator (SML) answers, on the DNS, which Service Metadata Publisher
 * (SMP) holds the participant's registration; the SMP says which documents it
 * takes and where. The first step is a DNS name computed from the identifier,
 * and that computation is all this file does. It sends nothing: the lookup is
 * a transport's, and needs a resolver this package does not have.
 *
 * Two rules, both from OpenPEPPOL's *Service Metadata Locator (SML)*
 * specification and the *Policy for use of Identifiers* (version 4):
 *
 * - **`cname`**, the original one: `B-` followed by the MD5 of the identifier
 *   value in lower case, written as 32 hexadecimal digits, then the identifier
 *   scheme and the zone of the SML —
 *   `B-<md5>.iso6523-actorid-upis.<zone>`, a name that holds a CNAME (or an A
 *   record) pointing at the SMP;
 * - **`naptr`**, the one the network moved to, from OASIS BDXL 1.0 as profiled
 *   by Peppol: the SHA-256 of the same lower-cased value, in base32 (RFC 4648,
 *   without the `=` padding), then the scheme and the zone —
 *   `<base32>.iso6523-actorid-upis.<zone>`, a name that holds a NAPTR record
 *   of service `Meta:SMP` whose regular expression gives the SMP's URL.
 *
 * In both, the value hashed is `scheme:value` of the participant — `0208:0999999922`
 * — lower-cased, without the `iso6523-actorid-upis::` in front of it, which
 * travels in clear as a label of its own. A DNS name is case-insensitive, so
 * the case of the base32 is not significant; RFC 4648 writes it in capitals,
 * and so does this function.
 *
 * MD5 and SHA-256 are written out below, from RFC 1321 and FIPS 180-4, so that
 * the package stays free of dependencies and of any one runtime's crypto
 * module; `test/participant.test.ts` holds both against Node's.
 */

import { PARTICIPANT_IDENTIFIER_SCHEME, ParticipantIdError, validateParticipantId } from './participant.js';

/**
 * The two DNS zones of the SML operated for OpenPEPPOL: production (SML) and
 * test (SMK). There is no default: which network a document goes to is the
 * caller's decision.
 */
export const SML_ZONES = Object.freeze({
  production: 'edelivery.tech.ec.europa.eu',
  test: 'acc.edelivery.tech.ec.europa.eu',
});

export type SmlLookup = 'cname' | 'naptr';

// --- MD5, RFC 1321 ---------------------------------------------------------

const MD5_SHIFTS = [7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21];
const MD5_TABLE = Array.from({ length: 64 }, (_, i) => Math.floor(Math.abs(Math.sin(i + 1)) * 2 ** 32) >>> 0);

export function md5(bytes: Uint8Array): Uint8Array {
  const length = bytes.length;
  const padded = new Uint8Array((((length + 8) >> 6) + 1) << 6);
  padded.set(bytes);
  padded[length] = 0x80;
  const view = new DataView(padded.buffer);
  view.setUint32(padded.length - 8, (length * 8) >>> 0, true);
  view.setUint32(padded.length - 4, Math.floor(length / 2 ** 29) >>> 0, true);

  let a0 = 0x67452301;
  let b0 = 0xefcdab89;
  let c0 = 0x98badcfe;
  let d0 = 0x10325476;
  const words = new Uint32Array(16);
  for (let block = 0; block < padded.length; block += 64) {
    for (let i = 0; i < 16; i += 1) words[i] = view.getUint32(block + i * 4, true);
    let a = a0;
    let b = b0;
    let c = c0;
    let d = d0;
    for (let i = 0; i < 64; i += 1) {
      let f: number;
      let g: number;
      if (i < 16) {
        f = (b & c) | (~b & d);
        g = i;
      } else if (i < 32) {
        f = (d & b) | (~d & c);
        g = (5 * i + 1) % 16;
      } else if (i < 48) {
        f = b ^ c ^ d;
        g = (3 * i + 5) % 16;
      } else {
        f = c ^ (b | ~d);
        g = (7 * i) % 16;
      }
      const shift = MD5_SHIFTS[(i >> 4) * 4 + (i % 4)] as number;
      const sum = (a + f + (MD5_TABLE[i] as number) + (words[g] as number)) >>> 0;
      a = d;
      d = c;
      c = b;
      b = (b + ((sum << shift) | (sum >>> (32 - shift)))) >>> 0;
    }
    a0 = (a0 + a) >>> 0;
    b0 = (b0 + b) >>> 0;
    c0 = (c0 + c) >>> 0;
    d0 = (d0 + d) >>> 0;
  }
  const out = new Uint8Array(16);
  const result = new DataView(out.buffer);
  [a0, b0, c0, d0].forEach((word, i) => result.setUint32(i * 4, word, true));
  return out;
}

// --- SHA-256, FIPS 180-4 ---------------------------------------------------

const SHA256_K = new Uint32Array([
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98,
  0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8,
  0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819,
  0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
  0xc67178f2,
]);

const rotr = (x: number, n: number): number => (x >>> n) | (x << (32 - n));

export function sha256(bytes: Uint8Array): Uint8Array {
  const length = bytes.length;
  const padded = new Uint8Array((((length + 8) >> 6) + 1) << 6);
  padded.set(bytes);
  padded[length] = 0x80;
  const view = new DataView(padded.buffer);
  view.setUint32(padded.length - 8, Math.floor(length / 2 ** 29) >>> 0, false);
  view.setUint32(padded.length - 4, (length * 8) >>> 0, false);

  const h = new Uint32Array([0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]);
  const w = new Uint32Array(64);
  for (let block = 0; block < padded.length; block += 64) {
    for (let i = 0; i < 16; i += 1) w[i] = view.getUint32(block + i * 4, false);
    for (let i = 16; i < 64; i += 1) {
      const x = w[i - 15] as number;
      const y = w[i - 2] as number;
      const s0 = rotr(x, 7) ^ rotr(x, 18) ^ (x >>> 3);
      const s1 = rotr(y, 17) ^ rotr(y, 19) ^ (y >>> 10);
      w[i] = ((w[i - 16] as number) + s0 + (w[i - 7] as number) + s1) >>> 0;
    }
    let [a, b, c, d, e, f, g, hh] = h as unknown as [number, number, number, number, number, number, number, number];
    for (let i = 0; i < 64; i += 1) {
      const t1 = (hh + (rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)) + ((e & f) ^ (~e & g)) + (SHA256_K[i] as number) + (w[i] as number)) >>> 0;
      const t2 = ((rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)) + ((a & b) ^ (a & c) ^ (b & c))) >>> 0;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) >>> 0;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) >>> 0;
    }
    [a, b, c, d, e, f, g, hh].forEach((value, i) => {
      h[i] = ((h[i] as number) + value) >>> 0;
    });
  }
  const out = new Uint8Array(32);
  const result = new DataView(out.buffer);
  h.forEach((word, i) => result.setUint32(i * 4, word, false));
  return out;
}

// --- encodings -------------------------------------------------------------

const hex = (bytes: Uint8Array): string => [...bytes].map((byte) => byte.toString(16).padStart(2, '0')).join('');

const BASE32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/** RFC 4648, section 6, without the padding. */
export function base32(bytes: Uint8Array): string {
  let out = '';
  let buffer = 0;
  let bits = 0;
  for (const byte of bytes) {
    buffer = ((buffer << 8) | byte) & 0xffff;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      out += BASE32[(buffer >> bits) & 31];
    }
  }
  if (bits > 0) out += BASE32[(buffer << (5 - bits)) & 31];
  return out;
}

/**
 * The DNS name an SML publishes a participant under.
 *
 * `participant` is anything {@link validateParticipantId} reads —
 * `0208:0999999922`, `iso6523-actorid-upis::0208:0999999922`, `BE:EN:0999999922`
 * — and is refused with a {@link ParticipantIdError}, which carries the
 * reasons, where it does not read it. A scheme
 * whose check digits are wrong is refused too: such an identifier is
 * registered nowhere, and a lookup would only say so later. `zone` is one of
 * {@link SML_ZONES}, or the zone of another SML; there is no default.
 */
export function smlHostname(participant: string, zone: string, lookup: SmlLookup): string {
  const check = validateParticipantId(participant);
  if (!check.valid || check.canonical === null) throw new ParticipantIdError(check.problems);
  const cleanZone = zone.trim().replace(/^\.+|\.+$/g, '');
  if (cleanZone === '') throw new TypeError('an SML zone is required: SML_ZONES.production or SML_ZONES.test');
  const bytes = new TextEncoder().encode(check.canonical);
  const label = lookup === 'cname' ? `B-${hex(md5(bytes))}` : base32(sha256(bytes));
  return `${label}.${PARTICIPANT_IDENTIFIER_SCHEME}.${cleanZone}`;
}
