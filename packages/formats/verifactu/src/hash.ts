/**
 * The fingerprint of a record: its `Huella`.
 *
 * From the AEAT's *Detalle de las especificaciones técnicas para generación
 * de la huella o hash de los registros de facturación*, version 0.1.2 of
 * 27 August 2024:
 *
 * - the fields, in this order — for a record *de alta*: `IDEmisorFactura`,
 *   `NumSerieFactura`, `FechaExpedicionFactura`, `TipoFactura`, `CuotaTotal`,
 *   `ImporteTotal`, the `Huella` of the record before, and
 *   `FechaHoraHusoGenRegistro`; for a record *de anulación*:
 *   `IDEmisorFacturaAnulada`, `NumSerieFacturaAnulada`,
 *   `FechaExpedicionFacturaAnulada`, the `Huella` before and
 *   `FechaHoraHusoGenRegistro` (section 3);
 * - each written `name=value`, joined by `&`, the value as the XML holds it
 *   with the spaces around it removed — `String.trim()` in the AEAT's own
 *   Java example, which removes every character up to U+0020 — and a field
 *   absent from the record written as its name and `=` alone: the first
 *   record of a system has `Huella=` (section 3);
 * - the text encoded as UTF-8, hashed with SHA-256 (list L12), written in
 *   hexadecimal, in capitals, 64 characters (section 5).
 *
 * The values are the model's, which is what the writer prints: the
 * fingerprint is always that of the record as written. Amounts are written
 * with two decimals in both; the AEAT treats `123.1` and `123.10` alike
 * (section 3), so either would do, and the same text in both is what keeps
 * the question from arising.
 *
 * SHA-256 is written out below, from FIPS 180-4, as `@ekwo-ai/peppol-ubl`
 * writes it, so that the package stays free of dependencies and of any one
 * runtime's crypto module; `test/hash.test.ts` holds it against Node's.
 */

import type { RecordModel } from './record.js';

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

/** Java's `String.trim()`: every character up to U+0020, at both ends. */
function javaTrim(value: string): string {
  let start = 0;
  let end = value.length;
  while (start < end && value.charCodeAt(start) <= 0x20) start += 1;
  while (end > start && value.charCodeAt(end - 1) <= 0x20) end -= 1;
  return value.slice(start, end);
}

function concatenate(fields: ReadonlyArray<readonly [string, string | null]>): string {
  return fields.map(([name, value]) => `${name}=${value === null ? '' : javaTrim(value)}`).join('&');
}

/** The text the fingerprint is computed on. */
export function fingerprintInput(model: RecordModel): string {
  const previous = model.chain.previous?.hash ?? null;
  if (model.kind === 'anulacion') {
    return concatenate([
      ['IDEmisorFacturaAnulada', model.issuer],
      ['NumSerieFacturaAnulada', model.number],
      ['FechaExpedicionFacturaAnulada', model.issued],
      ['Huella', previous],
      ['FechaHoraHusoGenRegistro', model.generatedAt],
    ]);
  }
  return concatenate([
    ['IDEmisorFactura', model.issuer],
    ['NumSerieFactura', model.number],
    ['FechaExpedicionFactura', model.issued],
    ['TipoFactura', model.invoiceType],
    ['CuotaTotal', model.totalTax],
    ['ImporteTotal', model.total],
    ['Huella', previous],
    ['FechaHoraHusoGenRegistro', model.generatedAt],
  ]);
}

/** SHA-256 of a text as UTF-8, in hexadecimal capitals: what `Huella` holds. */
export function fingerprint(text: string): string {
  return [...sha256(new TextEncoder().encode(text))]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('')
    .toUpperCase();
}
